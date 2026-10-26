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

  /// Soft variants of the user's color (same family, slight hue shift).
  static Color _fromPrimary({
    double hueShift = 0,
    double lightnessDelta = 0,
    double saturationFactor = 1,
  }) {
    final HSLColor hsl = HSLColor.fromColor(StudyColors.primary);
    return hsl
        .withHue((hsl.hue + hueShift) % 360.0)
        .withSaturation(
          (hsl.saturation * saturationFactor).clamp(0.25, 1.0),
        )
        .withLightness(
          (hsl.lightness + lightnessDelta).clamp(0.28, 0.72),
        )
        .toColor();
  }

  static Color get dashCyan => _fromPrimary(hueShift: 28, lightnessDelta: 0.05);
  static Color get dashGreen => StudyColors.success;
  static Color get dashPink => _fromPrimary(hueShift: -32, lightnessDelta: 0.04);
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
