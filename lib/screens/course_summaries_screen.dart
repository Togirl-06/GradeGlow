import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../services/notes_summarizer_service.dart';
import '../theme/study_theme.dart';
import '../utils/course_summary_actions.dart';
import '../utils/study_messenger.dart';

/// Full-screen list of saved study sets for one course.
class CourseSummariesScreen extends StatelessWidget {
  const CourseSummariesScreen({
    super.key,
    required this.course,
  });

  final Course course;

  Future<void> _renameSummary(BuildContext context, StudySummary summary) async {
    final String? newTitle = await CourseSummaryActions.promptRenameTitle(context, summary.title);
    if (newTitle == null || !context.mounted) return;

    try {
      await context.read<NotesSummarizerService>().renameSummary(summary.id, newTitle);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note renamed')));
    } catch (error) {
      if (!context.mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _deleteSummary(BuildContext context, StudySummary summary) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete summary?'),
        content: Text('Remove "${summary.title}"? This cannot be undone.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: StudyColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<NotesSummarizerService>().deleteSummary(summary.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Summary deleted')));
    } catch (error) {
      if (!context.mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _openSummary(BuildContext context, StudySummary summary) async {
    await CourseSummaryActions.openGeneratedNote(context, summary);
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final NotesSummarizerService summarizer = context.watch<NotesSummarizerService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${course.code} summaries'),
      ),
      body: StreamBuilder<List<StudySummary>>(
        stream: summarizer.watchSummaries(),
        builder: (BuildContext context, AsyncSnapshot<List<StudySummary>> snapshot) {
          final List<StudySummary> items =
              NotesSummarizerService.summariesForCourse(snapshot.data ?? <StudySummary>[], course);

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No summaries yet. Add one from Study sets or this course.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary, height: 1.4),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (BuildContext context, int index) {
              final StudySummary summary = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.description_outlined, color: StudyColors.primary),
                title: Text(summary.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  summary.createdAt.toLocal().toString().split('.').first,
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Actions',
                  icon: Icon(Icons.more_vert_rounded, color: textSecondary),
                  onSelected: (String action) {
                    switch (action) {
                      case 'rename':
                        _renameSummary(context, summary);
                      case 'delete':
                        _deleteSummary(context, summary);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: 'rename', child: Text('Rename')),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: StudyColors.danger)),
                    ),
                  ],
                ),
                onTap: () => _openSummary(context, summary),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CourseSummaryActions.addSummaryNote(context, course),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add summary'),
      ),
    );
  }
}
