import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_summary.dart';
import '../screens/summary_study_screens.dart';
import '../services/notes_summarizer_service.dart';
import '../utils/study_messenger.dart';

/// Opens quiz/flashcards generated from AI study summaries (notes uploads).
class SummaryStudyActions {
  SummaryStudyActions._();

  static StudySummary? latestSummary(List<StudySummary> summaries) {
    if (summaries.isEmpty) return null;
    return summaries.first;
  }

  static Future<StudySummary?> openQuiz(BuildContext context, StudySummary summary) async {
    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
    try {
      final StudySummary ready = await summarizer.ensureStudyMaterials(summary, quizOnly: true);
      if (!context.mounted) return ready;
      if (ready.quizQuestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quiz questions for this study set yet.')),
        );
        return ready;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => SummaryQuizScreen(summary: ready)),
      );
      return ready;
    } catch (error) {
      if (!context.mounted) return null;
      StudyMessenger.showError(context, error);
      return null;
    }
  }

  static Future<StudySummary?> openFlashcards(BuildContext context, StudySummary summary) async {
    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
    try {
      final StudySummary ready = await summarizer.ensureStudyMaterials(summary, flashcardsOnly: true);
      if (!context.mounted) return ready;
      if (ready.flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flashcards for this study set yet.')),
        );
        return ready;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => SummaryFlashcardsScreen(summary: ready)),
      );
      return ready;
    } catch (error) {
      if (!context.mounted) return null;
      StudyMessenger.showError(context, error);
      return null;
    }
  }

  static void promptNoSummaries(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summarize notes first to generate quiz and flashcards.')),
    );
  }
}
