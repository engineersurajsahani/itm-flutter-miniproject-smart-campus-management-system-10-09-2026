import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/loading_indicator.dart';

class PostNoticeScreen extends StatefulWidget {
  const PostNoticeScreen({super.key});

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _targetAudience = 'All';
  final List<String> _audiences = ['All', 'Students', 'Faculty'];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authorName = authProvider.currentUser?.name ?? 'Faculty Member';

      await noticeProvider.postNotice(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        audience: _targetAudience,
        author: authorName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notice broadcasted successfully!'),
            backgroundColor: const Color(0xFF30D158),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting notice: $e'),
            backgroundColor: const Color(0xFFFF453A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Broadcast Notice',
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
                      'ANNOUNCEMENT COMPOSER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Headline Title',
                        prefixIcon: Icon(Icons.campaign_rounded, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.length < 5) {
                          return 'Title must be at least 5 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Audience Segment',
                        prefixIcon: Icon(Icons.group_rounded, size: 20),
                      ),
                      initialValue: _targetAudience,
                      items: _audiences.map((String audience) {
                        return DropdownMenuItem<String>(
                          value: audience,
                          child: Text(
                            audience,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _targetAudience = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Notice Body & Announcement Details',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 7,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the content';
                        }
                        if (value.length < 10) {
                          return 'Content is too short';
                        }
                        return null;
                      },
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
                          onTap: _submitNotice,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Publish Notice',
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
