import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/world_curriculum_lesson_content.dart';
import '../../models/virtual_university_lesson_contract.dart';
import '../../models/world_curriculum_program.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../services/openai_service.dart';
import '../../services/world_curriculum_progress_service.dart';
import '../../widgets/virtual_university/vu_lesson_hub_shell.dart';

class WorldCurriculumLessonHubScreen extends StatelessWidget {
  const WorldCurriculumLessonHubScreen({
    super.key,
    required this.meta,
    required this.path,
  });

  final WorldSubjectMeta meta;
  final WorldLessonPath path;

  static final List<VuActivitySpec> _activities =
      VirtualUniversityLessonContract.visibleFor(
        hasInteractive: true,
        hasDiscussion: true,
      );

  @override
  Widget build(BuildContext context) {
    WorldCurriculumProgressService? progress;
    try {
      progress = context.watch<WorldCurriculumProgressService>();
    } catch (_) {}

    final Set<String> done =
        progress?.completedActivityNames(path.topic.id) ?? const <String>{};
    final bool certified = progress?.hasCertificate(path.topic.id) ?? false;
    final Color accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          path.topic.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: VuLessonHubShell(
        title: path.topic.title,
        subtitle: '${meta.title} · ${path.breadcrumb}',
        accent: accent,
        activities: _activities,
        completedActivityNames: done,
        certificateBadge: certified
            ? Icon(Icons.workspace_premium, color: accent, size: 36)
            : null,
        onOpen: (VuCanonicalActivity activity) {
          if (activity == VuCanonicalActivity.aiProfessor) {
            final OpenAiService openAi = context.read<OpenAiService>();
            final WorldCurriculumProgressService? store = progress;
            Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => AiProfessorClassroomScreen(
                  openAi: openAi,
                  lessonId: path.topic.id,
                  lessonTitle: path.topic.title,
                  courseId: path.course.id,
                  courseTitle: path.course.title,
                  moduleTitle: meta.title,
                  faculty: meta.subjectId,
                  onCompleted: () async {
                    await store?.complete(path.topic.id, activity.name);
                  },
                ),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _WorldActivityWorkspace(
                meta: meta,
                path: path,
                activity: activity,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WorldActivityWorkspace extends StatefulWidget {
  const _WorldActivityWorkspace({
    required this.meta,
    required this.path,
    required this.activity,
  });

  final WorldSubjectMeta meta;
  final WorldLessonPath path;
  final VuCanonicalActivity activity;

  @override
  State<_WorldActivityWorkspace> createState() =>
      _WorldActivityWorkspaceState();
}

class _WorldActivityWorkspaceState extends State<_WorldActivityWorkspace> {
  late final List<_QuizItem> _quiz;
  late final List<bool> _checks;
  int _quizIndex = 0;
  int _score = 0;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    _checks = List<bool>.filled(5, false);
    _quiz = WorldCurriculumLessonContent.quizFor(widget.meta, widget.path)
        .map(
          (WorldMcq q) => _QuizItem(
            stem: q.prompt,
            correct: q.choices[q.correctIndex],
            wrong: <String>[
              for (int i = 0; i < q.choices.length; i++)
                if (i != q.correctIndex) q.choices[i],
            ],
          ),
        )
        .toList();
    for (final _QuizItem item in _quiz) {
      item.shuffle(math.Random(widget.path.topic.id.hashCode));
    }
  }

  String get _title => switch (widget.activity) {
        VuCanonicalActivity.aiProfessor => 'AI Professor',
        VuCanonicalActivity.textbookNotes => 'Textbook Notes',
        VuCanonicalActivity.interactiveOrVideo => 'Interactive Lesson',
        VuCanonicalActivity.practiceOrHomework => 'Practice / Homework',
        VuCanonicalActivity.quizOrExam => 'Quiz / Exam',
        VuCanonicalActivity.discussionOrSummary => 'Discussion / Summary',
      };

  String get _lecture =>
      WorldCurriculumLessonContent.lecture(widget.meta, widget.path);

  Future<void> _complete() async {
    WorldCurriculumProgressService? progress;
    try {
      progress = context.read<WorldCurriculumProgressService>();
    } catch (_) {
      progress = null;
    }
    if (progress == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save progress. Please reopen this subject.'),
        ),
      );
      return;
    }
    try {
      await progress.complete(widget.path.topic.id, widget.activity.name);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save failed. Try again.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_title marked complete')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: switch (widget.activity) {
        VuCanonicalActivity.aiProfessor ||
        VuCanonicalActivity.textbookNotes ||
        VuCanonicalActivity.discussionOrSummary => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              SelectableText(
                _lecture,
                style: const TextStyle(height: 1.45, fontSize: 15),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _complete,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Mark complete'),
              ),
            ],
          ),
        VuCanonicalActivity.interactiveOrVideo => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                'Interactive checklist for ${widget.path.topic.title}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete every step, then finish.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ...List<Widget>.generate(_checks.length, (int i) {
                final List<String> labels = <String>[
                  'Define ${widget.path.topic.title} in your own words',
                  'List two real-world uses in ${widget.path.course.title}',
                  'Identify one common mistake',
                  'Solve a short example mentally',
                  'Summarize the key takeaway',
                ];
                return CheckboxListTile(
                  value: _checks[i],
                  onChanged: (bool? v) {
                    setState(() => _checks[i] = v ?? false);
                  },
                  title: Text(labels[i]),
                  activeColor: accent,
                );
              }),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _checks.every((bool c) => c) ? _complete : null,
                style: FilledButton.styleFrom(backgroundColor: accent),
                child: const Text('Finish interactive'),
              ),
            ],
          ),
        VuCanonicalActivity.practiceOrHomework ||
        VuCanonicalActivity.quizOrExam => _buildQuiz(context, accent),
      },
    );
  }

  Widget _buildQuiz(BuildContext context, Color accent) {
    if (_quizIndex >= _quiz.length) {
      final bool passed = _score >= (_quiz.length * 0.6).ceil();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Score $_score / ${_quiz.length}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'Passed — you can submit for mastery credit.'
                    : 'Keep studying the notes, then try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: passed
                    ? _complete
                    : () {
                        setState(() {
                          _quizIndex = 0;
                          _score = 0;
                          _lastCorrect = null;
                          _quiz
                            ..clear()
                            ..addAll(
                              WorldCurriculumLessonContent.quizFor(
                                widget.meta,
                                widget.path,
                                seed: DateTime.now().millisecond,
                              ).map(
                                (WorldMcq q) => _QuizItem(
                                  stem: q.prompt,
                                  correct: q.choices[q.correctIndex],
                                  wrong: <String>[
                                    for (int i = 0; i < q.choices.length; i++)
                                      if (i != q.correctIndex) q.choices[i],
                                  ],
                                ),
                              ),
                            );
                          for (final _QuizItem item in _quiz) {
                            item.shuffle(
                              math.Random(DateTime.now().microsecond),
                            );
                          }
                        });
                      },
                style: FilledButton.styleFrom(backgroundColor: accent),
                child: Text(passed ? 'Submit & complete' : 'Retry quiz'),
              ),
            ],
          ),
        ),
      );
    }

    final _QuizItem item = _quiz[_quizIndex];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Question ${_quizIndex + 1} of ${_quiz.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          item.stem,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...List<Widget>.generate(item.options.length, (int i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () {
                final bool correct = i == item.correctIndex;
                setState(() {
                  if (correct) _score++;
                  _lastCorrect = correct;
                  _quizIndex++;
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(item.options[i]),
              ),
            ),
          );
        }),
        if (_lastCorrect != null)
          Text(
            _lastCorrect! ? 'Correct' : 'Not quite — keep going',
            style: TextStyle(
              color: _lastCorrect! ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _QuizItem {
  _QuizItem({
    required this.stem,
    required String correct,
    required List<String> wrong,
  }) : options = <String>[correct, ...wrong],
       correctIndex = 0;

  final String stem;
  late List<String> options;
  late int correctIndex;

  void shuffle(math.Random rng) {
    final String correct = options[correctIndex];
    options = List<String>.from(options)..shuffle(rng);
    correctIndex = options.indexOf(correct);
  }
}
