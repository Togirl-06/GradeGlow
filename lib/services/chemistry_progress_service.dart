import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/chemistry_degree_catalog.dart';
import '../models/chemistry_degree.dart';

/// Local mastery, XP, streak & activity completion for the Chemistry degree.
class ChemistryProgressService extends ChangeNotifier {
  static const String _storageKey = 'chem_degree_progress_v1';

  final Map<String, Set<String>> _completedActivities =
      <String, Set<String>>{};
  final Map<String, Set<String>> _usedQuestionHashes = <String, Set<String>>{};
  final Set<String> _passedExams = <String>{};
  int _examAttemptSeed = 0;
  int _xp = 0;
  int _streakDays = 0;
  String? _lastActiveDate;
  String? _currentLessonId;
  final Set<String> _earnedBadges = <String>{};
  double? _cachedDegreeMastery;

  int get xp => _xp;
  int get streakDays => _streakDays;
  Set<String> get earnedBadges => Set<String>.unmodifiable(_earnedBadges);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
      _streakDays = (data['streakDays'] as num?)?.toInt() ?? 0;
      _lastActiveDate = data['lastActiveDate'] as String?;
      _currentLessonId = data['currentLessonId'] as String?;

      final activities = data['activities'] as Map<String, dynamic>?;
      if (activities != null) {
        _completedActivities.clear();
        for (final entry in activities.entries) {
          final list = (entry.value as List<dynamic>).cast<String>();
          _completedActivities[entry.key] = list.toSet();
        }
      }

      final badges = data['badges'] as List<dynamic>?;
      if (badges != null) {
        _earnedBadges
          ..clear()
          ..addAll(badges.cast<String>());
      }

      final used = data['usedQuestions'] as Map<String, dynamic>?;
      if (used != null) {
        _usedQuestionHashes.clear();
        for (final entry in used.entries) {
          _usedQuestionHashes[entry.key] =
              (entry.value as List<dynamic>).cast<String>().toSet();
        }
      }

      final passed = data['passedExams'] as List<dynamic>?;
      if (passed != null) {
        _passedExams
          ..clear()
          ..addAll(passed.cast<String>());
      }

