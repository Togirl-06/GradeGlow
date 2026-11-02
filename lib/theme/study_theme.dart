import 'package:flutter/material.dart';

/// Configurable primary palette derived from the user's chosen accent color.
class StudyPalette {
  const StudyPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;

  static const Color defaultPrimary = Color(0xFF2563EB);

  static final StudyPalette defaults = StudyPalette.fromPrimary(defaultPrimary);

  factory StudyPalette.fromPrimary(Color primary) {
    final HSLColor hsl = HSLColor.fromColor(primary);
    return StudyPalette(
      primary: primary,
      primaryDark: hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor(),
      primaryLight: hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor(),
    );
  }
}

/// Ocean Focus palette — calm blue for studying, warm amber for streaks & XP.
class StudyColors {
  static StudyPalette _palette = StudyPalette.defaults;

  static StudyPalette get palette => _palette;

  static void applyPalette(StudyPalette palette) => _palette = palette;

  static Color get primary => _palette.primary;
  static Color get primaryDark => _palette.primaryDark;
  static Color get primaryLight => _palette.primaryLight;

  /// Streaks, XP, achievements.
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFD97706);

  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFE11D48);
  static const Color pdfRed = Color(0xFFE11D48);

  static Color primaryTint(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return primary.withValues(alpha: 0.2);
    }
    final HSLColor hsl = HSLColor.fromColor(primary);
    return hsl
        .withLightness(0.93)
        .withSaturation((hsl.saturation * 0.25).clamp(0.0, 1.0))
        .toColor();
  }

  static Color accentTint(Brightness brightness) =>
      brightness == Brightness.dark ? accent.withValues(alpha: 0.18) : const Color(0xFFFEF3C7);

  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF0B1220) : const Color(0xFFF1F5F9);

  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF151E2E) : Colors.white;

  static Color surfaceElevated(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF1C2840) : const Color(0xFFFFFFFF);

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF243044) : const Color(0xFFE2E8F0);
}

ThemeData buildStudyTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final Color background = StudyColors.background(brightness);
  final Color surface = StudyColors.surface(brightness);
  final Color textPrimary = StudyColors.textPrimary(brightness);
  final Color textSecondary = StudyColors.textSecondary(brightness);
  final Color border = StudyColors.border(brightness);

  final ColorScheme scheme = ColorScheme(
    brightness: brightness,
    primary: StudyColors.primary,
    onPrimary: Colors.white,
    primaryContainer: StudyColors.primaryTint(brightness),
    onPrimaryContainer: isDark ? StudyColors.primaryLight : StudyColors.primaryDark,
    secondary: StudyColors.accent,
    onSecondary: const Color(0xFF1C1917),
    secondaryContainer: StudyColors.accentTint(brightness),
    onSecondaryContainer: StudyColors.accentDark,
    surface: surface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    error: StudyColors.danger,
    onError: Colors.white,
    outline: border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: StudyColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: StudyColors.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? StudyColors.surfaceElevated(brightness) : surface,
      labelStyle: TextStyle(color: textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: StudyColors.primary, width: 1.5),
      ),
      errorStyle: TextStyle(
        color: StudyColors.danger,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: border),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: const Color(0xFF1E293B),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      actionTextColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: StudyColors.primary),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return isDark ? StudyColors.textSecondary(brightness) : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return StudyColors.primary;
        return border;
      }),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
    ),
    dividerColor: border,
  );
}
