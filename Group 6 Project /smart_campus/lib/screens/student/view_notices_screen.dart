import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notice_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class ViewNoticesScreen extends StatefulWidget {
  const ViewNoticesScreen({super.key});

  @override
  State<ViewNoticesScreen> createState() => _ViewNoticesScreenState();
}

class _ViewNoticesScreenState extends State<ViewNoticesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoticeProvider>(context, listen: false).fetchNotices();
    });
  }

  Future<void> _refreshNotices() async {
    await Provider.of<NoticeProvider>(context, listen: false).fetchNotices();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Campus Notices',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Consumer<NoticeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notices.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.notices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notices broadcasted yet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedNotices = List.of(provider.notices)
            ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

          return RefreshIndicator(
            color: const Color(0xFF0A84FF),
            onRefresh: _refreshNotices,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              itemCount: sortedNotices.length,
              itemBuilder: (context, index) {
                final notice = sortedNotices[index];
                final formattedDate = DateFormat('MMM dd, yyyy').format(notice.createdDateTime);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 22,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        iconColor: const Color(0xFF0A84FF),
                        collapsedIconColor: isDark ? Colors.white38 : Colors.black38,
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A84FF).withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.campaign_rounded, color: Color(0xFF0A84FF), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notice.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      letterSpacing: -0.3,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          notice.author,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0A84FF),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        children: [
                          const SizedBox(height: 16),
                          Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              notice.content,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                height: 1.6,
                                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
