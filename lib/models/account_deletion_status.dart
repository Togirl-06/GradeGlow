/// Tracks a user's 30-day account deletion grace period.
class AccountDeletionStatus {
  const AccountDeletionStatus({
    required this.scheduled,
    required this.deleteAt,
    this.scheduledAt,
  });

  final bool scheduled;
  final DateTime deleteAt;
  final DateTime? scheduledAt;

  bool get isDue => scheduled && !DateTime.now().isBefore(deleteAt);

  int get daysRemaining {
    final int days = deleteAt.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  static AccountDeletionStatus? fromMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    final String status = data['accountStatus'] as String? ?? '';
    if (status != 'scheduled_for_deletion') return null;

    final DateTime? deleteAt = DateTime.tryParse(data['deleteAt'] as String? ?? '');
    if (deleteAt == null) return null;

    return AccountDeletionStatus(
      scheduled: true,
      deleteAt: deleteAt,
      scheduledAt: DateTime.tryParse(data['scheduledDeletionAt'] as String? ?? ''),
    );
  }
}

class AccountDeletionConfig {
  AccountDeletionConfig._();

  static const Duration recoveryWindow = Duration(days: 30);
  static const String confirmToken = 'DELETE';
  static const String scheduledStatus = 'scheduled_for_deletion';

  static const String warningMessage =
      'This action cannot be undone. All courses, notes, flashcards, quizzes, and account data will be permanently deleted after a 30-day recovery period.';
}
