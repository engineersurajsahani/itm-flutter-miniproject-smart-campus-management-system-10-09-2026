import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/course_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../models/course.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
      context.read<FacultyProvider>().fetchFaculty();
    });
  }

  void _showCourseDialog({Course? course}) {
    final isEditing = course != null;
    final nameController = TextEditingController(text: course?.name ?? '');
    final codeController = TextEditingController(text: course?.code ?? '');
    final deptController = TextEditingController(text: course?.department ?? '');
    int? selectedFacultyId = course?.facultyId;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isEditing ? 'Edit Course' : 'Create Course',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Course Name'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: 'Course Code (e.g. CS101)'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: deptController,
                        decoration: const InputDecoration(labelText: 'Department'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      Consumer<FacultyProvider>(
                        builder: (context, facultyProvider, _) {
                          if (facultyProvider.isLoading) {
                            return const Center(child: LoadingIndicator());
                          }
                          return DropdownButtonFormField<int>(
                            initialValue: selectedFacultyId,
                            decoration: const InputDecoration(labelText: 'Instructor / Faculty'),
                            items: facultyProvider.faculty.map((f) {
                              return DropdownMenuItem<int>(
                                value: f.id,
                                child: Text(f.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (val) => setStateDialog(() => selectedFacultyId = val),
                            validator: (v) => v == null ? 'Please select a faculty' : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final facultyProvider = context.read<FacultyProvider>();
                      final faculty = facultyProvider.faculty.firstWhere((f) => f.id == selectedFacultyId);

                      final newCourse = Course(
                        id: isEditing ? course.id : 0,
                        name: nameController.text,
                        code: codeController.text,
                        department: deptController.text,
                        facultyId: faculty.id,
                        facultyName: faculty.name,
                      );

                      if (isEditing) {
                        context.read<CourseProvider>().updateCourse(newCourse);
                      } else {
                        context.read<CourseProvider>().addCourse(newCourse);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Save',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Course?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        content: Text(
          'Are you sure you want to remove this course and associated registrations?',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF453A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Manage Courses',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCourseDialog(),
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No curriculum courses available',
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

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: provider.courses.length,
            itemBuilder: (context, index) {
              final course = provider.courses[index];
              return Dismissible(
                key: Key(course.id.toString()),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => _confirmDelete(context),
                onDismissed: (_) {
                  provider.deleteCourse(course.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Course removed'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A84FF).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF0A84FF), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${course.code} • ${course.department}\nFaculty: ${course.facultyName ?? 'Not Assigned'}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit course',
                              icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0A84FF), size: 22),
                              onPressed: () => _showCourseDialog(course: course),
                            ),
                            IconButton(
                              tooltip: 'Delete course',
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A), size: 22),
                              onPressed: () async {
                                final confirmed = await _confirmDelete(context);
                                if (confirmed != true || !context.mounted) return;
                                provider.deleteCourse(course.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Course removed')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
