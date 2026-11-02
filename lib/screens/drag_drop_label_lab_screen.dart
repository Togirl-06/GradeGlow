import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/chemistry_equipment_lab.dart';
import '../models/ai_practice_mode.dart';
import '../models/anatomy_game.dart';
import '../models/practice_lab.dart';
import '../models/visual_learning_lab.dart';
import '../services/practice_lab_service.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/anatomy/anatomy_game_hud.dart';

/// Drag labels onto chemistry bench equipment.
class DragDropLabelLabScreen extends StatefulWidget {
  const DragDropLabelLabScreen({
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
  State<DragDropLabelLabScreen> createState() => _DragDropLabelLabScreenState();
}

class _DragDropLabelLabScreenState extends State<DragDropLabelLabScreen> {
  late final List<DragDropLabItem> _targets;
  late final List<String> _labelPool;
  final Map<String, String> _placed = <String, String>{};
  final Set<String> _usedLabels = <String>{};
  final DateTime _startedAt = DateTime.now();

  int _round = 0;
  int _score = 0;
  int _lives = 3;
  int _xp = 0;
  int _streak = 0;
  bool _booting = true;
  String? _bootError;
  String? _feedback;
  bool? _lastCorrect;

  DragDropLabItem? get _currentTarget =>
      _round < _targets.length ? _targets[_round] : null;

  AnatomyGameProgress get _hud => AnatomyGameProgress(
        round: _round + 1,
        totalRounds: _targets.length,
        score: _score,
        streak: _streak,
        lives: _lives,
        xp: _xp,
      );

  @override
  void initState() {
    super.initState();
    _targets = ChemistryEquipmentLab.shuffledDeck(widget.lab.id);
    _labelPool = ChemistryEquipmentLab.items.map((DragDropLabItem i) => i.label).toList();
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

  void _onDrop(String targetId, String label) {
    final DragDropLabItem? target = _currentTarget;
    if (target == null || _feedback != null) return;
    if (_usedLabels.contains(label)) return;

    final bool correct = target.id == targetId && target.label == label;
    setState(() {
      _lastCorrect = correct;
      if (correct) {
        _usedLabels.add(label);
        _placed[targetId] = label;
        _score += 1;
        _streak += 1;
        _xp += 15 + _streak * 2;
        _feedback = target.hint;
      } else {
        _lives -= 1;
        _streak = 0;
        _feedback = 'That label belongs on a different piece of equipment.';
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_lives <= 0) {
        _finish();
        return;
      }
      setState(() {
        _feedback = null;
        if (correct) _round += 1;
      });
      if (correct && _round >= _targets.length) _finish();
    });
  }

  Future<void> _finish() async {
    final VisualLabScoreBreakdown scores = VisualLabScoreBreakdown.fromSession(
      correct: _score,
      total: _targets.length,
      elapsed: DateTime.now().difference(_startedAt),
      categories: widget.activity.scoreCategories,
      bonusPoints: _streak > 2 ? 5 : 0,
    );

    await context.read<PracticeLabService>().saveVisualLabResult(
          category: widget.category,
          lab: widget.lab,
          activityTitle: widget.activity.title,
          activityType: widget.activity.type,
          scoreBreakdown: scores,
          summary: 'Labeled $_score of ${_targets.length} pieces of lab equipment.',
          roundsPlayed: _round,
          xpEarned: _xp,
        );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: PracticeLabGameTheme.surface(context),
        title: Text('Lab Complete', style: TextStyle(color: PracticeLabGameTheme.textPrimary(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Overall: ${scores.overall}%', style: TextStyle(color: PracticeLabGameTheme.xp(context), fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 8),
            Text('Accuracy: ${scores.accuracy}% · Speed: ${scores.speed}%', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context))),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_bootError != null) {
      return Scaffold(
        backgroundColor: PracticeLabGameTheme.background(context),
        appBar: AppBar(title: const Text('Equipment Lab')),
        body: Center(child: Text(_bootError!, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)))),
      );
    }

    final DragDropLabItem? target = _currentTarget;
    final List<String> availableLabels = _labelPool.where((String l) => !_usedLabels.contains(l)).toList();

    return Scaffold(
      backgroundColor: PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.activity.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text('Drag & Drop · ${widget.difficulty.label}', style: TextStyle(fontSize: 11, color: PracticeLabGameTheme.textSecondary(context))),
          ],
        ),
        backgroundColor: PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnatomyGameHud(progress: _hud),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              target == null
                  ? 'Session complete'
                  : 'Drag the correct label onto the highlighted glassware',
              style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 13),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ChemistryBenchCanvas(
                placed: _placed,
                highlightId: target?.id,
                onAccept: _onDrop,
              ),
            ),
          ),
          if (_feedback != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _feedback!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _lastCorrect == true ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: availableLabels.map((String label) {
                return Draggable<String>(
                  data: label,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _LabelChip(label: label, dragging: true),
                  ),
                  childWhenDragging: Opacity(opacity: 0.35, child: _LabelChip(label: label)),
                  child: _LabelChip(label: label),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label, this.dragging = false});

  final String label;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFF1E3A5F) : PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF42A5F5).withValues(alpha: 0.5)),
        boxShadow: dragging
            ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)]
            : null,
      ),
      child: Text(label, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w800)),
    );
  }
}
