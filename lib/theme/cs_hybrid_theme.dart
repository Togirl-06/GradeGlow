import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Light CS workspace palette — accents follow the app theme color.
class CsHybridTheme {
  CsHybridTheme._();

  static const Color background = Color(0xFFF1F1F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFCCCCCC);
  static Color get primary => StudyColors.primary;
  static Color get primaryDark => StudyColors.primaryDark;
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3A3A3A);
  static const Color codeBg = Color(0xFF282A36);
  static const Color codeText = Color(0xFFE8E8E8);
  static const Color consoleGreen = Color(0xFF7EE787);
  static const Color error = Color(0xFFD32F2F);
  static Color get easy => StudyColors.primary;
  static const Color medium = Color(0xFFE7A600);
  static const Color hard = Color(0xFFD32F2F);

  static Color tierColor(String difficulty) {
    final String d = difficulty.toLowerCase();
    if (d.contains('easy')) return easy;
    if (d.contains('med')) return medium;
    return hard;
  }
}
