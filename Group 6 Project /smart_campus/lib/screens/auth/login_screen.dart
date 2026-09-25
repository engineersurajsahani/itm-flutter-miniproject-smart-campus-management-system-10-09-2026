import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          final role = authProvider.currentUser?.role;
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          } else if (role == 'faculty') {
            Navigator.pushReplacementNamed(context, '/faculty_dashboard');
          } else if (role == 'student') {
            Navigator.pushReplacementNamed(context, '/student_dashboard');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown role')),
            );
          }
        } else {
          final errorMsg = authProvider.errorMessage ?? 'Login failed. Please check your credentials or server connection.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF172033);
    final mutedColor = isDark ? Colors.white60 : const Color(0xFF667085);
    final accentColor = isDark ? const Color(0xFF72A7FF) : const Color(0xFF2457A6);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10151D) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 68)),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to manage your campus day.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: mutedColor, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 15),
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                    ),
                    const SizedBox(height: 22),
                    _isLoading
                        ? const Center(child: LoadingIndicator())
                        : FilledButton.icon(
                            onPressed: _login,
                            icon: const Icon(Icons.login_rounded, size: 19),
                            label: const Text('Sign in'),
                          ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Create an account'),
                    ),
                    const SizedBox(height: 28),
                    Divider(color: isDark ? Colors.white12 : Colors.black12),
                    const SizedBox(height: 18),
                    Text(
                      'Everything in one place',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: textColor, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _FeatureItem(icon: Icons.event_available_outlined, label: 'Attendance', color: accentColor),
                        _FeatureItem(icon: Icons.menu_book_outlined, label: 'Grades', color: accentColor),
                        _FeatureItem(icon: Icons.campaign_outlined, label: 'Notices', color: accentColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
