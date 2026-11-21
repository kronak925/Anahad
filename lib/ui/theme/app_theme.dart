import 'package:flutter/material.dart';

class AppTheme {
  // Obsidian Dark palette (Inspired by Obsidian-Music)
  static const Color darkBackground = Color(0xFF070B0E);
  static const Color darkObsidianBackground = darkBackground;
  static const Color darkSurface = Color(0xFF0F151B);
  static const Color darkSurfaceElevated = Color(0xFF162028);
  static const Color darkGlassSurface = Color(0xCC0D141A);
  static const Color darkBorder = Color(0xFF1F2D38);
  static const Color darkBorderGlow = Color(0x3300E5FF);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // AMOLED True Black palette
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF080C0E);
  static const Color amoledSurfaceElevated = Color(0xFF10161C);
  static const Color amoledGlassSurface = Color(0xDD040608);

  // Light palette
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Lossless badge colors
  static const Color losslessBadgeGold = Color(0xFFFFD166);
  static const Color hiResBadgeCyan = Color(0xFF00E5FF);
  static const Color anahadCyan = Color(0xFF00ADB5);
  static const Color neonCyan = Color(0xFF00F5D4);

  /// Helper to create a frosted glass container decoration
  static BoxDecoration glassBoxDecoration({
    required BuildContext context,
    double borderRadius = 20,
    Color? surfaceColor,
    Color? borderColor,
    bool glow = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final defaultSurface = isDark ? darkGlassSurface : Colors.white.withValues(alpha: 0.85);
    final defaultBorder = isDark
        ? (glow ? primary.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08))
        : Colors.black.withValues(alpha: 0.06);

    return BoxDecoration(
      color: surfaceColor ?? defaultSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: glow ? 1.2 : 0.8,
      ),
      boxShadow: [
        if (glow && isDark)
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        else
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
      ],
    );
  }

  static ThemeData getTheme({
    required bool isDark,
    required bool isAmoled,
    required Color accentColor,
  }) {
    if (!isDark) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: ColorScheme.light(
          primary: accentColor,
          surface: lightSurface,
          onSurface: lightTextPrimary,
          outline: lightBorder,
        ),
        cardTheme: CardTheme(
          color: lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: lightBorder, width: 0.8),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: lightTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: lightTextPrimary),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: lightSurface,
          selectedItemColor: accentColor,
          unselectedItemColor: lightTextMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );
    }

    final bg = isAmoled ? amoledBackground : darkBackground;
    final surface = isAmoled ? amoledSurface : darkSurface;
    final border = isAmoled ? const Color(0xFF141A1F) : darkBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        surface: surface,
        onSurface: darkTextPrimary,
        outline: border,
        surfaceContainerHighest: isAmoled ? amoledSurfaceElevated : darkSurfaceElevated,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accentColor,
        unselectedItemColor: darkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
