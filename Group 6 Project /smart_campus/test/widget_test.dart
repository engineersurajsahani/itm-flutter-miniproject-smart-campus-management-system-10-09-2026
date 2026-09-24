import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/main.dart';
import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/providers/student_provider.dart';
import 'package:smart_campus/providers/faculty_provider.dart';
import 'package:smart_campus/providers/course_provider.dart';
import 'package:smart_campus/providers/attendance_provider.dart';
import 'package:smart_campus/providers/notice_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    // Initial render displays Smart Campus title
    expect(find.text('Smart Campus'), findsWidgets);
  });
}
