import 'package:intl/intl.dart';

import '../models/todo_item.dart';

String todoDayKey(DateTime date) {
  final DateTime local = date.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String get todayDayKey => todoDayKey(DateTime.now());

List<TodoItem> todosForDay(List<TodoItem> items, String dayKey) {
  return items.where((TodoItem t) => t.dayKey == dayKey).toList()
    ..sort((TodoItem a, TodoItem b) => a.scheduledAt.compareTo(b.scheduledAt));
}

String formatTodoTime(DateTime at) => DateFormat.jm().format(at.toLocal());

DateTime combineDayAndTime(DateTime day, int hour, int minute) {
  final DateTime local = day.toLocal();
  return DateTime(local.year, local.month, local.day, hour, minute);
}
