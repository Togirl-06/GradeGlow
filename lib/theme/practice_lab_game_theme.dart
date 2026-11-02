import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Practice Lab colors — follows the user's app theme and accent color.
class PracticeLabColors {
  const PracticeLabColors(this.brightness);

  final Brightness brightness;

  Color get background => StudyColors.background(brightness);
  Color get surface => StudyColors.surface(brightness);
  Color get surfaceElevated => StudyColors.surfaceElevated(brightness);
  Color get border => StudyColors.border(brightness);
  Color get textPrimary => StudyColors.textPrimary(brightness);
  Color get textSecondary => StudyColors.textSecondary(brightness);

  /// User-chosen accent (buttons, progress, highlights).
  Color get primary => StudyColors.primary;

  /// Gamification / XP uses the user's accent.
  Color get xp => StudyColors.primary;

  Color get streak => StudyColors.accent;
  Color get success => StudyColors.success;
  Color get warning => StudyColors.warning;
  Color get danger => StudyColors.danger;

  Color difficultyColor(String difficulty) {
    final String d = difficulty.toLowerCase();
    if (d.contains('begin')) return success;
    if (d.contains('inter')) return warning;
    if (d.contains('adv')) return danger;
    return textSecondary;
  }
}

/// Theme helpers for Practice Labs — always use [of] for surfaces and text.
abstract final class PracticeLabGameTheme {
  static PracticeLabColors of(BuildContext context) =>
      PracticeLabColors(Theme.of(context).brightness);

  static Color background(BuildContext context) => of(context).background;
  static Color surface(BuildContext context) => of(context).surface;
  static Color surfaceElevated(BuildContext context) => of(context).surfaceElevated;
  static Color border(BuildContext context) => of(context).border;
  static Color textPrimary(BuildContext context) => of(context).textPrimary;
  static Color textSecondary(BuildContext context) => of(context).textSecondary;
  static Color primary(BuildContext context) => of(context).primary;
  static Color xp(BuildContext context) => of(context).xp;
  static Color streak(BuildContext context) => of(context).streak;
  static Color success(BuildContext context) => of(context).success;
  static Color warning(BuildContext context) => of(context).warning;
  static Color danger(BuildContext context) => of(context).danger;

  static Color difficultyColor(BuildContext context, String difficulty) =>
      of(context).difficultyColor(difficulty);
}

extension PracticeLabThemeContext on BuildContext {
  PracticeLabColors get practiceLab => PracticeLabGameTheme.of(this);
}
