import 'package:intl/intl.dart';

import '../models/course_schedule.dart';
import '../models/study_plan.dart';

enum UpcomingEventKind { classSession, exam }

/// Class meeting or exam on the student's calendar.
class UpcomingEvent {
  const UpcomingEvent({
    required this.at,
    required this.courseCode,
    required this.kind,
    this.examType,
  });

  final DateTime at;
  final String courseCode;
  final UpcomingEventKind kind;
  final String? examType;

  String get typeLabel => kind == UpcomingEventKind.exam ? (examType ?? 'Exam') : 'Class';

  String get headline => '$courseCode – $typeLabel';

  String get formattedDateTime => DateFormat('MMM d, yyyy · h:mm a').format(at.toLocal());

  String get formattedTime => DateFormat('h:mm a').format(at.toLocal());

  bool get isPast => at.toLocal().isBefore(DateTime.now());

  String get statusLabel => eventStatusLabel(at);
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  final DateTime la = a.toLocal();
  final DateTime lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

/// All classes and exams on a calendar day, sorted by time.
List<UpcomingEvent> findEventsOnDay({
  required DateTime day,
  required List<ExamDate> exams,
  required Map<String, CourseSchedule> schedules,
  required Map<String, String> courseCodesById,
  List<String> courseIds = const <String>[],
}) {
  final DateTime dayStart = DateTime(day.year, day.month, day.day);
  final int weekday = dayStart.weekday;
  final List<UpcomingEvent> events = <UpcomingEvent>[];

  for (final ExamDate exam in exams) {
    if (exam.completed) continue;
    final DateTime at = exam.date.toLocal();
    if (!isSameCalendarDay(at, dayStart)) continue;
    events.add(
      UpcomingEvent(
        at: at,
        courseCode: exam.courseCode.trim().isEmpty ? 'Exam' : exam.courseCode.trim(),
        kind: UpcomingEventKind.exam,
        examType: exam.examType,
      ),
    );
  }

  final Iterable<String> ids = courseIds.isEmpty ? schedules.keys : courseIds;
  for (final String courseId in ids) {
    final CourseSchedule? schedule = schedules[courseId];
    if (schedule == null || !schedule.weekdays.contains(weekday)) continue;
    final String code = (courseCodesById[courseId] ?? '').trim();
    events.add(
      UpcomingEvent(
        at: DateTime(dayStart.year, dayStart.month, dayStart.day, schedule.hour, schedule.minute),
        courseCode: code.isEmpty ? 'Class' : code,
        kind: UpcomingEventKind.classSession,
      ),
    );
  }

  events.sort((UpcomingEvent a, UpcomingEvent b) => a.at.compareTo(b.at));
  return events;
}

class DashboardScheduleDay {
  const DashboardScheduleDay({required this.day, required this.events});

  final DateTime day;
  final List<UpcomingEvent> events;

  UpcomingEvent? get nextFuture {
    final DateTime now = DateTime.now();
    for (final UpcomingEvent event in events) {
      if (event.at.isAfter(now)) return event;
    }
    return null;
  }

  String get dayLabel {
    final DateTime today = DateTime.now();
    if (isSameCalendarDay(day, today)) return 'Today';
    if (isSameCalendarDay(day, today.add(const Duration(days: 1)))) return 'Tomorrow';
    return DateFormat('EEEE, MMM d').format(day);
  }
}

/// Day of the next upcoming event, with every class and exam on that day.
DashboardScheduleDay? findDashboardScheduleDay({
  required List<ExamDate> exams,
  required Map<String, CourseSchedule> schedules,
  required Map<String, String> courseCodesById,
  List<String> courseIds = const <String>[],
}) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  final UpcomingEvent? next = findNextUpcoming(
    exams: exams,
    schedules: schedules,
    courseCodesById: courseCodesById,
    courseIds: courseIds,
  );

  if (next != null) {
    final DateTime focusDay = DateTime(next.at.year, next.at.month, next.at.day);
    final List<UpcomingEvent> events = findEventsOnDay(
      day: focusDay,
      exams: exams,
      schedules: schedules,
      courseCodesById: courseCodesById,
      courseIds: courseIds,
    );
    if (events.isNotEmpty) {
      return DashboardScheduleDay(day: focusDay, events: events);
    }
  }

  final List<UpcomingEvent> todayEvents = findEventsOnDay(
    day: today,
    exams: exams,
    schedules: schedules,
    courseCodesById: courseCodesById,
    courseIds: courseIds,
  );
  if (todayEvents.isNotEmpty) {
    return DashboardScheduleDay(day: today, events: todayEvents);
  }

  return null;
}

String eventStatusLabel(DateTime at) {
  final DateTime local = at.toLocal();
  final DateTime now = DateTime.now();
  final Duration diff = local.difference(now);

  if (diff.inMinutes <= -1) {
    return isSameCalendarDay(local, now) ? 'Earlier today' : 'Passed';
  }
  if (diff.inMinutes <= 0) return 'Starting now';

  if (diff.inDays >= 2) return 'In ${diff.inDays} days';
  if (diff.inDays == 1) return 'Tomorrow';
  if (diff.inHours >= 2) return 'In ${diff.inHours} hours';
  if (diff.inHours == 1) return 'In 1 hour';
  if (diff.inMinutes >= 1) return 'In ${diff.inMinutes} min';
  return 'Soon';
}

String formatCountdown(DateTime at) => eventStatusLabel(at);

DateTime? nextClassOccurrence(CourseSchedule schedule, {DateTime? from}) {
  if (schedule.weekdays.isEmpty) return null;
  final DateTime start = (from ?? DateTime.now()).toLocal();
  for (int offset = 0; offset < 21; offset++) {
    final DateTime day = DateTime(start.year, start.month, start.day).add(Duration(days: offset));
    if (!schedule.weekdays.contains(day.weekday)) continue;
    final DateTime at = DateTime(day.year, day.month, day.day, schedule.hour, schedule.minute);
    if (at.isAfter(start)) return at;
  }
  return null;
}

UpcomingEvent? findNextUpcoming({
  required List<ExamDate> exams,
  required Map<String, CourseSchedule> schedules,
  required Map<String, String> courseCodesById,
  List<String> courseIds = const <String>[],
}) {
  final DateTime now = DateTime.now();
  UpcomingEvent? best;

  for (final ExamDate exam in exams) {
    if (exam.completed) continue;
    final DateTime at = exam.date.toLocal();
    if (!at.isAfter(now)) continue;
    final UpcomingEvent candidate = UpcomingEvent(
      at: at,
      courseCode: exam.courseCode.trim().isEmpty ? 'Exam' : exam.courseCode.trim(),
      kind: UpcomingEventKind.exam,
      examType: exam.examType,
    );
    if (best == null || at.isBefore(best.at)) best = candidate;
  }

  final Iterable<String> ids = courseIds.isEmpty ? schedules.keys : courseIds;
  for (final String courseId in ids) {
    final CourseSchedule? schedule = schedules[courseId];
    if (schedule == null) continue;
    final DateTime? at = nextClassOccurrence(schedule, from: now);
    if (at == null) continue;
    final String code = (courseCodesById[courseId] ?? '').trim();
    final UpcomingEvent candidate = UpcomingEvent(
      at: at,
      courseCode: code.isEmpty ? 'Class' : code,
      kind: UpcomingEventKind.classSession,
    );
    if (best == null || at.isBefore(best.at)) best = candidate;
  }

  return best;
}
