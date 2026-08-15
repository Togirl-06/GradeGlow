import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for VU V2 progress, enrollment, and campus extras.
class VuV2ProgressStore extends ChangeNotifier {
  VuV2ProgressStore();

  static const String _key = 'vu_v2_progress_v1';

  bool _loaded = false;
  final Set<String> enrolledDegreeIds = <String>{};
  final Set<String> completedLessonIds = <String>{};
  final Map<String, double> quizScores = <String, double>{};
  final Set<String> attendanceDays = <String>{};
  final Set<String> earnedCertificateIds = <String>{};
  final List<VuV2NotificationItem> notifications = <VuV2NotificationItem>[];
  final List<String> plannerSlots = <String>[];
  final List<String> skills = <String>[];

  int studyMinutes = 0;
  int streakDays = 0;
  bool isPremium = false;
  bool preferLightTheme = false;
  double gpaPlaceholder = 3.6;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
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
      gpaPlaceholder = (data['gpa'] as num?)?.toDouble() ?? 3.6;
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
    } catch (_) {
      _seedNotifications();
    }
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
      title: 'Lesson completed',
      body: 'Nice work — progress saved to your degree path.',
      kind: 'achievement',
    );
    await _persist();
    notifyListeners();
  }

  Future<void> recordQuiz(String quizId, double percent) async {
    quizScores[quizId] = percent;
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
      _key,
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
        'gpa': gpaPlaceholder,
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
