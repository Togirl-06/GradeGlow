import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/business_school.dart';

class BusinessSchoolProgressService extends ChangeNotifier {
  static const String _storageKey = 'business_school_progress_v2';

  final Map<String, Set<String>> _completed = <String, Set<String>>{};
  final Set<String> _certificates = <String>{};
  final Set<String> _badges = <String>{};
  int _xp = 0;
  String? _currentLessonId;
  bool _loaded = false;

  int get xp => _xp;
  Set<String> get certificates => Set<String>.unmodifiable(_certificates);
  Set<String> get badges => Set<String>.unmodifiable(_badges);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
      _currentLessonId = data['currentLessonId'] as String?;
      final Map<String, dynamic>? activities =
          data['activities'] as Map<String, dynamic>?;
      if (activities != null) {
        for (final MapEntry<String, dynamic> entry in activities.entries) {
          _completed[entry.key] = (entry.value as List<dynamic>)
              .cast<String>()
              .toSet();
        }
      }
      _certificates.addAll(
        ((data['certificates'] as List<dynamic>?) ?? <dynamic>[])
            .cast<String>(),
      );
      _badges.addAll(
        ((data['badges'] as List<dynamic>?) ?? <dynamic>[]).cast<String>(),
      );
    } catch (_) {
      // Ignore corrupt local progress.
    }
    notifyListeners();
  }

  bool isComplete(String lessonId, BusinessActivityKind kind) =>
      _completed[lessonId]?.contains(kind.name) ?? false;

  bool hasCertificate(String lessonId) => _certificates.contains(lessonId);

  bool hasBadge(String lessonId, String badgeId) =>
      _badges.contains('$lessonId::$badgeId');

  List<String> badgesForLesson(String lessonId) => _badges
      .where((String b) => b.startsWith('$lessonId::'))
      .map((String b) => b.split('::').last)
      .toList();

  double lessonProgress(String lessonId, [BusinessMajor? major]) {
    var earned = 0;
    var total = 0;
    final List<BusinessActivityKind> required = businessRequiredActivities(
      major ?? BusinessMajor.economics,
    );
    for (final BusinessActivityKind kind in required) {
      total += kind.weight;
      if (isComplete(lessonId, kind)) earned += kind.weight;
    }
    return total == 0 ? 0 : earned / total;
  }

  double courseProgress(BusinessCourse course, [BusinessMajor? major]) {
    if (course.lessons.isEmpty) return 0;
    return course.lessons
            .map((BusinessLesson l) => lessonProgress(l.id, major))
            .reduce((double a, double b) => a + b) /
        course.lessons.length;
  }

  Future<void> complete(String lessonId, BusinessActivityKind kind) async {
    _currentLessonId = lessonId;
    if (businessActivityIsSupplemental(kind)) {
      notifyListeners();
      await _persist();
      return;
    }
    final Set<String> set = _completed.putIfAbsent(lessonId, () => <String>{});
    if (set.add(kind.name)) {
      _xp += kind.xp;
      _awardBadges(lessonId, kind);
      if (lessonProgress(lessonId) >= 1) {
        _certificates.add(lessonId);
        _badges.add('$lessonId::topic_master');
      }
      notifyListeners();
      await _persist();
    }
  }

  void _awardBadges(String lessonId, BusinessActivityKind kind) {
    switch (kind) {
      case BusinessActivityKind.professor:
        _badges.add('$lessonId::lecture_complete');
      case BusinessActivityKind.video:
        _badges.add('$lessonId::whiteboard_complete');
      case BusinessActivityKind.homework:
        _badges.add('$lessonId::homework_complete');
      case BusinessActivityKind.exam:
        _badges.add('$lessonId::exam_complete');
      default:
        break;
    }
  }

  String? get currentLessonId => _currentLessonId;

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'xp': _xp,
        'currentLessonId': _currentLessonId,
        'certificates': _certificates.toList(),
        'badges': _badges.toList(),
        'activities': _completed.map(
          (String key, Set<String> value) =>
              MapEntry<String, dynamic>(key, value.toList()),
        ),
      }),
    );
  }
}
