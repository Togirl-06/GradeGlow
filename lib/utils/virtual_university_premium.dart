import 'package:shared_preferences/shared_preferences.dart';

import 'api_error_messages.dart';
import 'practice_lab_limits.dart';

/// Free-tier caps and daily usage tracking for Virtual University premium gates.
abstract final class VirtualUniversityPremium {
  static const int freeAiProfessorQuestionsPerDay = 10;
  static const int freeLectureTtsMinutesPerDay = 15;
  static const int freeSimulationsPerMonth =
      PracticeLabLimits.freeSimulationsPerMonth;

  /// Intro / gateway courses (kept for labeling; all courses are open).
  static bool isIntroCourse(String courseTitle) {
    final String lower = courseTitle.toLowerCase();
    return lower.contains('introduction') ||
        lower.contains('fundamentals') ||
        lower.contains('general') ||
        lower.contains('college algebra') ||
        lower.contains('principles') ||
        lower.contains('anatomy') ||
        lower.contains('clinical skills') ||
        lower.contains('foundations');
  }

  /// Every catalog course is open — no Premium paywall on the curriculum.
  static bool canAccessCourse({
    required bool isPremium,
    required String courseTitle,
    int courseIndex = 0,
  }) {
    return true;
  }

  static bool canAccessAllCourses(bool isPremium) => true;

  static String _dateStamp([DateTime? now]) {
    final DateTime d = now ?? DateTime.now();
    final String y = d.year.toString().padLeft(4, '0');
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String _aiPrefsKey([DateTime? now]) =>
      'vu_premium_ai_qs_${_dateStamp(now)}';

  static String _ttsPrefsKey([DateTime? now]) =>
      'vu_premium_tts_min_${_dateStamp(now)}';

  static Future<int> aiQuestionsUsedToday() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_aiPrefsKey()) ?? 0;
  }

  static Future<void> recordAiQuestion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = _aiPrefsKey();
    final int used = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, used + 1);
  }

  static Future<bool> canAskAiProfessor(bool isPremium) async {
    return true;
  }

  static Future<int> ttsMinutesUsedToday() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ttsPrefsKey()) ?? 0;
  }

  static Future<void> recordTtsMinutes(int minutes) async {
    if (minutes <= 0) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = _ttsPrefsKey();
    final int used = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, used + minutes);
  }

  static Future<bool> canUseLectureTts(
    bool isPremium, {
    int additionalMinutes = 1,
  }) async {
    return true;
  }

  static const ApiErrorInfo dailyAiLimitReached = ApiErrorInfo(
    title: 'Campus AI is included',
    message:
        'The Virtual University AI Professor is free for every student.',
    steps: <String>[
      'Ask another question',
    ],
  );

  static const ApiErrorInfo dailyTtsLimitReached = ApiErrorInfo(
    title: 'Lecture audio is included',
    message:
        'Campus lecture audio is free for every student.',
    steps: <String>[
      'Play the lecture again',
    ],
  );
}
