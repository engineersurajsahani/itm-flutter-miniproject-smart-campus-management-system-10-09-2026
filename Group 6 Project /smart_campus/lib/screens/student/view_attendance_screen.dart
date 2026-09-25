import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/attendance.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendance();
    });
  }

  Future<void> _fetchAttendance() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      Provider.of<AttendanceProvider>(context, listen: false).fetchStudentAttendance(userId);
    }
  }

  Map<int, List<Attendance>> _groupAttendanceByCourse(List<Attendance> records) {
    final map = <int, List<Attendance>>{};
    for (var record in records) {
      if (!map.containsKey(record.courseId)) {
        map[record.courseId] = [];
      }
      map[record.courseId]!.add(record);
    }
    return map;
  }

  double _calculatePercentage(List<Attendance> records) {
    if (records.isEmpty) return 0.0;
    final presentOrLate = records.where((r) => r.status == 'present' || r.status == 'late').length;
    return (presentOrLate / records.length) * 100;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF30D158); // Apple Green
      case 'absent':
        return const Color(0xFFFF453A); // Apple Red
      case 'late':
        return const Color(0xFFFF9F0A); // Apple Amber
      default:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'My Attendance',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.attendanceRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No attendance records found',
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

          final groupedRecords = _groupAttendanceByCourse(provider.attendanceRecords);

          return RefreshIndicator(
            color: const Color(0xFFFF9500),
            onRefresh: _fetchAttendance,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              itemCount: groupedRecords.length,
              itemBuilder: (context, index) {
                final courseId = groupedRecords.keys.elementAt(index);
                final records = groupedRecords[courseId]!;
                records.sort((a, b) => b.date.compareTo(a.date));
                final percentage = _calculatePercentage(records);
                final courseDisplayName = records.first.courseName ?? 'Course #$courseId';
                final statusColor = percentage >= 75
                    ? const Color(0xFF30D158)
                    : (percentage >= 60 ? const Color(0xFFFF9F0A) : const Color(0xFFFF453A));

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 22,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        iconColor: statusColor,
                        collapsedIconColor: isDark ? Colors.white38 : Colors.black38,
                        title: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${percentage.toInt()}%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseDisplayName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      letterSpacing: -0.3,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${records.length} Classes Logged',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white54 : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (percentage / 100).clamp(0.0, 1.0),
                              backgroundColor: isDark ? Colors.white12 : Colors.black12,
                              color: statusColor,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        children: [
                          const SizedBox(height: 14),
                          Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: records.length,
                            itemBuilder: (context, idx) {
                              final record = records[idx];
                              final formattedDate = DateFormat('EEE, MMM dd, yyyy').format(
                                DateTime.tryParse(record.date) ?? DateTime.now(),
                              );
                              final itemColor = _getStatusColor(record.status);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: itemColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        formattedDate,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: itemColor.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        record.status.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: itemColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
