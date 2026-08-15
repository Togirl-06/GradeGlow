import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/law/law_program.dart';
import '../../models/quiz_question.dart';
import '../../services/law_lecture_notes_service.dart';
import '../../services/openai_service.dart';
import '../../theme/law_theme.dart';
import '../../utils/study_messenger.dart';

/// Quiz generated from AI professor lecture notes for this topic.
class LawExamScreen extends StatefulWidget {
  const LawExamScreen({super.key, required this.lesson, this.courseTitle});

  final LawLesson lesson;
  final String? courseTitle;

  @override
  State<LawExamScreen> createState() => _LawExamScreenState();
}

class _LawExamScreenState extends State<LawExamScreen> {
  List<QuizQuestion> _questions = <QuizQuestion>[];
  final List<int?> _answers = <int?>[];
  int _index = 0;
  bool _loading = true;
  bool _finished = false;
  String? _error;
  int? _revealed;
  bool _fromSavedNotes = false;

  String get _courseTitle => widget.courseTitle ?? 'Law School';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<QuizQuestion> _offlineQuizFromNotes(String notes) {
    final LawLesson l = widget.lesson;
    final List<String> els = l.elements;
    final String e0 = els.isNotEmpty ? els.first : 'the first element';
    final String e1 = els.length > 1 ? els[1] : 'the next element';
    final String eLast = els.isNotEmpty ? els.last : 'each element';
    final String snippet = notes.replaceAll(RegExp(r'\s+'), ' ').trim();
    final String noteBite = snippet.length > 100 ? '${snippet.substring(0, 100)}…' : snippet;
    return <QuizQuestion>[
      QuizQuestion(
        prompt: 'According to the AI notes for "${l.title}", what dispute opens the lesson?',
        options: <String>[
          l.hook.length > 90 ? '${l.hook.substring(0, 90)}…' : l.hook,
          'A tax audit with no facts',
          'A sports eligibility appeal only',
          'A maritime salvage claim only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which guiding question do the notes ask you to answer first?',
        options: <String>[
          l.question,
          'Who wins on sympathy alone?',
          'What is the maximum damages number?',
          'Which judge is easiest?',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which doctrine element appears in the AI notes checklist?',
        options: <String>[
          e0,
          'Jury nullification as a required element',
          'Always file in federal court first',
          'Ignore the facts and recite blackletter only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which is also covered in the notes\' elements?',
        options: <String>[
          e1,
          'The judge\'s personal politics',
          'Social media popularity',
          'Whether the client is likeable',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'How do the notes say you should use the doctrine?',
        options: <String>[
          'Apply each element to the hook facts',
          'Skip elements and argue policy only',
          'Copy a generic outline with no facts',
          'Ask the court to invent new elements',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'A common mistake flagged by these notes is to…',
        options: <String>[
          'Recite $eLast without tying it to the facts',
          'Define every term in plain English',
          'Apply $e1 carefully to both sides',
          'Spot the weakest element for each side',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which best reflects content from your saved AI notes?',
        options: <String>[
          noteBite.isEmpty ? l.doctrine : noteBite,
          'Ignore the lecture and only memorize case names',
          'Settlement is always better than learning the rule',
          'Elements never matter if the story is emotional',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Best next step after studying these AI notes?',
        options: <String>[
          'Retake the quiz, then practice writing or courtroom',
          'Delete the notes and skip the elements',
          'Memorize case names without rules',
          'Skip the dispute and read an unrelated treatise',
        ],
        correctIndex: 0,
      ),
    ];
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _finished = false;
      _index = 0;
      _revealed = null;
      _answers.clear();
      _questions = <QuizQuestion>[];
      _fromSavedNotes = false;
    });
    try {
      final String? saved = await LawLectureNotesService.instance.loadNotes(
        courseTitle: _courseTitle,
        lessonId: widget.lesson.id,
      );
      final String notes = await LawLectureNotesService.instance.notesForQuiz(
        courseTitle: _courseTitle,
        lesson: widget.lesson,
      );
      final bool usedSaved = saved != null && saved.trim().length >= 80;
      List<QuizQuestion> qs;
      if (AppConfig.hasOpenAi) {
        if (!mounted) return;
        final OpenAiService openAi = context.read<OpenAiService>();
        qs = await openAi.lawQuizFromNotes(
          title: '$_courseTitle — ${widget.lesson.title}',
          notes: notes,
        );
        if (qs.length < 3) qs = _offlineQuizFromNotes(notes);
      } else {
        qs = _offlineQuizFromNotes(notes);
      }
      if (!mounted) return;
      setState(() {
        _questions = qs;
        _answers.addAll(List<int?>.filled(qs.length, null));
        _fromSavedNotes = usedSaved;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final String notes = LawLectureNotesService.fallbackNotes(
        courseTitle: _courseTitle,
        lesson: widget.lesson,
      );
      setState(() {
        _questions = _offlineQuizFromNotes(notes);
        _answers
          ..clear()
          ..addAll(List<int?>.filled(_questions.length, null));
        _loading = false;
        _error = StudyMessenger.clean(e);
      });
    }
  }

  int get _score {
    int n = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) n++;
    }
    return n;
  }

  void _pick(int option) {
    if (_finished || _revealed != null) return;
    setState(() {
      _answers[_index] = option;
      _revealed = option;
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index += 1;
      _revealed = _answers[_index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawTheme.background,
      appBar: AppBar(
        backgroundColor: LawTheme.bench,
        foregroundColor: Colors.white,
        title: const Text('Professor Topic Quiz'),
        actions: <Widget>[
          if (!_loading && _questions.isNotEmpty)
            TextButton(
              onPressed: _load,
              child: const Text('New quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _finished
              ? _buildResults()
              : _buildQuestion(),
    );
  }

  Widget _buildResults() {
    final int total = _questions.length;
    final int score = _score;
    final bool strong = score >= (total * 0.7).ceil();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      children: <Widget>[
        Icon(
          strong ? Icons.emoji_events_outlined : Icons.school_outlined,
          size: 48,
          color: LawTheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          '$score / $total',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: LawTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          strong
              ? 'Solid grasp of the AI notes on ${widget.lesson.title}.'
              : 'Re-read the AI Professor notes, then retry this quiz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: LawTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _load,
          style: FilledButton.styleFrom(
            backgroundColor: LawTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Retake quiz', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to lesson'),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    if (_questions.isEmpty) {
      return Center(
        child: Text(_error ?? 'No questions available.', style: TextStyle(color: LawTheme.textSecondary)),
      );
    }
    final QuizQuestion q = _questions[_index];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        Text(
          _fromSavedNotes
              ? 'Quiz from your AI Professor notes'
              : 'Quiz from topic study notes — open AI Professor first for a lecture-based quiz',
          style: TextStyle(color: LawTheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          widget.lesson.title,
          style: TextStyle(color: LawTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 8),
          Text('Using offline quiz ($_error)', style: TextStyle(color: LawTheme.textSecondary, fontSize: 11)),
        ],
        const SizedBox(height: 14),
        Text(
          'Question ${_index + 1} of ${_questions.length}',
          style: TextStyle(color: LawTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LawTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LawTheme.border),
          ),
          child: Text(q.prompt, style: TextStyle(color: LawTheme.textPrimary, height: 1.45, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 14),
        ...List<Widget>.generate(q.options.length, (int i) {
          final bool selected = _revealed == i;
          final bool showCorrect = _revealed != null && i == q.correctIndex;
          final bool showWrong = selected && i != q.correctIndex;
          Color border = LawTheme.border;
          Color? fill;
          if (showCorrect) {
            border = LawTheme.success;
            fill = LawTheme.success.withValues(alpha: 0.1);
          } else if (showWrong) {
            border = Colors.redAccent;
            fill = Colors.redAccent.withValues(alpha: 0.08);
          } else if (selected) {
            border = LawTheme.primary;
            fill = LawTheme.primary.withValues(alpha: 0.08);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: fill ?? LawTheme.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _revealed == null ? () => _pick(i) : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Text(q.options[i], style: TextStyle(color: LawTheme.textPrimary, height: 1.35)),
                ),
              ),
            ),
          );
        }),
        if (_revealed != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _revealed == q.correctIndex ? 'Correct.' : 'Not quite — review the highlighted answer.',
            style: TextStyle(
              color: _revealed == q.correctIndex ? LawTheme.success : Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
              backgroundColor: LawTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _index >= _questions.length - 1 ? 'See results' : 'Next question',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }
}
