import 'package:flutter/material.dart';

/// Virtual University visual system — matches the mint/teal campus mockups.
abstract final class VuV2Colors {
  static const Color navy = Color(0xFF0A0E14);
  static const Color navyElevated = Color(0xFF121A26);
  static const Color card = Color(0xFF162032);
  static const Color ink = Color(0xFFF8FAFC);
  static const Color mute = Color(0xFF94A3B8);

  /// Brand mint / teal from mockups.
  static const Color mint = Color(0xFF3DDBAD);
  static const Color mintDeep = Color(0xFF28B69A);
  static const Color gold = Color(0xFFF5D76E);

  /// Alias used across older VU screens (now mint).
  static Color get orange => mint;
  static Color get orangeDeep => mintDeep;

  static const Color yellow = Color(0xFFFBBF24);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color stroke = Color(0xFF243044);
}

abstract final class VuV2Radii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 28;
}

ThemeData vuV2DarkTheme() {
  const Color primary = VuV2Colors.mint;
  final ColorScheme scheme = ColorScheme.dark(
    primary: primary,
    onPrimary: const Color(0xFF04110C),
    secondary: VuV2Colors.mintDeep,
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
        foregroundColor: const Color(0xFF04110C),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VuV2Radii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
  );
}

ThemeData vuV2LightTheme() {
  const Color primary = VuV2Colors.mintDeep;
  final ColorScheme scheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    secondary: VuV2Colors.mint,
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
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VuV2Radii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
  );
}
