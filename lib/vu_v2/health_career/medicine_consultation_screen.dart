import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'models/patient_profile.dart';

enum _MedStep {
  history,
  symptoms,
  exam,
  investigations,
  results,
  differential,
  nextStep,
  document,
  evaluate,
}

/// Fully playable medicine consult for Jamal Reed (GERD/gastritis vs ACS trap).
class MedicineConsultationScreen extends StatefulWidget {
  const MedicineConsultationScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<MedicineConsultationScreen> createState() =>
      _MedicineConsultationScreenState();
}

class _MedicineConsultationScreenState
    extends State<MedicineConsultationScreen> {
  static const PatientProfile _patient = PatientCatalog.jamalReed;
  static const String _scenarioId = 'medicine_consult_v1';

  static const List<_HistoryQ> _historyQs = <_HistoryQ>[
    _HistoryQ(
      id: 'onset',
      prompt: 'When did the pain start?',
      replyKey: 'onset',
    ),
    _HistoryQ(
      id: 'radiation',
      prompt: 'Does the pain radiate to arm, jaw, or back?',
      replyKey: 'radiation',
    ),
    _HistoryQ(
      id: 'relieving',
      prompt: 'What makes it better or worse?',
      replyKey: 'relieving',
    ),
    _HistoryQ(
      id: 'cardiac_hx',
      prompt: 'Any prior heart disease, diabetes, or smoking?',
      localReply:
          'No heart problems that I know of. I don\'t smoke. Night-shift worker.',
    ),
  ];

  static const List<_Choice> _symptomFlags = <_Choice>[
    _Choice(id: 'postprandial', label: 'Pain after large / spicy meal'),
    _Choice(id: 'epigastric', label: 'Epigastric location (upper belly)'),
    _Choice(id: 'no_radiation', label: 'No arm/jaw radiation'),
    _Choice(id: 'diaphoresis', label: 'Heavy sweating / syncope (trap)'),
    _Choice(id: 'crushing_chest', label: 'Crushing mid-chest pressure (trap)'),
  ];

  static const List<_ExamFinding> _examFindings = <_ExamFinding>[
    _ExamFinding(
      id: 'abdomen',
      label: 'Abdomen',
      finding: 'Epigastric tenderness; soft, non-peritoneal. Bowel sounds present.',
    ),
    _ExamFinding(
      id: 'heart',
      label: 'Heart',
      finding: 'Regular rate/rhythm, no murmur, no S3/S4.',
    ),
    _ExamFinding(
      id: 'lungs',
      label: 'Lungs',
      finding: 'Clear bilaterally; no crackles or wheeze.',
    ),
    _ExamFinding(
      id: 'vitals',
      label: 'Vitals review',
      finding: 'HR 88 · BP 128/78 · SpO₂ 98% · Temp 36.8 °C · Pain 6/10',
    ),
  ];

  static const List<_Choice> _investigations = <_Choice>[
    _Choice(id: 'ecg', label: '12-lead ECG'),
    _Choice(id: 'troponin', label: 'Troponin (serial)'),
    _Choice(id: 'cbc', label: 'CBC'),
    _Choice(id: 'cmp', label: 'CMP / LFTs'),
    _Choice(id: 'cxr', label: 'Chest X-ray'),
    _Choice(id: 'ugi', label: 'Urgent upper GI endoscopy (now)'),
    _Choice(id: 'cath', label: 'Activate cath lab NOW (no ECG)'),
  ];

  static const Map<String, String> _resultText = <String, String>{
    'ecg': 'Sinus rhythm · no ST elevation · no ischemic T-wave changes.',
    'troponin': 'Troponin I: 0.01 ng/mL (below educational cutoff).',
    'cbc': 'WBC 7.2 · Hb 14.8 · Plt 240 — within range.',
    'cmp': 'Normal electrolytes · mildly elevated ALT 48 (borderline).',
    'cxr': 'No infiltrate, no widened mediastinum, heart size normal.',
    'ugi': 'Not indicated emergently; defer elective after stabilization.',
    'cath': 'CRITICAL ERROR: cath lab activated without ECG/troponin gate.',
  };

  static const List<_Choice> _differentials = <_Choice>[
    _Choice(id: 'gerd', label: 'GERD / gastritis (most likely)'),
    _Choice(id: 'mi', label: 'Acute ST-elevation MI'),
    _Choice(id: 'pancreatitis', label: 'Acute pancreatitis'),
    _Choice(id: 'aortic', label: 'Aortic dissection'),
    _Choice(id: 'pe', label: 'Pulmonary embolism'),
  ];

  static const List<_Choice> _nextSteps = <_Choice>[
    _Choice(id: 'ppi_trial', label: 'Trial PPI + antacid, observe, educate diet'),
    _Choice(id: 'admit_acs', label: 'Admit as ACS pathway, heparin drip'),
    _Choice(id: 'cath_now', label: 'Urgent cath lab transfer'),
    _Choice(id: 'pcn', label: 'Give IM penicillin for presumed infection'),
    _Choice(id: 'discharge_nsaid', label: 'Discharge with high-dose NSAID only'),
  ];

  _MedStep _step = _MedStep.history;
  final Set<String> _askedHistory = <String>{};
  String? _lastReply;
  final Set<String> _symptomMarks = <String>{};
  final Set<String> _examOpened = <String>{};
  final Set<String> _ordered = <String>{};
  String? _differential;
  String? _nextStep;
  final TextEditingController _note = TextEditingController();
  int? _score;
  List<String> _feedback = <String>[];
  bool _criticalError = false;
  bool _submitting = false;

  void _onNoteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _note.addListener(_onNoteChanged);
  }

  @override
  void dispose() {
    _note.removeListener(_onNoteChanged);
    _note.dispose();
    super.dispose();
  }

  void _askHistory(_HistoryQ q) {
    final String reply = q.localReply ??
        _patient.dialogueHooks[q.replyKey!] ??
        '…';
    setState(() {
      _askedHistory.add(q.id);
      _lastReply = reply;
    });
  }

  Future<void> _evaluate() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final List<String> fb = <String>[];
    int score = 20;
    bool critical = false;

    if (_askedHistory.length >= 3) {
      score += 10;
      fb.add('Solid history coverage.');
    } else {
      fb.add('Ask more history questions before deciding.');
    }

    final bool goodSymptoms = _symptomMarks.contains('postprandial') &&
        _symptomMarks.contains('epigastric') &&
        _symptomMarks.contains('no_radiation') &&
        !_symptomMarks.contains('diaphoresis') &&
        !_symptomMarks.contains('crushing_chest');
    if (goodSymptoms) {
      score += 12;
      fb.add('Symptom review matches educational GERD pattern.');
    } else {
      fb.add('Symptom flags: prioritize post-meal epigastric pain without radiation.');
      if (_symptomMarks.contains('diaphoresis') ||
          _symptomMarks.contains('crushing_chest')) {
        score -= 8;
        fb.add('Avoid inventing ACS red-flag symptoms not supported by the case.');
      }
    }

    if (_examOpened.length >= 3) {
      score += 8;
      fb.add('Physical exam findings reviewed.');
    }

    if (_ordered.contains('cath') && !_ordered.contains('ecg')) {
      critical = true;
      score = 15;
      fb.add('CRITICAL: cath lab without ECG is unsafe in this simulation.');
    } else if (_ordered.contains('cath')) {
      critical = true;
      score = (score * 0.4).round().clamp(10, 40);
      fb.add('CRITICAL: cath activation is not indicated here.');
    }

    if (_ordered.contains('ecg')) {
      score += 12;
      fb.add('ECG appropriately ordered to rule out ACS.');
    } else if (!critical) {
      score -= 10;
      fb.add('Order an ECG before closing an epigastric “crushing” complaint.');
    }
    if (_ordered.contains('troponin')) {
      score += 8;
      fb.add('Troponin helps exclude ACS.');
    }

    if (_differential == 'gerd') {
      score += 15;
      fb.add('Correct differential: GERD/gastritis.');
    } else if (_differential == 'mi') {
      score -= 12;
      fb.add('STEMI is not supported by ECG/troponin/history here.');
    } else {
      score -= 5;
      fb.add('Best fit differential is GERD/gastritis.');
    }

    if (_nextStep == 'ppi_trial') {
      score += 15;
      fb.add('Safe next step: PPI/antacid trial and observation.');
    } else if (_nextStep == 'pcn') {
      critical = true;
      score = 10;
      fb.add('CRITICAL: penicillin has no role and risks harm (even with NKDA, wrong indication).');
    } else if (_nextStep == 'cath_now' || _nextStep == 'admit_acs') {
      score -= 15;
      fb.add('ACS pathway / cath is overtreatment for this educational case.');
    } else if (_nextStep == 'discharge_nsaid') {
      score -= 10;
      fb.add('High-dose NSAID alone can worsen gastritis.');
    }

    final String note = _note.text.trim().toLowerCase();
    if (note.length >= 40) {
      score += 8;
      fb.add('Documentation length adequate.');
    }
    if (note.contains('gerd') ||
        note.contains('gastritis') ||
        note.contains('epigastric')) {
      score += 5;
    }

    if (critical) {
      _criticalError = true;
      score = score.clamp(0, 35);
    } else {
      score = score.clamp(0, 100);
    }

    final int xpGain = critical
        ? 40
        : (90 + (score ~/ 4)).clamp(60, 140);

    await widget.progress.completeScenario(
      _scenarioId,
      score: score,
      xpGain: xpGain,
    );
    await widget.progress.completeSkill('medicine_consult_flow', xpGain: 25);

    if (!mounted) return;
    setState(() {
      _score = score;
      _feedback = fb;
      _criticalError = critical;
      _step = _MedStep.evaluate;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Medicine Consultation',
        icon: Icons.medical_services_rounded,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MedCosmic.pill(
              _patient.displayName,
              bg: MedCosmic.electric.withValues(alpha: 0.2),
              fg: MedCosmic.electric,
            ),
          ),
        ],
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _StepPills(
                labels: const <String>[
                  'History',
                  'Symptoms',
                  'Exam',
                  'Orders',
                  'Results',
                  'DDx',
                  'Plan',
                  'Note',
                  'Score',
                ],
                index: _step.index,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<_MedStep>(_step),
                    child: _body(),
                  ),
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case _MedStep.history:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            _PatientHeader(patient: _patient),
            const SizedBox(height: 12),
            const Text(
              'Ask history questions (at least 3)',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ..._historyQs.map((_HistoryQ q) {
              final bool asked = _askedHistory.contains(q.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectTile(
                  selected: asked,
                  title: q.prompt,
                  onTap: () => _askHistory(q),
                ),
              );
            }),
            if (_lastReply != null) ...<Widget>[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                child: Text(
                  'Patient: “$_lastReply”',
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        );
      case _MedStep.symptoms:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Mark findings supported by the interview',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Educational case — do not invent unsupported red flags.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._symptomFlags.map((_Choice c) {
              final bool on = _symptomMarks.contains(c.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectTile(
                  selected: on,
                  title: c.label,
                  multi: true,
                  onTap: () {
                    setState(() {
                      if (on) {
                        _symptomMarks.remove(c.id);
                      } else {
                        _symptomMarks.add(c.id);
                      }
                    });
                  },
                ),
              );
            }),
          ],
        );
      case _MedStep.exam:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Review physical exam findings',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ..._examFindings.map((_ExamFinding e) {
              final bool open = _examOpened.contains(e.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _examOpened.add(e.id)),
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: MedCosmic.panelBox(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                open
                                    ? Icons.check_circle
                                    : Icons.touch_app_rounded,
                                color: open ? MedCosmic.success : MedCosmic.mute,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                e.label,
                                style: const TextStyle(
                                  color: MedCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          if (open) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
                              e.finding,
                              style: const TextStyle(
                                color: MedCosmic.mute,
                                height: 1.4,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      case _MedStep.investigations:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Select investigations',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ECG first is mandatory before any cath pathway.',
              style: TextStyle(color: MedCosmic.warning, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._investigations.map((_Choice c) {
              final bool on = _ordered.contains(c.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectTile(
                  selected: on,
                  title: c.label,
                  multi: true,
                  danger: c.id == 'cath',
                  onTap: () {
                    setState(() {
                      if (on) {
                        _ordered.remove(c.id);
                      } else {
                        _ordered.add(c.id);
                      }
                    });
                  },
                ),
              );
            }),
          ],
        );
      case _MedStep.results:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Predefined results',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            if (_ordered.isEmpty)
              const Text(
                'No investigations ordered — go back to add ECG/labs.',
                style: TextStyle(color: MedCosmic.mute),
              )
            else
              ..._ordered.map((String id) {
                final String label = _investigations
                    .firstWhere((_Choice c) => c.id == id)
                    .label;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: MedCosmic.panelBox(
                      color: id == 'cath'
                          ? MedCosmic.danger.withValues(alpha: 0.12)
                          : MedCosmic.panel,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          label,
                          style: TextStyle(
                            color: id == 'cath'
                                ? MedCosmic.danger
                                : MedCosmic.clinical,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _resultText[id] ?? '',
                          style: const TextStyle(
                            color: MedCosmic.ink,
                            height: 1.4,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      case _MedStep.differential:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Pick the best working differential',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ..._differentials.map((_Choice c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectTile(
                  selected: _differential == c.id,
                  title: c.label,
                  onTap: () => setState(() => _differential = c.id),
                ),
              );
            }),
          ],
        );
      case _MedStep.nextStep:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Choose the safest next step',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ..._nextSteps.map((_Choice c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectTile(
                  selected: _nextStep == c.id,
                  title: c.label,
                  danger: c.id == 'pcn' || c.id == 'cath_now',
                  onTap: () => setState(() => _nextStep = c.id),
                ),
              );
            }),
          ],
        );
      case _MedStep.document:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Document assessment & plan',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Educational note — fictional patient, not clinical advice.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 6,
              style: const TextStyle(color: MedCosmic.ink),
              decoration: InputDecoration(
                filled: true,
                fillColor: MedCosmic.panel,
                hintText:
                    'e.g. Postprandial epigastric pain; ECG/troponin negative; likely GERD…',
                hintStyle: TextStyle(
                  color: MedCosmic.mute.withValues(alpha: 0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: MedCosmic.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: MedCosmic.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: MedCosmic.clinical),
                ),
              ),
            ),
          ],
        );
      case _MedStep.evaluate:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: Column(
                children: <Widget>[
                  Icon(
                    _criticalError
                        ? Icons.warning_amber_rounded
                        : Icons.verified_rounded,
                    color: _criticalError ? MedCosmic.danger : MedCosmic.success,
                    size: 42,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _criticalError ? 'Critical safety error' : 'Consult complete',
                    style: const TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score ${_score ?? 0}/100 · $_scenarioId',
                    style: const TextStyle(color: MedCosmic.mute),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._feedback.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: MedCosmic.mute,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _footer() {
    if (_step == _MedStep.evaluate) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: FilledButton.styleFrom(
              backgroundColor: MedCosmic.clinical,
              foregroundColor: MedCosmic.bgDeep,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Return to hub'),
          ),
        ),
      );
    }

    final bool canNext = switch (_step) {
      _MedStep.history => _askedHistory.length >= 3,
      _MedStep.symptoms => _symptomMarks.isNotEmpty,
      _MedStep.exam => _examOpened.length >= 2,
      _MedStep.investigations => _ordered.isNotEmpty,
      _MedStep.results => true,
      _MedStep.differential => _differential != null,
      _MedStep.nextStep => _nextStep != null,
      _MedStep.document => !_submitting && _note.text.trim().length >= 20,
      _MedStep.evaluate => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_step != _MedStep.history)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _step = _MedStep.values[_step.index - 1];
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (_step != _MedStep.history) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext
                  ? null
                  : () {
                      if (_step == _MedStep.document) {
                        _evaluate();
                        return;
                      }
                      setState(() {
                        _step = _MedStep.values[_step.index + 1];
                      });
                    },
              style: FilledButton.styleFrom(
                backgroundColor: MedCosmic.purple,
                foregroundColor: MedCosmic.ink,
                disabledBackgroundColor: MedCosmic.panelAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _submitting
                    ? 'Scoring…'
                    : _step == _MedStep.document
                        ? 'Submit & score'
                        : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryQ {
  const _HistoryQ({
    required this.id,
    required this.prompt,
    this.replyKey,
    this.localReply,
  });

  final String id;
  final String prompt;
  final String? replyKey;
  final String? localReply;
}

class _Choice {
  const _Choice({required this.id, required this.label});

  final String id;
  final String label;
}

class _ExamFinding {
  const _ExamFinding({
    required this.id,
    required this.label,
    required this.finding,
  });

  final String id;
  final String label;
  final String finding;
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient});

  final PatientProfile patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MedCosmic.panelBox(),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 26,
            backgroundColor: patient.skinTone,
            child: Text(
              patient.displayName[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${patient.displayName}, ${patient.ageYears}${patient.sexLabel[0]}',
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.chiefComplaint,
                  style: const TextStyle(
                    color: MedCosmic.mute,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.selected,
    required this.title,
    required this.onTap,
    this.multi = false,
    this.danger = false,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;
  final bool multi;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color accent = danger ? MedCosmic.danger : MedCosmic.purple;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.18) : MedCosmic.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? accent : MedCosmic.stroke),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                multi
                    ? (selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded)
                    : (selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off),
                color: selected ? accent : MedCosmic.mute,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected && danger ? MedCosmic.danger : MedCosmic.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepPills extends StatelessWidget {
  const _StepPills({required this.labels, required this.index});

  final List<String> labels;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: List<Widget>.generate(labels.length, (int i) {
          final bool active = i == index;
          final bool done = i < index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: MedCosmic.pill(
              labels[i],
              bg: active
                  ? MedCosmic.teal.withValues(alpha: 0.28)
                  : done
                      ? MedCosmic.success.withValues(alpha: 0.18)
                      : MedCosmic.panelAlt,
              fg: active
                  ? MedCosmic.teal
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
