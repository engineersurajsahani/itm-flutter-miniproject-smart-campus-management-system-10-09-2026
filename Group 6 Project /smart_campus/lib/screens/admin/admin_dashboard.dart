import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/recent_access_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'students': 0,
    'faculty': 0,
    'courses': 0,
    'notices': 0,
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
              'students': data['students'] ?? data['total_students'] ?? 0,
              'faculty': data['faculty'] ?? data['total_faculty'] ?? 0,
              'courses': data['courses'] ?? data['total_courses'] ?? 0,
              'notices': data['notices'] ?? data['total_notices'] ?? 0,
            };
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? 'Administrator';

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
                            backgroundColor: const Color(0xFF0A84FF).withValues(alpha: 0.2),
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A84FF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: RefreshIndicator(
                        color: const Color(0xFF0A84FF),
                        onRefresh: _fetchStats,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SYSTEM CREDENTIAL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Admin Master Pass (Apple Wallet format)
                              WalletCard(
                                title: 'Campus System Keycard',
                                badgeText: 'ROOT ADMINISTRATOR',
                                subtitle: 'Full Permissions',
                                gradient: AppTheme.adminGradient,
                                glowColor: const Color(0xFF0A84FF).withValues(alpha: 0.35),
                                onTap: () => Navigator.pushNamed(context, '/manage_students'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Campus Hub',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.6,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '● All Services Operational',
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
                                      child: const Icon(
                                        Icons.admin_panel_settings_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              RecentAccessCard(
                                lastLoginAt: authProvider.lastLoginAt,
                                role: 'admin',
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'CAMPUS TELEMETRY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 12),

                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.05,
                                children: [
                                  StatCard(
                                    title: 'Students',
                                    value: _stats['students'].toString(),
                                    subtitle: 'Enrolled',
                                    icon: Icons.school_rounded,
                                    color: const Color(0xFFFF9500),
                                    onTap: () => Navigator.pushNamed(context, '/manage_students'),
                                  ),
                                  StatCard(
                                    title: 'Faculty',
                                    value: _stats['faculty'].toString(),
                                    subtitle: 'Active Staff',
                                    icon: Icons.person_rounded,
                                    color: const Color(0xFF30D158),
                                    onTap: () => Navigator.pushNamed(context, '/manage_faculty'),
                                  ),
                                  StatCard(
                                    title: 'Courses',
                                    value: _stats['courses'].toString(),
                                    subtitle: 'Curriculum',
                                    icon: Icons.menu_book_rounded,
                                    color: const Color(0xFF0A84FF),
                                    onTap: () => Navigator.pushNamed(context, '/manage_courses'),
                                  ),
                                  StatCard(
                                    title: 'Notices',
                                    value: _stats['notices'].toString(),
                                    subtitle: 'Broadcasts',
                                    icon: Icons.campaign_rounded,
                                    color: const Color(0xFFBF5AF2),
                                    onTap: () => Navigator.pushNamed(context, '/view_notices'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'MANAGEMENT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Apple-style grouped actions container
                              GlassContainer(
                                padding: EdgeInsets.zero,
                                borderRadius: 22,
                                child: Column(
                                  children: [
                                    _buildGroupedTile(
                                      context: context,
                                      title: 'Manage Students',
                                      icon: Icons.people_alt_rounded,
                                      color: const Color(0xFFFF9500),
                                      route: '/manage_students',
                                      showDivider: true,
                                    ),
                                    _buildGroupedTile(
                                      context: context,
                                      title: 'Manage Faculty',
                                      icon: Icons.badge_rounded,
                                      color: const Color(0xFF30D158),
                                      route: '/manage_faculty',
                                      showDivider: true,
                                    ),
                                    _buildGroupedTile(
                                      context: context,
                                      title: 'Manage Courses',
                                      icon: Icons.auto_stories_rounded,
                                      color: const Color(0xFF0A84FF),
                                      route: '/manage_courses',
                                      showDivider: true,
                                    ),
                                    _buildGroupedTile(
                                      context: context,
                                      title: 'Broadcast Notice',
                                      icon: Icons.campaign_rounded,
                                      color: const Color(0xFFBF5AF2),
                                      route: '/post_notice',
                                      showDivider: false,
                                    ),
                                  ],
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

  Widget _buildGroupedTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required bool showDivider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}
