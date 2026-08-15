import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../models/study_summary.dart';
import '../theme/study_theme.dart';
import '../utils/speech_text.dart';
import '../widgets/math_rich_text.dart';
import '../widgets/modern_quiz_view.dart';
import '../widgets/read_aloud_button.dart';
import '../widgets/study_surface.dart';

/// Flip cards from a saved summary.
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
  int _index = 0;
  bool _finished = false;
  bool _endedEarly = false;

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

  int get _score {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) score++;
    }
    return score;
  }

  void _retry() {
    setState(() {
      _index = 0;
      _finished = false;
      _endedEarly = false;
      for (int i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<QuizQuestion> questions = _questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.summary.title)),
        body: const Center(child: Text('No quiz questions yet.')),
      );
    }

    if (_finished) {
      return Scaffold(
        body: ModernQuizResultsView(
          title: widget.summary.title,
          score: _score,
          total: questions.length,
          answeredCount: _answers.where((int? a) => a != null).length,
          endedEarly: _endedEarly,
          onDone: () => Navigator.pop(context),
          onRetry: _retry,
        ),
      );
    }

    final QuizQuestion current = questions[_index];
    final int? selected = _index < _answers.length ? _answers[_index] : null;
    final bool isLast = _index >= questions.length - 1;

    return Scaffold(
      body: ModernQuizView(
        title: widget.summary.title,
        questionNumber: _index + 1,
        totalQuestions: questions.length,
        prompt: current.prompt,
        options: current.options,
        selectedIndex: selected,
        revealed: selected != null,
        correctIndex: current.correctIndex,
        useMath: true,
        onSelect: (int option) => setState(() => _answers[_index] = option),
        onBack: () {
          if (_index > 0) {
            setState(() => _index -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        onNext: () {
          if (isLast) {
            setState(() => _finished = true);
          } else {
            setState(() => _index += 1);
          }
        },
        onEndExam: () async {
          if (!await confirmEndExam(context)) return;
          if (!mounted) return;
          setState(() {
            _endedEarly = true;
            _finished = true;
          });
        },
        nextLabel: isLast ? 'Finish' : 'Next',
        nextEnabled: selected != null,
      ),
    );
  }
}
