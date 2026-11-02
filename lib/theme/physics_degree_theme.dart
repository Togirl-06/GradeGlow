import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Physics faculty palette — follows the user's chosen accent color.
class PhysicsDegreeColors {
  const PhysicsDegreeColors(this.brightness);

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
                color: primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
}

abstract final class PhysicsDegreeTheme {
  static PhysicsDegreeColors of(BuildContext context) =>
      PhysicsDegreeColors(Theme.of(context).brightness);
}
