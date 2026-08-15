import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight V2 onboarding + campus preferences.
class VuV2Session extends ChangeNotifier {
  VuV2Session();

  static const String _key = 'vu_v2_session_v1';

  bool _loaded = false;
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

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
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
    } catch (_) {}
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
      _key,
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
      }),
    );
  }
}
