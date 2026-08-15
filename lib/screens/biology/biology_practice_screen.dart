import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/math_practice_question.dart';
import '../../models/biology_degree.dart';
import '../../services/biology_progress_service.dart';
import '../../services/biology_question_service.dart';
import '../../services/openai_service.dart';
import '../../theme/biology_degree_theme.dart';
import '../../widgets/tutor_markdown_body.dart';

class BiologyPracticeScreen extends StatefulWidget {
  const BiologyPracticeScreen({
    super.key,
    required this.path,
    required this.kind,
  });

  final BiologyLessonPath path;
  final BioLessonActivityKind kind;

  @override
  State<BiologyPracticeScreen> createState() =>
      _BiologyPracticeScreenState();
}

class _BiologyPracticeScreenState extends State<BiologyPracticeScreen> {
  final TextEditingController _answerController = TextEditingController();

  List<MathPracticeQuestion> _questions = <MathPracticeQuestion>[];
  final List<MathPracticeAnswer> _answers = <MathPracticeAnswer>[];
  int _index = 0;
  int? _selectedOption;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  bool _finished = false;
  bool? _examPassed;
  int _correctCount = 0;
  int _attemptSeed = 0;

  bool get _isExam => widget.kind == BioLessonActivityKind.exam;

  @override
  void initState() {
    super.initState();
    _attemptSeed = context.read<BiologyProgressService>().nextExamAttemptSeed();
    _load();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final BiologyQuestionService service = BiologyQuestionService(
        context.read<OpenAiService>(),
        context.read<BiologyProgressService>(),
      );
      final List<MathPracticeQuestion> questions = await service.loadForActivity(
        path: widget.path,
        kind: widget.kind,
        attemptSeed: _attemptSeed,
      );
      if (!mounted) return;
      if (questions.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Could not load questions. Try again.';
        });
        return;
      }
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  MathPracticeQuestion? get _current =>
      _index < _questions.length ? _questions[_index] : null;

  Future<void> _submit() async {
    final MathPracticeQuestion? question = _current;
    if (question == null || _submitting) return;

    String answer;
    if (question.isMultipleChoice) {
      if (_selectedOption == null) return;
      answer = _selectedOption.toString();
    } else {
      answer = _answerController.text.trim();
      if (answer.isEmpty) return;
    }

    setState(() => _submitting = true);
    try {
      final BiologyQuestionService service = BiologyQuestionService(
        context.read<OpenAiService>(),
        context.read<BiologyProgressService>(),
      );
      final bool correct = await service.gradeAnswer(
        question: question,
        answer: question.isMultipleChoice
            ? question.options[int.parse(answer)]
            : answer,
        topicName: widget.path.lesson.title,
      );

      if (!mounted) return;
      setState(() {
        _answers.add(
          MathPracticeAnswer(
            question: question,
            studentAnswer: question.isMultipleChoice
                ? question.options[int.parse(answer)]
                : answer,
            isCorrect: correct,
          ),
        );
        if (correct) _correctCount += 1;
        _submitting = false;
        _selectedOption = null;
        _answerController.clear();
      });

      if (_index + 1 >= _questions.length) {
        await _finishSession();
      } else {
        setState(() => _index += 1);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not grade answer: $e')),
      );
    }
  }

  Future<void> _finishSession() async {
    final BiologyQuestionService service = BiologyQuestionService(
      context.read<OpenAiService>(),
      context.read<BiologyProgressService>(),
    );
    await service.recordSession(
      lessonId: widget.path.lesson.id,
      questions: _questions,
    );

    if (_isExam) {
      final bool passed =
          _correctCount >= BiologyQuestionService.examPassThreshold;
      setState(() {
        _finished = true;
        _examPassed = passed;
      });
    } else {
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  void _retryExam() {
    setState(() {
      _questions = <MathPracticeQuestion>[];
      _answers.clear();
      _index = 0;
      _correctCount = 0;
      _finished = false;
      _examPassed = null;
      _attemptSeed = context.read<BiologyProgressService>().nextExamAttemptSeed();
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.path.lesson.title} · ${widget.kind.label}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : _finished && _isExam
                  ? _ExamResults(
                      correct: _correctCount,
                      total: _questions.length,
                      passed: _examPassed ?? false,
                      onRetry: _retryExam,
                      onDone: () => Navigator.of(context).pop(_examPassed == true),
                    )
                  : _QuestionView(
                      question: _current!,
                      index: _index,
                      total: _questions.length,
                      selectedOption: _selectedOption,
                      answerController: _answerController,
                      submitting: _submitting,
                      onSelect: (int i) => setState(() => _selectedOption = i),
                      onSubmit: _submit,
                    ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selectedOption,
    required this.answerController,
    required this.submitting,
    required this.onSelect,
    required this.onSubmit,
  });

  final MathPracticeQuestion question;
  final int index;
  final int total;
  final int? selectedOption;
  final TextEditingController answerController;
  final bool submitting;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (index + 1) / total,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: c.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${index + 1}/$total',
              style: TextStyle(
                color: c.primaryLight,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _Tag(
              label: question.difficulty.label,
              color: c.primary,
            ),
            _Tag(
              label: switch (question.kind) {
                MathPracticeQuestionKind.multipleChoice => 'Multiple choice',
                MathPracticeQuestionKind.graph => 'Graph',
                MathPracticeQuestionKind.freeResponse => 'Solve',
              },
              color: c.primary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: c.cardDecoration(),
          child: TutorMarkdownBody(text: question.prompt),
        ),
        if (question.kind == MathPracticeQuestionKind.graph) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: c.cardDecoration(),
            child: CustomPaint(
              painter: _GraphGridPainter(primary: c.primary),
              child: const SizedBox.expand(),
            ),
          ),
          if (question.graphNote != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                question.graphNote!,
                style: TextStyle(
                  color: c.textPrimary.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ),
        ],
        const SizedBox(height: 20),
        if (question.isMultipleChoice)
          ...List<Widget>.generate(question.options.length, (int i) {
            final bool selected = selectedOption == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: submitting ? null : () => onSelect(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: selected
                          ? c.primary.withValues(alpha: 0.2)
                          : c.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? c.primary
                            : c.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      children: <Widget>[
                        Text(
                          String.fromCharCode(65 + i),
                          style: TextStyle(
                            color: c.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.options[i],
                            style: TextStyle(color: c.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
        else
          TextField(
            controller: answerController,
            maxLines: question.kind == MathPracticeQuestionKind.graph ? 4 : 3,
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: question.kind == MathPracticeQuestionKind.graph
                  ? 'Describe the graph or key features…'
                  : 'Your answer…',
              hintStyle: TextStyle(color: c.textPrimary.withValues(alpha: 0.4)),
              filled: true,
              fillColor: c.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: c.primary.withValues(alpha: 0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: c.primary),
              ),
            ),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: submitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              submitting
                  ? 'Checking…'
                  : index + 1 >= total
                      ? 'Finish'
                      : 'Next',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExamResults extends StatelessWidget {
  const _ExamResults({
    required this.correct,
    required this.total,
    required this.passed,
    required this.onRetry,
    required this.onDone,
  });

  final int correct;
  final int total;
  final bool passed;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
            size: 72,
            color: passed ? c.primary : c.textPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            passed ? 'Certificate earned!' : 'Exam not passed',
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Score: $correct / $total',
            style: TextStyle(
              color: c.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passed
                ? 'You scored at least ${BiologyQuestionService.examPassThreshold} correct. Well done!'
                : 'You need ${BiologyQuestionService.examPassThreshold} or more correct to earn your certificate. Try again with new questions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textPrimary.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          if (!passed)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Retry exam', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          if (!passed) const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDone,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.textPrimary,
                side: BorderSide(color: c.primary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                passed ? 'Done' : 'Back to lesson',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

class _GraphGridPainter extends CustomPainter {
  _GraphGridPainter({required this.primary});

  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    final Paint axis = Paint()
      ..color = primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;

    for (var i = 1; i < 8; i++) {
      final double x = size.width * i / 8;
      final double y = size.height * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axis);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), axis);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
