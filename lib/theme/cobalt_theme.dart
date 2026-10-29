import 'package:flutter/material.dart';

/// Hallmark "Cobalt" Modern Minimalist Design System
/// Enforces high-contrast hierarchy, clean geometric lines, and structured cards.
class CobaltTheme {
  // Brand Colors
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Cobalt Electric Accent
  static const Color cobaltBlue = Color(0xFF2563EB);
  static const Color cobaltHover = Color(0xFF1D4ED8);
  static const Color cobaltLight = Color(0xFFEFF6FF);

  // Semantic Status Colors
  static const Color statusTodo = Color(0xFF64748B);
  static const Color statusInProgress = Color(0xFFD97706);
  static const Color statusReview = Color(0xFF7C3AED);
  static const Color statusDone = Color(0xFF16A34A);

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: slate50,
      colorScheme: ColorScheme.light(
        primary: slate900,
        secondary: cobaltBlue,
        surface: Colors.white,
        error: priorityUrgent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        iconTheme: IconThemeData(color: slate900),
        titleTextStyle: TextStyle(
          color: slate900,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: slate200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: slate100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: slate200, width: 1),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: slate700,
        ),
      ),
    );
  }
}
