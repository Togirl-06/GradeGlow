/// When to remind the student before an exam.
class ExamReminderOption {
  const ExamReminderOption({
    required this.id,
    required this.label,
    this.beforeExam,
    this.morningOfExam = false,
  });

  final String id;
  final String label;
  final Duration? beforeExam;
  final bool morningOfExam;

  static const List<ExamReminderOption> choices = <ExamReminderOption>[
    ExamReminderOption(id: '30m', label: '30 minutes before', beforeExam: Duration(minutes: 30)),
    ExamReminderOption(id: '1h', label: '1 hour before', beforeExam: Duration(hours: 1)),
    ExamReminderOption(id: '2h', label: '2 hours before', beforeExam: Duration(hours: 2)),
    ExamReminderOption(id: '3h', label: '3 hours before', beforeExam: Duration(hours: 3)),
    ExamReminderOption(id: '1d', label: '1 day before', beforeExam: Duration(days: 1)),
    ExamReminderOption(id: 'morning', label: 'Morning of exam (8:00 AM)', morningOfExam: true),
  ];

  static ExamReminderOption fromId(String id) {
    return choices.firstWhere(
      (ExamReminderOption o) => o.id == id,
      orElse: () => choices[1],
    );
  }

  DateTime? reminderAt(DateTime examAt) {
    final DateTime local = examAt.toLocal();
    if (morningOfExam) {
      return DateTime(local.year, local.month, local.day, 8, 0);
    }
    if (beforeExam != null) {
      return local.subtract(beforeExam!);
    }
    return null;
  }

  String get shortLabel => label;
}
