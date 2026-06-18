import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/course_schedule.dart';
import 'exam_notification_service.dart';

class ClassScheduleResult {
  const ClassScheduleResult({
    required this.permissionGranted,
    this.scheduledCount = 0,
    this.message,
  });

  final bool permissionGranted;
  final int scheduledCount;
  final String? message;
}

class ClassNotificationService {
  ClassNotificationService._();
  static final ClassNotificationService instance = ClassNotificationService._();

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'class_reminders',
    'Class reminders',
    channelDescription: 'Alerts before your classes start',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  static const int _idBase = 300000;

  int _notificationId(String courseId, int weekday) =>
      (_idBase + courseId.hashCode.abs() % 100000 + weekday * 7) % 2147483647;

  Future<ClassScheduleResult> scheduleForCourse({
    required CourseSchedule schedule,
    required String courseCode,
  }) async {
    await ExamNotificationService.instance.initialize();
    await cancelForCourse(schedule.courseId);

    if (!schedule.hasReminder || schedule.weekdays.isEmpty) {
      return const ClassScheduleResult(
        permissionGranted: true,
        message: 'Class time saved. Turn on a reminder to get notified.',
      );
    }

    if (!ExamNotificationService.instance.permissionGranted) {
      return const ClassScheduleResult(
        permissionGranted: false,
        message: 'Enable notifications in system settings to get class reminders.',
      );
    }

    final FlutterLocalNotificationsPlugin plugin = ExamNotificationService.instance.notificationsPlugin;

    int scheduled = 0;
    for (final int weekday in schedule.weekdays) {
      final DateTime? remindAt = _reminderDateTime(schedule, weekday);
      if (remindAt == null || !remindAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1)))) {
        continue;
      }

      final tz.TZDateTime when = tz.TZDateTime(
        tz.local,
        remindAt.year,
        remindAt.month,
        remindAt.day,
        remindAt.hour,
        remindAt.minute,
      );

      final int id = _notificationId(schedule.courseId, weekday);
      try {
        await plugin.zonedSchedule(
          id,
          'Class starting soon',
          '$courseCode starts at ${formatClassTime(schedule)}',
          when,
          const NotificationDetails(android: _androidDetails, iOS: DarwinNotificationDetails()),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (_) {
        await plugin.zonedSchedule(
          id,
          'Class starting soon',
          '$courseCode starts at ${formatClassTime(schedule)}',
          when,
          const NotificationDetails(android: _androidDetails, iOS: DarwinNotificationDetails()),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      scheduled++;
    }

    return ClassScheduleResult(
      permissionGranted: true,
      scheduledCount: scheduled,
      message: scheduled == 0
          ? 'No upcoming reminders — check class days and time.'
          : 'Reminders set for $scheduled class day${scheduled == 1 ? '' : 's'}.',
    );
  }

  DateTime? _reminderDateTime(CourseSchedule schedule, int weekday) {
    final DateTime classAt = _nextWeekdayAt(schedule.hour, schedule.minute, weekday);
    return schedule.reminder.reminderAt(classAt);
  }

  DateTime _nextWeekdayAt(int hour, int minute, int weekday) {
    DateTime cursor = DateTime.now();
    while (cursor.weekday != weekday) {
      cursor = cursor.add(const Duration(days: 1));
    }
    return DateTime(cursor.year, cursor.month, cursor.day, hour, minute);
  }

  String formatClassTime(CourseSchedule schedule) {
    final DateTime dt = DateTime(2000, 1, 1, schedule.hour, schedule.minute);
    final String period = dt.hour >= 12 ? 'PM' : 'AM';
    final int h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final String m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Future<void> cancelForCourse(String courseId) async {
    await ExamNotificationService.instance.initialize();
    final FlutterLocalNotificationsPlugin plugin = ExamNotificationService.instance.notificationsPlugin;
    for (int weekday = 1; weekday <= 7; weekday++) {
      await plugin.cancel(_notificationId(courseId, weekday));
    }
  }

  Future<void> rescheduleAll(
    Map<String, CourseSchedule> schedules,
    Map<String, String> courseCodesById,
  ) async {
    for (final CourseSchedule schedule in schedules.values) {
      final String? code = courseCodesById[schedule.courseId];
      if (code != null) {
        await scheduleForCourse(schedule: schedule, courseCode: code);
      }
    }
  }
}
