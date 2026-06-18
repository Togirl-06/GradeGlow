import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_item.dart';
import '../models/quiz_question.dart';
import '../services/notes_service.dart';
import '../services/quiz_service.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';
import '../utils/study_messenger.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  NoteItem? _selectedNote;
  bool _quizGenerated = false;
  int _currentQuestion = 0;
  List<QuizQuestion> _questions = <QuizQuestion>[];

  Future<void> _generateQuiz(QuizService quiz) async {
    if (_selectedNote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a note to generate a quiz.')),
      );
      return;
    }

    try {
      final List<QuizQuestion> questions = await quiz.generateFromNote(_selectedNote!.name);
      if (!mounted) return;
      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions were generated. Try again.')),
        );
        return;
      }
      setState(() {
        _questions = questions;
        _quizGenerated = true;
        _currentQuestion = 0;
      });
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuizService quiz = context.watch<QuizService>();
    final NotesService notes = context.watch<NotesService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    if (_quizGenerated && _questions.isNotEmpty) {
      final QuizQuestion question = _questions[_currentQuestion];
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => setState(() => _quizGenerated = false),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  'Question ${_currentQuestion + 1} of ${_questions.length}',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.prompt,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(question.options.length, (int index) {
            return StudySurfaceCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text('${String.fromCharCode(65 + index)}   ${question.options[index]}'),
            );
          }),
          const SizedBox(height: 16),
          if (_currentQuestion < _questions.length - 1)
            FilledButton(
              onPressed: () => setState(() => _currentQuestion++),
              child: const Text('Next question'),
            )
          else
            FilledButton(
              onPressed: () => setState(() {
                _quizGenerated = false;
                _currentQuestion = 0;
              }),
              child: const Text('Finish quiz'),
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text('Quiz', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Generate quizzes from your uploaded notes', style: TextStyle(color: textSecondary)),
        const SizedBox(height: 20),
        const Text('1. Select a note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        StreamBuilder<List<NoteItem>>(
          stream: notes.watchNotes(),
          builder: (BuildContext context, AsyncSnapshot<List<NoteItem>> snapshot) {
            final List<NoteItem> items = snapshot.data ?? <NoteItem>[];
            if (items.isEmpty) {
              return StudySurfaceCard(
                child: Text(
                  'Upload a note first, then generate a quiz.',
                  style: TextStyle(color: textSecondary),
                ),
              );
            }
            return Column(
              children: items
                  .map(
                    (NoteItem note) => _NoteOption(
                      title: note.name,
                      selected: _selectedNote?.id == note.id,
                      onTap: () => setState(() => _selectedNote = note),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: quiz.isGenerating ? null : () => _generateQuiz(quiz),
            icon: quiz.isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(quiz.isGenerating ? 'Generating…' : 'Generate quiz with AI'),
          ),
        ),
        const SizedBox(height: 24),
        Text('Recent quizzes', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        StreamBuilder<List<QuizRecord>>(
          stream: quiz.watchQuizzes(),
          builder: (BuildContext context, AsyncSnapshot<List<QuizRecord>> snapshot) {
            final List<QuizRecord> records = snapshot.data ?? <QuizRecord>[];
            if (records.isEmpty) {
              return StudySurfaceCard(
                child: Text('No quizzes yet.', style: TextStyle(color: textSecondary)),
              );
            }
            return Column(
              children: records
                  .map(
                    (QuizRecord record) => StudySurfaceCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.quiz_outlined, color: StudyColors.primary),
                        title: Text(record.noteName),
                        subtitle: Text('${record.questionCount} questions'),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _NoteOption extends StatelessWidget {
  const _NoteOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudySurfaceCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? StudyColors.primary : StudyColors.textSecondary(Theme.of(context).brightness),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          const Icon(Icons.picture_as_pdf_rounded, color: StudyColors.pdfRed, size: 20),
        ],
      ),
    );
  }
}
