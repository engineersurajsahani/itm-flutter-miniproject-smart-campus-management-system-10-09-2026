import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/app_theme.dart';
import 'widgets/app_logo.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/faculty_provider.dart';
import 'providers/course_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/notice_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/manage_courses_screen.dart';
import 'screens/admin/manage_faculty_screen.dart';
import 'screens/admin/manage_students_screen.dart';
import 'screens/faculty/faculty_dashboard.dart';
import 'screens/faculty/mark_attendance_screen.dart';
import 'screens/faculty/post_notice_screen.dart';
import 'screens/faculty/upload_grades_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/view_attendance_screen.dart';
import 'screens/student/view_grades_screen.dart';
import 'screens/student/view_notices_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => FacultyProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
      ],
      child: const SmartCampusApp(),
    ),
  );
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'Smart Campus',
          theme: AppTheme.getTheme(false),
          darkTheme: AppTheme.getTheme(true),
          themeMode: authProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const SplashWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/admin_dashboard': (context) => const AdminDashboard(),
            '/faculty_dashboard': (context) => const FacultyDashboard(),
            '/student_dashboard': (context) => const StudentDashboard(),
            '/manage_students': (context) => const ManageStudentsScreen(),
            '/manage_faculty': (context) => const ManageFacultyScreen(),
            '/manage_courses': (context) => const ManageCoursesScreen(),
            '/post_notice': (context) => const PostNoticeScreen(),
            '/view_notices': (context) => const ViewNoticesScreen(),
            '/mark_attendance': (context) => const MarkAttendanceScreen(),
            '/upload_grades': (context) => const UploadGradesScreen(),
            '/view_attendance': (context) => const ViewAttendanceScreen(),
            '/view_grades': (context) => const ViewGradesScreen(),
          },
        );
      },
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Stack(
          children: [
            // Apple Ambient Glow
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0A84FF).withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5E5CE6).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(
                    size: 92,
                    showGlow: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Smart Campus',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Campus Management System',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A84FF)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final role = authProvider.currentUser!.role.toString().toLowerCase();
      if (role == 'admin') {
        return const AdminDashboard();
      } else if (role == 'faculty') {
        return const FacultyDashboard();
      } else {
        return const StudentDashboard();
      }
    }

    return const LoginScreen();
  }
}
