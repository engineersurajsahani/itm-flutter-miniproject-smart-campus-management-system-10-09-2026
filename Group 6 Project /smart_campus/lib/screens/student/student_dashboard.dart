import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/recent_access_card.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import 'view_attendance_screen.dart';
import 'view_grades_screen.dart';
import 'view_notices_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'my_courses': 0,
    'attendance_percent': 0.0,
    'average_grade': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _stats = {
              'my_courses': data['my_courses'] ?? 0,
              'attendance_percent': (data['attendance_percent'] ?? 0.0).toDouble(),
              'average_grade': (data['average_grade'] ?? 0.0).toDouble(),
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? 'Student';
    final attendance = (_stats['attendance_percent'] as num).toDouble();
    final avgGrade = (_stats['average_grade'] as num).toDouble();
    final coursesCount = _stats['my_courses'] ?? 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : Stack(
              children: [


                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // Apple iOS style Large Title SliverAppBar
                    SliverAppBar(
                      expandedHeight: 110,
                      floating: false,
                      pinned: true,
                      backgroundColor: isDark
                          ? const Color(0xFF000000).withValues(alpha: 0.8)
                          : const Color(0xFFF2F2F7).withValues(alpha: 0.8),
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
                        title: Text(
                          'Dashboard',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      leading: Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFFF9500).withValues(alpha: 0.2),
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF9500),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: RefreshIndicator(
                        color: const Color(0xFFFF9500),
                        onRefresh: _fetchStats,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Label
                              Text(
                                'ACTIVE PASSES',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 12),

                              RecentAccessCard(
                                lastLoginAt: authProvider.lastLoginAt,
                                role: 'student',
                              ),

                              const SizedBox(height: 24),

                              // Pass 1: Attendance & Campus ID Pass (Apple Wallet format)
                              WalletCard(
                                title: 'Attendance & Enrollment Pass',
                                badgeText: 'SMART CAMPUS ID',
                                subtitle: '$coursesCount Enrolled',
                                gradient: AppTheme.studentGradient,
                                glowColor: const Color(0xFFFF9500).withValues(alpha: 0.4),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ViewAttendanceScreen()),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${attendance.toStringAsFixed(1)}%',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1.0,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          attendance >= 75
                                              ? '● Good Standing'
                                              : (attendance >= 60 ? '▲ Attention Required' : '▼ Critical Attendance'),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.fact_check_rounded,
                                        color: isDark ? Colors.white : Colors.black,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Pass 2: Academic Standing & GPA Pass
                              WalletCard(
                                title: 'Academic Performance Pass',
                                badgeText: 'GRADE SUMMARY',
                                subtitle: avgGrade >= 75 ? 'Distinction' : (avgGrade >= 50 ? 'Standard' : 'Review'),
                                gradient: AppTheme.purplePassGradient,
                                glowColor: const Color(0xFFBF5AF2).withValues(alpha: 0.35),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ViewGradesScreen()),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${avgGrade.toStringAsFixed(1)}%',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1.0,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Average Assessment Score',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.military_tech_rounded,
                                        color: isDark ? Colors.white : Colors.black,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Apple Music style "Quick Hits / Shortcuts"
                              Text(
                                'QUICK ACTIONS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionTile(
                                      context: context,
                                      title: 'Attendance',
                                      subtitle: 'Logs & Details',
                                      icon: Icons.calendar_month_rounded,
                                      color: const Color(0xFFFF9500),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ViewAttendanceScreen()),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionTile(
                                      context: context,
                                      title: 'My Grades',
                                      subtitle: 'Exams & Tasks',
                                      icon: Icons.assessment_rounded,
                                      color: const Color(0xFFBF5AF2),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ViewGradesScreen()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _buildActionTile(
                                context: context,
                                title: 'Campus Notices',
                                subtitle: 'Announcements, events & deadlines',
                                icon: Icons.campaign_rounded,
                                color: const Color(0xFF0A84FF),
                                isFullWidth: true,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ViewNoticesScreen()),
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderRadius: 20,
      onTap: onTap,
      child: isFullWidth
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }
}
