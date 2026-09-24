import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  Course? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
  bool _isLoadingStudents = false;
  List<User> _students = [];
  Map<int, String> _attendanceMap = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    });
  }

  Future<void> _fetchStudents() async {
    if (_selectedCourse == null) return;

    setState(() {
      _isLoadingStudents = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users?role=student'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _students = data.map((json) => User.fromJson(json)).toList();
          _attendanceMap = {
            for (var student in _students) student.id: 'present'
          };
        });
      } else {
        _showError('Failed to fetch students.');
      }
    } catch (e) {
      _showError('Error fetching students: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF453A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submitAttendance() async {
    if (_selectedCourse == null || _students.isEmpty) {
      _showError('Please select a course and load student roster.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

      final records = _attendanceMap.entries.map((e) => {
        'student_id': e.key,
        'studentId': e.key,
        'status': e.value,
      }).toList();

      await attendanceProvider.markAttendance(
        courseId: _selectedCourse!.id,
        date: _selectedDate,
        records: records,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Attendance saved successfully'),
            backgroundColor: const Color(0xFF30D158),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to mark attendance: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Controls (Course & Date Selector)
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                children: [
                  Consumer<CourseProvider>(
                    builder: (context, courseProvider, child) {
                      if (courseProvider.isLoading) {
                        return const LoadingIndicator();
                      }

                      return DropdownButtonFormField<Course>(
                        decoration: InputDecoration(
                          labelText: 'Select Course',
                          prefixIcon: const Icon(Icons.auto_stories_rounded, size: 20),
                          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14),
                        ),
                        initialValue: _selectedCourse,
                        items: courseProvider.courses.map((course) {
                          return DropdownMenuItem(
                            value: course,
                            child: Text(
                              course.name,
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: (Course? value) {
                          setState(() {
                            _selectedCourse = value;
                            _fetchStudents();
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Change',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF30D158),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Student Roster List
            Expanded(
              child: _isLoadingStudents
                  ? const Center(child: LoadingIndicator())
                  : _students.isEmpty
                      ? Center(
                          child: Text(
                            'Please select a course to load the student roster',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final currentStatus = _attendanceMap[student.id] ?? 'present';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 18,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(0xFF30D158).withValues(alpha: 0.18),
                                          child: Text(
                                            student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF30D158),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.name,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              Text(
                                                student.email,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  color: isDark ? Colors.white54 : Colors.black45,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Apple style segmented selection
                                    Row(
                                      children: ['present', 'late', 'absent'].map((status) {
                                        final isSelected = currentStatus == status;
                                        Color statusColor;
                                        if (status == 'present') {
                                          statusColor = const Color(0xFF30D158);
                                        } else if (status == 'late') {
                                          statusColor = const Color(0xFFFF9F0A);
                                        } else {
                                          statusColor = const Color(0xFFFF453A);
                                        }

                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _attendanceMap[student.id] = status;
                                                });
                                              },
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? statusColor
                                                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? statusColor
                                                        : (isDark ? Colors.white12 : Colors.black12),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    status.toUpperCase(),
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w800,
                                                      letterSpacing: 0.6,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : (isDark ? Colors.white70 : Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 12),

            // Submit Button
            _isSubmitting
                ? const Center(child: LoadingIndicator())
                : Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.facultyGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF30D158).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _students.isEmpty ? null : _submitAttendance,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Text(
                            'Save Attendance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
