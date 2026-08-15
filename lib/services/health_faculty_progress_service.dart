import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/virtual_university_lesson_contract.dart';

/// Local progress for Nursing / Medicine / Psychology Virtual University programs.
class HealthFacultyProgressService extends ChangeNotifier {
  static const String _storageKey = 'health_faculty_progress_v1';

  static const List<String> requiredActivityNames = <String>[
    'aiProfessor',
    'interactiveOrVideo',
    'practiceOrHomework',
    'quizOrExam',
  ];

  static const int _xpPerActivity = 20;

  final Map<String, Set<String>> _completed = <String, Set<String>>{};
  final Set<String> _certificates = <String>{};
  int _xp = 0;
  bool _loaded = false;

  int get xp => _xp;
  Set<String> get certificates => Set<String>.unmodifiable(_certificates);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
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
    } catch (_) {
      // Ignore corrupt local progress.
    }
    notifyListeners();
  }

  bool isComplete(String topicId, String activityName) =>
      _completed[topicId]?.contains(activityName) ?? false;

  bool hasCertificate(String topicId) => _certificates.contains(topicId);

  Set<String> completedActivityNames(String topicId) =>
      Set<String>.unmodifiable(_completed[topicId] ?? const <String>{});

  /// Fraction of the four required VU activities completed for [topicId].
  double lessonProgress(String topicId) {
    var earned = 0;
    for (final String name in requiredActivityNames) {
      if (isComplete(topicId, name)) earned += 1;
    }
    return earned / requiredActivityNames.length;
  }

  Future<void> complete(String topicId, String activityName) async {
    final Set<String> set = _completed.putIfAbsent(topicId, () => <String>{});
    if (!set.add(activityName)) {
      notifyListeners();
      await _persist();
      return;
    }

    final bool countsTowardMastery = requiredActivityNames.contains(
      activityName,
    );
    if (countsTowardMastery) {
      _xp += _xpPerActivity;
    }

    if (lessonProgress(topicId) >= 1) {
      _certificates.add(topicId);
    }

    notifyListeners();
    await _persist();
  }

  Future<void> completeCanonical(
    String topicId,
    VuCanonicalActivity activity,
  ) => complete(topicId, activity.name);

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'xp': _xp,
        'certificates': _certificates.toList(),
        'activities': _completed.map(
          (String key, Set<String> value) =>
              MapEntry<String, dynamic>(key, value.toList()),
        ),
      }),
    );
  }
}
