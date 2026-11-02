import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/diagram_misconception_store.dart';
import '../../utils/gpa_predictor.dart';
import 'vu_v2_lesson_flow.dart';

/// Local persistence for VU V2 progress, enrollment, and campus extras.
class VuV2ProgressStore extends ChangeNotifier {
  VuV2ProgressStore();

  static const String _legacyKey = 'vu_v2_progress_v1';

  bool _loaded = false;
  String? _userId;
  final Set<String> enrolledDegreeIds = <String>{};
  final Set<String> completedLessonIds = <String>{};
  final Map<String, double> quizScores = <String, double>{};
  final Set<String> attendanceDays = <String>{};
  final Set<String> earnedCertificateIds = <String>{};
  final List<VuV2NotificationItem> notifications = <VuV2NotificationItem>[];
  final List<String> plannerSlots = <String>[];
  final List<String> skills = <String>[];

  /// lessonId → completed step keys (see [VuV2LessonFlowPlan.stepKey]).
  final Map<String, Set<String>> completedStepsByLessonId = <String, Set<String>>{};

  /// Misconception pair id → wrong-answer count (synced from [DiagramMisconceptionStore]).
  final Map<String, int> diagramMisconceptions = <String, int>{};

  /// Consecutive correct clears of diagram misconceptions (not login streak).
  int masteryClearStreak = 0;

  /// Total XP earned from gated lesson steps.
  int lessonXp = 0;

  int studyMinutes = 0;
  int streakDays = 0;
  bool isPremium = false;
  bool preferLightTheme = false;
  double gpaPlaceholder = 0;

  /// Predicted term GPA on a 4.0 letter scale from quiz performance.
  double get gpa {
    if (quizScores.isEmpty) return 0;
    return GpaPredictor.fromPercents(
      percents: quizScores.values.map((double v) => v.round()).toList(),
    ).predictedGpa;
  }

  String get gpaLabel => gpa.toStringAsFixed(2);

  String get _storageKey {
    final String? id = _userId;
    if (id == null || id.isEmpty) return _legacyKey;
    return '${_legacyKey}_$id';
  }

