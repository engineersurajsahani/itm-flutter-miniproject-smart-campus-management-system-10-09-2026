import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_courses_screen.dart';
import '../screens/admin/manage_faculty_screen.dart';
import '../screens/admin/manage_students_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/faculty/faculty_dashboard.dart';
import '../screens/faculty/mark_attendance_screen.dart';
import '../screens/faculty/post_notice_screen.dart';
import '../screens/faculty/upload_grades_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/view_attendance_screen.dart';
import '../screens/student/view_grades_screen.dart';
import '../screens/student/view_notices_screen.dart';

class CustomDrawer extends StatelessWidget {
  final dynamic currentUser;
  final VoidCallback? onLogout;

  const CustomDrawer({
    super.key,
    this.currentUser,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = currentUser ?? authProvider.currentUser;
    final role = (user?.role ?? 'student').toString().toLowerCase();
    final name = user?.name ?? 'User';
    final email = user?.email ?? 'user@example.com';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleColor = AppTheme.getRoleColor(role);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF141416) : const Color(0xFFF9F9FB),
      child: SafeArea(
        child: Column(
          children: [
            // Standard Profile Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: roleColor.withValues(alpha: 0.15),
                          radius: 26,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: roleColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: roleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (role == 'admin') ...[
                    _DrawerTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      onTap: () => _navigate(context, const AdminDashboard()),
                    ),
                    _DrawerTile(
                      icon: Icons.people_alt_rounded,
                      title: 'Manage Students',
                      onTap: () => _navigate(context, const ManageStudentsScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.badge_rounded,
                      title: 'Manage Faculty',
                      onTap: () => _navigate(context, const ManageFacultyScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.auto_stories_rounded,
                      title: 'Manage Courses',
                      onTap: () => _navigate(context, const ManageCoursesScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.campaign_rounded,
                      title: 'Notices',
                      onTap: () => _navigate(context, const ViewNoticesScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Register User',
                      onTap: () => _navigate(context, const RegisterScreen()),
                    ),
                  ],

                  if (role == 'faculty') ...[
                    _DrawerTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      onTap: () => _navigate(context, const FacultyDashboard()),
                    ),
                    _DrawerTile(
                      icon: Icons.fact_check_rounded,
                      title: 'Mark Attendance',
                      onTap: () => _navigate(context, const MarkAttendanceScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Upload Grades',
                      onTap: () => _navigate(context, const UploadGradesScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.rate_review_rounded,
                      title: 'Post Notice',
                      onTap: () => _navigate(context, const PostNoticeScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.campaign_rounded,
                      title: 'Notices',
                      onTap: () => _navigate(context, const ViewNoticesScreen()),
                    ),
                  ],

                  if (role == 'student') ...[
                    _DrawerTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      onTap: () => _navigate(context, const StudentDashboard()),
                    ),
                    _DrawerTile(
                      icon: Icons.event_available_rounded,
                      title: 'My Attendance',
                      onTap: () => _navigate(context, const ViewAttendanceScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.military_tech_rounded,
                      title: 'My Grades',
                      onTap: () => _navigate(context, const ViewGradesScreen()),
                    ),
                    _DrawerTile(
                      icon: Icons.campaign_rounded,
                      title: 'Notices',
                      onTap: () => _navigate(context, const ViewNoticesScreen()),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom controls: Dark Mode switch & Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFEDEDF2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          authProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 20,
                          color: isDark ? Colors.amber : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dark Mode',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: authProvider.isDarkMode,
                      onChanged: (value) {
                        authProvider.toggleDarkMode();
                      },
                      activeTrackColor: const Color(0xFF30D158),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InkWell(
                onTap: () async {
                  if (onLogout != null) {
                    onLogout!();
                  } else {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.power_settings_new_rounded, color: Color(0xFFFF453A), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFF453A),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
