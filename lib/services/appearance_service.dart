import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/study_theme.dart';

class AppearanceService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = StudyPalette.defaultPrimary;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isLoaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? themeModeName = prefs.getString(_themeModeKey);
    if (themeModeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == themeModeName,
        orElse: () => ThemeMode.light,
      );
    }

    final int? colorValue = prefs.getInt(_primaryColorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }

    StudyColors.applyPalette(StudyPalette.fromPrimary(_primaryColor));
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    _primaryColor = color;
    StudyColors.applyPalette(StudyPalette.fromPrimary(color));
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.toARGB32());
  }
}
