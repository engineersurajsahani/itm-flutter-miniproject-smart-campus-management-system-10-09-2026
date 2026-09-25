import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Set this to your computer's local Wi-Fi IP (e.g. '10.136.147.133:3000') or deployed URL.
  /// Leave empty ('') to automatically use localhost on Web/Desktop/iOS Sim or 10.0.2.2 on Android Emulator.
  static const String serverHost = '';

  static String get baseUrl {
    if (serverHost.isNotEmpty) {
      final prefix = serverHost.startsWith('http://') || serverHost.startsWith('https://')
          ? serverHost
          : 'http://$serverHost';
      return '$prefix/api';
    }
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String users = '/users';
  static const String courses = '/courses';
  static const String attendance = '/attendance';
  static const String grades = '/grades';
  static const String notices = '/notices';
  static const String dashboardStats = '/dashboard/stats';
}
