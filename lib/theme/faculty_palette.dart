import 'package:flutter/material.dart';

import 'study_theme.dart';

/// Visual tokens shared by faculty UI — always follows the user's accent color.
class FacultyPalette {
  const FacultyPalette({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.heroGradient,
    required this.cardRadius,
    this.appBarGradient,
    this.appBarForeground = Colors.white,
    this.glowColor,
    this.patternAccent,
  });

  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> heroGradient;
  final List<Color>? appBarGradient;
  final Color appBarForeground;
  final Color? glowColor;
  final Color? patternAccent;
  final double cardRadius;

  /// Palette driven by the user's selected accent color + current brightness.
  factory FacultyPalette.user(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primary = StudyColors.primary;
    final Color primaryDark = StudyColors.primaryDark;
    return FacultyPalette(
      primary: primary,
      primaryDark: primaryDark,
      accent: StudyColors.accent,
      background: StudyColors.background(brightness),
      surface: StudyColors.surface(brightness),
      surfaceElevated: StudyColors.surfaceElevated(brightness),
      border: StudyColors.border(brightness),
      textPrimary: StudyColors.textPrimary(brightness),
      textSecondary: StudyColors.textSecondary(brightness),
      heroGradient: <Color>[primaryDark, primary, StudyColors.primaryLight],
      appBarGradient: <Color>[primaryDark, primary],
      glowColor: primary.withValues(alpha: 0.28),
      patternAccent: StudyColors.accent,
      cardRadius: 16,
    );
  }

  static FacultyPalette physics([BuildContext? context]) =>
      context != null ? FacultyPalette.user(context) : FacultyPalette.userFallback();

  static FacultyPalette law([BuildContext? context]) =>
      context != null ? FacultyPalette.user(context) : FacultyPalette.userFallback();

  static FacultyPalette engineering([BuildContext? context]) =>
      context != null ? FacultyPalette.user(context) : FacultyPalette.userFallback();

  static FacultyPalette computerScience([BuildContext? context]) =>
      context != null ? FacultyPalette.user(context) : FacultyPalette.userFallback();

  /// Fallback when no [BuildContext] is available (rare static call sites).
  factory FacultyPalette.userFallback() {
    final Color primary = StudyColors.primary;
    final Color primaryDark = StudyColors.primaryDark;
    return FacultyPalette(
      primary: primary,
      primaryDark: primaryDark,
      accent: StudyColors.accent,
      background: StudyColors.background(Brightness.light),
      surface: StudyColors.surface(Brightness.light),
      surfaceElevated: StudyColors.surfaceElevated(Brightness.light),
      border: StudyColors.border(Brightness.light),
      textPrimary: StudyColors.textPrimary(Brightness.light),
      textSecondary: StudyColors.textSecondary(Brightness.light),
      heroGradient: <Color>[primaryDark, primary, StudyColors.primaryLight],
      appBarGradient: <Color>[primaryDark, primary],
      glowColor: primary.withValues(alpha: 0.28),
      patternAccent: StudyColors.accent,
      cardRadius: 16,
    );
  }
}
