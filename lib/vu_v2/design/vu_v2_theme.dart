import 'package:flutter/material.dart';

import '../../theme/study_theme.dart';

/// Campus tokens follow GradeGlow appearance (light/dark + accent).
abstract final class VuV2Colors {
  static Brightness _brightness = Brightness.dark;

  static void syncTo(ThemeData theme) {
    _brightness = theme.brightness;
  }

  static Brightness get brightness => _brightness;
  static bool get isLight => _brightness == Brightness.light;

  static Color get navy => StudyColors.background(_brightness);
  static Color get navyElevated => StudyColors.surfaceElevated(_brightness);
  static Color get card => StudyColors.surface(_brightness);
  static Color get ink => StudyColors.textPrimary(_brightness);
  static Color get mute => StudyColors.textSecondary(_brightness);
  static Color get stroke => StudyColors.border(_brightness);

  static Color get mint => StudyColors.primary;
  static Color get mintDeep => StudyColors.primaryDark;
  static Color get gold => StudyColors.accent;
  static Color get orange => StudyColors.primary;
  static Color get orangeDeep => StudyColors.primaryDark;

  static const Color yellow = Color(0xFFFBBF24);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}

abstract final class VuV2Radii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 28;
}

ThemeData vuV2DarkTheme() => buildStudyTheme(Brightness.dark);

ThemeData vuV2LightTheme() => buildStudyTheme(Brightness.light);
