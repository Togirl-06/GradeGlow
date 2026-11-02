import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/microbiology_lab_data.dart';
import '../models/anatomy_game.dart';
import '../models/ai_practice_mode.dart';
import '../models/microbiology_specimen.dart';
import '../models/practice_lab.dart';
import '../models/visual_learning_lab.dart';
import '../services/practice_lab_service.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/anatomy/anatomy_game_hud.dart';
import '../widgets/science/microscope_specimen_canvas.dart';

class MicrobiologyIdLabScreen extends StatefulWidget {
  const MicrobiologyIdLabScreen({
    super.key,
    required this.category,
    required this.lab,
    required this.activity,
    required this.difficulty,
    required this.specimenCategory,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final VisualLabActivity activity;
  final PracticeDifficulty difficulty;
  final MicrobiologyCategory specimenCategory;

  @override
  State<MicrobiologyIdLabScreen> createState() => _MicrobiologyIdLabScreenState();
}

class _MicrobiologyIdLabScreenState extends State<MicrobiologyIdLabScreen> {
  late final List<MicrobiologySpecimen> _deck;
  int _index = 0;
  int _score = 0;
  int _lives = 3;
  int _xp = 0;
  bool _booting = true;
  String? _bootError;
  bool _showFeedback = false;
  String? _aiNote;
  final DateTime _startedAt = DateTime.now();

  MicrobiologySpecimen get _specimen => _deck[_index];

  @override
  void initState() {
    super.initState();
    _deck = MicrobiologyLabData.deckFor(widget.specimenCategory, widget.lab.id);
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

  String _promptFor(MicrobiologySpecimen specimen) {
    const List<String> prompts = <String>[
      'What type of microorganism is shown in this microscope field?',
      'Identify the specimen in this micrograph',
      'Which classification best matches this microscope image?',
      'Name the microbe visible at this magnification',
    ];
    return prompts[Random(specimen.id.hashCode + _index).nextInt(prompts.length)];
  }

  List<String> _optionsFor(MicrobiologySpecimen target) {
    final List<MicrobiologySpecimen> pool = MicrobiologyLabData.allForCategory(widget.specimenCategory);
    final List<String> options = <String>[target.name];
    final List<MicrobiologySpecimen> others = pool.where((MicrobiologySpecimen s) => s.id != target.id).toList();
    others.shuffle(Random(target.id.hashCode));
    for (final MicrobiologySpecimen specimen in others) {
      if (options.length >= 4) break;
      if (!options.contains(specimen.name)) options.add(specimen.name);
    }
    options.shuffle(Random(widget.lab.id.hashCode + _index));
    return options;
  }

  Future<void> _answer(String choice) async {
    if (_showFeedback) return;
    final bool correct = choice == _specimen.name;
    setState(() {
      _showFeedback = true;
      if (correct) {
        _score += 1;
        _xp += 18;
        _aiNote = _specimen.hint;
      } else {
        _lives -= 1;
        _aiNote = null;
      }
    });

    if (!correct) {
      final String explanation = await context.read<PracticeLabService>().explainLabelingMistake(
            diagramTitle: 'Microbiology slide',
            correctLabel: _specimen.name,
            studentChoice: choice,
            subjectName: widget.category.name,
            context: 'Microscope specimen identification',
          );
      if (mounted) setState(() => _aiNote = explanation);
    }

    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    if (_lives <= 0 || _index >= _deck.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _index += 1;
      _showFeedback = false;
      _aiNote = null;
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
          activityType: VisualLabActivityType.imageIdentification,
          scoreBreakdown: scores,
          summary: 'Identified $_score of ${_deck.length} specimens.',
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
      return Scaffold(appBar: AppBar(title: Text(widget.activity.title)), body: Center(child: Text(_bootError!)));
    }

    final List<String> options = _optionsFor(_specimen);
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
          const SizedBox(height: 12),
          Text(_promptFor(_specimen), style: TextStyle(color: PracticeLabGameTheme.textSecondary(context))),
          const SizedBox(height: 12),
          MicroscopeSpecimenCanvas(specimen: _specimen),
          const SizedBox(height: 16),
          ...options.map(
            (String option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: _showFeedback ? null : () => _answer(option),
                child: Align(alignment: Alignment.centerLeft, child: Text(option)),
              ),
            ),
          ),
          if (_aiNote != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_aiNote!, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4)),
            ),
        ],
      ),
    );
  }
}
