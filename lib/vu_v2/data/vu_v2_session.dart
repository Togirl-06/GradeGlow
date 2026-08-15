import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight V2 onboarding + campus preferences (per signed-in user).
class VuV2Session extends ChangeNotifier {
  VuV2Session();

  static const String _legacyKey = 'vu_v2_session_v1';

  bool _loaded = false;
  String? _userId;
  bool onboardingComplete = false;
  String displayName = 'Student';
  String majorId = 'computer_science';
  String majorLabel = 'Computer Science';
  List<String> goals = <String>[];
  int weeklyMinutes = 150;
  int streakGoal = 5;
  String? continueTitle;
  String? continueSubtitle;
  double continueProgress = 0;

  /// Last unfinished onboarding page (0–4). Used to resume without retyping.
  int onboardingStep = 0;

  String get _storageKey {
    final String? id = _userId;
    if (id == null || id.isEmpty) return _legacyKey;
    return '${_legacyKey}_$id';
  }

  Future<void> ensureLoaded({String? userId}) async {
    if (_loaded && _userId == userId) return;
    _loaded = true;
    _userId = userId;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_storageKey);
    // Migrate legacy device-wide session into this user once.
    if (raw == null && userId != null && userId.isNotEmpty) {
      raw = prefs.getString(_legacyKey);
      if (raw != null) {
        await prefs.setString(_storageKey, raw);
      }
    }
    if (raw == null) {
      notifyListeners();
      return;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      onboardingComplete = data['onboardingComplete'] as bool? ?? false;
      displayName = data['displayName'] as String? ?? 'Student';
      majorId = data['majorId'] as String? ?? 'computer_science';
      majorLabel = data['majorLabel'] as String? ?? 'Computer Science';
      goals = ((data['goals'] as List<dynamic>?) ?? <dynamic>[])
          .whereType<String>()
          .toList();
      weeklyMinutes = (data['weeklyMinutes'] as num?)?.toInt() ?? 150;
      streakGoal = (data['streakGoal'] as num?)?.toInt() ?? 5;
      continueTitle = data['continueTitle'] as String?;
      continueSubtitle = data['continueSubtitle'] as String?;
      continueProgress = (data['continueProgress'] as num?)?.toDouble() ?? 0;
      onboardingStep = (data['onboardingStep'] as num?)?.toInt() ?? 0;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> saveOnboardingDraft({
    required String name,
    required List<String> goals,
    String? majorId,
    String? majorLabel,
    required int weeklyMinutes,
    required int step,
  }) async {
    if (onboardingComplete) return;
    final String trimmed = name.trim();
    if (trimmed.isNotEmpty) displayName = trimmed;
    this.goals = List<String>.from(goals);
    if (majorId != null && majorId.isNotEmpty) this.majorId = majorId;
    if (majorLabel != null && majorLabel.isNotEmpty) {
      this.majorLabel = majorLabel;
    }
    this.weeklyMinutes = weeklyMinutes;
    onboardingStep = step.clamp(0, 4);
    await _persist();
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required String majorId,
    required String majorLabel,
    required List<String> goals,
    required int weeklyMinutes,
  }) async {
    displayName = name.trim().isEmpty ? 'Student' : name.trim();
    this.majorId = majorId;
    this.majorLabel = majorLabel;
    this.goals = List<String>.from(goals);
    this.weeklyMinutes = weeklyMinutes;
    onboardingComplete = true;
    onboardingStep = 4;
    continueTitle = 'Orientation: Meet your AI Professor';
    continueSubtitle = '$majorLabel · Module 1';
    continueProgress = 0.08;
    await _persist();
    notifyListeners();
  }

  Future<void> setContinue({
    required String title,
    required String subtitle,
    required double progress,
  }) async {
    continueTitle = title;
    continueSubtitle = subtitle;
    continueProgress = progress.clamp(0.0, 1.0);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'onboardingComplete': onboardingComplete,
        'displayName': displayName,
        'majorId': majorId,
        'majorLabel': majorLabel,
        'goals': goals,
        'weeklyMinutes': weeklyMinutes,
        'streakGoal': streakGoal,
        'continueTitle': continueTitle,
        'continueSubtitle': continueSubtitle,
        'continueProgress': continueProgress,
        'onboardingStep': onboardingStep,
      }),
    );
  }
}
