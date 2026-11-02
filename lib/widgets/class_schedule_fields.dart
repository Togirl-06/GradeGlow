import 'package:flutter/material.dart';

import '../models/course_schedule.dart';
import '../models/exam_reminder_option.dart';
import '../theme/study_theme.dart';
import '../utils/schedule_format.dart';

/// Weekday chips, class time picker, and reminder dropdown.
class ClassScheduleFields extends StatelessWidget {
  const ClassScheduleFields({
    super.key,
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
    required this.time,
    required this.onTimeChanged,
    required this.reminderId,
    required this.onReminderChanged,
  });

  final Set<int> selectedWeekdays;
  final ValueChanged<Set<int>> onWeekdaysChanged;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final String reminderId;
  final ValueChanged<String> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text('Class days', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List<Widget>.generate(7, (int index) {
            final int day = index + 1;
            final bool selected = selectedWeekdays.contains(day);
            return FilterChip(
              label: Text(weekdayShortLabels[index]),
              selected: selected,
              onSelected: (bool value) {
                final Set<int> next = Set<int>.from(selectedWeekdays);
                if (value) {
                  next.add(day);
                } else {
                  next.remove(day);
                }
                onWeekdaysChanged(next);
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        const Text('Class time', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) onTimeChanged(picked);
          },
          icon: const Icon(Icons.schedule_outlined),
          label: Text(formatTimeOfDay(time.hour, time.minute)),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Remind me', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Get notified before class starts', style: TextStyle(color: textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: reminderId,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.notifications_active_outlined),
          ),
          items: classReminderChoices()
              .map(
                (ExamReminderOption option) => DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: (String? value) {
            if (value != null) onReminderChanged(value);
          },
        ),
      ],
    );
  }
}

CourseSchedule buildScheduleFromFields({
  required String courseId,
  required Set<int> weekdays,
  required TimeOfDay time,
  required String reminderId,
}) {
  return CourseSchedule(
    courseId: courseId,
    weekdays: weekdays.toList()..sort(),
    hour: time.hour,
    minute: time.minute,
    reminderId: reminderId,
  );
}
