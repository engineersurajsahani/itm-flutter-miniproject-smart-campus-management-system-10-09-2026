import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';

class RecentAccessCard extends StatefulWidget {
  final DateTime? lastLoginAt;
  final String role;

  const RecentAccessCard({
    super.key,
    required this.lastLoginAt,
    required this.role,
  });

  @override
  State<RecentAccessCard> createState() => _RecentAccessCardState();
}

class _RecentAccessCardState extends State<RecentAccessCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsedText() {
    final loginTime = widget.lastLoginAt;
    if (loginTime == null) return 'No recent sign-in recorded';

    final elapsed = _now.difference(loginTime);
    if (elapsed.isNegative || elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} min session';
    if (elapsed.inDays < 1) return '${elapsed.inHours} hr session';
    return '${elapsed.inDays} day session';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.getRoleColor(widget.role);
    final loginTime = widget.lastLoginAt;
    final timeLabel = loginTime == null
        ? 'Not available'
        : DateFormat('d MMM yyyy, h:mm a').format(loginTime.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent access',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  timeLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_elapsedText()}  •  ${widget.role[0].toUpperCase()}${widget.role.substring(1)} account',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ],
      ),
    );
  }
}
