import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/business_school_catalog.dart';
import '../models/business_school.dart';
import '../models/practice_lab.dart';
import '../models/virtual_university_dashboard.dart';
import '../utils/practice_lab_game_stats.dart';
import 'business_school_progress_service.dart';

/// Aggregates faculty progress into a campus dashboard read model.
///
/// Persists lightweight VU prefs (continue list, study minutes, last active).
/// Adapts [BusinessSchoolProgressService] and [PracticeLabGameStats] when wired.
class VirtualUniversityDashboardService extends ChangeNotifier {
  VirtualUniversityDashboardService({BusinessSchoolProgressService? business})
    : _business = business;

  static const String _storageKey = 'vu_dashboard_prefs_v1';
  static const int defaultWeeklyGoal = 5;
  static const int _maxContinueItems = 12;
  static const int _certificateProgressCap = 10;

  BusinessSchoolProgressService? _business;
  List<PracticeLabRecord> _labRecords = <PracticeLabRecord>[];

  List<VuContinueItem> _continueItems = <VuContinueItem>[];
  final Map<String, int> _studyMinutesByDay = <String, int>{};
  String? _lastActiveIso;
  bool _loaded = false;

  List<VuContinueItem> get continueItems =>
      List<VuContinueItem>.unmodifiable(_continueItems);

  Map<String, int> get studyMinutesByDay =>
      Map<String, int>.unmodifiable(_studyMinutesByDay);

  String? get lastActiveIso => _lastActiveIso;

  void setBusiness(BusinessSchoolProgressService? business) {
    _business = business;
    notifyListeners();
  }