  Future<void> ensureLoaded({String? userId}) async {
    if (_loaded && _userId == userId) return;
    _loaded = true;
    _userId = userId;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_storageKey);
    if (raw == null && userId != null && userId.isNotEmpty) {
      raw = prefs.getString(_legacyKey);
      if (raw != null) {
        await prefs.setString(_storageKey, raw);
      }
    }
    if (raw == null) {
      _seedNotifications();
      notifyListeners();
      return;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      enrolledDegreeIds
        ..clear()
        ..addAll(((data['enrolled'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>());
      completedLessonIds
        ..clear()
        ..addAll(((data['lessons'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>());
      quizScores
        ..clear()
        ..addAll(
          ((data['quizzes'] as Map<String, dynamic>?) ?? <String, dynamic>{})
              .map((String k, dynamic v) => MapEntry(k, (v as num).toDouble())),
        );
      attendanceDays
        ..clear()
        ..addAll(((data['attendance'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>());
      earnedCertificateIds
        ..clear()
        ..addAll(((data['certs'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>());
      plannerSlots
        ..clear()
        ..addAll(((data['planner'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>());
      skills
        ..clear()
        ..addAll(((data['skills'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<String>());
      studyMinutes = (data['studyMinutes'] as num?)?.toInt() ?? 0;
      streakDays = (data['streakDays'] as num?)?.toInt() ?? 0;
      isPremium = data['isPremium'] as bool? ?? false;
      preferLightTheme = data['preferLightTheme'] as bool? ?? false;
      gpaPlaceholder = (data['gpa'] as num?)?.toDouble() ?? 0;
      lessonXp = (data['lessonXp'] as num?)?.toInt() ?? 0;
      masteryClearStreak = (data['masteryClearStreak'] as num?)?.toInt() ?? 0;
      completedStepsByLessonId
        ..clear()
        ..addAll(
          ((data['lessonSteps'] as Map<String, dynamic>?) ?? <String, dynamic>{})
              .map(
            (String k, dynamic v) => MapEntry(
              k,
              ((v as List<dynamic>?) ?? <dynamic>[])
                  .whereType<String>()
                  .toSet(),
            ),
          ),
        );
      notifications
        ..clear()
        ..addAll(
          ((data['notifications'] as List<dynamic>?) ?? <dynamic>[])
              .whereType<Map>()
              .map(
                (Map raw) => VuV2NotificationItem(
                  id: raw['id']?.toString() ?? '',
                  title: raw['title']?.toString() ?? '',
                  body: raw['body']?.toString() ?? '',
                  kind: raw['kind']?.toString() ?? 'tip',
                  read: raw['read'] as bool? ?? false,
                ),
              ),
        );
      if (notifications.isEmpty) _seedNotifications();
      diagramMisconceptions
        ..clear()
        ..addAll(
          ((data['diagramMisconceptions'] as Map<String, dynamic>?) ?? <String, dynamic>{})
              .map((String k, dynamic v) => MapEntry(k, (v as num).toInt())),
        );
      await syncDiagramMisconceptions();
    } catch (_) {
      _seedNotifications();
    }
    notifyListeners();
  }

  Future<void> syncDiagramMisconceptions() async {
    await DiagramMisconceptionStore.instance.ensureLoaded();
    diagramMisconceptions
      ..clear()
      ..addAll(DiagramMisconceptionStore.instance.exportCounts());
  }

  Future<void> recordDiagramConfusion({
    required String diagramId,
    required String tappedRegionId,
    required String targetRegionId,
  }) async {
    await DiagramMisconceptionStore.instance.recordConfusion(
      diagramId: diagramId,
      tappedRegionId: tappedRegionId,
      targetRegionId: targetRegionId,
    );
    await syncDiagramMisconceptions();
    notifyListeners();
  }

  List<String> get topDiagramMisconceptions {
    final List<MapEntry<String, int>> sorted = diagramMisconceptions.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
    return sorted.map((MapEntry<String, int> e) => e.key).take(5).toList(growable: false);
  }

  /// Misconceptions at or above the adaptive re-teach threshold.
  int get dueAdaptiveReviews {
    return diagramMisconceptions.values
        .where((int c) => c >= DiagramMisconceptionStore.reviewThreshold)
        .length;
  }

  Future<void> recordMisconceptionCleared(String misconceptionId) async {
    await DiagramMisconceptionStore.instance.markReviewed(misconceptionId);
    await syncDiagramMisconceptions();
    masteryClearStreak += 1;
    lessonXp += 15;
    if (!skills.contains('Spatial anatomist')) {
      skills.add('Spatial anatomist');
    }
    await _persist();
    notifyListeners();
  }

  void _seedNotifications() {
    if (notifications.isNotEmpty) return;
    notifications.addAll(<VuV2NotificationItem>[
      const VuV2NotificationItem(
        id: 'n1',
        title: 'Welcome to campus',
        body: 'Meet your AI Professor from any lesson hub.',
        kind: 'tip',
      ),
      const VuV2NotificationItem(
        id: 'n2',
        title: 'Quiz reminder',
        body: 'Finish a topic quiz to lock in what you learned.',
        kind: 'tip',
      ),
      const VuV2NotificationItem(
        id: 'n3',
        title: 'Exam coming up',
        body: 'Semester exam unlocks after course modules.',
        kind: 'exam',
      ),
    ]);
  }

  Future<void> enroll(String degreeId) async {
    enrolledDegreeIds.add(degreeId);
    await _persist();
    notifyListeners();
  }

  Future<void> keepOnlyEnrolled(String degreeId) async {
    if (degreeId.isEmpty) return;
    if (enrolledDegreeIds.length == 1 && enrolledDegreeIds.contains(degreeId)) {
      return;
    }
    enrolledDegreeIds
      ..clear()
      ..add(degreeId);
    await _persist();
    notifyListeners();
  }

  /// Enroll every program id so Lecture Halls open without per-program gates.
  Future<void> enrollAll(Iterable<String> degreeIds) async {
    var changed = false;
    for (final String id in degreeIds) {
      if (id.isEmpty) continue;
      if (enrolledDegreeIds.add(id)) changed = true;
    }
    if (!changed) return;
    await _persist();
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId, {int minutes = 12}) async {
    completedLessonIds.add(lessonId);
    studyMinutes += minutes;
    _markAttendanceToday();
    _bumpStreak();
    if (!skills.contains('Active learner')) {
      skills.add('Active learner');
    }
    await pushNotification(
      id: 'lesson_$lessonId',
      title: 'Skill mastered',
      body: 'Lecture, lab, and knowledge check are complete.',
      kind: 'achievement',
    );
    await _persist();
    notifyListeners();
  }

  /// Campus is fully open — no sequential course/lesson/step locks.
  static const bool unlockAllCourses = true;

  /// Whether [step] is done for this lesson.
  bool isStepComplete(String lessonId, VuV2LessonStep step) {
    return completedStepsByLessonId[lessonId]
            ?.contains(VuV2LessonFlowPlan.stepKey(step)) ??
        false;
  }

  /// First hub step is always unlocked; later steps need the previous one done.
  bool isStepUnlocked(
    String lessonId,
    VuV2LessonStep step, {
    List<VuV2LessonStep>? steps,
  }) {
    if (unlockAllCourses) return true;
    final List<VuV2LessonStep> ordered =
        steps ?? VuV2LessonFlowPlan.hubSteps;
    final int i = ordered.indexOf(step);
    if (i <= 0) return true;
    return isStepComplete(lessonId, ordered[i - 1]);
  }

  /// Next incomplete unlocked step, or null when the hub journey is finished.
  VuV2LessonStep? nextOpenStep(
    String lessonId, {
    List<VuV2LessonStep>? steps,
  }) {
    final List<VuV2LessonStep> ordered =
        steps ?? VuV2LessonFlowPlan.hubSteps;
    for (final VuV2LessonStep step in ordered) {
      if (!isStepComplete(lessonId, step) &&
          isStepUnlocked(lessonId, step, steps: ordered)) {
        return step;
      }
    }
    return null;
  }

  bool areAllHubStepsComplete(String lessonId) {
    for (final VuV2LessonStep step in VuV2LessonFlowPlan.hubSteps) {
      if (!isStepComplete(lessonId, step)) return false;
    }
    return true;
  }

  /// Lecture alone is not mastery. Professor + check (+ lab when required).
  bool meetsMastery(String lessonId, {bool requiresLab = true}) {
    for (final VuV2LessonStep step
        in VuV2LessonFlowPlan.masterySteps(requiresLab: requiresLab)) {
      if (!isStepComplete(lessonId, step)) return false;
    }
    return true;
  }

  /// Mark a flow step done, award XP, and complete the lesson at mastery.
  Future<bool> markStep(
    String lessonId,
    VuV2LessonStep step, {
    String? subjectId,
    String? topicTitle,
    bool requiresLab = true,
  }) async {
    final String key = VuV2LessonFlowPlan.stepKey(step);
    final Set<String> bucket =
        completedStepsByLessonId.putIfAbsent(lessonId, () => <String>{});
    final bool already = bucket.contains(key);
    if (!already) {
      bucket.add(key);
      lessonXp += VuV2LessonFlowPlan.xpFor(step);
      studyMinutes += 4;
      _markAttendanceToday();
    }

    final bool finished = meetsMastery(lessonId, requiresLab: requiresLab);
    if (finished && !completedLessonIds.contains(lessonId)) {
      completedLessonIds.add(lessonId);
      studyMinutes += 8;
      _bumpStreak();
      if (!skills.contains('Active learner')) {
        skills.add('Active learner');
      }
      lessonXp += 40; // completion bonus
      await pushNotification(
        id: 'lesson_flow_$lessonId',
        title: 'You can do this yourself',
        body:
            'You learned it from the professor, used it in the lab, and proved it.',
        kind: 'achievement',
      );
    }

    if (already && !finished) {
      notifyListeners();
      return false;
    }

    await _persist();
    notifyListeners();
    return finished;
  }

  /// Course lessons unlock in order: first always open; later need prior complete.
  bool isLessonUnlocked(String lessonId, List<String> orderedLessonIds) {
    if (unlockAllCourses) return true;
    if (orderedLessonIds.isEmpty) return true;
    final int i = orderedLessonIds.indexOf(lessonId);
    if (i <= 0) return true;
    return completedLessonIds.contains(orderedLessonIds[i - 1]);
  }

  Future<void> recordQuiz(String quizId, double percent) async {
    quizScores[quizId] = percent;
    gpaPlaceholder = gpa;
    studyMinutes += 8;
    _markAttendanceToday();
    await _persist();
    notifyListeners();
  }

  Future<void> awardCertificate(String courseId) async {
    earnedCertificateIds.add(courseId);
    await pushNotification(
      id: 'cert_$courseId',
      title: 'Certificate unlocked',
      body: 'Open Graduation Hall to view your certificate.',
      kind: 'achievement',
    );
    await _persist();
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    isPremium = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setPreferLightTheme(bool value) async {
    preferLightTheme = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setPlannerSlots(List<String> slots) async {
    plannerSlots
      ..clear()
      ..addAll(slots);
    await _persist();
    notifyListeners();
  }

  Future<void> pushNotification({
    required String id,
    required String title,
    required String body,
    required String kind,
  }) async {
    notifications.removeWhere((VuV2NotificationItem n) => n.id == id);
    notifications.insert(
      0,
      VuV2NotificationItem(
        id: id,
        title: title,
        body: body,
        kind: kind,
      ),
    );
    if (notifications.length > 40) {
      notifications.removeRange(40, notifications.length);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> markNotificationRead(String id) async {
    final int i = notifications.indexWhere((VuV2NotificationItem n) => n.id == id);
    if (i < 0) return;
    notifications[i] = notifications[i].copyWith(read: true);
    await _persist();
    notifyListeners();
  }

  int get unreadCount =>
      notifications.where((VuV2NotificationItem n) => !n.read).length;

  double courseProgress({
    required String courseId,
    required List<String> lessonIds,
  }) {
    if (lessonIds.isEmpty) return 0;
    final int done =
        lessonIds.where(completedLessonIds.contains).length;
    return done / lessonIds.length;
  }

  double degreeProgress({
    required List<String> lessonIds,
  }) {
    if (lessonIds.isEmpty) return 0;
    final int done =
        lessonIds.where(completedLessonIds.contains).length;
    return done / lessonIds.length;
  }

  void _markAttendanceToday() {
    final String day = DateTime.now().toIso8601String().substring(0, 10);
    attendanceDays.add(day);
  }

  void _bumpStreak() {
    streakDays = attendanceDays.isEmpty ? 1 : attendanceDays.length.clamp(1, 365);
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'enrolled': enrolledDegreeIds.toList(),
        'lessons': completedLessonIds.toList(),
        'quizzes': quizScores,
        'attendance': attendanceDays.toList(),
        'certs': earnedCertificateIds.toList(),
        'planner': plannerSlots,
        'skills': skills,
        'studyMinutes': studyMinutes,
        'streakDays': streakDays,
        'isPremium': isPremium,
        'preferLightTheme': preferLightTheme,
        'gpa': gpa,
        'lessonXp': lessonXp,
        'masteryClearStreak': masteryClearStreak,
        'lessonSteps': completedStepsByLessonId.map(
          (String k, Set<String> v) => MapEntry(k, v.toList()),
        ),
        'diagramMisconceptions': diagramMisconceptions,
        'notifications': notifications
            .map(
              (VuV2NotificationItem n) => <String, dynamic>{
                'id': n.id,
                'title': n.title,
                'body': n.body,
                'kind': n.kind,
                'read': n.read,
              },
            )
            .toList(),
      }),
    );
  }
}

class VuV2NotificationItem {
  const VuV2NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final String kind;
  final bool read;

  VuV2NotificationItem copyWith({bool? read}) {
    return VuV2NotificationItem(
      id: id,
      title: title,
      body: body,
      kind: kind,
      read: read ?? this.read,
    );
  }
}
