import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../services/todo_service.dart';
import '../utils/todo_day.dart';
import '../utils/study_messenger.dart';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  String _activityType = 'Study';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final DateTime scheduledAt = combineDayAndTime(DateTime.now(), _time.hour, _time.minute);
      await context.read<TodoService>().addTodo(
        title: _titleController.text,
        scheduledAt: scheduledAt,
        activityType: _activityType,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Add to-do',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Task',
              hintText: 'Math – Calculus',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
            icon: const Icon(Icons.schedule_outlined),
            label: Text(formatTodoTime(combineDayAndTime(DateTime.now(), _time.hour, _time.minute))),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _activityType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: todoActivityTypes
                .map((String t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                .toList(),
            onChanged: (String? value) {
              if (value != null) setState(() => _activityType = value);
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add to-do'),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showAddTodoSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) => const AddTodoSheet(),
  );
}
