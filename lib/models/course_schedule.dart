import 'exam_reminder_option.dart';

/// Per-user class meeting time and reminder (stored on user profile).
class CourseSchedule {
  const CourseSchedule({
    required this.courseId,
    required this.weekdays,
    required this.hour,
    required this.minute,
    this.reminderId = '30m',
  });

  final String courseId;
  /// [DateTime.monday] = 1 … [DateTime.sunday] = 7
  final List<int> weekdays;
  final int hour;
  final int minute;
  final String reminderId;

  ExamReminderOption get reminder {
    if (reminderId == 'none') {
      return const ExamReminderOption(id: 'none', label: 'No reminder');
    }
    return ExamReminderOption.fromId(reminderId);
  }

  bool get hasReminder => reminderId != 'none';

  factory CourseSchedule.fromMap(String courseId, Map<String, dynamic> data) {
    final List<int> days = (data['weekdays'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic e) => (e as num).toInt())
        .where((int d) => d >= 1 && d <= 7)
        .toList();
    return CourseSchedule(
      courseId: courseId,
      weekdays: days,
      hour: (data['hour'] as num?)?.toInt() ?? 9,
      minute: (data['minute'] as num?)?.toInt() ?? 0,
      reminderId: data['reminderId'] as String? ?? '30m',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'weekdays': weekdays,
        'hour': hour,
        'minute': minute,
        'reminderId': reminderId,
      };

  CourseSchedule copyWith({
    List<int>? weekdays,
    int? hour,
    int? minute,
    String? reminderId,
  }) {
    return CourseSchedule(
      courseId: courseId,
      weekdays: weekdays ?? this.weekdays,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      reminderId: reminderId ?? this.reminderId,
    );
  }
}
