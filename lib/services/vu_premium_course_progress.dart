import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local progress for the premium course classroom experience.
class VuPremiumCourseProgress extends ChangeNotifier {
  VuPremiumCourseProgress({required this.courseId});

  final String courseId;

  static const String _prefix = 'vu_premium_course_v1_';

  final Set<String> _completedItemIds = <String>{};
  int _xp = 0;
  int _streakDays = 0;
  String? _lastActiveIso;
  String? _continueItemId;
  bool _loaded = false;

  Set<String> get completedItemIds => Set<String>.unmodifiable(_completedItemIds);
  int get xp => _xp;
  int get streakDays => _streakDays;
  String? get continueItemId => _continueItemId;

  String get _key => '$_prefix$courseId';

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
      _completedItemIds
        ..clear()
        ..addAll(
          ((data['completed'] as List<dynamic>?) ?? <dynamic>[])
              .whereType<String>(),
        );
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
      _streakDays = (data['streak'] as num?)?.toInt() ?? 0;
      _lastActiveIso = data['lastActive'] as String?;
      _continueItemId = data['continueId'] as String?;
      _refreshStreak();
    } catch (_) {}
    notifyListeners();
  }

  double progressFraction(int totalItems) {
    if (totalItems <= 0) return 0;
    return (_completedItemIds.length / totalItems).clamp(0.0, 1.0);
  }

  bool isComplete(String itemId) => _completedItemIds.contains(itemId);

  int completedIn(Iterable<String> ids) =>
      ids.where(_completedItemIds.contains).length;

  String letterGrade(double fraction) {
    if (fraction >= 0.93) return 'A';
    if (fraction >= 0.90) return 'A-';
    if (fraction >= 0.87) return 'B+';
    if (fraction >= 0.83) return 'B';
    if (fraction >= 0.80) return 'B-';
    if (fraction >= 0.77) return 'C+';
    if (fraction >= 0.70) return 'C';
    if (fraction >= 0.60) return 'D';
    if (fraction <= 0) return '—';
    return 'F';
  }

  Future<void> setContinue(String itemId) async {
    await ensureLoaded();
    _continueItemId = itemId;
    _touchActive();
    await _persist();
    notifyListeners();
  }

  Future<void> completeItem(String itemId, {int xpReward = 40}) async {
    await ensureLoaded();
    final bool wasDone = _completedItemIds.contains(itemId);
    _completedItemIds.add(itemId);
    if (!wasDone) _xp += xpReward;
    _continueItemId = itemId;
    _touchActive();
    await _persist();
    notifyListeners();
  }

  void _touchActive() {
    final DateTime now = DateTime.now();
    final String today = _dayKey(now);
    if (_lastActiveIso == null) {
      _streakDays = 1;
    } else {
      final DateTime? last = DateTime.tryParse(_lastActiveIso!);
      if (last != null) {
        final String lastDay = _dayKey(last);
        if (lastDay != today) {
          final DateTime yesterday = now.subtract(const Duration(days: 1));
          if (_dayKey(yesterday) == lastDay) {
            _streakDays += 1;
          } else {
            _streakDays = 1;
          }
        }
      }
    }
    _lastActiveIso = now.toIso8601String();
  }

  void _refreshStreak() {
    if (_lastActiveIso == null) return;
    final DateTime? last = DateTime.tryParse(_lastActiveIso!);
    if (last == null) return;
    final DateTime now = DateTime.now();
    final int gap = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    if (gap > 1) _streakDays = 0;
  }

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'completed': _completedItemIds.toList(),
        'xp': _xp,
        'streak': _streakDays,
        'lastActive': _lastActiveIso,
        'continueId': _continueItemId,
      }),
    );
  }
}
