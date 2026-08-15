import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/physics_degree_catalog.dart';
import '../models/physics/physics_program.dart';
import '../models/physics_degree.dart';

/// Local mastery, XP, streak & activity completion for the Physics faculty.
class PhysicsProgressService extends ChangeNotifier {
  static const String _storageKey = 'phys_degree_progress_v1';

  final Map<String, Set<String>> _completedActivities =
      <String, Set<String>>{};
  int _xp = 0;
  int _streakDays = 0;
  String? _lastActiveDate;
  String? _currentTopicId;
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
      _currentTopicId = data['currentTopicId'] as String?;

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
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'xp': _xp,
        'streakDays': _streakDays,
        'lastActiveDate': _lastActiveDate,
        'currentTopicId': _currentTopicId,
        'activities': activities,
        'badges': _earnedBadges.toList(),
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

  Set<String> completedForTopic(String topicId) {
    return Set<String>.from(_completedActivities[topicId] ?? const <String>{});
  }

  bool isActivityComplete(String topicId, PhysLessonActivityKind kind) {
    return completedForTopic(topicId).contains(kind.name);
  }

  double lessonMastery(String topicId) {
    if (completedForTopic(topicId).isEmpty) return 0;

    final int max = PhysLessonActivityKind.activeFlowWeightTotal;
    if (max == 0) return 0;

    var earned = 0;
    for (final kind in PhysLessonActivityKind.activeLessonFlow) {
      if (isActivityComplete(topicId, kind)) {
        earned += kind.masteryWeight;
      }
    }
    return (earned / max * 100).clamp(0, 100).toDouble();
  }

  bool isLessonMastered(String topicId) {
    for (final kind in PhysLessonActivityKind.activeLessonFlow) {
      if (!isActivityComplete(topicId, kind)) return false;
    }
    return true;
  }

  double courseMastery(PhysicsCourse course) {
    if (course.topics.isEmpty) return 0;
    var sum = 0.0;
    for (final PhysicsTopic topic in course.topics) {
      sum += lessonMastery(topic.id);
    }
    return sum / course.topics.length;
  }

  double levelMastery(PhysicsLevel level) {
    final List<PhysicsCourseRef> courses = PhysicsDegreeCatalog.coursesForLevel(level);
    if (courses.isEmpty) return 0;
    var sum = 0.0;
    var count = 0;
    for (final PhysicsCourseRef ref in courses) {
      sum += courseMastery(ref.course);
      count += 1;
    }
    return sum / count;
  }

  double get degreeMastery {
    if (_cachedDegreeMastery != null) return _cachedDegreeMastery!;
    final paths = PhysicsDegreeCatalog.allLessonPaths;
    if (paths.isEmpty) return 0;
    var sum = 0.0;
    for (final path in paths) {
      sum += lessonMastery(path.topic.id);
    }
    return _cachedDegreeMastery = sum / paths.length;
  }

  PhysicsLessonPath currentPath() {
    if (_currentTopicId != null) {
      final resolved = PhysicsDegreeCatalog.resolveTopic(_currentTopicId!);
      if (resolved != null) return resolved;
    }
    return PhysicsDegreeCatalog.defaultLesson;
  }

  String readinessLabel(PhysicsLessonPath path) {
    if (isLessonMastered(path.topic.id)) return 'Mastered';
    final mastery = lessonMastery(path.topic.id);
    if (mastery >= 70) return 'Research ready';
    if (mastery >= 40) return 'Building fluency';
    if (mastery > 0) return 'In progress';
    return 'Not started';
  }

  Future<void> completeActivity(
    String topicId,
    PhysLessonActivityKind kind,
  ) async {
    _touchStreak();
    _currentTopicId = topicId;

    final set = _completedActivities.putIfAbsent(topicId, () => <String>{});
    if (set.add(kind.name)) {
      _xp += kind.masteryWeight * 2;
      _maybeAwardBadge(topicId);
      notifyListeners();
      await _persist();
    }
  }

  void _maybeAwardBadge(String topicId) {
    final path = PhysicsDegreeCatalog.resolveTopic(topicId);
    if (path == null) return;

    if (isLessonMastered(topicId)) {
      _earnedBadges.add('${path.topic.id}_master');
    }

    if (path.course.id == 'intro_physics' && path.topic.title.contains('Newton')) {
      if (lessonMastery(topicId) >= 70) _earnedBadges.add('newton_master');
    }

    if (degreeMastery >= 25 && !_earnedBadges.contains('phys_catalog_quarter')) {
      _earnedBadges.add('phys_catalog_quarter');
    }
    if (degreeMastery >= 50 && !_earnedBadges.contains('phys_catalog_half')) {
      _earnedBadges.add('phys_catalog_half');
    }
    if (degreeMastery >= 100 && !_earnedBadges.contains('phys_explorer')) {
      _earnedBadges.add('phys_explorer');
    }
  }

  int assignmentsDueCount() {
    var due = 0;
    for (final path in PhysicsDegreeCatalog.allLessonPaths) {
      if (lessonMastery(path.topic.id) > 0 &&
          lessonMastery(path.topic.id) < 100 &&
          !isActivityComplete(path.topic.id, PhysLessonActivityKind.quiz)) {
        due += 1;
      }
      if (due >= 5) break;
    }
    return due.clamp(0, 5);
  }
}
