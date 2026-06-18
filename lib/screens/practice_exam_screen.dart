import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_question.dart';
import '../services/practice_exam_service.dart';
import '../theme/study_theme.dart';
import '../widgets/premium_gate.dart';
import '../widgets/study_surface.dart';
import '../utils/study_messenger.dart';

class PracticeExamScreen extends StatefulWidget {
  const PracticeExamScreen({super.key});

  @override
  State<PracticeExamScreen> createState() => _PracticeExamScreenState();
}

class _PracticeExamScreenState extends State<PracticeExamScreen> {
  final TextEditingController _subject = TextEditingController(text: 'Biology');
  String _difficulty = 'Medium';
  int _count = 20;
  PracticeExamResult? _exam;
  final List<int?> _answers = <int?>[];
  bool _submitted = false;

  @override
  void dispose() {
    _subject.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _exam = null;
      _answers.clear();
      _submitted = false;
    });
    final PracticeExamService exams = context.read<PracticeExamService>();
    try {
      final PracticeExamResult result = await exams.generate(
        subject: _subject.text.trim(),
        difficulty: _difficulty,
        questionCount: _count,
      );
      if (!mounted) return;
      setState(() {
        _exam = result;
        _answers.addAll(List<int?>.filled(result.questions.length, null));
      });
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  void _submit() {
    setState(() => _submitted = true);
    final PracticeExamService exams = context.read<PracticeExamService>();
    final int score = exams.scoreAnswers(_exam!.questions, _answers);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Score: $score / ${_exam!.questions.length}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PracticeExamService exams = context.watch<PracticeExamService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return PremiumGate(
      title: 'Practice Exam Generator',
      description:
          'AI-generated exam reviews and full-length practice tests are included with Premium.',
      icon: Icons.quiz_outlined,
      child: Scaffold(
      appBar: AppBar(title: const Text('Practice Exam Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Subject', hintText: 'Biology'),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _difficulty,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(value: 'Easy', child: Text('Easy')),
                    DropdownMenuItem<String>(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem<String>(value: 'Hard', child: Text('Hard')),
                  ],
                  onChanged: _exam == null ? (String? v) => setState(() => _difficulty = v ?? 'Medium') : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _count,
                  decoration: const InputDecoration(labelText: 'Questions'),
                  items: const <DropdownMenuItem<int>>[
                    DropdownMenuItem<int>(value: 10, child: Text('10')),
                    DropdownMenuItem<int>(value: 20, child: Text('20')),
                    DropdownMenuItem<int>(value: 30, child: Text('30')),
                  ],
                  onChanged: _exam == null ? (int? v) => setState(() => _count = v ?? 20) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: exams.isGenerating ? null : _generate,
            icon: exams.isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.quiz_outlined),
            label: Text(exams.isGenerating ? 'Generating…' : 'Generate exam'),
          ),
          if (_exam != null) ...<Widget>[
            const SizedBox(height: 24),
            Text('${_exam!.subject} · ${_exam!.difficulty}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 12),
            ...List<Widget>.generate(_exam!.questions.length, (int i) {
              final QuizQuestion q = _exam!.questions[i];
              final int? selected = _answers[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudySurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${i + 1}. ${q.prompt}', style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35)),
                      const SizedBox(height: 10),
                      ...List<Widget>.generate(q.options.length, (int o) {
                        final bool isCorrect = o == q.correctIndex;
                        final bool isSelected = selected == o;
                        Color? tileColor;
                        if (_submitted && isCorrect) tileColor = StudyColors.success.withValues(alpha: 0.15);
                        if (_submitted && isSelected && !isCorrect) tileColor = StudyColors.danger.withValues(alpha: 0.12);
                        return ListTile(
                          dense: true,
                          tileColor: tileColor,
                          title: Text(q.options[o]),
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
              FilledButton(onPressed: _answers.every((int? a) => a != null) ? _submit : null, child: const Text('Submit & grade')),
            if (_submitted)
              Text(
                'Graded automatically — review green (correct) and red (your miss).',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
          ],
        ],
      ),
    ),
    );
  }
}
