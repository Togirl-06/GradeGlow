import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/virtual_chemistry_data.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../models/visual_learning_lab.dart';
import '../services/practice_lab_service.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';

class VirtualChemistryLabScreen extends StatefulWidget {
  const VirtualChemistryLabScreen({
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
  State<VirtualChemistryLabScreen> createState() => _VirtualChemistryLabScreenState();
}

class _VirtualChemistryLabScreenState extends State<VirtualChemistryLabScreen> {
  ChemReagent? _flaskA;
  ChemReagent? _flaskB;
  ChemReaction? _result;
  String? _aiExplanation;
  bool _booting = true;
  bool _mixing = false;
  String? _bootError;
  final DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
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

  Future<void> _mix() async {
    if (_flaskA == null || _flaskB == null || _mixing) return;
    setState(() {
      _mixing = true;
      _aiExplanation = null;
    });
    final ChemReaction reaction = VirtualChemistryData.mix(_flaskA!, _flaskB!);
    final String explanation = await context.read<PracticeLabService>().explainChemistryReaction(
          reagentA: _flaskA!.name,
          reagentB: _flaskB!.name,
          outcome: reaction.outcome,
          ph: reaction.ph,
          subjectName: widget.category.name,
        );
    if (!mounted) return;
    setState(() {
      _result = reaction;
      _aiExplanation = explanation;
      _mixing = false;
    });
  }

  Future<void> _complete() async {
    final VisualLabScoreBreakdown scores = VisualLabScoreBreakdown.fromSession(
      correct: _result != null ? 1 : 0,
      total: 1,
      elapsed: DateTime.now().difference(_startedAt),
      categories: widget.activity.scoreCategories,
      bonusPoints: _result != null ? 15 : 0,
    );
    await context.read<PracticeLabService>().saveVisualLabResult(
          category: widget.category,
          lab: widget.lab,
          activityTitle: widget.activity.title,
          activityType: VisualLabActivityType.virtualLab,
          scoreBreakdown: scores,
          summary: _result == null ? 'Explored the virtual lab.' : 'Mixed ${_flaskA!.name} + ${_flaskB!.name} — pH ${_result!.ph.toStringAsFixed(1)}',
          roundsPlayed: 1,
          xpEarned: 40,
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: AppBar(
        title: Text(widget.activity.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(widget.activity.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(child: _FlaskSlot(label: 'Beaker A', reagent: _flaskA, resultColor: _result?.color)),
              const SizedBox(width: 12),
              Expanded(child: _FlaskSlot(label: 'Beaker B', reagent: _flaskB, resultColor: _result?.color)),
            ],
          ),
          if (_result != null) ...<Widget>[
            const SizedBox(height: 16),
            Text('pH: ${_result!.ph.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 8),
            Text(_result!.outcome, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.4)),
          ],
          if (_aiExplanation != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_aiExplanation!, style: const TextStyle(color: Colors.white, height: 1.4)),
            ),
          ],
          const SizedBox(height: 16),
          const Text('SELECT REAGENTS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VirtualChemistryData.reagents.map((ChemReagent r) {
              return ActionChip(
                label: Text(r.name, style: const TextStyle(fontSize: 11)),
                backgroundColor: r.color.withValues(alpha: 0.35),
                onPressed: () {
                  setState(() {
                    _result = null;
                    _aiExplanation = null;
                    if (_flaskA == null) {
                      _flaskA = r;
                    } else if (_flaskB == null && _flaskA!.id != r.id) {
                      _flaskB = r;
                    } else {
                      _flaskA = r;
                      _flaskB = null;
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _flaskA != null && _flaskB != null && !_mixing ? _mix : null,
            child: Text(_mixing ? 'Running reaction…' : 'Mix & measure pH'),
          ),
          if (_result != null)
            TextButton(onPressed: _complete, child: const Text('Complete lab', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class _FlaskSlot extends StatelessWidget {
  const _FlaskSlot({required this.label, required this.reagent, this.resultColor});

  final String label;
  final ChemReagent? reagent;
  final Color? resultColor;

  @override
  Widget build(BuildContext context) {
    final Color fill = resultColor ?? reagent?.color ?? Colors.white12;
    return Column(
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: fill.withValues(alpha: reagent == null ? 0.08 : 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Text(
              reagent?.name ?? 'Empty',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}
