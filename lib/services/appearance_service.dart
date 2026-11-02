import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../theme/study_theme.dart';
import 'auth_service.dart';

class AppearanceService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = StudyPalette.defaultPrimary;
  bool _loaded = false;
  AuthService? _auth;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isLoaded => _loaded;

  /// Bind auth so theme/accent can sync to Firestore across devices.
  void bindAuth(AuthService auth) {
    _auth = auth;
  }

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

  /// Pull cloud appearance after login so every device matches.
  Future<void> syncFromCloud() async {
    final String? uid = _auth?.uid;
    if (uid == null ||
        _auth!.isDemoMode ||
        !AppConfig.hasFirebase) {
      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final Map<String, dynamic>? data = doc.data();
      if (data == null) {
        await _pushToCloud();
        return;
      }

      bool changed = false;
      final String? themeName = data['themeMode'] as String?;
      if (themeName != null) {
        final ThemeMode mode = ThemeMode.values.firstWhere(
          (ThemeMode m) => m.name == themeName,
          orElse: () => _themeMode,
        );
        if (mode != _themeMode) {
          _themeMode = mode;
          changed = true;
        }
      }

      final Object? colorRaw = data['primaryColor'];
      if (colorRaw is int) {
        final Color color = Color(colorRaw);
        if (color.toARGB32() != _primaryColor.toARGB32()) {
          _primaryColor = color;
          StudyColors.applyPalette(StudyPalette.fromPrimary(color));
          changed = true;
        }
      }

      if (changed) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeModeKey, _themeMode.name);
        await prefs.setInt(_primaryColorKey, _primaryColor.toARGB32());
        notifyListeners();
      } else if (themeName == null && colorRaw == null) {
        await _pushToCloud();
      }
    } catch (error) {
      debugPrint('Appearance syncFromCloud failed: $error');
    }
  }

  Future<void> _pushToCloud() async {
    final String? uid = _auth?.uid;
    if (uid == null ||
        _auth!.isDemoMode ||
        !AppConfig.hasFirebase) {
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        <String, dynamic>{
          'themeMode': _themeMode.name,
          'primaryColor': _primaryColor.toARGB32(),
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      debugPrint('Appearance pushToCloud failed: $error');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    await _pushToCloud();
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    _primaryColor = color;
    StudyColors.applyPalette(StudyPalette.fromPrimary(color));
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.toARGB32());
    await _pushToCloud();
  }
}
