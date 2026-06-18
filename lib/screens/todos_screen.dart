import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../services/todo_service.dart';
import '../theme/study_theme.dart';
import '../widgets/add_todo_sheet.dart';
import '../widgets/todo_timeline_row.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoService todos = context.watch<TodoService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTodoSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add to-do'),
      ),
      body: StreamBuilder<List<TodoItem>>(
        stream: todos.watchTodayTodos(),
        builder: (BuildContext context, AsyncSnapshot<List<TodoItem>> snap) {
          final List<TodoItem> items = snap.data ?? <TodoItem>[];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.checklist_rounded, size: 56, color: textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('No to-dos for today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Add tasks like “Math – Calculus” with a time and tap the circle when you finish.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final TodoItem item = items[index];
              return Dismissible(
                key: ValueKey<String>(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: StudyColors.danger.withValues(alpha: 0.15),
                  child: const Icon(Icons.delete_outline, color: StudyColors.danger),
                ),
                onDismissed: (_) => todos.deleteTodo(item.id),
                child: TodoTimelineRow(
                  item: item,
                  dotColor: TodoTimelineRow.dotColorForIndex(index),
                  isFirst: index == 0,
                  isLast: index == items.length - 1,
                  onToggle: () => todos.toggleTodo(item.id, !item.completed),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
