import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/account_deletion_status.dart';
import '../models/course_schedule.dart';
import '../models/parsed_question.dart';
import '../models/study_progress.dart';
import '../models/user_profile.dart';
import 'class_notification_service.dart';
import '../utils/apple_auth.dart';
import '../utils/gamification.dart';
import '../utils/study_limits.dart';
import '../utils/tutor_limits.dart';
import '../models/subscription_plan.dart';
import 'auth_service.dart';
import 'account_deletion_service.dart';

class UserService extends ChangeNotifier {
  UserService(this._auth);

  final AuthService _auth;
  UserProfile? _demoProfile;
  int _demoTutorMediaCount = 0;
  String _demoTutorMediaDate = '';
  int _demoSummarizeCount = 0;
  String _demoSummarizeDate = '';
  TutorMediaUsage? _tutorUsageCache;
  SummarizeDailyUsage? _summarizeUsageCache;
  TutorMediaUsage? get tutorUsage => _tutorUsageCache;
  SummarizeDailyUsage? get summarizeUsage => _summarizeUsageCache;

  UserProfile get _demoCurrent =>
      _demoProfile ?? UserProfile.empty(email: _auth.email, displayName: _auth.displayName);

  void _patchDemo(UserProfile Function(UserProfile current) patch) {
    _demoProfile = patch(_demoCurrent);
    notifyListeners();
  }

