import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Physics Faculty — deep space accent on shared study surfaces.
class PhysicsTheme {
  PhysicsTheme._();

  static const Color accent = Color(0xFF6366F1);
  static const Color accentDark = Color(0xFF4338CA);
  static const Color nebula = Color(0xFF818CF8);

  static Color get primary => accent;
  static Color get primaryDark => accentDark;
  static Color get background => StudyColors.background(Brightness.light);
  static Color get surface => StudyColors.surface(Brightness.light);
  static Color get border => StudyColors.border(Brightness.light);
  static Color get textPrimary => StudyColors.textPrimary(Brightness.light);
  static Color get textSecondary => StudyColors.textSecondary(Brightness.light);

  static const Color consoleBg = Color(0xFF0B1026);
  static const Color consolePanel = Color(0xFF151B3D);
  static const Color consoleBorder = Color(0xFF2D3561);
  static const Color consoleText = Color(0xFFE8EAFF);
  static const Color consoleMuted = Color(0xFF9CA3CF);
  static const Color consoleAccent = Color(0xFF818CF8);
  static const Color consoleGood = Color(0xFF34D399);
  static const Color consoleBad = Color(0xFFF87171);
  static const Color success = consoleGood;
}
