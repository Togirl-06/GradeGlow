import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Engineering Faculty surfaces — accents follow the app theme color.
class EngineeringTheme {
  EngineeringTheme._();

  static Color get primary => StudyColors.primary;
  static Color get primaryDark => StudyColors.primaryDark;
  static Color get background => StudyColors.background(Brightness.light);
  static Color get surface => StudyColors.surface(Brightness.light);
  static Color get surfaceElevated => StudyColors.surfaceElevated(Brightness.light);
  static Color get border => StudyColors.border(Brightness.light);
  static Color get textPrimary => StudyColors.textPrimary(Brightness.light);
  static Color get textSecondary => StudyColors.textSecondary(Brightness.light);
  static Color get danger => StudyColors.danger;
  static Color get success => StudyColors.success;
  static Color get warning => StudyColors.warning;

  /// Dark mission-control panel (simulators / labs).
  static const Color consoleBg = Color(0xFF0F172A);
  static const Color consolePanel = Color(0xFF1E293B);
  static const Color consoleBorder = Color(0xFF334155);
  static const Color consoleText = Color(0xFFF1F5F9);
  static const Color consoleMuted = Color(0xFF94A3B8);
  static const Color consoleAccent = Color(0xFF38BDF8);
  static const Color consoleGood = Color(0xFF4ADE80);
  static const Color consoleBad = Color(0xFFF87171);
}
