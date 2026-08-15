import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Mathematics / Virtual University colors — follows the app theme.
class MathematicsDegreeColors {
  const MathematicsDegreeColors(this.brightness);

  final Brightness brightness;

  Color get background => StudyColors.background(brightness);
  Color get surface => StudyColors.surface(brightness);
  Color get surfaceElevated => StudyColors.surfaceElevated(brightness);
  Color get textPrimary => StudyColors.textPrimary(brightness);
  Color get textSecondary => StudyColors.textSecondary(brightness);
  Color get border => StudyColors.border(brightness);
  Color get primary => StudyColors.primary;
  Color get primaryDark => StudyColors.primaryDark;
  Color get primaryLight => StudyColors.primaryLight;
  Color get accent => StudyColors.accent;
  Color get success => StudyColors.success;

  // Legacy aliases used across math screens.
  Color get navy => background;
  Color get navyCard => surfaceElevated;
  Color get navyLight => surfaceElevated;
  Color get ivory => textPrimary;
  Color get gold => primary;
  Color get goldLight => primaryLight;
  Color get accentBlue => primary;

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[primaryDark, primary],
      );

  BoxDecoration cardDecoration({Color? borderColor}) {
    final bool isDark = brightness == Brightness.dark;
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor ?? border),
      boxShadow: isDark
          ? null
          : <BoxShadow>[
              BoxShadow(
                color: primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
}

abstract final class MathematicsDegreeTheme {
  static MathematicsDegreeColors of(BuildContext context) =>
      MathematicsDegreeColors(Theme.of(context).brightness);

  static BoxDecoration cardDecoration(BuildContext context, {Color? border}) =>
      of(context).cardDecoration(borderColor: border);

  static LinearGradient heroGradient(BuildContext context) => of(context).heroGradient;
}
