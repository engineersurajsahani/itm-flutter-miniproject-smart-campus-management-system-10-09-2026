import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/faculty_provider.dart';
import '../../models/user.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class ManageFacultyScreen extends StatefulWidget {
  const ManageFacultyScreen({super.key});

  @override
  State<ManageFacultyScreen> createState() => _ManageFacultyScreenState();
}

class _ManageFacultyScreenState extends State<ManageFacultyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacultyProvider>().fetchFaculty();
    });
  }

  void _showEditDialog(User faculty) {
    final nameController = TextEditingController(text: faculty.name);
    final emailController = TextEditingController(text: faculty.email);
    final deptController = TextEditingController(text: faculty.department);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Edit Faculty',
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
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
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
              backgroundColor: const Color(0xFF30D158),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedFaculty = faculty.copyWith(
                  name: nameController.text,
                  email: emailController.text,
                  department: deptController.text,
                );
                context.read<FacultyProvider>().updateFaculty(updatedFaculty);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Faculty Member?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        content: Text(
          'Are you sure you want to delete this faculty record? This action cannot be undone.',
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
          'Manage Faculty',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
      body: Consumer<FacultyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.faculty.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No faculty members found',
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
            itemCount: provider.faculty.length,
            itemBuilder: (context, index) {
              final faculty = provider.faculty[index];
              return Dismissible(
                key: Key(faculty.id.toString()),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => _confirmDelete(context),
                onDismissed: (_) {
                  provider.deleteFaculty(faculty.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Faculty member removed'),
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
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF30D158).withValues(alpha: 0.18),
                          child: Text(
                            faculty.name.isNotEmpty ? faculty.name[0].toUpperCase() : 'F',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF30D158),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                faculty.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${faculty.email} • ${faculty.department}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit faculty member',
                              icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0A84FF), size: 22),
                              onPressed: () => _showEditDialog(faculty),
                            ),
                            IconButton(
                              tooltip: 'Delete faculty member',
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A), size: 22),
                              onPressed: () async {
                                final confirmed = await _confirmDelete(context);
                                if (confirmed != true || !context.mounted) return;
                                provider.deleteFaculty(faculty.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Faculty member removed')),
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
