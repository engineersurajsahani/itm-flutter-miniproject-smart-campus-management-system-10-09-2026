import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Course> courses = [];
  bool isLoading = false;
  String? errorMessage;

  void setToken(String token) {
    _apiService.setToken(token);
  }

  Future<void> fetchCourses() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _apiService.get('/courses');
      if (response != null && response is List) {
        courses = response.map((data) => Course.fromJson(data)).toList();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(dynamic nameOrCourse, [String? code, int? facultyId, String? department]) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      Map<String, dynamic> body;
      if (nameOrCourse is Course) {
        body = {
          'name': nameOrCourse.name,
          'code': nameOrCourse.code,
          'faculty_id': nameOrCourse.facultyId,
          'department': nameOrCourse.department,
        };
      } else {
        body = {
          'name': nameOrCourse.toString(),
          'code': code ?? '',
          'faculty_id': facultyId,
          'department': department,
        };
      }

      await _apiService.post('/courses', body);
      await fetchCourses();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(dynamic idOrCourse, [Map<String, dynamic>? data]) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      int id;
      Map<String, dynamic> updateData;

      if (idOrCourse is Course) {
        id = idOrCourse.id;
        updateData = {
          'name': idOrCourse.name,
          'code': idOrCourse.code,
          'faculty_id': idOrCourse.facultyId,
          'department': idOrCourse.department,
        };
      } else {
        id = idOrCourse as int;
        updateData = data ?? {};
      }

      await _apiService.put('/courses/$id', updateData);
      await fetchCourses();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _apiService.delete('/courses/$id');
      await fetchCourses();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
