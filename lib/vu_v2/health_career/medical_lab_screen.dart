import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';

enum _LabStep {
  pickSpecimen,
  receive,
  process,
  result,
  flag,
  criticalReport,
  done,
}

class _SpecimenWorkflow {
  const _SpecimenWorkflow({
    required this.id,
    required this.label,
    required this.source,
    required this.patientLabel,
    required this.processHint,
    required this.resultLines,
    required this.abnormal,
    required this.critical,
    required this.criticalValue,
    required this.interpretation,
    required this.reportKeywords,
  });

  final String id;
  final String label;
  final String source;
  final String patientLabel;
  final String processHint;
  final List<String> resultLines;
  final bool abnormal;
  final bool critical;
  final String criticalValue;
  final String interpretation;
  final List<String> reportKeywords;
}

/// Interactive specimen workflows: CBC + urinalysis with critical reporting.
class MedicalLabScreen extends StatefulWidget {
  const MedicalLabScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<MedicalLabScreen> createState() => _MedicalLabScreenState();
}

class _MedicalLabScreenState extends State<MedicalLabScreen> {
  static const List<_SpecimenWorkflow> _workflows = <_SpecimenWorkflow>[
    _SpecimenWorkflow(
      id: 'cbc',
      label: 'CBC with differential',
      source: 'EDTA whole blood · SPEC-CBC-1204',
      patientLabel: 'Maria Lopez (educational)',
      processHint:
          'Verify label → mix tube gently → run analyzer → review flags.',
      resultLines: <String>[
        'WBC 18.6 ×10⁹/L (H)',
        'Neutrophils 88%',
        'Hb 12.9 g/dL',
        'Platelets 42 ×10⁹/L (L) — CRITICAL LOW',
        'MCV 88 fL',
      ],
      abnormal: true,
      critical: true,
      criticalValue: 'Platelets 42 ×10⁹/L',
      interpretation:
          'Leukocytosis with neutrophilia plus critical thrombocytopenia — '
          'report immediately to clinical team.',
      reportKeywords: <String>[
        'platelet',
        'thrombocytopenia',
        'critical',
        '42',
      ],
    ),
    _SpecimenWorkflow(
      id: 'ua',
      label: 'Urinalysis (dip + micro)',
      source: 'Clean-catch urine · SPEC-UA-771',
      patientLabel: 'Jamal Reed (educational)',
      processHint:
          'Check integrity → dipstick → centrifuge for microscopy → document.',
      resultLines: <String>[
        'Appearance: cloudy',
        'Leukocyte esterase: positive',
        'Nitrite: positive',
        'WBC 25–50 /hpf',
        'Bacteria: many',
        'RBC 0–2 /hpf',
        'No critical chemistry alert',
      ],
      abnormal: true,
      critical: false,
      criticalValue: 'None — infection pattern, not a critical chemical value',
      interpretation:
          'Findings support UTI pattern educationally; escalate clinically, '
          'but no classic critical-value chemistry alert.',
      reportKeywords: <String>['uti', 'infection', 'leukocyte', 'nitrite', 'bacteria'],
    ),
  ];

  _LabStep _step = _LabStep.pickSpecimen;
  _SpecimenWorkflow? _selected;
  bool? _markedAbnormal;
  bool? _markedCritical;
  bool _calledCritical = false;
  final TextEditingController _report = TextEditingController();
  int? _score;
  List<String> _feedback = <String>[];
  bool _awarding = false;

