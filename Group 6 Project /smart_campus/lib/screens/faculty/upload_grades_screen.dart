import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class UploadGradesScreen extends StatefulWidget {
  const UploadGradesScreen({super.key});

  @override
  State<UploadGradesScreen> createState() => _UploadGradesScreenState();
}

class _UploadGradesScreenState extends State<UploadGradesScreen> {
  final _formKey = GlobalKey<FormState>();

  Course? _selectedCourse;
  User? _selectedStudent;
  String? _selectedExamType;

  final _marksController = TextEditingController();
  final _totalMarksController = TextEditingController();

  bool _isLoadingStudents = false;
  bool _isSubmitting = false;
  List<User> _students = [];

  final List<String> _examTypes = ['Midterm', 'Final', 'Assignment'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    });
  }

  @override
  void dispose() {
    _marksController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoadingStudents = true;
      _selectedStudent = null;
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
        });
      } else {
        _showError('Failed to load students.');
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF30D158),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submitGrades() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final double marks = double.parse(_marksController.text);
      final double totalMarks = double.parse(_totalMarksController.text);

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/grades'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'courseId': _selectedCourse!.id,
          'course_id': _selectedCourse!.id,
          'studentId': _selectedStudent!.id,
          'student_id': _selectedStudent!.id,
          'examType': _selectedExamType,
          'exam_type': _selectedExamType,
          'marks': marks,
          'totalMarks': totalMarks,
          'total_marks': totalMarks,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccess('Grades uploaded successfully');
        _resetForm();
      } else {
        _showError('Failed to upload grades.');
      }
    } catch (e) {
      _showError('Error uploading grades: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCourse = null;
      _selectedStudent = null;
      _selectedExamType = null;
      _students.clear();
      _marksController.clear();
      _totalMarksController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Upload Assessment',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSESSMENT DETAILS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<CourseProvider>(
                      builder: (context, courseProvider, child) {
                        if (courseProvider.isLoading) {
                          return const LoadingIndicator();
                        }
                        return DropdownButtonFormField<Course>(
                          decoration: InputDecoration(
                            labelText: 'Course',
                            prefixIcon: const Icon(Icons.auto_stories_rounded, size: 20),
                          ),
                          initialValue: _selectedCourse,
                          validator: (value) => value == null ? 'Please select a course' : null,
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
                    const SizedBox(height: 16),
                    if (_isLoadingStudents)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: LoadingIndicator()),
                      )
                    else
                      DropdownButtonFormField<User>(
                        decoration: InputDecoration(
                          labelText: 'Student',
                          prefixIcon: const Icon(Icons.person_rounded, size: 20),
                        ),
                        initialValue: _selectedStudent,
                        validator: (value) => value == null ? 'Please select a student' : null,
                        items: _students.map((student) {
                          return DropdownMenuItem(
                            value: student,
                            child: Text(
                              '${student.name} (${student.department})',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: _students.isEmpty ? null : (User? value) {
                          setState(() {
                            _selectedStudent = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Assessment Type',
                        prefixIcon: const Icon(Icons.military_tech_rounded, size: 20),
                      ),
                      initialValue: _selectedExamType,
                      validator: (value) => value == null ? 'Please select assessment type' : null,
                      items: _examTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedExamType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _marksController,
                            decoration: const InputDecoration(
                              labelText: 'Marks Awarded',
                              prefixIcon: Icon(Icons.score_rounded, size: 20),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              if (_totalMarksController.text.isNotEmpty) {
                                final total = double.tryParse(_totalMarksController.text);
                                final marks = double.parse(value);
                                if (total != null && marks > total) {
                                  return 'Exceeds total';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _totalMarksController,
                            decoration: const InputDecoration(
                              labelText: 'Max Marks',
                              prefixIcon: Icon(Icons.grade_rounded, size: 20),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                          onTap: _submitGrades,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Publish Grade',
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
      ),
    );
  }
}
