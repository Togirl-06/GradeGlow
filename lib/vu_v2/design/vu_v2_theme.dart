import 'package:flutter/material.dart';

import '../../theme/study_theme.dart';

/// Campus tokens follow the main GradeGlow appearance (light/dark + accent).
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

  /// Primary campus accent = user's app color.
  static Color get mint => StudyColors.primary;
  static Color get mintDeep => StudyColors.primaryDark;
  static Color get orange => StudyColors.primary;
  static Color get orangeDeep => StudyColors.primaryDark;

  static Color get gold => StudyColors.accent;
  static Color get yellow => StudyColors.accent;

  // Game / progress secondary accents (work on light and dark).
  static Color get dashCyan =>
      isLight ? const Color(0xFF0891B2) : const Color(0xFF22D3EE);
  static Color get dashGreen => StudyColors.success;
  static Color get dashPink =>
      isLight ? const Color(0xFFDB2777) : const Color(0xFFEC4899);
  static Color get dashGold => StudyColors.accent;
  static Color get dashPurple => StudyColors.primary;
  static Color get dashPurpleDeep => StudyColors.primaryDark;

  /// Aliases used by the VU dashboard mockup widgets.
  static Color get dashBg => navy;
  static Color get dashPanel => navyElevated;
  static Color get dashCard => card;
  static Color get dashStroke => stroke;
  static Color get dashInk => ink;
  static Color get dashMute => mute;

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
