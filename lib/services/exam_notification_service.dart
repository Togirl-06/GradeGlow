import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/study_plan.dart';

class ExamScheduleResult {
  const ExamScheduleResult({
    required this.permissionGranted,
    this.approachingAt,
    this.startedAt,
    this.message,
  });

  final bool permissionGranted;
  final DateTime? approachingAt;
  final DateTime? startedAt;
  final String? message;

  bool get hasScheduled => approachingAt != null || startedAt != null;
}

class ExamNotificationService {
  ExamNotificationService._();
  static final ExamNotificationService instance = ExamNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _permissionGranted = false;

  bool get isReady => _ready;
  bool get permissionGranted => _permissionGranted;
  FlutterLocalNotificationsPlugin get notificationsPlugin => _plugin;

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'exam_reminders',
    'Exam reminders',
    channelDescription: 'Alerts when exams are approaching or starting',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    if (_ready) return;

    // Local notifications + timezone plugins hang on web — skip entirely.
    if (kIsWeb) {
      _permissionGranted = false;
      _ready = true;
      return;
    }

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(settings);

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    _permissionGranted = await androidPlugin?.requestNotificationsPermission() ?? true;
    await androidPlugin?.requestExactAlarmsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final bool? iosGranted = await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    if (iosGranted != null) _permissionGranted = iosGranted;

    _ready = true;
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  int _approachingId(String examId) => examId.hashCode.abs() % 100000;
  int _startedId(String examId) => _approachingId(examId) + 1;

  Future<ExamScheduleResult> scheduleForExam(ExamDate exam) async {
    if (!_ready) await initialize();
    if (exam.completed || exam.id.isEmpty) {
      return const ExamScheduleResult(permissionGranted: true, message: 'Exam completed — no reminders.');
    }

    if (!_permissionGranted) {
      return const ExamScheduleResult(
        permissionGranted: false,
        message: 'Enable notifications in system settings to get exam reminders.',
      );
    }

    await cancelForExam(exam.id);

    final DateTime examAt = exam.date.toLocal();
    final DateTime now = DateTime.now();
    DateTime? approachingAt;
    DateTime? startedAt;

    final DateTime? remindAt = exam.reminder.reminderAt(examAt);
    if (remindAt != null && remindAt.isAfter(now)) {
      await _schedule(
        id: _approachingId(exam.id),
        when: remindAt,
        title: 'Exam approaching',
        body: '${exam.courseCode} ${exam.examType} starts at ${exam.formattedTime}',
      );
      approachingAt = remindAt;
    }

    if (examAt.isAfter(now)) {
      await _schedule(
        id: _startedId(exam.id),
        when: examAt,
        title: 'Exam started',
        body: '${exam.courseCode} ${exam.examType} is starting now. Good luck!',
      );
      startedAt = examAt;
    }

    String? message;
    if (approachingAt == null && startedAt == null) {
      message = 'Exam time has passed — no future reminders to schedule.';
    } else if (approachingAt == null) {
      message = 'Reminder time already passed; you will still be notified when the exam starts.';
    }

    return ExamScheduleResult(
      permissionGranted: true,
      approachingAt: approachingAt,
      startedAt: startedAt,
      message: message,
    );
  }

  Future<void> cancelForExam(String examId) async {
    if (!_ready) return;
    await _plugin.cancel(_approachingId(examId));
    await _plugin.cancel(_startedId(examId));
  }

  Future<void> rescheduleAll(List<ExamDate> exams) async {
    if (!_ready) await initialize();
    for (final ExamDate exam in exams) {
      if (!exam.completed) {
        await scheduleForExam(exam);
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      when.year,
      when.month,
      when.day,
      when.hour,
      when.minute,
      when.second,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(android: _androidDetails, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(android: _androidDetails, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
