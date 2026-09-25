import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Widget? trailingBadge;
  final Widget child;
  final LinearGradient gradient;
  final Color? glowColor;
  final VoidCallback? onTap;
  final double height;
  final IconData? icon;
  final bool showNfcIcon;

  const WalletCard({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.trailingBadge,
    required this.child,
    required this.gradient,
    this.glowColor,
    this.onTap,
    this.height = 190,
    this.icon,
    this.showNfcIcon = true,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = widget.glowColor ?? widget.gradient.colors.first.withValues(alpha: 0.35);

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: Container(
        height: widget.height,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: widget.gradient,
          boxShadow: [
            BoxShadow(
              color: effectiveGlow,
              blurRadius: 26,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            (widget.title).toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      if (widget.trailingBadge != null)
                        widget.trailingBadge!
                      else if (widget.subtitle != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            widget.subtitle!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Middle Content
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.child,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
