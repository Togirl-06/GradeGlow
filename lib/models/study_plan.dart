import 'exam_reminder_option.dart';

class ExamDate {
  const ExamDate({
    this.id = '',
    required this.courseCode,
    required this.examType,
    required this.date,
    this.completed = false,
    this.reminderId = '1h',
  });

  final String id;
  final String courseCode;
  final String examType;

  /// Full date + time when the exam starts.
  final DateTime date;
  final bool completed;
  final String reminderId;

  ExamReminderOption get reminder => ExamReminderOption.fromId(reminderId);

  String get reminderLabel => reminder.shortLabel;

  String get formattedDate {
    final DateTime local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    final DateTime local = date.toLocal();
    final int hour = local.hour;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int h = hour % 12 == 0 ? 12 : hour % 12;
    final String m = local.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String get formattedDateTime => '$formattedDate · $formattedTime';

  ExamDate copyWith({bool? completed, String? reminderId}) {
    return ExamDate(
      id: id,
      courseCode: courseCode,
      examType: examType,
      date: date,
      completed: completed ?? this.completed,
      reminderId: reminderId ?? this.reminderId,
    );
  }

  factory ExamDate.fromMap(String id, Map<String, dynamic> data) {
    return ExamDate(
      id: id,
      courseCode: data['courseCode'] as String? ?? '',
      examType: data['examType'] as String? ?? 'Final',
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
      completed: data['completed'] as bool? ?? false,
      reminderId: data['reminderId'] as String? ?? '1h',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'courseCode': courseCode,
    'examType': examType,
    'date': date.toIso8601String(),
    'completed': completed,
    'reminderId': reminderId,
  };
}

/// Preset calendar event types for the planner dropdown.
///
/// Covers everything a student inputs on the calendar — recurring classes as
/// well as one-off assessments — so the same storage + reminder pipeline drives
/// classes, exams, tests, assignments, and study sessions.
class ExamTypeOption {
  const ExamTypeOption(this.label);
  final String label;

  static const List<ExamTypeOption> choices = <ExamTypeOption>[
    ExamTypeOption('Class'),
    ExamTypeOption('Lecture'),
    ExamTypeOption('Lab'),
    ExamTypeOption('Exam'),
    ExamTypeOption('Midterm'),
    ExamTypeOption('Final'),
    ExamTypeOption('Quiz'),
    ExamTypeOption('Test'),
    ExamTypeOption('Assignment'),
    ExamTypeOption('Presentation'),
    ExamTypeOption('Study session'),
  ];
}

class StudyPlanTask {
  const StudyPlanTask({
    required this.date,
    required this.title,
    required this.courseCode,
    required this.completed,
  });

  final DateTime date;
  final String title;
  final String courseCode;
  final bool completed;

  factory StudyPlanTask.fromMap(Map<String, dynamic> data) {
    return StudyPlanTask(
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
      title: data['title'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      completed: data['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'date': date.toIso8601String(),
    'title': title,
    'courseCode': courseCode,
    'completed': completed,
  };
}
