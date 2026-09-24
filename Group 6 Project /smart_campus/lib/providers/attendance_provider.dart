import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalDbService _localDbService = LocalDbService();

  List<Attendance> attendanceList = [];
  List<Attendance> get attendanceRecords => attendanceList;

  bool isLoading = false;
  String? errorMessage;

  void setToken(String token) {
    _apiService.setToken(token);
  }

  Future<void> fetchStudentAttendance(int studentId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _apiService.get('/attendance/student/$studentId');
      if (response != null && response is List) {
        attendanceList = response.map((data) => Attendance.fromJson(data)).toList();
        await _localDbService.cacheAttendance(attendanceList);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      // Fallback to cache if network fails
      attendanceList = await _localDbService.getCachedAttendance();
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourseAttendance(int courseId, {String? date}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      String url = '/attendance/course/$courseId';
      if (date != null) {
        url += '?date=$date';
      }

      final response = await _apiService.get(url);
      if (response != null && response is List) {
        attendanceList = response.map((data) => Attendance.fromJson(data)).toList();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAttendance({
    required int courseId,
    required dynamic date,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final dateStr = date is DateTime
          ? '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : date.toString();

      await _apiService.post('/attendance', {
        'course_id': courseId,
        'date': dateStr,
        'records': records,
      });

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadCachedAttendance() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      attendanceList = await _localDbService.getCachedAttendance();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
