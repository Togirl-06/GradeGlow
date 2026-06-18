import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exam_reminder_option.dart';
import '../models/study_plan.dart';
import '../services/exam_notification_service.dart';
import '../services/study_planner_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';
import '../utils/premium_access.dart';
import '../widgets/study_surface.dart';
import '../utils/study_messenger.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final TextEditingController _courseController = TextEditingController();
  String _examType = ExamTypeOption.choices.first.label;
  String _reminderId = ExamReminderOption.choices[1].id;
  late DateTime _examDateTime;

  @override
  void initState() {
    super.initState();
    final DateTime base = DateTime.now().add(const Duration(days: 14));
    _examDateTime = DateTime(base.year, base.month, base.day, 9, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ExamNotificationService.instance.initialize();
      if (mounted) {
        await context.read<StudyPlannerService>().syncExamNotifications();
      }
    });
  }

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _examDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _examDateTime.hour,
          _examDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _examDateTime.hour, minute: _examDateTime.minute),
    );
    if (picked != null) {
      setState(() {
        _examDateTime = DateTime(
          _examDateTime.year,
          _examDateTime.month,
          _examDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final StudyPlannerService planner = context.watch<StudyPlannerService>();
    final bool isPremium = context.watch<SubscriptionService>().isPremium;
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final ExamDate preview = ExamDate(
      courseCode: '',
      examType: '',
      date: _examDateTime,
      reminderId: _reminderId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Smart study planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Add exam dates and times. You\'ll get reminders before and when each exam starts.',
            style: TextStyle(color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(controller: _courseController, decoration: const InputDecoration(labelText: 'Course code')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _examType,
            decoration: const InputDecoration(labelText: 'Exam type'),
            items: ExamTypeOption.choices
                .map(
                  (ExamTypeOption type) => DropdownMenuItem<String>(
                    value: type.label,
                    child: Text(type.label),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) setState(() => _examType = value);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _reminderId,
            decoration: const InputDecoration(labelText: 'Remind me'),
            items: ExamReminderOption.choices
                .map(
                  (ExamReminderOption option) => DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) setState(() => _reminderId = value);
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Also notifies when the exam starts.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exam date'),
            subtitle: Text(preview.formattedDate),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exam time'),
            subtitle: Text(preview.formattedTime),
            trailing: const Icon(Icons.access_time_outlined),
            onTap: _pickTime,
          ),
          FilledButton(
            onPressed: () async {
              if (_courseController.text.trim().isEmpty) return;
              final ExamScheduleResult result = await planner.addExam(
                ExamDate(
                  courseCode: _courseController.text.trim().toUpperCase(),
                  examType: _examType,
                  date: _examDateTime,
                  reminderId: _reminderId,
                ),
              );
              _courseController.clear();
              if (!context.mounted) return;

              final StringBuffer msg = StringBuffer('Exam added.');
              if (!result.permissionGranted) {
                msg.write(' ${result.message ?? "Allow notifications in settings."}');
              } else if (result.approachingAt != null) {
                final DateTime t = result.approachingAt!.toLocal();
                msg.write(
                  ' Reminder set for ${t.month}/${t.day} at '
                  '${TimeOfDay.fromDateTime(t).format(context)}.',
                );
              } else if (result.startedAt != null) {
                msg.write(' You\'ll be notified when the exam starts.');
              } else {
                msg.write(' ${result.message ?? "Pick a future date/time for reminders."}');
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg.toString()), duration: const Duration(seconds: 4)),
              );
            },
            child: const Text('Add exam'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: planner.isGenerating
                ? null
                : () async {
                    if (!isPremium) {
                      await PremiumAccess.showUpgradeDialog(
                        context,
                        feature: PremiumFeature.studyPlans,
                      );
                      return;
                    }
                    try {
                      await planner.generatePlan();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Study plan generated')),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      StudyMessenger.showError(context, error);
                    }
                  },
            icon: planner.isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome),
            label: Text(planner.isGenerating ? 'Generating…' : 'Generate schedule with AI'),
          ),
          if (!isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'AI-generated personalized schedules require Premium. Manual exam reminders stay free.',
                style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
              ),
            ),
          const SizedBox(height: 24),
          StreamBuilder<List<ExamDate>>(
            stream: planner.watchExams(),
            builder: (BuildContext context, AsyncSnapshot<List<ExamDate>> snap) {
              final List<ExamDate> exams = snap.data ?? <ExamDate>[];
              if (exams.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Your exams', style: TextStyle(fontWeight: FontWeight.w700)),
                  ...exams.map(
                    (ExamDate e) => StudySurfaceCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          '${e.courseCode} · ${e.examType}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: e.completed ? TextDecoration.lineThrough : null,
                            color: e.completed ? textSecondary : null,
                          ),
                        ),
                        subtitle: Text(
                          e.completed
                              ? 'Done · ${e.formattedDateTime}'
                              : '${e.formattedDateTime}\nRemind: ${e.reminderLabel}',
                          style: TextStyle(
                            decoration: e.completed ? TextDecoration.lineThrough : null,
                            height: 1.35,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              tooltip: e.completed ? 'Mark upcoming' : 'Mark done',
                              icon: Icon(
                                e.completed ? Icons.check_circle : Icons.check_circle_outline,
                                color: e.completed ? StudyColors.success : StudyColors.primary,
                              ),
                              onPressed: () => planner.toggleExamDone(e.id, !e.completed),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: Icon(Icons.delete_outline, color: StudyColors.danger),
                              onPressed: () async {
                                await planner.deleteExam(e.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed ${e.courseCode}')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
          StreamBuilder<List<StudyPlanTask>>(
            stream: planner.watchTasks(),
            builder: (BuildContext context, AsyncSnapshot<List<StudyPlanTask>> snap) {
              final List<StudyPlanTask> tasks = snap.data ?? <StudyPlanTask>[];
              if (tasks.isEmpty) {
                return Text('No tasks yet — add exams and generate.', style: TextStyle(color: textSecondary));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...tasks.asMap().entries.map(
                        (MapEntry<int, StudyPlanTask> entry) {
                          final StudyPlanTask task = entry.value;
                          return StudySurfaceCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: task.completed,
                              onChanged: (_) => planner.toggleTask(task, entry.key, tasks),
                              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${task.date.toLocal().toString().split(' ').first} · ${task.courseCode}',
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          );
                        },
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
