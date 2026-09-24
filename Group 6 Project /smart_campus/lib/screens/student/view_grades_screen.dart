import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../models/academic_record.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class ViewGradesScreen extends StatefulWidget {
  const ViewGradesScreen({super.key});

  @override
  State<ViewGradesScreen> createState() => _ViewGradesScreenState();
}

class _ViewGradesScreenState extends State<ViewGradesScreen> {
  bool _isLoading = true;
  List<AcademicRecord> _grades = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/student/$userId'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _grades = data.map((json) => AcademicRecord.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load grades';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading grades: $e';
          _isLoading = false;
        });
      }
    }
  }

  Map<int, List<AcademicRecord>> _groupGradesByCourse(List<AcademicRecord> records) {
    final map = <int, List<AcademicRecord>>{};
    for (var record in records) {
      if (!map.containsKey(record.courseId)) {
        map[record.courseId] = [];
      }
      map[record.courseId]!.add(record);
    }
    return map;
  }

  double _getCourseAverage(List<AcademicRecord> records) {
    if (records.isEmpty) return 0.0;
    double totalPercentage = 0.0;
    for (var record in records) {
      totalPercentage += (record.marks / record.totalMarks) * 100;
    }
    return totalPercentage / records.length;
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF30D158); // Apple Green
    if (percentage >= 50) return const Color(0xFFFF9F0A); // Apple Amber
    return const Color(0xFFFF453A); // Apple Red
  }

  String _getGradeLabel(double percentage) {
    if (percentage >= 85) return 'High Distinction';
    if (percentage >= 70) return 'Distinction';
    if (percentage >= 50) return 'Pass';
    return 'Action Needed';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Academic Grades',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF453A), fontSize: 15),
                  ),
                )
              : _grades.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.military_tech_rounded,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No grades published yet',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFBF5AF2),
                      onRefresh: _fetchGrades,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        itemCount: _groupGradesByCourse(_grades).length,
                        itemBuilder: (context, index) {
                          final groupedGrades = _groupGradesByCourse(_grades);
                          final courseId = groupedGrades.keys.elementAt(index);
                          final records = groupedGrades[courseId]!;
                          final average = _getCourseAverage(records);
                          final courseTitle = records.first.courseName ?? 'Course #$courseId';
                          final gradeColor = _getGradeColor(average);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              courseTitle,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.3,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getGradeLabel(average),
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: gradeColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: gradeColor.withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${average.toStringAsFixed(1)}%',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: gradeColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(
                                    height: 1,
                                    color: isDark ? Colors.white12 : Colors.black12,
                                  ),
                                  const SizedBox(height: 12),
                                  ...records.map((record) {
                                    final percentage = (record.marks / record.totalMarks) * 100;
                                    final itemColor = _getGradeColor(percentage);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: itemColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.assignment_turned_in_rounded, size: 16, color: itemColor),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              record.examType,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${record.marks} / ${record.totalMarks}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: isDark ? Colors.white54 : Colors.black45,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Container(
                                            width: 58,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '${percentage.toStringAsFixed(0)}%',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: itemColor,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
