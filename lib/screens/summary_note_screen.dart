import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_summary.dart';
import '../services/notes_summarizer_service.dart';
import '../services/subscription_service.dart';
import '../utils/course_summary_actions.dart';
import '../utils/premium_access.dart';
import '../utils/summary_study_actions.dart';
import '../theme/study_theme.dart';
import '../widgets/read_aloud_button.dart';
import '../widgets/study_surface.dart';
import '../widgets/tutor_markdown_body.dart';
import '../utils/study_messenger.dart';

/// Full summary note for a saved PDF/slides upload.
class SummaryNoteScreen extends StatefulWidget {
  const SummaryNoteScreen({super.key, required this.summary});

  final StudySummary summary;

  @override
  State<SummaryNoteScreen> createState() => _SummaryNoteScreenState();
}

class _SummaryNoteScreenState extends State<SummaryNoteScreen> {
  late StudySummary _summary;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _summary = widget.summary;
  }

  Future<void> _openFlashcards() async {
    final StudySummary? ready = await SummaryStudyActions.openFlashcards(context, _summary);
    if (!mounted || ready == null) return;
    setState(() => _summary = ready);
  }

  Future<void> _openQuiz() async {
    final StudySummary? ready = await SummaryStudyActions.openQuiz(context, _summary);
    if (!mounted || ready == null) return;
    setState(() => _summary = ready);
  }

  Future<void> _rename() async {
    final String? newTitle = await CourseSummaryActions.promptRenameTitle(context, _summary.title);
    if (newTitle == null || !mounted) return;

    try {
      await context.read<NotesSummarizerService>().renameSummary(_summary.id, newTitle);
      if (!mounted) return;
      setState(() => _summary = _summary.copyWith(title: newTitle));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note renamed')));
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _regenerate() async {
    final SubscriptionService subs = context.read<SubscriptionService>();
    if (!subs.isPremium) {
      await PremiumAccess.showUpgradeDialog(context, feature: PremiumFeature.studyGuides);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Regenerate study set?'),
        content: const Text(
          'This will rebuild your notes, flashcards, and quiz from the original content. '
          'It may take a minute and uses your OpenAI quota.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Regenerate')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();

    try {
      final StudySummary updated = await summarizer.regenerateSummary(_summary);
      if (!mounted) return;
      setState(() => _summary = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study set regenerated')),
      );
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Plain text the Listen button reads aloud: title, notes, then key concepts.
  String _spokenNotes() {
    final StringBuffer buffer = StringBuffer()
      ..writeln(_summary.title)
      ..writeln(_summary.cheatSheet);
    if (_summary.keyConcepts.isNotEmpty) {
      buffer
        ..writeln('Key concepts.')
        ..writeln(_summary.keyConcepts.join('. '));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final bool canAct = !_busy;

    return Scaffold(
      appBar: AppBar(
        title: Text(_summary.title),
        actions: <Widget>[
          ReadAloudButton(textBuilder: _spokenNotes),
          IconButton(
            tooltip: 'Rename',
            icon: const Icon(Icons.edit_outlined),
            onPressed: canAct ? _rename : null,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (_summary.courseCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _summary.courseCode,
                    style: TextStyle(fontWeight: FontWeight.w800, color: StudyColors.primary),
                  ),
                ),
              if (_summary.category.isNotEmpty)
                Text(_summary.category, style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              const Text('Study notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              StudySurfaceCard(
                child: TutorMarkdownBody(text: _summary.cheatSheet),
              ),
              if (_summary.keyConcepts.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                const Text('Key concepts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _summary.keyConcepts
                      .map((String c) => Chip(label: Text(c), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: canAct ? _regenerate : null,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Regenerate'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canAct ? _openQuiz : null,
                      icon: const Icon(Icons.quiz_outlined),
                      label: Text(_summary.quizQuestions.isEmpty ? 'Quiz' : 'Quiz (${_summary.quizQuestions.length})'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canAct ? _openFlashcards : null,
                      icon: const Icon(Icons.style_outlined),
                      label: Text(
                        _summary.flashcards.isEmpty ? 'Flashcards' : 'Cards (${_summary.flashcards.length})',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x66FFFFFF),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Regenerating study set…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
