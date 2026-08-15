import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/physics/physics_formula_engine.dart';
import '../../models/physics/physics_program.dart';
import '../../models/quiz_question.dart';
import '../../services/openai_service.dart';
import '../../theme/physics_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/math_rich_text.dart';

/// Default number of multiple-choice questions per physics topic quiz.
const int kPhysicsQuizQuestionCount = 15;

/// Multiple-choice quiz generated from the physics topic content.
class PhysicsQuizScreen extends StatefulWidget {
  const PhysicsQuizScreen({
    super.key,
    required this.track,
    required this.course,
    required this.topic,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;

  @override
  State<PhysicsQuizScreen> createState() => _PhysicsQuizScreenState();
}

class _PhysicsQuizScreenState extends State<PhysicsQuizScreen> {
  List<QuizQuestion> _questions = <QuizQuestion>[];
  final List<int?> _answers = <int?>[];
  int _index = 0;
  bool _loading = true;
  bool _finished = false;
  String? _error;
  int? _revealed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<QuizQuestion> _offlineQuiz() {
    final PhysicsTopic t = widget.topic;
    final List<String> concepts = t.keyConcepts;
    final String c0 = concepts.isNotEmpty ? concepts.first : t.title;
    final String c1 = concepts.length > 1 ? concepts[1] : 'experimental verification';
    final String c2 = concepts.length > 2 ? concepts[2] : 'model limits';
    final List<PhysicsFormula> formulas = PhysicsFormulaEngine.formulasFor(
      courseId: widget.course.id,
      topic: t,
    );
    final String formulaPrimary = formulas.isEmpty
        ? 'the governing relation for ${t.title}'
        : '${formulas.first.name}: \$${formulas.first.latex}\$';
    final String formulaSecondary = formulas.length > 1
        ? '${formulas[1].name}: \$${formulas[1].latex}\$'
        : 'A relation with undefined symbols and no SI units';
    final String hookShort = t.hook.length > 90 ? '${t.hook.substring(0, 90)}…' : t.hook;
    final String summaryShort = t.summary.length > 100 ? '${t.summary.substring(0, 100)}…' : t.summary;
    final String realWorld = t.realWorld.isNotEmpty
        ? (t.realWorld.length > 95 ? '${t.realWorld.substring(0, 95)}…' : t.realWorld)
        : 'Engineering, research labs, and technology depend on ${t.title}.';
    final String career = t.career.isNotEmpty
        ? (t.career.length > 95 ? '${t.career.substring(0, 95)}…' : t.career)
        : 'Physicists and engineers apply ${t.title} in quantitative modeling.';

    final List<QuizQuestion> questions = <QuizQuestion>[
      QuizQuestion(
        prompt: 'Which statement best describes **${t.title}**?',
        options: <String>[
          summaryShort.isEmpty ? 'A core idea in ${widget.course.title}' : summaryShort,
          'A topic unrelated to ${widget.course.title}',
          'Only a historical footnote with no measurable predictions',
          'A concept that cannot be tested experimentally',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which real-world scenario matches the opening hook for this topic?',
        options: <String>[
          hookShort,
          'A purely fictional scenario with no physical quantities',
          'A legal dispute about contract damages',
          'A grammar exercise about sentence structure',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which is a key concept for **${t.title}**?',
        options: <String>[c0, 'Ignoring units when comparing quantities', 'Assuming all variables are constant without justification', 'Skipping definitions and memorizing symbols only'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which concept is also central to this topic?',
        options: <String>[c1, 'Whether the professor prefers metric units', 'The color of laboratory equipment', 'The alphabetical order of variable names'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which study habit supports mastery of **${t.title}**?',
        options: <String>[c2, 'Never checking limiting cases', 'Avoiding graphs entirely', 'Mixing up vector and scalar quantities deliberately'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which formula or relation belongs to this topic?',
        options: <String>[formulaPrimary, 'A = B × C with no defined symbols', r'$x = \text{random number}$ (no physical meaning)', 'F = ma applied to purely social behavior'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: formulas.length > 1
            ? 'Which is another governing relation for **${t.title}**?'
            : 'Which study step helps you learn the governing relation for **${t.title}**?',
        options: formulas.length > 1
            ? <String>[
                formulaSecondary,
                r'$\rho = \dfrac{m}{V}$ for unrelated fluid density only',
                r'$E = mc^2$ for every everyday motion problem',
                r'$P = IV$ for purely mechanical collisions',
              ]
            : <String>[
                'Derive it from definitions in the AI Professor lecture',
                'Memorize symbols without meaning',
                'Skip unit checks on every variable',
                'Ignore the Formula Notebook',
              ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'A student confuses **${t.title}** with an unrelated idea. What is the textbook fix?',
        options: <String>[
          'Return to definitions and check units on every quantity',
          'Memorize answers without understanding symbols',
          'Skip worked examples and only read headlines',
          'Ignore the lab simulator entirely',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'How should you verify understanding of **${t.title}**?',
        options: <String>[
          'Predict an outcome, then test it in the 3D Simulation & Lab',
          'Recite formulas without naming what each symbol means',
          'Avoid any numerical examples',
          'Only read the topic title once',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Where does **${t.title}** show up outside the classroom?',
        options: <String>[realWorld, 'Only in fictional stories with no measurements', 'Nowhere — it has no practical use', 'Only in ancient history with no modern technology'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which career path might use **${t.title}** regularly?',
        options: <String>[career, 'Only poetry critics with no quantitative work', 'Only historians studying ancient languages', 'Only graphic designers choosing fonts'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Before substituting numbers into a **${t.title}** equation, you should:',
        options: <String>[
          'Define every symbol and confirm SI units match both sides',
          'Plug in values without labeling units',
          'Change units mid-calculation without conversion',
          'Skip dimensional analysis entirely',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'You miss a calculation question on **${t.title}**. Best review step?',
        options: <String>[
          'Open Formula Notebook, rework the relation, then retry similar problems',
          'Memorize the wrong answer from the quiz',
          'Skip the AI Professor lecture entirely',
          'Assume the simulation lab is unrelated',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which matches the **${widget.course.title}** context for **${t.title}**?',
        options: <String>[
          '${t.title} is part of ${widget.course.title} at the ${widget.track.level.label} level',
          '${t.title} belongs to an unrelated medical licensing exam only',
          '${t.title} is never studied in formal physics curricula',
          '${t.title} has no connection to ${widget.course.title}',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Best next step after this quiz on **${t.title}**?',
        options: <String>[
          'Review missed questions, then read the AI Professor lecture',
          'Skip definitions and move to an unrelated course',
          'Ignore formulas and only memorize topic names',
          'Never retake practice questions',
        ],
        correctIndex: 0,
      ),
    ];

    for (int i = 2; i < formulas.length && questions.length < kPhysicsQuizQuestionCount; i++) {
      final PhysicsFormula f = formulas[i];
      final String correct = '\$${f.latex}\$';
      final List<String> wrong = <String>[];
      for (int j = 0; j < formulas.length && wrong.length < 3; j++) {
        if (j != i) wrong.add('\$${formulas[j].latex}\$');
      }
      while (wrong.length < 3) {
        wrong.add(r'$Q = \text{undefined}$');
      }
      questions.add(
        QuizQuestion(
          prompt: 'Which expression matches **${f.name}** for ${t.title}?',
          options: <String>[correct, wrong[0], wrong[1], wrong[2]],
          correctIndex: 0,
        ),
      );
    }

    return questions.take(kPhysicsQuizQuestionCount).toList();
  }

  List<QuizQuestion> _mergeToTarget(List<QuizQuestion> primary, List<QuizQuestion> fallback) {
    final Set<String> seen = primary.map((QuizQuestion q) => q.prompt).toSet();
    final List<QuizQuestion> merged = List<QuizQuestion>.from(primary);
    for (final QuizQuestion q in fallback) {
      if (merged.length >= kPhysicsQuizQuestionCount) break;
      if (seen.add(q.prompt)) merged.add(q);
    }
    return merged;
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
    });

    try {
      List<QuizQuestion> qs;
      if (AppConfig.hasOpenAi) {
        if (!mounted) return;
        qs = await context.read<OpenAiService>().physicsQuizFromTopic(
              levelLabel: widget.track.level.label,
              courseTitle: widget.course.title,
              course: widget.course,
              topic: widget.topic,
              questionCount: kPhysicsQuizQuestionCount,
            );
        if (qs.length < kPhysicsQuizQuestionCount) {
          qs = _mergeToTarget(qs, _offlineQuiz());
        }
      } else {
        qs = _offlineQuiz();
      }
      if (!mounted) return;
      setState(() {
        _questions = qs;
        _answers.addAll(List<int?>.filled(qs.length, null));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _questions = _offlineQuiz();
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
      backgroundColor: PhysicsTheme.background,
      appBar: AppBar(
        backgroundColor: PhysicsTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Topic Quiz'),
        actions: <Widget>[
          if (!_loading && _questions.isNotEmpty)
            TextButton(
              onPressed: _load,
              child: const Text('New quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: PhysicsTheme.primary))
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
          color: PhysicsTheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          '$score / $total',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: PhysicsTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          strong
              ? 'Solid grasp of ${widget.topic.title}.'
              : 'Review the AI Professor lecture on ${widget.topic.title}, then retry.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PhysicsTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _load,
          style: FilledButton.styleFrom(
            backgroundColor: PhysicsTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Retake quiz', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to topic'),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    if (_questions.isEmpty) {
      return Center(
        child: Text(_error ?? 'No questions available.', style: TextStyle(color: PhysicsTheme.textSecondary)),
      );
    }
    final QuizQuestion q = _questions[_index];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        Text(
          '${widget.course.title} · ${widget.track.level.label}',
          style: TextStyle(color: PhysicsTheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          widget.topic.title,
          style: TextStyle(color: PhysicsTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 8),
          Text('Using offline quiz ($_error)', style: TextStyle(color: PhysicsTheme.textSecondary, fontSize: 11)),
        ],
        const SizedBox(height: 14),
        Text(
          'Question ${_index + 1} of ${_questions.length}',
          style: TextStyle(color: PhysicsTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PhysicsTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PhysicsTheme.border),
          ),
          child: MathRichText(
            text: q.prompt,
            color: PhysicsTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        ...List<Widget>.generate(q.options.length, (int i) {
          final bool selected = _revealed == i;
          final bool showCorrect = _revealed != null && i == q.correctIndex;
          final bool showWrong = selected && i != q.correctIndex;
          Color border = PhysicsTheme.border;
          Color? fill;
          if (showCorrect) {
            border = PhysicsTheme.success;
            fill = PhysicsTheme.success.withValues(alpha: 0.1);
          } else if (showWrong) {
            border = Colors.redAccent;
            fill = Colors.redAccent.withValues(alpha: 0.08);
          } else if (selected) {
            border = PhysicsTheme.primary;
            fill = PhysicsTheme.primary.withValues(alpha: 0.08);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: fill ?? PhysicsTheme.surface,
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
                  child: MathRichText(
                    text: q.options[i],
                    color: PhysicsTheme.textPrimary,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
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
              color: _revealed == q.correctIndex ? PhysicsTheme.success : Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
              backgroundColor: PhysicsTheme.primary,
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
