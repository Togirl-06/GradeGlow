import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/law/law_catalog.dart';
import '../models/law/law_program.dart';

/// One court case per specialization per calendar day, with completion tracking.
class LawDailyProgressService extends ChangeNotifier {
  LawDailyProgressService._();

  static final LawDailyProgressService instance = LawDailyProgressService._();

  static const String _keyCompleted = 'law_daily_completed_keys';

  final Set<String> _completedKeys = <String>{};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _completedKeys
      ..clear()
      ..addAll(prefs.getStringList(_keyCompleted) ?? <String>[]);
    _loaded = true;
    notifyListeners();
  }

  static String dayKey([DateTime? when]) {
    final DateTime d = when ?? DateTime.now();
    final String mm = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  static String completionKey(String specializationId, [DateTime? when]) =>
      '${dayKey(when)}|$specializationId';

  /// Stable daily lesson for a specialization (changes each calendar day).
  static LawLesson? dailyLessonFor(String specializationId, [DateTime? when]) {
    final LawSpecialization? spec = LawCatalog.byId(specializationId);
    if (spec == null) return null;
    final List<LawLesson> lessons = <LawLesson>[
      for (final LawCourse c in spec.courses) ...c.lessons,
    ];
    if (lessons.isEmpty) return null;
    final DateTime d = when ?? DateTime.now();
    final int seed = d.year * 10000 + d.month * 100 + d.day;
    final int index = (seed + specializationId.hashCode).abs() % lessons.length;
    return lessons[index];
  }

  static String? dailyCourseIdFor(String specializationId, LawLesson lesson) {
    final LawSpecialization? spec = LawCatalog.byId(specializationId);
    if (spec == null) return null;
    for (final LawCourse c in spec.courses) {
      for (final LawLesson l in c.lessons) {
        if (l.id == lesson.id) return c.id;
      }
    }
    return spec.courses.isEmpty ? null : spec.courses.first.id;
  }

  bool isDailyCompleted(String specializationId, [DateTime? when]) =>
      _completedKeys.contains(completionKey(specializationId, when));

  Future<void> markDailyCompleted(String specializationId, [DateTime? when]) async {
    await ensureLoaded();
    final String key = completionKey(specializationId, when);
    if (_completedKeys.contains(key)) return;
    _completedKeys.add(key);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompleted, _completedKeys.toList());
    notifyListeners();
  }
}
