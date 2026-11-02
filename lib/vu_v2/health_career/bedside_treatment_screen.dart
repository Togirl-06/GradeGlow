import 'dart:async';

import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'models/hospital_case.dart';
import 'models/patient_profile.dart';
import 'widgets/hospital_bed_scene.dart';

enum _Phase { arrive, interview, vitals, treat, document, debrief }

/// Real-time bedside treatment: assess → intervene → watch vitals respond.
class BedsideTreatmentScreen extends StatefulWidget {
  const BedsideTreatmentScreen({
    super.key,
    required this.progress,
    required this.bed,
  });

  final HealthCareerProgress progress;
  final HospitalBed bed;

  @override
  State<BedsideTreatmentScreen> createState() => _BedsideTreatmentScreenState();
}

class _BedsideTreatmentScreenState extends State<BedsideTreatmentScreen> {
  _Phase _phase = _Phase.arrive;
  late LiveVitals _vitals;
  final Set<String> _asked = <String>{};
  String? _reply;
  bool _vitalsRevealed = false;
  final Set<String> _done = <String>{};
  final List<String> _log = <String>[];
  final TextEditingController _note = TextEditingController();
  Timer? _ticker;
  int? _score;
  bool _critical = false;
  List<String> _notes = <String>[];
  bool _submitting = false;

  HospitalBed get _bed => widget.bed;
  PatientProfile get _patient => _bed.patient;
  List<TreatmentAction> get _toolkit => HospitalWardCatalog.toolkitFor(_bed);

  @override
  void initState() {
    super.initState();
    _vitals = LiveVitals.fromPatient(_patient.vitals);
    _note.addListener(() {
      if (mounted && _phase == _Phase.document) setState(() {});
    });
    _ticker = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _phase == _Phase.debrief) return;
      setState(() {
        TreatmentEngine.tickUntreated(_vitals);
        if (_vitals.critical && !_done.contains('notify_md')) {
          _log.add('Monitor alarm: vitals critical — escalate.');
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _note.dispose();
    super.dispose();
  }

  String _prompt(String key) {
    switch (key) {
      case 'onset':
        return 'When did this start?';
      case 'severity':
        return 'How bad is the shortness of breath?';
      case 'sputum':
        return 'Any cough or sputum?';
      case 'fever':
        return 'Fever or chills?';
      case 'radiation':
        return 'Does the pain go to arm, jaw, or back?';
      case 'relieving':
        return 'What makes it better or worse?';
      case 'pain':
        return 'Where is your pain and how bad?';
      case 'dizziness':
        return 'Any dizziness or fainting?';
      case 'thirst':
        return 'How is your thirst and urination?';
      case 'meds':
        return 'What medicines are you taking?';
      case 'bleeding':
        return 'Any bleeding from the incision?';
      case 'diet':
        return 'Tell me about your usual diet.';
      default:
        return key;
    }
  }

  void _ask(String key) {
    setState(() {
      _asked.add(key);
      _reply = _patient.dialogueHooks[key] ?? '…';
      _log.add('Asked: ${_prompt(key)}');
    });
  }

  void _revealVitals() {
    setState(() {
      _vitalsRevealed = true;
      _log.add(
        'Vitals: HR ${_vitals.hr} · BP ${_vitals.bpLabel} · '
        'SpO₂ ${_vitals.spo2}% · RR ${_vitals.rr} · Temp ${_vitals.tempLabel}',
      );
    });
  }

  void _treat(TreatmentAction a) {
    if (_done.contains(a.id) && a.kind != TreatmentActionKind.reassessment) {
      return;
    }
    final String effect = TreatmentEngine.apply(_vitals, a);
    setState(() {
      _done.add(a.id);
      _log.add('${a.label}: $effect');
    });
  }

  Future<void> _finish() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final result = TreatmentEngine.score(
      bed: _bed,
      doneActions: _done,
      askedKeys: _asked,
      vitals: _vitals,
      measuredVitals: _vitalsRevealed,
    );
    await widget.progress.completeScenario(
      _bed.caseId,
      score: result.score,
      xpGain: result.critical
          ? (_bed.xpReward ~/ 3)
          : (result.score >= 60 ? _bed.xpReward : _bed.xpReward ~/ 2),
    );
    if (!mounted) return;
    setState(() {
      _score = result.score;
      _critical = result.critical;
      _notes = result.notes;
      _phase = _Phase.debrief;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Room ${_bed.roomId}',
        icon: Icons.hotel_rounded,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: MedCosmic.pill(
              _bed.acuity,
              bg: _acuityColor(_bed.acuity).withValues(alpha: 0.22),
              fg: _acuityColor(_bed.acuity),
            ),
          ),
        ],
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _PhaseStrip(phase: _phase),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(flex: 3, child: _sceneColumn()),
                          SizedBox(width: 340, child: _sidePanel()),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        children: <Widget>[
                          _sceneColumn(),
                          const SizedBox(height: 10),
                          _sidePanel(),
                        ],
                      ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sceneColumn() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HospitalBedScene(
            patient: _patient,
            vitals: _vitals,
            vitalsRevealed: _vitalsRevealed,
            caption: _vitalsRevealed
                ? null
                : '${_patient.displayName} · Connect to monitor / take vitals',
          ),
          if (_reply != null) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: MedCosmic.panelBox(radius: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _patient.skinTone,
                    child: Text(
                      _patient.displayName[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '"$_reply"',
                      style: const TextStyle(
                        color: MedCosmic.ink,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_phase == _Phase.treat || _phase == _Phase.document) ...<Widget>[
            const SizedBox(height: 8),
            _VitalsStrip(vitals: _vitals, revealed: _vitalsRevealed),
          ],
        ],
      ),
    );
  }

  Widget _sidePanel() {
    switch (_phase) {
      case _Phase.arrive:
        return _ArrivePanel(bed: _bed);
      case _Phase.interview:
        return _InterviewPanel(
          keys: _bed.interviewKeys,
          asked: _asked,
          promptFor: _prompt,
          onAsk: _ask,
        );
      case _Phase.vitals:
        return _VitalsPanel(
          revealed: _vitalsRevealed,
          vitals: _vitals,
          onMeasure: _revealVitals,
        );
      case _Phase.treat:
        return _TreatPanel(
          actions: _toolkit,
          done: _done,
          onTreat: _treat,
          log: _log,
        );
      case _Phase.document:
        return _DocPanel(controller: _note, log: _log);
      case _Phase.debrief:
        return _DebriefPanel(
          bed: _bed,
          score: _score ?? 0,
          critical: _critical,
          notes: _notes,
          vitals: _vitals,
        );
    }
  }

  Widget _bottomBar() {
    if (_phase == _Phase.debrief) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: FilledButton.styleFrom(
            backgroundColor: MedCosmic.clinical,
            foregroundColor: MedCosmic.bgDeep,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Return to ward'),
        ),
      );
    }

