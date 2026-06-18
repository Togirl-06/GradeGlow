import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../theme/study_theme.dart';
import '../utils/course_summary_actions.dart';
import '../utils/study_content_input_actions.dart';
import 'study_input_cards.dart';

class RecordStartIntent {
  const RecordStartIntent({required this.course, required this.title});

  final Course course;
  final String title;
}

/// Upload PDF or slides and attach the summary to an enrolled course.
class SummarizeForCourseSheet extends StatefulWidget {
  const SummarizeForCourseSheet({super.key, required this.course});

  final Course course;

  static Future<void> show(BuildContext context, Course course) async {
    final Object? result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => SummarizeForCourseSheet(course: course),
    );

    if (!context.mounted) return;

    if (result is RecordStartIntent) {
      await StudyContentInputActions.startRecording(
        context,
        course: result.course,
        title: result.title,
      );
    }
  }

  @override
  State<SummarizeForCourseSheet> createState() => _SummarizeForCourseSheetState();
}

class _SummarizeForCourseSheetState extends State<SummarizeForCourseSheet> {
  final TextEditingController _titleController = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = StudyContentInputActions.defaultTitle(widget.course);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _title {
    final String value = _titleController.text.trim();
    return value.isEmpty ? StudyContentInputActions.defaultTitle(widget.course) : value;
  }

  Future<void> _run(Future<StudySummary?> Function() action) async {
    setState(() => _busy = true);
    try {
      final StudySummary? summary = await action();
      if (!mounted || summary == null) return;
      Navigator.pop(context);
      await CourseSummaryActions.openGeneratedNote(context, summary);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final Course course = widget.course;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StudyColors.border(Theme.of(context).brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(course.code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            if (course.professor.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(course.professor, style: TextStyle(color: textSecondary)),
              ),
            const SizedBox(height: 12),
            Text(
              'Upload anything and get interactive notes, flashcards, quizzes, and more',
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              enabled: !_busy,
              decoration: const InputDecoration(labelText: 'Title / topic'),
            ),
            const SizedBox(height: 16),
            StudyInputCards(
              enabled: !_busy,
              onUpload: () => _run(() => StudyContentInputActions.upload(context, course: course, title: _title)),
              onPaste: () => StudyContentInputActions.paste(
                context,
                course: course,
                title: _title,
                successPopCount: 2,
              ),
              onRecord: _busy
                  ? null
                  : () => Navigator.pop(
                        context,
                        RecordStartIntent(course: course, title: _title),
                      ),
            ),
            if (_busy) ...<Widget>[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Center(child: Text('Building your study set…', style: TextStyle(color: textSecondary))),
            ],
          ],
        ),
      ),
    );
  }
}