  void setLabRecords(List<PracticeLabRecord> records) {
    _labRecords = List<PracticeLabRecord>.from(records);
    notifyListeners();
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) {
      notifyListeners();
      return;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      final List<dynamic> continueRaw =
          (data['lastContinue'] as List<dynamic>?) ?? <dynamic>[];
      _continueItems = continueRaw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> m) =>
                VuContinueItem.fromJson(Map<String, dynamic>.from(m)),
          )
          .where(_isRealContinueItem)
          .toList();
      final Map<String, dynamic>? minutesRaw =
          data['studyMinutesByDay'] as Map<String, dynamic>?;
      _studyMinutesByDay
        ..clear()
        ..addAll(
          minutesRaw?.map(
                (String key, dynamic value) =>
                    MapEntry<String, int>(key, (value as num?)?.toInt() ?? 0),
              ) ??
              <String, int>{},
        );
      _lastActiveIso = data['lastActiveIso'] as String?;
      // Drop legacy "Open Chemistry" faculty-open stubs from older builds.
      if (continueRaw.length != _continueItems.length) {
        await _persist();
      }
    } catch (_) {
      // Ignore corrupt local prefs.
    }
    notifyListeners();
  }

  Future<void> recordContinue({
    required String subjectId,
    required String subjectName,
    required String courseTitle,
    required String lessonTitle,
    required String routeHint,
    required double progress,
  }) async {
    await load();
    final VuContinueItem item = VuContinueItem(
      subjectId: subjectId,
      subjectName: subjectName,
      courseTitle: courseTitle,
      lessonTitle: lessonTitle,
      routeHint: routeHint,
      progress: progress.clamp(0.0, 1.0),
    );
    _continueItems.removeWhere(
      (VuContinueItem e) =>
          e.subjectId == subjectId &&
          e.courseTitle == courseTitle &&
          e.lessonTitle == lessonTitle,
    );
    _continueItems.insert(0, item);
    if (_continueItems.length > _maxContinueItems) {
      _continueItems = _continueItems.sublist(0, _maxContinueItems);
    }
    _touchActiveDay();
    await _persist();
    notifyListeners();
  }

  Future<void> recordStudyMinutes(int minutes) async {
    if (minutes <= 0) return;
    await load();
    final String dayKey = _dayKey(DateTime.now());
    _studyMinutesByDay[dayKey] = (_studyMinutesByDay[dayKey] ?? 0) + minutes;
    _touchActiveDay();
    await _persist();
    notifyListeners();
  }

  /// Builds a dashboard snapshot from local prefs + optional faculty adapters.
  Future<VuDashboardSnapshot> snapshot({String welcomeName = 'Student'}) async {
    await load();
    final BusinessSchoolProgressService? business = _business;
    if (business != null) {
      await business.load();
    }

    final PracticeLabGameStats? labStats = _labRecords.isEmpty
        ? null
        : PracticeLabGameStats.fromRecords(_labRecords);

    final List<VuCertificateItem> certificates = _certificatesFromBusiness(
      business,
    );
    final List<VuAchievementItem> achievements = _achievementsFromBusiness(
      business,
    );

    final List<VuContinueItem> continues = _continueItems
        .where(_isRealContinueItem)
        .toList();
    final List<VuCourseProgressItem> currentCourses = _currentCoursesFrom(
      continues,
    );
    final List<VuContinueItem> recentlyCompleted = continues
        .where((VuContinueItem e) => e.progress >= 1.0)
        .toList();

    final int streakDays = labStats?.streakDays ?? _streakFromLocalActivity();
    final int weeklyGoal = defaultWeeklyGoal;
    final int weeklyCompleted =
        labStats?.weeklyLabs ?? _studyDaysCompletedThisWeek();

    final int totalXp = (business?.xp ?? 0) + (labStats?.totalXp ?? 0);

    final double overallProgress = _overallProgress(
      continues: continues,
      certificateCount: certificates.length,
    );

    final List<String> upcomingLessons = continues
        .where((VuContinueItem e) => e.progress < 1.0)
        .map((VuContinueItem e) => e.lessonTitle)
        .take(5)
        .toList();

    final List<String> recommendations = _buildRecommendations(
      continues: continues,
      certificates: certificates,
      labStats: labStats,
    );

    return VuDashboardSnapshot(
      welcomeName: welcomeName.trim().isEmpty ? 'Student' : welcomeName.trim(),
      continueItems: continues,
      currentCourses: currentCourses,
      streakDays: streakDays,
      weeklyGoal: weeklyGoal,
      weeklyCompleted: weeklyCompleted,
      dailyStudyMinutes: _studyMinutesByDay[_dayKey(DateTime.now())] ?? 0,
      upcomingLessons: upcomingLessons,
      recommendations: recommendations,
      recentlyCompleted: recentlyCompleted,
      certificates: certificates,
      achievements: achievements,
      overallProgress: overallProgress,
      totalXp: totalXp,
    );
  }

  List<VuCertificateItem> _certificatesFromBusiness(
    BusinessSchoolProgressService? business,
  ) {
    if (business == null) return const <VuCertificateItem>[];
    final List<VuCertificateItem> out = <VuCertificateItem>[];
    for (final String lessonId in business.certificates) {
      final BusinessLessonPath? path = _findBusinessLesson(lessonId);
      out.add(
        VuCertificateItem(
          id: lessonId,
          title: path?.lesson.title ?? lessonId,
          subjectName: path?.major.title ?? 'Business',
          badgeIds: business.badgesForLesson(lessonId),
        ),
      );
    }
    return out;
  }

  List<VuAchievementItem> _achievementsFromBusiness(
    BusinessSchoolProgressService? business,
  ) {
    if (business == null) return const <VuAchievementItem>[];
    final List<VuAchievementItem> out = <VuAchievementItem>[];
    for (final String badge in business.badges) {
      final List<String> parts = badge.split('::');
      final String lessonId = parts.isNotEmpty ? parts.first : badge;
      final String badgeId = parts.length > 1 ? parts.last : badge;
      final BusinessLessonPath? path = _findBusinessLesson(lessonId);
      out.add(
        VuAchievementItem(
          id: badge,
          title: _humanizeBadge(badgeId),
          subtitle: path == null
              ? 'Business School'
              : '${path.major.title} · ${path.lesson.title}',
        ),
      );
    }
    return out;
  }

  BusinessLessonPath? _findBusinessLesson(String lessonId) {
    for (final BusinessMajor major in BusinessMajor.values) {
      for (final BusinessLessonPath path in BusinessSchoolCatalog.pathsFor(
        major,
      )) {
        if (path.lesson.id == lessonId) return path;
      }
    }
    return null;
  }

  List<VuCourseProgressItem> _currentCoursesFrom(
    List<VuContinueItem> continues,
  ) {
    final Map<String, VuCourseProgressItem> byCourse =
        <String, VuCourseProgressItem>{};
    for (final VuContinueItem item in continues) {
      final String key = '${item.subjectId}::${item.courseTitle}';
      final VuCourseProgressItem? existing = byCourse[key];
      if (existing == null || item.progress > existing.progress) {
        byCourse[key] = VuCourseProgressItem(
          subjectId: item.subjectId,
          subjectName: item.subjectName,
          courseTitle: item.courseTitle,
          progress: item.progress,
        );
      }
    }
    return byCourse.values.toList();
  }

  double _overallProgress({
    required List<VuContinueItem> continues,
    required int certificateCount,
  }) {
    if (continues.isNotEmpty) {
      final double sum = continues.fold<double>(
        0,
        (double acc, VuContinueItem e) => acc + e.progress,
      );
      return (sum / continues.length).clamp(0.0, 1.0);
    }
    return (certificateCount / _certificateProgressCap).clamp(0.0, 1.0);
  }

  int _streakFromLocalActivity() {
    final Set<DateTime> days = <DateTime>{};
    for (final String key in _studyMinutesByDay.keys) {
      final DateTime? parsed = DateTime.tryParse(key);
      if (parsed != null) {
        days.add(DateTime(parsed.year, parsed.month, parsed.day));
      }
    }
    if (_lastActiveIso != null) {
      final DateTime? last = DateTime.tryParse(_lastActiveIso!);
      if (last != null) {
        days.add(DateTime(last.year, last.month, last.day));
      }
    }
    if (days.isEmpty) return 0;

    final List<DateTime> sorted = days.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final int gapFromToday = todayDate.difference(sorted.first).inDays;
    if (gapFromToday > 1) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i - 1].difference(sorted[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _studyDaysCompletedThisWeek() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime weekStart = today.subtract(
      Duration(days: today.weekday - 1),
    );
    int count = 0;
    for (final MapEntry<String, int> entry in _studyMinutesByDay.entries) {
      if (entry.value <= 0) continue;
      final DateTime? day = DateTime.tryParse(entry.key);
      if (day == null) continue;
      final DateTime d = DateTime(day.year, day.month, day.day);
      if (!d.isBefore(weekStart) && !d.isAfter(today)) {
        count++;
      }
    }
    return count;
  }

  List<String> _buildRecommendations({
    required List<VuContinueItem> continues,
    required List<VuCertificateItem> certificates,
    required PracticeLabGameStats? labStats,
  }) {
    final List<String> tips = <String>[];
    VuContinueItem? next;
    for (final VuContinueItem item in continues) {
      if (item.progress < 1.0) {
        next = item;
        break;
      }
    }
    if (next != null) {
      tips.add('Continue ${next.lessonTitle} in ${next.subjectName}');
    } else {
      tips.add('Browse a faculty and start your next lesson');
    }
    if ((labStats?.weeklyLabs ?? 0) < defaultWeeklyGoal) {
      tips.add('Complete a practice lab to hit your weekly goal');
    }
    if (certificates.isEmpty) {
      tips.add('Finish a Business topic exam to earn your first certificate');
    } else {
      tips.add('Review your certificates wall and unlock the next badge');
    }
    return tips.take(3).toList();
  }

  void _touchActiveDay() {
    _lastActiveIso = DateTime.now().toIso8601String();
  }

  /// Legacy faculty-open stubs looked like "Open Chemistry" at ~5% progress.
  static bool _isRealContinueItem(VuContinueItem item) {
    final String title = item.lessonTitle.trim().toLowerCase();
    if (title.startsWith('open ') && item.progress <= 0.06) return false;
    return title.isNotEmpty;
  }

  String _dayKey(DateTime dt) {
    final String m = dt.month.toString().padLeft(2, '0');
    final String d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  String _humanizeBadge(String badgeId) {
    return badgeId
        .split('_')
        .where((String p) => p.isNotEmpty)
        .map(
          (String p) =>
              '${p[0].toUpperCase()}${p.length > 1 ? p.substring(1) : ''}',
        )
        .join(' ');
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'lastContinue': _continueItems
            .map((VuContinueItem e) => e.toJson())
            .toList(),
        'studyMinutesByDay': _studyMinutesByDay,
        'lastActiveIso': _lastActiveIso,
      }),
    );
  }
}
