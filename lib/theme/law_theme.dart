import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Law School surfaces — accents follow the app theme; courtroom panels stay dark wood/slate.
class LawTheme {
  LawTheme._();

  static Color get primary => StudyColors.primary;
  static Color get primaryDark => StudyColors.primaryDark;
  static Color get background => StudyColors.background(Brightness.light);
  static Color get surface => StudyColors.surface(Brightness.light);
  static Color get border => StudyColors.border(Brightness.light);
  static Color get textPrimary => StudyColors.textPrimary(Brightness.light);
  static Color get textSecondary => StudyColors.textSecondary(Brightness.light);
  static Color get success => StudyColors.success;
  static Color get danger => StudyColors.danger;
  static Color get warning => StudyColors.warning;

  static const Color bench = Color(0xFF3E2723);
  static const Color benchLight = Color(0xFF5D4037);
  static const Color courtroomBg = Color(0xFF1C1917);
  static const Color courtroomPanel = Color(0xFF292524);
  static const Color courtroomBorder = Color(0xFF44403C);
  static const Color courtroomText = Color(0xFFFAFAF9);
  static const Color courtroomMuted = Color(0xFFA8A29E);
  static const Color gavel = Color(0xFFD6A85B);
}
