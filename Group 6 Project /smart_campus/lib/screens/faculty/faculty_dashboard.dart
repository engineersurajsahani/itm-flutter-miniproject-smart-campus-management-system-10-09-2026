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
import 'mark_attendance_screen.dart';
import 'upload_grades_screen.dart';
import 'post_notice_screen.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'my_courses': 0,
    'total_students': 0,
    'recent_notices': 0,
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
              'my_courses': data['my_courses'] ?? data['courses_count'] ?? 0,
              'total_students': data['total_students'] ?? 0,
              'recent_notices': data['recent_notices'] ?? 0,
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
    final userName = authProvider.currentUser?.name ?? 'Faculty';
    final coursesCount = _stats['my_courses'] ?? 0;
    final studentsCount = _stats['total_students'] ?? 0;
    final noticesCount = _stats['recent_notices'] ?? 0;

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
                            backgroundColor: const Color(0xFF30D158).withValues(alpha: 0.2),
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'F',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF30D158),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: RefreshIndicator(
                        color: const Color(0xFF30D158),
                        onRefresh: _fetchStats,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TEACHING PASS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Faculty Active Teaching Pass (Apple Wallet format)
                              WalletCard(
                                title: 'Active Teaching & Course Pass',
                                badgeText: 'FACULTY CREDENTIAL',
                                subtitle: '$studentsCount Enrolled Students',
                                gradient: AppTheme.facultyGradient,
                                glowColor: const Color(0xFF30D158).withValues(alpha: 0.35),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MarkAttendanceScreen()),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$coursesCount Assigned',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.8,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '● Current Academic Semester',
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
                                        Icons.badge_rounded,
                                        color: isDark ? Colors.white : Colors.black,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              RecentAccessCard(
                                lastLoginAt: authProvider.lastLoginAt,
                                role: 'faculty',
                              ),

                              const SizedBox(height: 24),

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
                                      title: 'Mark Attendance',
                                      subtitle: 'Record class roll',
                                      icon: Icons.how_to_reg_rounded,
                                      color: const Color(0xFF30D158),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const MarkAttendanceScreen()),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionTile(
                                      context: context,
                                      title: 'Upload Grades',
                                      subtitle: 'Submit test scores',
                                      icon: Icons.workspace_premium_rounded,
                                      color: const Color(0xFF00C7BE),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const UploadGradesScreen()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _buildActionTile(
                                context: context,
                                title: 'Publish Notice',
                                subtitle: 'Broadcast announcement to students ($noticesCount live)',
                                icon: Icons.campaign_rounded,
                                color: const Color(0xFF0A84FF),
                                isFullWidth: true,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PostNoticeScreen()),
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
