import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  late final AuthService _authService;

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;
  bool isDarkMode = false;
  DateTime? lastLoginAt;

  String? get token => currentUser?.token ?? _apiService.token;
  bool get isAuthenticated => currentUser != null;

  AuthProvider() {
    _authService = AuthService(_apiService);
  }

  ApiService get apiService => _apiService;

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await _authService.login(email, password);
      lastLoginAt = await _authService.getLastLogin();

      isLoading = false;
      notifyListeners();
      return currentUser != null;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? department,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        department: department,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.logout();
      currentUser = null;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading = true;
      notifyListeners();

      currentUser = await _authService.getStoredUser();
      lastLoginAt = await _authService.getLastLogin();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