  @override
  void dispose() {
    _report.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_awarding || _selected == null || _markedAbnormal == null) return;
    if (_markedCritical == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decide if a critical value is present.')),
      );
      return;
    }
    final String text = _report.text.trim();
    if (text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write a short critical-value style report.'),
        ),
      );
      return;
    }

    setState(() => _awarding = true);
    final _SpecimenWorkflow w = _selected!;
    final List<String> fb = <String>[];
    int score = 25;

    if (_markedAbnormal == w.abnormal) {
      score += 20;
      fb.add('Abnormal flag correct.');
    } else {
      score -= 8;
      fb.add('Abnormal recognition missed. ${w.interpretation}');
    }

    if (_markedCritical == w.critical) {
      score += 25;
      fb.add(
        w.critical
            ? 'Critical value correctly identified (${w.criticalValue}).'
            : 'Correctly noted: no classic critical chemical alert.',
      );
    } else {
      score -= 12;
      fb.add(
        w.critical
            ? 'Missed critical: ${w.criticalValue}.'
            : 'Over-called critical — this UA has no critical chemistry alert.',
      );
    }

    if (w.critical) {
      if (_calledCritical) {
        score += 15;
        fb.add('Critical call / escalate step completed.');
      } else {
        score -= 15;
        fb.add('Critical CBC requires an explicit report/call step.');
      }
    } else if (_calledCritical) {
      score += 5;
      fb.add('Documented escalation even without critical chemistry — acceptable.');
    }

    final String lower = text.toLowerCase();
    final bool keywordHit =
        w.reportKeywords.any((String k) => lower.contains(k));
    if (keywordHit) {
      score += 10;
      fb.add('Report language matched educational key findings.');
    } else {
      fb.add('Tighten report wording to the key laboratory finding.');
    }
    if (text.length >= 40) score += 5;

    score = score.clamp(0, 100);
    await widget.progress.completeScenario(
      'mls_${w.id}_v1',
      score: score,
      xpGain: 80 + (score ~/ 5),
    );
    await widget.progress.completeSkill('mls_${w.id}_workflow', xpGain: 20);

    if (!mounted) return;
    setState(() {
      _score = score;
      _feedback = fb;
      _step = _LabStep.done;
      _awarding = false;
    });
  }

  void _resetForNew() {
    setState(() {
      _step = _LabStep.pickSpecimen;
      _selected = null;
      _markedAbnormal = null;
      _markedCritical = null;
      _calledCritical = false;
      _report.clear();
      _score = null;
      _feedback = <String>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Medical Laboratory',
        icon: Icons.biotech_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _LabDots(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<_LabStep>(_step),
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
      case _LabStep.pickSpecimen:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Choose a specimen workflow',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete CBC and urinalysis paths for full MLS practice.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._workflows.map((_SpecimenWorkflow w) {
              final bool on = _selected?.id == w.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selected = w),
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: on
                            ? MedCosmic.purple.withValues(alpha: 0.18)
                            : MedCosmic.panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: on ? MedCosmic.purple : MedCosmic.stroke,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            on
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: on ? MedCosmic.purple : MedCosmic.mute,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  w.label,
                                  style: const TextStyle(
                                    color: MedCosmic.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  w.source,
                                  style: const TextStyle(
                                    color: MedCosmic.mute,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      case _LabStep.receive:
        final _SpecimenWorkflow w = _selected!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: MedCosmic.panelBox(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MedCosmic.pill(
                    w.source.split('·').last.trim(),
                    bg: MedCosmic.gold.withValues(alpha: 0.2),
                    fg: MedCosmic.gold,
                    icon: Icons.qr_code_2_rounded,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Received: ${w.label}',
                    style: const TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient: ${w.patientLabel}\n${w.source}',
                    style: const TextStyle(
                      color: MedCosmic.mute,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Verify label matches requisition, then process.',
                    style: TextStyle(color: MedCosmic.mute, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        );
      case _LabStep.process:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: MedCosmic.panelBox(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Processing checklist',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _selected!.processHint,
                    style: const TextStyle(
                      color: MedCosmic.mute,
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  MedCosmic.pill(
                    'Educational simulation — predefined results next',
                    bg: MedCosmic.clinical.withValues(alpha: 0.18),
                    fg: MedCosmic.clinical,
                    icon: Icons.info_outline_rounded,
                  ),
                ],
              ),
            ),
          ],
        );
      case _LabStep.result:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Text(
              _selected!.label,
              style: const TextStyle(
                color: MedCosmic.mute,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ..._selected!.resultLines.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: MedCosmic.panelBox(
                    color: line.toLowerCase().contains('critical')
                        ? MedCosmic.danger.withValues(alpha: 0.12)
                        : MedCosmic.panel,
                  ),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: line.toLowerCase().contains('critical')
                          ? MedCosmic.danger
                          : MedCosmic.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case _LabStep.flag:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Is the panel abnormal?',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ChoiceChip(
                    label: 'Abnormal',
                    selected: _markedAbnormal == true,
                    color: MedCosmic.warning,
                    onTap: () => setState(() => _markedAbnormal = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ChoiceChip(
                    label: 'Within range',
                    selected: _markedAbnormal == false,
                    color: MedCosmic.success,
                    onTap: () => setState(() => _markedAbnormal = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Is there a critical value to report?',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ChoiceChip(
                    label: 'Critical yes',
                    selected: _markedCritical == true,
                    color: MedCosmic.danger,
                    onTap: () => setState(() => _markedCritical = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ChoiceChip(
                    label: 'No critical',
                    selected: _markedCritical == false,
                    color: MedCosmic.teal,
                    onTap: () => setState(() => _markedCritical = false),
                  ),
                ),
              ],
            ),
            if (_markedAbnormal != null && _markedCritical != null) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                child: Text(
                  'Teaching note: ${_selected!.interpretation}',
                  style: const TextStyle(
                    color: MedCosmic.mute,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        );
      case _LabStep.criticalReport:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Critical-value reporting step',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reference: ${_selected!.criticalValue}',
              style: const TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _calledCritical = !_calledCritical),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _calledCritical
                        ? MedCosmic.danger.withValues(alpha: 0.16)
                        : MedCosmic.panel,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          _calledCritical ? MedCosmic.danger : MedCosmic.stroke,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        _calledCritical
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: _calledCritical
                            ? MedCosmic.danger
                            : MedCosmic.mute,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'I notified / documented escalation to clinical team',
                          style: TextStyle(
                            color: MedCosmic.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _report,
              maxLines: 5,
              style: const TextStyle(color: MedCosmic.ink),
              decoration: InputDecoration(
                filled: true,
                fillColor: MedCosmic.panel,
                hintText:
                    'Write the call / report note (finding + action)…',
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
      case _LabStep.done:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.science_rounded,
                    color: MedCosmic.teal,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_selected?.label ?? "Lab"} workflow complete',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score ${_score ?? 0}/100 · mls_${_selected?.id ?? "demo"}_v1',
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
    if (_step == _LabStep.done) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: _resetForNew,
                style: OutlinedButton.styleFrom(
                  foregroundColor: MedCosmic.mute,
                  side: const BorderSide(color: MedCosmic.stroke),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Another specimen'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
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
          ],
        ),
      );
    }

    final bool canNext = switch (_step) {
      _LabStep.pickSpecimen => _selected != null,
      _LabStep.receive => true,
      _LabStep.process => true,
      _LabStep.result => true,
      _LabStep.flag => _markedAbnormal != null && _markedCritical != null,
      _LabStep.criticalReport => !_awarding,
      _LabStep.done => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_step != _LabStep.pickSpecimen)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _step = _LabStep.values[_step.index - 1];
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (_step != _LabStep.pickSpecimen) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext
                  ? null
                  : () {
                      if (_step == _LabStep.criticalReport) {
                        _submitReport();
                        return;
                      }
                      setState(() {
                        _step = _LabStep.values[_step.index + 1];
                      });
                    },
              style: FilledButton.styleFrom(
                backgroundColor: MedCosmic.purple,
                foregroundColor: MedCosmic.ink,
                disabledBackgroundColor: MedCosmic.panelAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _awarding
                    ? 'Saving…'
                    : _step == _LabStep.criticalReport
                        ? 'Submit report'
                        : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabDots extends StatelessWidget {
  const _LabDots({required this.step});

  final _LabStep step;

  static const List<String> _labels = <String>[
    'Pick',
    'Receive',
    'Process',
    'Result',
    'Flag',
    'Report',
    'Done',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: List<Widget>.generate(_labels.length, (int i) {
          final bool active = i == step.index;
          final bool done = i < step.index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: MedCosmic.pill(
              _labels[i],
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

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : MedCosmic.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : MedCosmic.stroke),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : MedCosmic.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
