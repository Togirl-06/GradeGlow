import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/study_plan.dart';
import '../utils/premium_access.dart';
import 'auth_service.dart';
import 'exam_notification_service.dart';
import 'openai_service.dart';
import 'subscription_service.dart';

class StudyPlannerService extends ChangeNotifier {
  StudyPlannerService(this._auth, this._openAi, this._subscription);

  final AuthService _auth;
  final OpenAiService _openAi;
  final SubscriptionService _subscription;
  bool _generating = false;
  bool get isGenerating => _generating;

  final List<ExamDate> _demoExams = <ExamDate>[];
  final List<StudyPlanTask> _demoTasks = <StudyPlanTask>[];

  Stream<List<ExamDate>> watchExams() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<ExamDate>>.value(<ExamDate>[]);

    if (!AppConfig.hasFirebase) {
      return Stream<List<ExamDate>>.multi((StreamController<List<ExamDate>> controller) {
        void emit() => controller.add(List<ExamDate>.from(_demoExams));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exam_dates')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ExamDate.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((ExamDate a, ExamDate b) => a.date.compareTo(b.date)),
        );
  }

  Stream<List<StudyPlanTask>> watchTasks() => _watchTasks();

  Stream<List<StudyPlanTask>> _watchTasks() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<StudyPlanTask>>.value(<StudyPlanTask>[]);

    if (!AppConfig.hasFirebase) {
      return Stream<List<StudyPlanTask>>.multi((StreamController<List<StudyPlanTask>> controller) {
        void emit() => controller.add(List<StudyPlanTask>.from(_demoTasks));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('study_plan')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => StudyPlanTask.fromMap(doc.data()))
              .toList()
            ..sort((StudyPlanTask a, StudyPlanTask b) => a.date.compareTo(b.date)),
        );
  }

  Future<ExamScheduleResult> addExam(ExamDate exam) async {
    final String? uid = _auth.uid;
    if (uid == null) {
      return const ExamScheduleResult(permissionGranted: false, message: 'Sign in to add exams.');
    }

    ExamDate saved;
    if (!AppConfig.hasFirebase) {
      saved = ExamDate(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        courseCode: exam.courseCode,
        examType: exam.examType,
        date: exam.date,
        reminderId: exam.reminderId,
      );
      _demoExams.add(saved);
      notifyListeners();
    } else {
      final DocumentReference<Map<String, dynamic>> ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('exam_dates')
          .add(exam.toMap());
      saved = ExamDate(
        id: ref.id,
        courseCode: exam.courseCode,
        examType: exam.examType,
        date: exam.date,
        reminderId: exam.reminderId,
      );
    }

    return ExamNotificationService.instance.scheduleForExam(saved);
  }

  Future<void> deleteExam(String examId) async {
    final String? uid = _auth.uid;
    if (uid == null || examId.isEmpty) return;

    if (!AppConfig.hasFirebase) {
      _demoExams.removeWhere((ExamDate e) => e.id == examId);
      notifyListeners();
      await ExamNotificationService.instance.cancelForExam(examId);
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exam_dates')
        .doc(examId)
        .delete();

    await ExamNotificationService.instance.cancelForExam(examId);
  }

  Future<void> toggleExamDone(String examId, bool completed) async {
    final String? uid = _auth.uid;
    if (uid == null || examId.isEmpty) return;

    ExamDate? updated;
    if (!AppConfig.hasFirebase) {
      final int index = _demoExams.indexWhere((ExamDate e) => e.id == examId);
      if (index >= 0) {
        updated = _demoExams[index] = _demoExams[index].copyWith(completed: completed);
        notifyListeners();
      }
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('exam_dates')
          .doc(examId)
          .update(<String, dynamic>{'completed': completed});
      final List<ExamDate> all = await watchExams().first;
      for (final ExamDate e in all) {
        if (e.id == examId) {
          updated = e.copyWith(completed: completed);
          break;
        }
      }
    }

    if (updated != null) {
      if (completed) {
        await ExamNotificationService.instance.cancelForExam(examId);
      } else {
        await ExamNotificationService.instance.scheduleForExam(updated);
      }
    }
  }

  Future<void> syncExamNotifications() async {
    final List<ExamDate> exams = await watchExams().first;
    await ExamNotificationService.instance.rescheduleAll(exams);
  }

  Future<void> generateQuickPlan({
    required String subject,
    required DateTime examDate,
  }) async {
    PremiumAccess.requirePremium(_subscription.plan, feature: PremiumFeature.studyPlans);

    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to create a study plan.');

    _generating = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> raw = await _openAi.generateSubjectStudyPlan(
        subject: subject,
        examDate: examDate,
      );

      final List<StudyPlanTask> tasks = raw
          .map(
            (Map<String, dynamic> t) => StudyPlanTask(
              date: DateTime.tryParse(t['date'] as String? ?? '') ?? DateTime.now(),
              title: t['title'] as String? ?? 'Study',
              courseCode: t['courseCode'] as String? ?? subject,
              completed: false,
            ),
          )
          .toList();

      if (!AppConfig.hasFirebase) {
        _demoTasks
          ..clear()
          ..addAll(tasks);
        notifyListeners();
        return;
      }

      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final QuerySnapshot<Map<String, dynamic>> old = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('study_plan')
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in old.docs) {
        batch.delete(doc.reference);
      }
      for (final StudyPlanTask task in tasks) {
        final DocumentReference<Map<String, dynamic>> ref =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('study_plan').doc();
        batch.set(ref, task.toMap());
      }
      await batch.commit();
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  Future<void> generatePlan() async {
    PremiumAccess.requirePremium(_subscription.plan, feature: PremiumFeature.studyPlans);

    final String? uid = _auth.uid;
    if (uid == null) return;

    _generating = true;
    notifyListeners();

    try {
      final List<ExamDate> exams =
          (await watchExams().first).where((ExamDate e) => !e.completed).toList();
      if (exams.isEmpty) throw Exception('Add at least one upcoming exam first.');

      final List<Map<String, dynamic>> raw = await _openAi.generateStudyPlan(
        exams: exams
            .map(
              (ExamDate e) => <String, String>{
                'courseCode': e.courseCode,
                'examType': e.examType,
                'date': e.formattedDate,
                'time': e.formattedTime,
              },
            )
            .toList(),
      );

      final List<StudyPlanTask> tasks = raw
          .map(
            (Map<String, dynamic> t) => StudyPlanTask(
              date: DateTime.tryParse(t['date'] as String? ?? '') ?? DateTime.now(),
              title: t['title'] as String? ?? 'Study',
              courseCode: t['courseCode'] as String? ?? '',
              completed: false,
            ),
          )
          .toList();

      if (!AppConfig.hasFirebase) {
        _demoTasks
          ..clear()
          ..addAll(tasks);
        notifyListeners();
        return;
      }

      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final QuerySnapshot<Map<String, dynamic>> old = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('study_plan')
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in old.docs) {
        batch.delete(doc.reference);
      }
      for (final StudyPlanTask task in tasks) {
        final DocumentReference<Map<String, dynamic>> ref =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('study_plan').doc();
        batch.set(ref, task.toMap());
      }
      await batch.commit();
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(StudyPlanTask task, int index, List<StudyPlanTask> all) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final StudyPlanTask updated = StudyPlanTask(
      date: task.date,
      title: task.title,
      courseCode: task.courseCode,
      completed: !task.completed,
    );

    if (!AppConfig.hasFirebase) {
      if (index >= 0 && index < _demoTasks.length) {
        _demoTasks[index] = updated;
        notifyListeners();
      }
      return;
    }

    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('study_plan')
        .orderBy('date')
        .get();
    if (index < snap.docs.length) {
      await snap.docs[index].reference.update(<String, dynamic>{'completed': updated.completed});
    }
  }
}