    final bool canNext = switch (_phase) {
      _Phase.arrive => true,
      _Phase.interview => _asked.length >= 2,
      _Phase.vitals => _vitalsRevealed,
      _Phase.treat => _done.length >= 2,
      _Phase.document => _note.text.trim().length >= 12,
      _Phase.debrief => true,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_phase.index > 0)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _phase = _Phase.values[_phase.index - 1];
                });
              },
              style: OutlinedButton.styleFrom(foregroundColor: MedCosmic.mute),
              child: const Text('Back'),
            ),
          if (_phase.index > 0) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext || _submitting
                  ? null
                  : () {
                      if (_phase == _Phase.document) {
                        _finish();
                      } else {
                        setState(() {
                          _phase = _Phase.values[_phase.index + 1];
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: MedCosmic.purple,
                foregroundColor: MedCosmic.ink,
                disabledBackgroundColor: MedCosmic.panelAlt,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                _submitting
                    ? 'Scoring…'
                    : _phase == _Phase.document
                        ? 'Complete handoff'
                        : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _acuityColor(String a) {
    switch (a) {
      case 'Critical':
        return MedCosmic.danger;
      case 'Urgent':
        return MedCosmic.warning;
      case 'Watch':
        return MedCosmic.gold;
      default:
        return MedCosmic.success;
    }
  }
}

class _PhaseStrip extends StatelessWidget {
  const _PhaseStrip({required this.phase});
  final _Phase phase;

  static const List<String> labels = <String>[
    'Arrive',
    'Ask',
    'Vitals',
    'Treat',
    'Document',
    'Debrief',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: List<Widget>.generate(labels.length, (int i) {
          final bool on = i == phase.index;
          final bool done = i < phase.index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: MedCosmic.pill(
              labels[i],
              bg: on
                  ? MedCosmic.clinical.withValues(alpha: 0.28)
                  : done
                      ? MedCosmic.success.withValues(alpha: 0.18)
                      : MedCosmic.panelAlt,
              fg: on
                  ? MedCosmic.clinical
                  : done
                      ? MedCosmic.success
                      : MedCosmic.mute,
            ),
          );
        }),
      ),
    );
  }
}

