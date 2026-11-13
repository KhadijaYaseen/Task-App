import 'package:flutter/material.dart';

/// Cobalt Design System theme configuration and color tokens.
class CobaltTheme {
  static const Color paper = Color(0xFFFAFBFC);
  static const Color paper2 = Color(0xFFF1F5F9);
  static const Color paper3 = Color(0xFFE2E8F0);

  static const Color ink = Color(0xFF0F172A);
  static const Color ink2 = Color(0xFF334155);
  static const Color muted = Color(0xFF64748B);
  static const Color rule = Color(0xFFE2E8F0);
  static const Color rule2 = Color(0xFFCBD5E1);

  static const Color accent = Color(0xFF1D4ED8);
  static const Color accentHover = Color(0xFF1E40AF);
  static const Color accentEdge = Color(0xFF172554);
  static const Color accentWash = Color(0xFFEFF6FF);

  static const Color keyFace = Color(0xFFFFFFFF);
  static const Color keyEdge = Color(0xFFCBD5E1);

  static const Color statusSuccess = Color(0xFF16A34A);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusInfo = Color(0xFF2563EB);

  // Modern Purple & Gradient Palette
  static const Color purplePrimary = Color(0xFF7C3AED);
  static const Color purpleSecondary = Color(0xFF6366F1);
  static const Color purpleWash = Color(0xFFFAF5FF);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleDark = Color(0xFF581C87);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentHeroGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> purpleGlowShadow = [
    BoxShadow(
      color: Color(0x287C3AED),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  // Geometry
  static const double radiusCard = 8.0;
  static const double radiusCardLarge = 16.0;
  static const double radiusCardXLarge = 20.0;
  static const double radiusInput = 8.0;
  static const double radiusButton = 8.0;
  static const double radiusPill = 20.0;

  // Compatibility Aliases (prevents undefined getter errors across versions)
  static const Color accentLight = accentWash;
  static const Color slate950 = ink;
  static const Color slate900 = ink;
  static const Color slate800 = ink2;
  static const Color slate700 = ink2;
  static const Color slate600 = muted;
  static const Color slate500 = muted;
  static const Color slate400 = muted;
  static const Color slate200 = rule;
  static const Color slate100 = paper2;
  static const Color slate50 = paper;

  static const Color cobaltBlue = accent;
  static const Color cobaltHover = accentHover;
  static const Color cobaltLight = accentWash;

  static const Color statusTodo = muted;
  static const Color statusInProgress = statusWarning;
  static const Color statusReview = accent;
  static const Color statusDone = statusSuccess;

  static const Color priorityUrgent = statusError;
  static const Color priorityHigh = statusWarning;
  static const Color priorityMedium = statusWarning;
  static const Color priorityLow = muted;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: const ColorScheme.light(
        primary: purplePrimary,
        surface: Colors.white,
        error: statusError,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: purplePrimary, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: rule2),
        ),
        floatingLabelStyle: const TextStyle(
          color: purplePrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: ink),
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      fontFamily: 'Roboto',
    );
  }
}
