import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _lastLoginKey = 'last_login_at';

  AuthService(this._apiService);

  Future<User> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConfig.login,
      {
        'email': email,
        'password': password,
      },
    );

    final token = response['token'];
    final userJson = response['user'];
    
    // Add token to user JSON so it's parsed into the User model
    if (token != null) {
      userJson['token'] = token;
    }
    
    final user = User.fromJson(userJson);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userJson));
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    
    _apiService.setToken(token);
    
    return user;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? department,
  }) async {
    final response = await _apiService.post(
      ApiConfig.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'department': ?department,
      },
    );

    final user = User.fromJson(response['user'] ?? response);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _apiService.setToken(null);
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        final userJson = jsonDecode(userStr);
        final user = User.fromJson(userJson);
        final token = await getToken();
        _apiService.setToken(token);
        return user;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<DateTime?> getLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastLoginKey);
    return value == null ? null : DateTime.tryParse(value);
  }
}
