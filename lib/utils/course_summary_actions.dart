import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../screens/course_summaries_screen.dart';
import '../screens/summary_note_screen.dart';
import '../services/notes_summarizer_service.dart';
import '../widgets/summarize_for_course_sheet.dart';

/// View or add PDF summaries for an enrolled course.
class CourseSummaryActions {
  CourseSummaryActions._();

  static Future<void> addSummaryNote(BuildContext context, Course course) {
    return SummarizeForCourseSheet.show(context, course);
  }

  static Future<void> openGeneratedNote(BuildContext context, StudySummary summary) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => SummaryNoteScreen(summary: summary)),
    );
  }

  static Future<String?> promptRenameTitle(BuildContext context, String currentTitle) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => _RenameTitleDialog(initialTitle: currentTitle),
    );
  }

  static Future<void> viewSummaryNote(
    BuildContext context,
    Course course,
    List<StudySummary> summaries,
  ) async {
    final List<StudySummary> matches = NotesSummarizerService.summariesForCourse(summaries, course);
    if (matches.isEmpty) {
      final bool? addNow = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('No summary for ${course.code}'),
          content: const Text('Upload a PDF or slides to create an AI summary for this class.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add summary')),
          ],
        ),
      );
      if (addNow == true && context.mounted) {
        await addSummaryNote(context, course);
      }
      return;
    }

    if (matches.length == 1) {
      await openGeneratedNote(context, matches.first);
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => CourseSummariesScreen(course: course)),
    );
  }
}

class _RenameTitleDialog extends StatefulWidget {
  const _RenameTitleDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameTitleDialog> createState() => _RenameTitleDialogState();
}

class _RenameTitleDialogState extends State<_RenameTitleDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename note'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Title'),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