  Stream<UserProfile> watchProfile() {
    final String? uid = _auth.uid;
    if (uid == null) {
      return Stream<UserProfile>.value(UserProfile.empty(email: ''));
    }

    if (_auth.isDemoMode) {
      _demoProfile ??= UserProfile.empty(email: _auth.email, displayName: _auth.displayName);
      return Stream<UserProfile>.multi((StreamController<UserProfile> controller) {
        void emit() => controller.add(_demoProfile!);
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map(
          (DocumentSnapshot<Map<String, dynamic>> snapshot) => UserProfile.fromMap(
            snapshot.data(),
            email: _auth.email,
            displayName: _auth.displayName,
          ),
        );
  }

  Future<void> ensureUserDocument() async {
    final String? uid = _auth.uid;
    if (uid == null || _auth.isDemoMode || !AppConfig.hasFirebase) return;

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    if (!doc.exists) {
      await ref.set(<String, dynamic>{
        'displayName': _auth.displayName,
        'email': _auth.email,
        'isEduVerified': _eduVerifiedStatus(),
        'school': '',
        'major': '',
        'year': '',
        'courseIds': <String>[],
        'anonymousByDefault': false,
        'gpa': 0,
        'streakDays': 0,
        'solutionsCount': 0,
        'verifiedSolver': false,
        'xp': 0,
        'badges': <String>[],
        'weakTopics': <String, dynamic>{},
        'trackedSemesters': <String>[],
        'courseSchedules': <String, dynamic>{},
        'studyProgress': StudyProgress.empty().toMap(),
        'plan': 'free',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return;
    }

    await ref.set(<String, dynamic>{
      'displayName': _auth.displayName,
      'email': _auth.email,
      'isEduVerified': _eduVerifiedStatus(),
    }, SetOptions(merge: true));
  }

  bool _eduVerifiedStatus() {
    if (!isEduEmail(_auth.email)) return false;
    return _auth.isEmailVerified;
  }

  Future<void> updateDisplayName(String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final String? uid = _auth.uid;
    if (uid == null) return;

    await _auth.updateDisplayName(trimmed);

    if (_auth.isDemoMode) {
      _patchDemo((UserProfile c) => c.copyWith(displayName: trimmed));
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{'displayName': trimmed},
      SetOptions(merge: true),
    );
  }

  Future<AccountDeletionStatus?> fetchDeletionStatus() async {
    final String? uid = _auth.uid;
    if (uid == null || _auth.isDemoMode || !AppConfig.hasFirebase) return null;

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return AccountDeletionStatus.fromMap(doc.data());
  }

  /// Schedules permanent deletion after the 30-day recovery window, then signs out.
  Future<void> scheduleAccountDeletion({String? password}) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to delete your account.');

    if (_auth.isDemoMode) {
      _demoProfile = null;
      await _auth.signOut();
      return;
    }

    await _auth.reauthenticateForDeletion(password: password);
    await ensureUserDocument();

    final DateTime deleteAt = DateTime.now().add(AccountDeletionConfig.recoveryWindow);
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'accountStatus': AccountDeletionConfig.scheduledStatus,
        'deleteAt': deleteAt.toIso8601String(),
        'scheduledDeletionAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );

    await _auth.signOut();
  }

  Future<void> cancelScheduledDeletion() async {
    final String? uid = _auth.uid;
    if (uid == null || _auth.isDemoMode || !AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'accountStatus': FieldValue.delete(),
        'deleteAt': FieldValue.delete(),
        'scheduledDeletionAt': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  /// Permanently deletes the account when the recovery window has passed.
  /// Returns true when the Firebase Auth user was removed.
  Future<bool> finalizeDeletionIfDue() async {
    final AccountDeletionStatus? status = await fetchDeletionStatus();
    if (status == null || !status.isDue) return false;

    final String? uid = _auth.uid;
    if (uid == null) return false;

    if (AppConfig.hasFirebase) {
      try {
        await AccountDeletionService.wipeUserData(uid);
      } catch (_) {}
    }

    await _auth.deleteAccount();
    return true;
  }

  /// Immediate permanent deletion (used by tests/admin flows).
  Future<void> deleteAccount({String? password}) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      _demoProfile = null;
      await _auth.deleteAccount();
      return;
    }

    await _auth.reauthenticateForDeletion(password: password);

    if (AppConfig.hasFirebase) {
      try {
        await AccountDeletionService.wipeUserData(uid);
      } catch (_) {}
    }

    await _auth.deleteAccount();
  }

  Future<void> updateProfile({
    required String school,
    required String major,
    required String year,
    required bool anonymousByDefault,
    double? gpa,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final Map<String, dynamic> data = <String, dynamic>{
      'school': school.trim(),
      'major': major.trim(),
      'year': year.trim(),
      'anonymousByDefault': anonymousByDefault,
      'gpa': ?gpa,
    };

    if (_auth.isDemoMode) {
      _patchDemo(
        (UserProfile c) => c.copyWith(
          school: school,
          major: major,
          year: year,
          anonymousByDefault: anonymousByDefault,
          gpa: gpa ?? c.gpa,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> removeCourseFromProfile(String courseId) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    await ClassNotificationService.instance.cancelForCourse(courseId);

    if (_auth.isDemoMode) {
      final Map<String, CourseSchedule> schedules = Map<String, CourseSchedule>.from(_demoCurrent.courseSchedules)
        ..remove(courseId);
      _patchDemo(
        (UserProfile c) => c.copyWith(
          courseIds: c.courseIds.where((String id) => id != courseId).toList(),
          courseSchedules: schedules,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'courseIds': FieldValue.arrayRemove(<String>[courseId]),
        'courseSchedules.$courseId': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
  }

  Future<ClassScheduleResult> setCourseSchedule({
    required CourseSchedule schedule,
    required String courseCode,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) {
      return const ClassScheduleResult(permissionGranted: false, message: 'Sign in to save class time.');
    }

    if (_auth.isDemoMode) {
      final Map<String, CourseSchedule> schedules = Map<String, CourseSchedule>.from(_demoCurrent.courseSchedules)
        ..[schedule.courseId] = schedule;
      _patchDemo((UserProfile c) => c.copyWith(courseSchedules: schedules));
    } else {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        <String, dynamic>{
          'courseSchedules': <String, dynamic>{
            schedule.courseId: schedule.toMap(),
          },
        },
        SetOptions(merge: true),
      );
    }

    return ClassNotificationService.instance.scheduleForCourse(
      schedule: schedule,
      courseCode: courseCode,
    );
  }

  Future<void> addTrackedSemester(String semester) async {
    final String label = semester.trim();
    if (label.isEmpty) return;
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      _patchDemo((UserProfile c) {
        if (c.trackedSemesters.contains(label)) return c;
        return c.copyWith(trackedSemesters: <String>[...c.trackedSemesters, label]);
      });
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'trackedSemesters': FieldValue.arrayUnion(<String>[label]),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeTrackedSemester(String semester) async {
    final String label = semester.trim();
    if (label.isEmpty) return;
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      _patchDemo(
        (UserProfile c) => c.copyWith(
          trackedSemesters: c.trackedSemesters.where((String s) => s != label).toList(),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'trackedSemesters': FieldValue.arrayRemove(<String>[label]),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> addCourseToProfile(String courseId) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      if (!_demoCurrent.courseIds.contains(courseId)) {
        _patchDemo((UserProfile c) => c.copyWith(courseIds: <String>[...c.courseIds, courseId]));
      }
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'courseIds': FieldValue.arrayUnion(<String>[courseId]),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> recordStudyActivity(String uid) async {
    if (_auth.isDemoMode) {
      final int streak = _demoCurrent.streakDays + 1;
      _patchDemo(
        (UserProfile c) => c.copyWith(
          streakDays: streak,
          lastStudyDate: DateTime.now(),
          badges: _mergeBadges(c.badges, streak),
        ),
      );
      return;
    }

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final DateTime today = DateTime.now();
    final DateTime? lastStudy = DateTime.tryParse(data['lastStudyDate'] as String? ?? '');
    int streak = (data['streakDays'] as num?)?.toInt() ?? 0;

    if (lastStudy == null) {
      streak = 1;
    } else {
      final int daysDiff = today.difference(DateTime(lastStudy.year, lastStudy.month, lastStudy.day)).inDays;
      if (daysDiff == 1) {
        streak += 1;
      } else if (daysDiff > 1) {
        streak = 1;
      }
    }

    final List<String> badges = _mergeBadges(
      (data['badges'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      streak,
    );

    await ref.set(<String, dynamic>{
      'streakDays': streak,
      'lastStudyDate': today.toIso8601String(),
      'badges': badges,
    }, SetOptions(merge: true));
  }

  List<String> _mergeBadges(List<String> current, int streakDays) {
    final List<String> merged = List<String>.from(current);
    for (final String badge in Gamification.badgesForStreak(streakDays)) {
      if (!merged.contains(badge)) merged.add(badge);
    }
    return merged;
  }

  Future<void> addXp(int amount) async {
    final String? uid = _auth.uid;
    if (uid == null || amount <= 0) return;

    if (_auth.isDemoMode) {
      _patchDemo((UserProfile c) => c.copyWith(xp: c.xp + amount));
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{'xp': FieldValue.increment(amount)},
      SetOptions(merge: true),
    );
  }

  Future<void> recordQuizMiss(ParsedQuestion question) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final List<String> topics = question.topics.isNotEmpty
        ? question.topics
        : <String>[question.questionType, question.courseCode];

    if (_auth.isDemoMode) {
      final Map<String, int> weak = Map<String, int>.from(_demoCurrent.weakTopics);
      for (final String topic in topics) {
        final String key = topic.trim();
        if (key.isEmpty) continue;
        weak[key] = (weak[key] ?? 0) + 1;
      }
      _patchDemo((UserProfile c) => c.copyWith(weakTopics: weak));
      return;
    }

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final Map<String, int> weak = <String, int>{};
    final dynamic raw = data['weakTopics'];
    if (raw is Map) {
      raw.forEach((dynamic key, dynamic value) {
        weak[key.toString()] = (value as num?)?.toInt() ?? 0;
      });
    }
    for (final String topic in topics) {
      final String key = topic.trim();
      if (key.isEmpty) continue;
      weak[key] = (weak[key] ?? 0) + 1;
    }
    await ref.set(<String, dynamic>{'weakTopics': weak}, SetOptions(merge: true));
  }

  Future<void> recordQuizResult({
    required String courseCode,
    required int correct,
    required int total,
  }) async {
    if (total <= 0) return;
    final int scorePercent = ((correct / total) * 100).round();
    final QuizResult result = QuizResult(
      date: DateTime.now(),
      courseCode: courseCode.isEmpty ? 'General' : courseCode,
      scorePercent: scorePercent,
      correct: correct,
      total: total,
    );

    await _patchProgress((StudyProgress p) {
      final List<QuizResult> results = <QuizResult>[result, ...p.quizResults].take(30).toList();
      final Map<String, int> subjects = Map<String, int>.from(p.subjectScores);
      subjects[result.courseCode] = scorePercent;
      final WeeklyStats week = p.normalizedWeekly().copyWith(
        quizzesCompleted: p.normalizedWeekly().quizzesCompleted + 1,
      );
      return p.copyWith(quizResults: results, subjectScores: subjects, weekly: week);
    });
  }

  Future<void> incrementWeeklyStat({
    int studyMinutes = 0,
    int tutorSessions = 0,
    int chaptersReviewed = 0,
  }) async {
    if (studyMinutes == 0 && tutorSessions == 0 && chaptersReviewed == 0) return;
    await _patchProgress((StudyProgress p) {
      final WeeklyStats week = p.normalizedWeekly().copyWith(
        studyMinutes: p.normalizedWeekly().studyMinutes + studyMinutes,
        tutorSessions: p.normalizedWeekly().tutorSessions + tutorSessions,
        chaptersReviewed: p.normalizedWeekly().chaptersReviewed + chaptersReviewed,
      );
      return p.copyWith(weekly: week);
    });
  }

  Future<void> _patchProgress(StudyProgress Function(StudyProgress current) patch) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      _patchDemo((UserProfile c) => c.copyWith(studyProgress: patch(c.studyProgress)));
      return;
    }

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    final StudyProgress current = StudyProgress.fromMap(
      doc.data()?['studyProgress'] as Map<String, dynamic>?,
    );
    final StudyProgress updated = patch(current);
    await ref.set(<String, dynamic>{'studyProgress': updated.toMap()}, SetOptions(merge: true));
  }

  Future<void> updateGpa(double gpa) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      _patchDemo((UserProfile c) => c.copyWith(gpa: gpa));
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{'gpa': gpa},
      SetOptions(merge: true),
    );
  }

  static String _todayDateKey([DateTime? when]) {
    final DateTime d = when ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<TutorMediaUsage> refreshTutorUsage(SubscriptionPlan plan) async {
    _tutorUsageCache = await _loadTutorMediaUsage(plan);
    notifyListeners();
    return _tutorUsageCache!;
  }

  Future<bool> canSendTutorMedia(SubscriptionPlan plan, int attachmentCount) async {
    if (attachmentCount <= 0) return true;
    final TutorMediaUsage usage = await _loadTutorMediaUsage(plan);
    _tutorUsageCache = usage;
    return usage.canAdd(attachmentCount);
  }

  Future<void> recordTutorMedia(SubscriptionPlan plan, int attachmentCount) async {
    if (plan.isPaid || attachmentCount <= 0) return;

    final String today = _todayDateKey();
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      if (_demoTutorMediaDate != today) {
        _demoTutorMediaDate = today;
        _demoTutorMediaCount = 0;
      }
      _demoTutorMediaCount += attachmentCount;
      _tutorUsageCache = TutorMediaUsage(
        count: _demoTutorMediaCount,
        limit: TutorLimits.freeDailyMediaAttachments,
        isPremium: false,
      );
      notifyListeners();
      return;
    }

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    int count = 0;
    if (data['tutorMediaDate'] == today) {
      count = (data['tutorMediaCount'] as num?)?.toInt() ?? 0;
    }
    count += attachmentCount;

    await ref.set(<String, dynamic>{
      'tutorMediaDate': today,
      'tutorMediaCount': count,
    }, SetOptions(merge: true));

    _tutorUsageCache = TutorMediaUsage(
      count: count,
      limit: TutorLimits.freeDailyMediaAttachments,
      isPremium: false,
    );
    notifyListeners();
  }

  Future<TutorMediaUsage> _loadTutorMediaUsage(SubscriptionPlan plan) async {
    if (plan.isPaid) {
      return TutorMediaUsage(
        count: 0,
        limit: TutorLimits.freeDailyMediaAttachments,
        isPremium: true,
      );
    }

    final String today = _todayDateKey();
    final String? uid = _auth.uid;
    if (uid == null) {
      return const TutorMediaUsage(
        count: 0,
        limit: TutorLimits.freeDailyMediaAttachments,
        isPremium: false,
      );
    }

    if (_auth.isDemoMode) {
      if (_demoTutorMediaDate != today) {
        _demoTutorMediaDate = today;
        _demoTutorMediaCount = 0;
      }
      return TutorMediaUsage(
        count: _demoTutorMediaCount,
        limit: TutorLimits.freeDailyMediaAttachments,
        isPremium: false,
      );
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = doc.data();
    int count = 0;
    if (data?['tutorMediaDate'] == today) {
      count = (data?['tutorMediaCount'] as num?)?.toInt() ?? 0;
    }

    return TutorMediaUsage(
      count: count,
      limit: TutorLimits.freeDailyMediaAttachments,
      isPremium: false,
    );
  }

  Future<SummarizeDailyUsage> refreshSummarizeUsage(SubscriptionPlan plan) async {
    _summarizeUsageCache = await _loadSummarizeUsage(plan);
    notifyListeners();
    return _summarizeUsageCache!;
  }

  Future<bool> canSummarize(SubscriptionPlan plan) async {
    final SummarizeDailyUsage usage = await _loadSummarizeUsage(plan);
    _summarizeUsageCache = usage;
    return usage.canCreate();
  }

  Future<void> recordSummarize(SubscriptionPlan plan) async {
    if (plan.isPaid) return;

    final String today = _todayDateKey();
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      if (_demoSummarizeDate != today) {
        _demoSummarizeDate = today;
        _demoSummarizeCount = 0;
      }
      _demoSummarizeCount += 1;
      _summarizeUsageCache = SummarizeDailyUsage(
        count: _demoSummarizeCount,
        limit: StudyLimits.freeDailySummarizeActions,
        isPremium: false,
      );
      notifyListeners();
      return;
    }

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    int count = 0;
    if (data['summarizeDate'] == today) {
      count = (data['summarizeCount'] as num?)?.toInt() ?? 0;
    }
    count += 1;

    await ref.set(<String, dynamic>{
      'summarizeDate': today,
      'summarizeCount': count,
    }, SetOptions(merge: true));

    _summarizeUsageCache = SummarizeDailyUsage(
      count: count,
      limit: StudyLimits.freeDailySummarizeActions,
      isPremium: false,
    );
    notifyListeners();
  }

  Future<SummarizeDailyUsage> _loadSummarizeUsage(SubscriptionPlan plan) async {
    if (plan.isPaid) {
      return SummarizeDailyUsage(
        count: 0,
        limit: StudyLimits.freeDailySummarizeActions,
        isPremium: true,
      );
    }

    final String today = _todayDateKey();
    final String? uid = _auth.uid;
    if (uid == null) {
      return const SummarizeDailyUsage(
        count: 0,
        limit: StudyLimits.freeDailySummarizeActions,
        isPremium: false,
      );
    }

    if (_auth.isDemoMode) {
      if (_demoSummarizeDate != today) {
        _demoSummarizeDate = today;
        _demoSummarizeCount = 0;
      }
      return SummarizeDailyUsage(
        count: _demoSummarizeCount,
        limit: StudyLimits.freeDailySummarizeActions,
        isPremium: false,
      );
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = doc.data();
    int count = 0;
    if (data?['summarizeDate'] == today) {
      count = (data?['summarizeCount'] as num?)?.toInt() ?? 0;
    }

    return SummarizeDailyUsage(
      count: count,
      limit: StudyLimits.freeDailySummarizeActions,
      isPremium: false,
    );
  }
}
