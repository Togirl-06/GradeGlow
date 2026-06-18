import 'package:intl/intl.dart';

import '../models/course_schedule.dart';
import '../models/exam_reminder_option.dart';

const List<String> weekdayShortLabels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatWeekdays(List<int> weekdays) {
  if (weekdays.isEmpty) return 'No days set';
  final List<int> sorted = List<int>.from(weekdays)..sort();
  return sorted.map((int d) => weekdayShortLabels[d - 1]).join(' · ');
}

String formatTimeOfDay(int hour, int minute) {
  final DateTime dt = DateTime(2000, 1, 1, hour, minute);
  return DateFormat.jm().format(dt);
}

String formatClassScheduleSummary(CourseSchedule? schedule) {
  if (schedule == null || schedule.weekdays.isEmpty) {
    return 'Tap to set class time & reminders';
  }
  final String time = formatTimeOfDay(schedule.hour, schedule.minute);
  final String days = formatWeekdays(schedule.weekdays);
  if (!schedule.hasReminder) {
    return '$days · $time';
  }
  return '$days · $time · ${schedule.reminder.shortLabel}';
}

List<ExamReminderOption> classReminderChoices() {
  return <ExamReminderOption>[
    const ExamReminderOption(id: 'none', label: 'No reminder'),
    ...ExamReminderOption.choices,
  ];
}
