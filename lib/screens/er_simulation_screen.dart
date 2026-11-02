import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/er_simulation_data.dart';
import '../models/er_simulation.dart';
import '../models/practice_lab.dart';
import '../services/practice_lab_service.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/er/er_simulation_widgets.dart';
import 'er_ask_questions_screen.dart';
import 'er_case_summary_screen.dart';
import 'er_patient_monitor_screen.dart';

class ErSimulationScreen extends StatefulWidget {
  const ErSimulationScreen({super.key, required this.category, required this.lab});

  final PracticeLabCategory category;
  final PracticeLabType lab;

  @override
  State<ErSimulationScreen> createState() => _ErSimulationScreenState();
}

class _ErSimulationScreenState extends State<ErSimulationScreen> {
  ErSimulationRun? _run;
  Timer? _timer;
  bool _booting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        _error = StudyMessenger.clean(error);
        _booting = false;
      });
      return;
    }

    final ErSimulationCase caseData = ErSimulationData.caseForLabId(widget.lab.id);
    _run = ErSimulationRun(caseData: caseData);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _run == null) return;
      setState(() => _run!.tickSecond());
    });
    if (mounted) setState(() => _booting = false);
  }

  void _refresh() => setState(() {});

  Future<void> _handleAction(ErSimulationAction action) async {
    final ErSimulationRun run = _run!;
    switch (action.id) {
      case 'ask':
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ErAskQuestionsScreen(run: run, onChanged: _refresh),
          ),
        );
      case 'vitals':
        run.addXp(5);
        run.patientLine = 'My chest still feels tight, but thank you for checking on me.';
        _refresh();
      case 'tests':
        if (!run.ecgOrdered) {
          run.ecgOrdered = true;
          run.addXp(20);
          run.achievements.add('Ordered ECG');
          if (run.objectives.length > 2) {
            run.objectives[2] = run.objectives[2].advance();
          }
          run.patientLine = 'Is that the heart monitor? Will it hurt?';
        }
        _refresh();
      case 'meds':
        _showMedicationSheet(run);
      case 'specialist':
        run.addXp(10);
        run.patientLine = 'Cardiology is on the way? That makes me nervous...';
        _refresh();
      case 'chart':
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ErPatientMonitorScreen(run: run),
          ),
        );
    }
    _maybeFinish(run);
  }

  void _showMedicationSheet(ErSimulationRun run) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ErSimulationData.panelBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Administer Medication', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 12),
            _MedButton(
              label: 'Aspirin 325 mg PO',
              onTap: () {
                if (!run.aspirinGiven) {
                  run.aspirinGiven = true;
                  run.addXp(25);
                  run.achievements.add('Administered aspirin');
                  run.patientLine = 'Okay, I swallowed the aspirin. My chest is still tight though.';
                }
                Navigator.pop(context);
                _refresh();
                _maybeFinish(run);
              },
            ),
            const SizedBox(height: 8),
            _MedButton(
              label: 'Supplemental oxygen 2L NC',
              onTap: () {
                if (!run.oxygenApplied) {
                  run.oxygenApplied = true;
                  run.vitals = run.vitals.copyWith(spo2: 94, heartRate: 112);
                  run.addXp(20);
                  run.achievements.add('Stabilized the patient');
                  run.objectives[0] = run.objectives[0].advance();
                  run.patientLine = 'The oxygen helps a little. I can breathe easier now.';
                }
                Navigator.pop(context);
                _refresh();
                _maybeFinish(run);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _maybeFinish(ErSimulationRun run) async {
    if (!run.allObjectivesComplete) return;
    _timer?.cancel();
    final PracticeLabService labs = context.read<PracticeLabService>();
    final int stars = run.computeStars();
    final int score = run.computeScorePercent();
    await labs.saveErSimulationResult(
      category: widget.category,
      lab: widget.lab,
      score: score,
      summary: 'Completed ${run.caseData.title} with $stars-star performance.',
      xpEarned: run.xp,
      stars: stars,
    );
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ErCaseSummaryScreen(run: run, stars: stars),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(
        backgroundColor: ErSimulationData.screenBg,
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_error != null || _run == null) {
      return Scaffold(body: Center(child: Text(_error ?? 'Unable to start simulation.')));
    }

    final ErSimulationRun run = _run!;
    return Scaffold(
      backgroundColor: ErSimulationData.screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            const Text('EMERGENCY ROOM', style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
            Text('Case ${run.caseData.caseNumber}: ${run.caseData.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: <Widget>[
          if (run.allObjectivesComplete)
            TextButton(
              onPressed: () => _maybeFinish(run),
              child: const Text('Finish', style: TextStyle(color: Color(0xFF22D3EE))),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          ErGameHud(run: run),
          const SizedBox(height: 14),
          ErPatientScene(run: run),
          const SizedBox(height: 12),
          ErVitalsPanel(vitals: run.vitals),
          const SizedBox(height: 18),
          Text('What would you like to do?', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ErActionGrid(onAction: _handleAction),
        ],
      ),
    );
  }
}

class _MedButton extends StatelessWidget {
  const _MedButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.25),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
