import 'package:flutter/material.dart';

import '../../theme/study_theme.dart';

/// GradeGlow Virtual University V2 design tokens.
/// Accent colors follow the user's Appearance primary ([StudyColors]).
abstract final class VuV2Colors {
  static const Color navy = Color(0xFF0F172A);
  static const Color navyElevated = Color(0xFF1E293B);
  static const Color ink = Color(0xFFF8FAFC);
  static const Color mute = Color(0xFF94A3B8);

  /// User-chosen accent (settings / Appearance).
  static Color get orange => StudyColors.primary;
  static Color get orangeDeep => StudyColors.primaryDark;

  static const Color yellow = Color(0xFFFBBF24);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color stroke = Color(0xFF334155);
}

abstract final class VuV2Radii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

ThemeData vuV2DarkTheme() {
  final Color primary = StudyColors.primary;
  final ColorScheme scheme = ColorScheme.dark(
    primary: primary,
    onPrimary: Colors.white,
    secondary: StudyColors.primaryLight,
    surface: VuV2Colors.navy,
    onSurface: VuV2Colors.ink,
    onSurfaceVariant: VuV2Colors.mute,
    error: VuV2Colors.danger,
    outline: VuV2Colors.stroke,
    surfaceContainerHighest: VuV2Colors.navyElevated,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: VuV2Colors.navy,
    appBarTheme: const AppBarTheme(
      backgroundColor: VuV2Colors.navy,
      foregroundColor: VuV2Colors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: VuV2Colors.ink,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: VuV2Colors.navyElevated,
      indicatorColor: primary.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VuV2Radii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
  );
}

ThemeData vuV2LightTheme() {
  final Color primary = StudyColors.primary;
  final Color primaryDark = StudyColors.primaryDark;
  final ColorScheme scheme = ColorScheme.light(
    primary: primaryDark,
    onPrimary: Colors.white,
    secondary: StudyColors.primaryLight,
    surface: const Color(0xFFF8FAFC),
    onSurface: const Color(0xFF0F172A),
    onSurfaceVariant: const Color(0xFF64748B),
    error: VuV2Colors.danger,
    outline: const Color(0xFFCBD5E1),
    surfaceContainerHighest: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF1F5F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VuV2Radii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
  );
}
