import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<User> students = [];
  bool isLoading = false;
  String? errorMessage;

  void setToken(String token) {
    _apiService.setToken(token);
  }

  Future<void> fetchStudents() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _apiService.get('/users?role=student');
      if (response != null && response is List) {
        students = response.map((data) => User.fromJson(data)).toList();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _apiService.delete('/users/$id');
      await fetchStudents();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(dynamic idOrUser, [Map<String, dynamic>? data]) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final int id = idOrUser is User ? idOrUser.id : (idOrUser as int);
      final updateData = data ?? (idOrUser is User ? idOrUser.toJson() : <String, dynamic>{});

      await _apiService.put('/users/$id', updateData);
      await fetchStudents();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
