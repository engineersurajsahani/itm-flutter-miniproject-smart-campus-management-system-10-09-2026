import 'package:flutter/material.dart';
import 'package:smart_campus/config/app_theme.dart';

class AppLogo extends StatefulWidget {
  final double size;
  final bool showGlow;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showGlow = true,
    this.onTap,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidget = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.225),
          boxShadow: widget.showGlow
              ? [
                  BoxShadow(
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.35),
                    blurRadius: widget.size * 0.35,
                    offset: Offset(0, widget.size * 0.12),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: widget.size * 0.2,
                    offset: Offset(0, widget.size * 0.08),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size * 0.225),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.adminGradient,
                ),
                child: Icon(
                  Icons.near_me_rounded,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              );
            },
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
}
