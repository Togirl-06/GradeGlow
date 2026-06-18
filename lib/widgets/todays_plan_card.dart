import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../screens/todos_screen.dart';
import '../services/todo_service.dart';
import '../theme/study_theme.dart';
import '../widgets/add_todo_sheet.dart';
import '../widgets/study_surface.dart';
import '../widgets/todo_timeline_row.dart';

/// Dashboard to-do list for today (not the study planner).
class TodaysTodoCard extends StatelessWidget {
  const TodaysTodoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoService todos = context.watch<TodoService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return StreamBuilder<List<TodoItem>>(
      stream: todos.watchTodayTodos(),
      builder: (BuildContext context, AsyncSnapshot<List<TodoItem>> snap) {
        final List<TodoItem> items = (snap.data ?? <TodoItem>[]).take(5).toList();

        return StudySurfaceCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Today's To-Do", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const TodosScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: StudyColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View all', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Nothing on your list yet. Add a task for today.',
                    style: TextStyle(color: textSecondary, height: 1.35),
                  ),
                )
              else
                ...List<Widget>.generate(items.length, (int index) {
                  final TodoItem item = items[index];
                  return TodoTimelineRow(
                    item: item,
                    dotColor: TodoTimelineRow.dotColorForIndex(index),
                    isFirst: index == 0,
                    isLast: index == items.length - 1,
                    onToggle: () => todos.toggleTodo(item.id, !item.completed),
                  );
                }),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => showAddTodoSheet(context),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Add to-do'),
                style: TextButton.styleFrom(foregroundColor: StudyColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }
}