class _VitalsStrip extends StatelessWidget {
  const _VitalsStrip({required this.vitals, required this.revealed});
  final LiveVitals vitals;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    if (!revealed) {
      return MedCosmic.pill('Vitals not yet measured', bg: MedCosmic.panelAlt);
    }
    Widget cell(String k, String v, Color c) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: MedCosmic.panelBox(radius: 10),
            child: Column(
              children: <Widget>[
                Text(k, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
                Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 15)),
              ],
            ),
          ),
        );
    return Row(
      children: <Widget>[
        cell('HR', '${vitals.hr}', vitals.tachycardic ? MedCosmic.danger : MedCosmic.ink),
        cell('BP', vitals.bpLabel, vitals.hypertensive || vitals.systolic < 100 ? MedCosmic.warning : MedCosmic.ink),
        cell('SpO₂', '${vitals.spo2}%', vitals.hypoxia ? MedCosmic.danger : MedCosmic.success),
        cell('RR', '${vitals.rr}', vitals.tachypneic ? MedCosmic.warning : MedCosmic.ink),
        cell('Temp', vitals.tempLabel, vitals.febrile ? MedCosmic.warning : MedCosmic.ink),
      ],
    );
  }
}

class _ArrivePanel extends StatelessWidget {
  const _ArrivePanel({required this.bed});
  final HospitalBed bed;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Text(
            bed.patient.displayName,
            style: const TextStyle(
              color: MedCosmic.clinical,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${bed.patient.ageYears} · ${bed.patient.sexLabel} · ${bed.unit}',
            style: const TextStyle(color: MedCosmic.mute),
          ),
          const SizedBox(height: 10),
          MedCosmic.pill(bed.acuity),
          const SizedBox(height: 12),
          const Text('Chief complaint', style: TextStyle(color: MedCosmic.gold, fontWeight: FontWeight.w800)),
          Text(bed.patient.chiefComplaint, style: const TextStyle(color: MedCosmic.ink, height: 1.35)),
          const SizedBox(height: 10),
          const Text('Clinical hint', style: TextStyle(color: MedCosmic.gold, fontWeight: FontWeight.w800)),
          Text(bed.diagnosisHint, style: const TextStyle(color: MedCosmic.mute, height: 1.35)),
          const SizedBox(height: 10),
          const Text('Allergies', style: TextStyle(color: MedCosmic.danger, fontWeight: FontWeight.w800)),
          Text(bed.patient.allergies.join(', '), style: const TextStyle(color: MedCosmic.ink)),
          const SizedBox(height: 10),
          const Text('Objectives', style: TextStyle(color: MedCosmic.gold, fontWeight: FontWeight.w800)),
          ...bed.objectives.map(
            (String o) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $o', style: const TextStyle(color: MedCosmic.mute, height: 1.3)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewPanel extends StatelessWidget {
  const _InterviewPanel({
    required this.keys,
    required this.asked,
    required this.promptFor,
    required this.onAsk,
  });

  final List<String> keys;
  final Set<String> asked;
  final String Function(String) promptFor;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          const Text(
            'Ask the patient',
            style: TextStyle(color: MedCosmic.ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Talk at the bedside before treating.',
            style: TextStyle(color: MedCosmic.mute, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...keys.map((String k) {
            final bool done = asked.contains(k);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => onAsk(k),
                style: OutlinedButton.styleFrom(
                  foregroundColor: done ? MedCosmic.success : MedCosmic.ink,
                  side: BorderSide(
                    color: done ? MedCosmic.success : MedCosmic.stroke,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                child: Text(promptFor(k)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _VitalsPanel extends StatelessWidget {
  const _VitalsPanel({
    required this.revealed,
    required this.vitals,
    required this.onMeasure,
  });

  final bool revealed;
  final LiveVitals vitals;
  final VoidCallback onMeasure;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          const Text(
            'Bedside assessment',
            style: TextStyle(color: MedCosmic.ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: revealed ? null : onMeasure,
            icon: const Icon(Icons.monitor_heart_rounded),
            label: Text(revealed ? 'Vitals on monitor' : 'Take vitals now'),
            style: FilledButton.styleFrom(
              backgroundColor: MedCosmic.clinical,
              foregroundColor: MedCosmic.bgDeep,
              disabledBackgroundColor: MedCosmic.panelAlt,
            ),
          ),
          if (revealed) ...<Widget>[
            const SizedBox(height: 14),
            _flag('SpO₂', '${vitals.spo2}%', vitals.hypoxia),
            _flag('Heart rate', '${vitals.hr} bpm', vitals.tachycardic),
            _flag('Blood pressure', vitals.bpLabel, vitals.hypertensive || vitals.systolic < 100),
            _flag('Respiratory rate', '${vitals.rr}', vitals.tachypneic),
            _flag('Temperature', vitals.tempLabel, vitals.febrile),
            _flag('Pain', '${vitals.painScore}/10', vitals.painScore >= 5),
          ],
        ],
      ),
    );
  }

  Widget _flag(String k, String v, bool abnormal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: MedCosmic.panelBox(
        color: abnormal
            ? MedCosmic.danger.withValues(alpha: 0.12)
            : MedCosmic.panelAlt,
        radius: 10,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(k, style: const TextStyle(color: MedCosmic.mute)),
          ),
          Text(
            v,
            style: TextStyle(
              color: abnormal ? MedCosmic.danger : MedCosmic.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (abnormal) ...<Widget>[
            const SizedBox(width: 6),
            MedCosmic.pill('Abnormal', bg: MedCosmic.danger.withValues(alpha: 0.2), fg: MedCosmic.danger),
          ],
        ],
      ),
    );
  }
}

class _TreatPanel extends StatelessWidget {
  const _TreatPanel({
    required this.actions,
    required this.done,
    required this.onTreat,
    required this.log,
  });

  final List<TreatmentAction> actions;
  final Set<String> done;
  final ValueChanged<TreatmentAction> onTreat;
  final List<String> log;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          const Text(
            'Treat the patient',
            style: TextStyle(color: MedCosmic.ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Interventions change live vitals. Unsafe choices hurt the patient.',
            style: TextStyle(color: MedCosmic.mute, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          ...actions.map((TreatmentAction a) {
            final bool used = done.contains(a.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTreat(a),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: MedCosmic.panelBox(
                      color: used
                          ? MedCosmic.success.withValues(alpha: 0.12)
                          : null,
                      radius: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          a.icon,
                          color: a.safe ? MedCosmic.clinical : MedCosmic.danger,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                a.label,
                                style: const TextStyle(
                                  color: MedCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                a.detail,
                                style: const TextStyle(
                                  color: MedCosmic.mute,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (used)
                          const Icon(Icons.check_circle, color: MedCosmic.success, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (log.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            const Text('Care log', style: TextStyle(color: MedCosmic.gold, fontWeight: FontWeight.w800)),
            ...log.reversed.take(6).map(
                  (String l) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• $l', style: const TextStyle(color: MedCosmic.mute, fontSize: 11, height: 1.3)),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _DocPanel extends StatelessWidget {
  const _DocPanel({required this.controller, required this.log});
  final TextEditingController controller;
  final List<String> log;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          const Text(
            'Document & handoff',
            style: TextStyle(color: MedCosmic.ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 5,
            onChanged: (_) {},
            style: const TextStyle(color: MedCosmic.ink),
            decoration: InputDecoration(
              hintText: 'SBAR note: Situation, Background, Assessment, Recommendation…',
              hintStyle: const TextStyle(color: MedCosmic.mute, fontSize: 13),
              filled: true,
              fillColor: MedCosmic.panelAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MedCosmic.stroke),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Session log', style: TextStyle(color: MedCosmic.gold, fontWeight: FontWeight.w800)),
          ...log.map(
            (String l) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $l', style: const TextStyle(color: MedCosmic.mute, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebriefPanel extends StatelessWidget {
  const _DebriefPanel({
    required this.bed,
    required this.score,
    required this.critical,
    required this.notes,
    required this.vitals,
  });

  final HospitalBed bed;
  final int score;
  final bool critical;
  final List<String> notes;
  final LiveVitals vitals;

  @override
  Widget build(BuildContext context) {
    final bool passed = !critical && score >= 60;
    return _Panel(
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Text(
            passed ? 'Case complete' : 'Needs improvement',
            style: TextStyle(
              color: passed ? MedCosmic.success : MedCosmic.warning,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Score $score / 100${critical ? " · critical safety error" : ""}',
            style: const TextStyle(color: MedCosmic.ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Final vitals: SpO₂ ${vitals.spo2}% · HR ${vitals.hr} · BP ${vitals.bpLabel}',
            style: const TextStyle(color: MedCosmic.mute, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(bed.debrief, style: const TextStyle(color: MedCosmic.mute, height: 1.4)),
          const SizedBox(height: 12),
          ...notes.map(
            (String n) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $n', style: const TextStyle(color: MedCosmic.mute, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 12, 8),
      decoration: MedCosmic.panelBox(radius: 16),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
