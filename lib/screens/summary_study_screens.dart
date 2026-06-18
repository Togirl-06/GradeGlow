import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../models/study_summary.dart';
import '../theme/study_theme.dart';
import '../utils/speech_text.dart';
import '../widgets/math_rich_text.dart';
import '../widgets/read_aloud_button.dart';
import '../widgets/study_surface.dart';

/// Quizlet-style flip cards from a saved summary.
class SummaryFlashcardsScreen extends StatefulWidget {
  const SummaryFlashcardsScreen({super.key, required this.summary});

  final StudySummary summary;

  @override
  State<SummaryFlashcardsScreen> createState() => _SummaryFlashcardsScreenState();
}

class _SummaryFlashcardsScreenState extends State<SummaryFlashcardsScreen> {
  int _index = 0;
  bool _flipped = false;

  List<Map<String, String>> get _cards => widget.summary.flashcards;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.summary.title)),
        body: const Center(child: Text('No flashcards yet.')),
      );
    }

    final Map<String, String> card = _cards[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards · ${_index + 1}/${_cards.length}'),
        actions: <Widget>[
          ReadAloudButton(
            key: ValueKey<String>('$_index-$_flipped'),
            textBuilder: () => speechTextFromMarkdown(
              _flipped ? (card['back'] ?? '') : (card['front'] ?? ''),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(widget.summary.title, style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _flipped = !_flipped),
                child: StudySurfaceCard(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _flipped ? 'Answer' : 'Term',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: StudyColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MathRichText(
                            text: _flipped ? (card['back'] ?? '') : (card['front'] ?? ''),
                            color: StudyColors.textPrimary(Theme.of(context).brightness),
                            fontSize: 20,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text('Tap to flip', style: TextStyle(color: textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _index == 0
                        ? null
                        : () => setState(() {
                              _index -= 1;
                              _flipped = false;
                            }),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _index >= _cards.length - 1
                        ? null
                        : () => setState(() {
                              _index += 1;
                              _flipped = false;
                            }),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Multiple-choice quiz from AI-generated summary questions.
class SummaryQuizScreen extends StatefulWidget {
  const SummaryQuizScreen({super.key, required this.summary});

  final StudySummary summary;

  @override
  State<SummaryQuizScreen> createState() => _SummaryQuizScreenState();
}

class _SummaryQuizScreenState extends State<SummaryQuizScreen> {
  final List<int?> _answers = <int?>[];
  bool _submitted = false;

  List<QuizQuestion> get _questions {
    return widget.summary.quizQuestions
        .map((Map<String, dynamic> m) => QuizQuestion.fromJson(m))
        .where((QuizQuestion q) => q.prompt.isNotEmpty && q.options.length >= 2)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _answers.addAll(List<int?>.filled(_questions.length, null));
  }

  void _submit() {
    setState(() => _submitted = true);
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) score++;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Score: $score / ${_questions.length}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final List<QuizQuestion> questions = _questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.summary.title)),
        body: const Center(child: Text('No quiz questions yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quiz · ${widget.summary.title}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            '${questions.length} AI-generated questions',
            style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...List<Widget>.generate(questions.length, (int i) {
            final QuizQuestion q = questions[i];
            final int? selected = i < _answers.length ? _answers[i] : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StudySurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${i + 1}. ', style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35)),
                        Expanded(
                          child: MathRichText(
                            text: q.prompt,
                            color: StudyColors.textPrimary(Theme.of(context).brightness),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List<Widget>.generate(q.options.length, (int o) {
                      final bool isCorrect = o == q.correctIndex;
                      final bool isSelected = selected == o;
                      Color? tileColor;
                      if (_submitted && isCorrect) tileColor = StudyColors.success.withValues(alpha: 0.15);
                      if (_submitted && isSelected && !isCorrect) {
                        tileColor = StudyColors.danger.withValues(alpha: 0.12);
                      }
                      return ListTile(
                        dense: true,
                        tileColor: tileColor,
                        title: MathRichText(
                          text: q.options[o],
                          color: StudyColors.textPrimary(Theme.of(context).brightness),
                          fontSize: 15,
                          height: 1.35,
                        ),
                        leading: Radio<int>(
                          value: o,
                          groupValue: selected,
                          onChanged: _submitted
                              ? null
                              : (int? v) => setState(() => _answers[i] = v),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
          if (!_submitted)
            FilledButton(
              onPressed: _answers.every((int? a) => a != null) ? _submit : null,
              child: const Text('Submit & grade'),
            ),
        ],
      ),
    );
  }
}
