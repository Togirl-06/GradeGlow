/// A single item on the student's daily to-do list (not the AI study planner).
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.activityType,
    required this.completed,
    required this.dayKey,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String activityType;
  final bool completed;
  /// Calendar day bucket, e.g. `2026-05-20`.
  final String dayKey;

  factory TodoItem.fromMap(String id, Map<String, dynamic> data) {
    return TodoItem(
      id: id,
      title: data['title'] as String? ?? '',
      scheduledAt: DateTime.tryParse(data['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      activityType: data['activityType'] as String? ?? 'Study',
      completed: data['completed'] as bool? ?? false,
      dayKey: data['dayKey'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'scheduledAt': scheduledAt.toIso8601String(),
        'activityType': activityType,
        'completed': completed,
        'dayKey': dayKey,
      };

  TodoItem copyWith({bool? completed}) {
    return TodoItem(
      id: id,
      title: title,
      scheduledAt: scheduledAt,
      activityType: activityType,
      completed: completed ?? this.completed,
      dayKey: dayKey,
    );
  }
}

const List<String> todoActivityTypes = <String>['Study', 'Review', 'Practice'];
