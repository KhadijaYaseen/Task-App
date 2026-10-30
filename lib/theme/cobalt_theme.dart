import 'package:flutter/material.dart';

/// Authentic Hallmark "Cobalt" Design System
/// Extracted directly from usehallmark.com/themes/cobalt
class CobaltTheme {
  // Surface / Canvas Palette
  static const Color paper = Color(0xFFFAFBFC);
  static const Color paper2 = Color(0xFFF1F5F9);
  static const Color paper3 = Color(0xFFE2E8F0);

  // Typography Ink Palette
  static const Color ink = Color(0xFF0F172A);
  static const Color ink2 = Color(0xFF334155);
  static const Color muted = Color(0xFF64748B);
  static const Color rule = Color(0xFFE2E8F0);
  static const Color rule2 = Color(0xFFCBD5E1);

  // Cobalt Electric Accent Palette
  static const Color accent = Color(0xFF1D4ED8); // oklch(52% 0.19 258)
  static const Color accentHover = Color(0xFF1E40AF);
  static const Color accentEdge = Color(0xFF172554); // 3D bottom keycap shadow
  static const Color accentWash = Color(0xFFEFF6FF);

  // Neutral Keycap Palette
  static const Color keyFace = Color(0xFFFFFFFF);
  static const Color keyEdge = Color(0xFFCBD5E1); // 3D neutral keycap edge

  // Status & Semantic Colors
  static const Color statusSuccess = Color(0xFF16A34A);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusInfo = Color(0xFF2563EB);

  // Geometry
  static const double radiusCard = 8.0;
  static const double radiusInput = 6.0;
  static const double radiusPill = 20.0;

  // Compatibility Aliases (prevents undefined getter errors across versions)
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
        primary: accent,
        surface: Colors.white,
        error: statusError,
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
