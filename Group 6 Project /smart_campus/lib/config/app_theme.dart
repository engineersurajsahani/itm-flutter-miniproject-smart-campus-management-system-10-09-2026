import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple System & Ambient Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121214);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkSecondaryCard = Color(0xFF2C2C2E);
  static const Color darkTertiary = Color(0xFF3A3A3C);

  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSecondaryCard = Color(0xFFE5E5EA);

  // Role dynamic accent gradients & colors
  static const Color studentPrimary = Color(0xFFFF9500); // Apple Orange
  static const Color studentSecondary = Color(0xFFFF2D55); // Apple Pink/Rose
  static const Color facultyPrimary = Color(0xFF30D158); // Apple Mint/Green
  static const Color facultySecondary = Color(0xFF00C7BE); // Apple Teal
  static const Color adminPrimary = Color(0xFF0A84FF); // Apple System Blue
  static const Color adminSecondary = Color(0xFF5E5CE6); // Apple Indigo

  static const LinearGradient studentGradient = LinearGradient(
    colors: [Color(0xFFFF9F0A), Color(0xFFFF375F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient facultyGradient = LinearGradient(
    colors: [Color(0xFF30D158), Color(0xFF00C7BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purplePassGradient = LinearGradient(
    colors: [Color(0xFFBF5AF2), Color(0xFF5E5CE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkMeshGradient = LinearGradient(
    colors: [Color(0xFF242429), Color(0xFF161618)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData getTheme(bool isDark) {
    final background = isDark ? darkBackground : lightBackground;
    final surface = isDark ? darkSurface : lightSurface;
    final cardColor = isDark ? darkCard : lightCard;
    final primary = const Color(0xFF0A84FF);

    final baseTextTheme = ThemeData(brightness: isDark ? Brightness.dark : Brightness.light).textTheme;
    final typography = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: isDark ? Colors.white : Colors.black,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: isDark ? Colors.white : Colors.black,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: isDark ? Colors.white : Colors.black,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45,
      ),
    );

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: const Color(0xFF5E5CE6),
      onSecondary: Colors.white,
      error: const Color(0xFFFF453A),
      onError: Colors.white,
      surface: surface,
      onSurface: isDark ? Colors.white : Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: typography,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: typography.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0A84FF),
            width: 1.5,
          ),
        ),
        hintStyle: typography.bodyMedium?.copyWith(
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminPrimary;
      case 'faculty':
        return facultyPrimary;
      case 'student':
        return studentPrimary;
      default:
        return Colors.grey;
    }
  }

  static LinearGradient getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminGradient;
      case 'faculty':
        return facultyGradient;
      case 'student':
        return studentGradient;
      default:
        return cardDarkMeshGradient;
    }
  }
}