      _examAttemptSeed = (data['examAttemptSeed'] as num?)?.toInt() ?? 0;
    } catch (_) {
      // Corrupt storage — start fresh.
    }
    notifyListeners();
  }

  void _invalidateMasteryCache() {
    _cachedDegreeMastery = null;
  }

  @override
  void notifyListeners() {
    _invalidateMasteryCache();
    super.notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final activities = <String, List<String>>{};
    for (final entry in _completedActivities.entries) {
      activities[entry.key] = entry.value.toList();
    }
    final used = <String, List<String>>{};
    for (final entry in _usedQuestionHashes.entries) {
      used[entry.key] = entry.value.toList();
    }
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'xp': _xp,
        'streakDays': _streakDays,
        'lastActiveDate': _lastActiveDate,
        'currentLessonId': _currentLessonId,
        'activities': activities,
        'badges': _earnedBadges.toList(),
        'usedQuestions': used,
        'passedExams': _passedExams.toList(),
        'examAttemptSeed': _examAttemptSeed,
      }),
    );
  }

  void _touchStreak() {
    final today = _todayKey();
    if (_lastActiveDate == today) return;

    if (_lastActiveDate != null) {
      final last = DateTime.parse(_lastActiveDate!);
      final now = DateTime.parse(today);
      final diff = now.difference(last).inDays;
      if (diff == 1) {
        _streakDays += 1;
      } else if (diff > 1) {
        _streakDays = 1;
      }
    } else {
      _streakDays = 1;
    }
    _lastActiveDate = today;
  }

  String _todayKey() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toIso8601String();
  }

  Set<String> completedForLesson(String lessonId) {
    return Set<String>.from(_completedActivities[lessonId] ?? const <String>{});
  }

  Set<String> usedQuestionHashes(String lessonId) {
    return Set<String>.from(_usedQuestionHashes[lessonId] ?? const <String>{});
  }

  bool isExamPassed(String lessonId) => _passedExams.contains(lessonId);

  int nextExamAttemptSeed() => _examAttemptSeed++;

  Future<void> recordUsedQuestions(String lessonId, Iterable<String> hashes) async {
    final set = _usedQuestionHashes.putIfAbsent(lessonId, () => <String>{});
    final int before = set.length;
    set.addAll(hashes);
    if (set.length > before) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> markExamPassed(String lessonId) async {
    if (_passedExams.add(lessonId)) {
      notifyListeners();
      await _persist();
    }
  }

  bool isActivityComplete(String lessonId, ChemLessonActivityKind kind) {
    if (kind == ChemLessonActivityKind.exam) {
      return _passedExams.contains(lessonId);
    }
    return completedForLesson(lessonId).contains(kind.name);
  }

  double lessonMastery(String lessonId) {
    final done = completedForLesson(lessonId);
    if (done.isEmpty) return 0;

    final int max = ChemLessonActivityKind.activeFlowWeightTotal;
    if (max == 0) return 0;

    var earned = 0;
    for (final kind in ChemLessonActivityKind.activeLessonFlow) {
      if (isActivityComplete(lessonId, kind)) {
        earned += kind.masteryWeight;
      }
    }
    return (earned / max * 100).clamp(0, 100).toDouble();
  }

  bool isLessonMastered(String lessonId) {
    for (final kind in ChemLessonActivityKind.activeLessonFlow) {
      if (!isActivityComplete(lessonId, kind)) return false;
    }
    return true;
  }

  double courseMastery(ChemistryDegreeCourse course) {
    if (course.lessonCount == 0) return 0;
    var sum = 0.0;
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        sum += lessonMastery(lesson.id);
      }
    }
    return sum / course.lessonCount;
  }

  double yearMastery(ChemistryDegreeYear year) {
    var lessons = 0;
    var sum = 0.0;
    for (final course in year.courses) {
      for (final module in course.modules) {
        for (final lesson in module.lessons) {
          lessons += 1;
          sum += lessonMastery(lesson.id);
        }
      }
    }
    if (lessons == 0) return 0;
    return sum / lessons;
  }

  double get degreeMastery {
    if (_cachedDegreeMastery != null) return _cachedDegreeMastery!;
    final paths = ChemistryDegreeCatalog.allLessonPaths;
    if (paths.isEmpty) return 0;
    var sum = 0.0;
    for (final path in paths) {
      sum += lessonMastery(path.lesson.id);
    }
    return _cachedDegreeMastery = sum / paths.length;
  }

  ChemistryLessonPath currentPath() {
    if (_currentLessonId != null) {
      final resolved = ChemistryDegreeCatalog.resolveLesson(_currentLessonId!);
      if (resolved != null) return resolved;
    }
    return ChemistryDegreeCatalog.defaultLesson;
  }

  ChemistryLessonPath? nextIncompleteLesson() {
    for (final path in ChemistryDegreeCatalog.allLessonPaths) {
      if (!isLessonMastered(path.lesson.id)) return path;
    }
    return null;
  }

  String readinessLabel(ChemistryLessonPath path) {
    if (isLessonMastered(path.lesson.id)) return 'Mastered';
    final mastery = lessonMastery(path.lesson.id);
    if (mastery >= 70) return 'Exam ready';
    if (mastery >= 40) return 'Building fluency';
    if (mastery > 0) return 'In progress';
    return 'Not started';
  }

  Future<void> completeActivity(
    String lessonId,
    ChemLessonActivityKind kind,
  ) async {
    _touchStreak();
    _currentLessonId = lessonId;

    final set = _completedActivities.putIfAbsent(lessonId, () => <String>{});
    if (set.add(kind.name)) {
      _xp += kind.masteryWeight * 2;
      _maybeAwardBadge(lessonId);
      notifyListeners();
      await _persist();
    }
  }

  void _maybeAwardBadge(String lessonId) {
    final mastery = lessonMastery(lessonId);
    final path = ChemistryDegreeCatalog.resolveLesson(lessonId);
    if (path == null) return;

    if (isLessonMastered(lessonId)) {
      _earnedBadges.add('${path.lesson.id}_master');
    }

    if (path.course.id == 'general_chemistry' && path.lesson.title == 'Chemical Bonding') {
      if (mastery >= 70) _earnedBadges.add('bonding_master');
    }

    if (degreeMastery >= 25 && !_earnedBadges.contains('chem_catalog_quarter')) {
      _earnedBadges.add('chem_catalog_quarter');
    }
    if (degreeMastery >= 50 && !_earnedBadges.contains('chem_catalog_half')) {
      _earnedBadges.add('chem_catalog_half');
    }
    if (degreeMastery >= 100 && !_earnedBadges.contains('chem_explorer')) {
      _earnedBadges.add('chem_explorer');
    }
  }

  int assignmentsDueCount() {
    var due = 0;
    for (final path in ChemistryDegreeCatalog.allLessonPaths) {
      if (lessonMastery(path.lesson.id) > 0 &&
          lessonMastery(path.lesson.id) < 100 &&
          !isActivityComplete(path.lesson.id, ChemLessonActivityKind.quiz)) {
        due += 1;
      }
      if (due >= 5) break;
    }
    return due.clamp(0, 5);
  }
}

