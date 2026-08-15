import 'package:shared_preferences/shared_preferences.dart';

import '../data/english/english_lesson_catalog.dart';
import '../models/english_cefr.dart';

/// Local progression for the English program.
class EnglishProgressService {
  EnglishProgressService._();
  static final EnglishProgressService instance = EnglishProgressService._();

  static const String _keyStreak = 'english_streak_days';
  static const String _keyLastDate = 'english_last_lesson_date';
  static const String _keySessionXp = 'english_session_xp';
  static const String _keyNextSkill = 'english_next_skill_id';
  static const String _keyLessonsDone = 'english_lessons_completed';
  static const String _keyCompletedIds = 'english_completed_lesson_ids';
  static const String _keyCefrRank = 'english_cefr_rank';

  int streakDays = 0;
  int sessionXp = 0;
  int lessonsCompleted = 0;
  String nextSkillId = 'present_perfect_1';
  EnglishCefrLevel cefrLevel = EnglishCefrLevel.b1;
  final Set<String> completedLessonIds = <String>{};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    streakDays = prefs.getInt(_keyStreak) ?? 0;
    sessionXp = prefs.getInt(_keySessionXp) ?? 0;
    lessonsCompleted = prefs.getInt(_keyLessonsDone) ?? 0;
    nextSkillId = prefs.getString(_keyNextSkill) ?? 'present_perfect_1';
    cefrLevel = EnglishCefrLevel.fromRank(prefs.getInt(_keyCefrRank) ?? 3);
    if (!englishLessonCatalog.any((EnglishLessonEntry e) => e.id == nextSkillId)) {
      nextSkillId = englishLessonCatalog.first.id;
    }
    completedLessonIds
      ..clear()
      ..addAll(prefs.getStringList(_keyCompletedIds) ?? <String>[]);

    final String? last = prefs.getString(_keyLastDate);
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    if (last != null) {
      final DateTime lastDate = DateTime.parse(last);
      final int gap = todayDate.difference(lastDate).inDays;
      if (gap > 1) streakDays = 0;
    }
    _loaded = true;
  }

  bool isCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  Future<void> recordLessonComplete({
    required int xpEarned,
    required String skillId,
    required bool mastered,
    EnglishCefrLevel? levelAfter,
  }) async {
    await ensureLoaded();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);

    final String? last = prefs.getString(_keyLastDate);
    if (last == null) {
      streakDays = 1;
    } else {
      final DateTime lastDate = DateTime.parse(last);
      final int gap = todayDate.difference(lastDate).inDays;
      if (gap == 0) {
        // same day
      } else if (gap == 1) {
        streakDays += 1;
      } else {
        streakDays = 1;
      }
    }

    sessionXp += xpEarned;
    lessonsCompleted += 1;
    completedLessonIds.add(skillId);
    if (levelAfter != null) {
      cefrLevel = levelAfter;
    }
    _advanceNextSkill(skillId, mastered: mastered);

    await prefs.setInt(_keyStreak, streakDays);
    await prefs.setInt(_keySessionXp, sessionXp);
    await prefs.setInt(_keyLessonsDone, lessonsCompleted);
    await prefs.setString(_keyNextSkill, nextSkillId);
    await prefs.setInt(_keyCefrRank, cefrLevel.rank);
    await prefs.setStringList(_keyCompletedIds, completedLessonIds.toList());
    await prefs.setString(_keyLastDate, todayDate.toIso8601String());
  }

  void _advanceNextSkill(String completedId, {required bool mastered}) {
    final int idx = englishLessonCatalog.indexWhere(
      (EnglishLessonEntry e) => e.id == completedId,
    );
    if (idx < 0) return;

    for (int i = idx + 1; i < englishLessonCatalog.length; i++) {
      if (!completedLessonIds.contains(englishLessonCatalog[i].id)) {
        nextSkillId = englishLessonCatalog[i].id;
        return;
      }
    }
    for (final EnglishLessonEntry entry in englishLessonCatalog) {
      if (!completedLessonIds.contains(entry.id)) {
        nextSkillId = entry.id;
        return;
      }
    }
    if (mastered && idx + 1 < englishLessonCatalog.length) {
      nextSkillId = englishLessonCatalog[idx + 1].id;
    }
  }

  double streakMultiplier() {
    if (streakDays >= 7) return 1.5;
    if (streakDays >= 3) return 1.25;
    return 1.0;
  }
}
