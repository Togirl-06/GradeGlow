import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/punnett_square_data.dart';
import '../models/ai_practice_mode.dart';
import '../models/anatomy_game.dart';
import '../models/practice_lab.dart';
import '../models/visual_learning_lab.dart';
import '../services/practice_lab_service.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/anatomy/anatomy_game_hud.dart';

class PunnettSquareLabScreen extends StatefulWidget {
  const PunnettSquareLabScreen({
    super.key,
    required this.category,
    required this.lab,
    required this.activity,
    required this.difficulty,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final VisualLabActivity activity;
  final PracticeDifficulty difficulty;

  @override
  State<PunnettSquareLabScreen> createState() => _PunnettSquareLabScreenState();
}

class _PunnettSquareLabScreenState extends State<PunnettSquareLabScreen> {
  late final List<PunnettProblem> _deck;
  int _index = 0;
  int _score = 0;
  int _lives = 3;
  int _xp = 0;
  bool _booting = true;
  String? _bootError;
  bool _showFeedback = false;
  String? _feedback;
  final DateTime _startedAt = DateTime.now();

  PunnettProblem get _problem => _deck[_index];
  PunnettGrid get _grid => PunnettGrid(parent1: _problem.parent1, parent2: _problem.parent2);

  @override
  void initState() {
    super.initState();
    _deck = PunnettSquareData.deckFor(widget.difficulty, widget.lab.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final PracticeLabService labs = context.read<PracticeLabService>();
    if (!await labs.canStartSimulation()) {
      if (!mounted) return;
      await PremiumAccess.showUpgradeDialog(context, feature: PremiumFeature.practiceLabs);
      if (mounted) Navigator.pop(context);
      return;
    }
    try {
      await labs.consumeSimulationSlot();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bootError = StudyMessenger.clean(error);
        _booting = false;
      });
      return;
    }
    if (mounted) setState(() => _booting = false);
  }

  void _answer(int choiceIndex) {
    if (_showFeedback) return;
    final bool correct = choiceIndex == _problem.correctIndex;
    setState(() {
      _showFeedback = true;
      _feedback = correct ? _problem.explanation : 'Review the Punnett square — ${_problem.explanation}';
      if (correct) {
        _score += 1;
        _xp += 20;
      } else {
        _lives -= 1;
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_lives <= 0 || _index >= _deck.length - 1) {
        _finish();
        return;
      }
      setState(() {
        _index += 1;
        _showFeedback = false;
        _feedback = null;
      });
    });
  }

  Future<void> _finish() async {
    final VisualLabScoreBreakdown scores = VisualLabScoreBreakdown.fromSession(
      correct: _score,
      total: _deck.length,
      elapsed: DateTime.now().difference(_startedAt),
      categories: widget.activity.scoreCategories,
    );
    await context.read<PracticeLabService>().saveVisualLabResult(
          category: widget.category,
          lab: widget.lab,
          activityTitle: widget.activity.title,
          activityType: VisualLabActivityType.practicalExam,
          scoreBreakdown: scores,
          summary: 'Solved $_score of ${_deck.length} Punnett square problems.',
          roundsPlayed: _index + 1,
          xpEarned: _xp,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
    if (_bootError != null) {
      return Scaffold(appBar: AppBar(title: const Text('Punnett Square')), body: Center(child: Text(_bootError!)));
    }

    final PunnettGrid grid = _grid;
    return Scaffold(
      backgroundColor: PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Text(widget.activity.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AnatomyGameHud(
            progress: AnatomyGameProgress(round: _index + 1, totalRounds: _deck.length, score: _score, streak: 0, lives: _lives, xp: _xp),
          ),
          const SizedBox(height: 16),
          Text(_problem.prompt, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 16),
          _PunnettGridView(grid: grid, parent1: _problem.parent1, parent2: _problem.parent2),
          const SizedBox(height: 16),
          ...List<Widget>.generate(_problem.answers.length, (int i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: _showFeedback ? null : () => _answer(i),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PracticeLabGameTheme.textPrimary(context),
                  side: BorderSide(color: i == _problem.correctIndex && _showFeedback ? const Color(0xFF22C55E) : PracticeLabGameTheme.border(context)),
                  padding: const EdgeInsets.all(14),
                ),
                child: Align(alignment: Alignment.centerLeft, child: Text(_problem.answers[i])),
              ),
            );
          }),
          if (_feedback != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_feedback!, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4)),
            ),
        ],
      ),
    );
  }
}

class _PunnettGridView extends StatelessWidget {
  const _PunnettGridView({required this.grid, required this.parent1, required this.parent2});

  final PunnettGrid grid;
  final String parent1;
  final String parent2;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: PracticeLabGameTheme.border(context)),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: <TableRow>[
        TableRow(children: <Widget>[_cell(context, ''), _cell(context, grid.colLabels[0]), _cell(context, grid.colLabels[1])]),
        TableRow(children: <Widget>[_cell(context, grid.rowLabels[0]), _cell(context, grid.cells[0][0]), _cell(context, grid.cells[0][1])]),
        TableRow(children: <Widget>[_cell(context, grid.rowLabels[1]), _cell(context, grid.cells[1][0]), _cell(context, grid.cells[1][1])]),
      ],
    );
  }

  Widget _cell(BuildContext context, String text) => Container(
        padding: const EdgeInsets.all(12),
        color: PracticeLabGameTheme.surface(context),
        child: Text(text, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w700)),
      );
}
