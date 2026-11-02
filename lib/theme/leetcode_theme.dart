import 'package:flutter/material.dart';

/// LeetCode-inspired palette for computer science practice labs.
class LeetCodeTheme {
  LeetCodeTheme._();

  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF282828);
  static const Color surfaceElevated = Color(0xFF323232);
  static const Color border = Color(0xFF3E3E3E);
  static const Color textPrimary = Color(0xFFEFF1F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color easy = Color(0xFF00B8A3);
  static const Color medium = Color(0xFFFFC01E);
  static const Color hard = Color(0xFFFF375F);
  static const Color accent = Color(0xFFFFA116);
  static const Color codeBackground = Color(0xFF0D1117);
  static const Color success = Color(0xFF2ECC71);
  static const Color consoleGreen = Color(0xFF7EE787);

  static Color difficultyColor(String difficulty) {
    final String lower = difficulty.toLowerCase();
    if (lower.contains('beginner') || lower == 'easy') return easy;
    if (lower.contains('intermediate') || lower == 'medium') return medium;
    return hard;
  }

  static String difficultyLabel(String difficulty) {
    final String lower = difficulty.toLowerCase();
    if (lower.contains('beginner')) return 'Easy';
    if (lower.contains('intermediate')) return 'Med.';
    if (lower.contains('advanced')) return 'Hard';
    return difficulty;
  }

  /// Stable pseudo acceptance rate for problem list display.
  static String acceptanceRate(String topicId) {
    final int hash = topicId.codeUnits.fold<int>(0, (int a, int b) => a + b);
    final double rate = 28 + (hash % 470) / 10;
    return '${rate.toStringAsFixed(1)}%';
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: easy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      dividerColor: border,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
    );
  }
}
