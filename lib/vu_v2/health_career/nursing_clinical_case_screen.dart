import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'models/clinical_scenario.dart';
import 'models/patient_profile.dart';

enum _CaseStep {
  brief,
  interview,
  instruments,
  flagAbnormals,
  actions,
  debrief,
}

/// Full playable nursing case for [ClinicalScenarioCatalog.dyspneaWard].
class NursingClinicalCaseScreen extends StatefulWidget {
  const NursingClinicalCaseScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<NursingClinicalCaseScreen> createState() =>
      _NursingClinicalCaseScreenState();
}

class _NursingClinicalCaseScreenState extends State<NursingClinicalCaseScreen> {
  static const ClinicalScenario _scenario = ClinicalScenarioCatalog.dyspneaWard;

  _CaseStep _step = _CaseStep.brief;
  final Set<String> _askedKeys = <String>{};
  String? _activeReply;
  final Set<ClinicalInstrument> _measured = <ClinicalInstrument>{};
  ClinicalInstrument? _lastInstrument;
  final Set<ClinicalInstrument> _flagged = <ClinicalInstrument>{};
  final Set<String> _chosenActions = <String>{};
  ClinicalEvaluation? _eval;
  bool _submitting = false;

  PatientProfile get _patient => _scenario.patient;

  static String _instrumentLabel(ClinicalInstrument i) {
    switch (i) {
      case ClinicalInstrument.stethoscope:
        return 'Stethoscope';
      case ClinicalInstrument.thermometer:
        return 'Thermometer';
      case ClinicalInstrument.bpCuff:
        return 'BP cuff';
      case ClinicalInstrument.pulseOx:
        return 'Pulse ox';
    }
  }

  static IconData _instrumentIcon(ClinicalInstrument i) {
    switch (i) {
      case ClinicalInstrument.stethoscope:
        return Icons.hearing_rounded;
      case ClinicalInstrument.thermometer:
        return Icons.thermostat_rounded;
      case ClinicalInstrument.bpCuff:
        return Icons.monitor_heart_rounded;
      case ClinicalInstrument.pulseOx:
        return Icons.favorite_rounded;
    }
  }

  static String _interviewPrompt(String key) {
    switch (key) {
      case 'onset':
        return 'When did symptoms start?';
      case 'severity':
        return 'How bad is the shortness of breath?';
      case 'sputum':
        return 'Any sputum with the cough?';
      case 'fever':
        return 'Have you had fever or chills?';
      default:
        return key;
    }
  }

  void _ask(String key) {
    final String? reply = _patient.dialogueHooks[key];
    setState(() {
      _askedKeys.add(key);
      _activeReply = reply ?? '…';
    });
  }

  void _useInstrument(ClinicalInstrument i) {
    setState(() {
      _measured.add(i);
      _lastInstrument = i;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final ClinicalEvaluation eval = ClinicalScenarioEngine.evaluate(
      scenario: _scenario,
      measured: _measured,
      flaggedAbnormal: _flagged,
      chosenActionIds: _chosenActions,
      askedKeys: _askedKeys,
    );
    await widget.progress.completeScenario(
      _scenario.id,
      score: eval.score,
      xpGain: eval.passed ? _scenario.xpReward : (_scenario.xpReward ~/ 2),
    );
    if (!mounted) return;
    setState(() {
      _eval = eval;
      _step = _CaseStep.debrief;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: _scenario.title,
        icon: Icons.local_hospital_rounded,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MedCosmic.pill(
              _scenario.difficulty,
              bg: MedCosmic.clinical.withValues(alpha: 0.2),
              fg: MedCosmic.clinical,
            ),
          ),
        ],
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _StepDots(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: KeyedSubtree(
                    key: ValueKey<_CaseStep>(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
              _NavBar(
                step: _step,
                canAdvanceInterview: _askedKeys.length >= 2,
                canAdvanceInstruments: _measured.length >= 3,
                canAdvanceFlags: _flagged.isNotEmpty,
                canSubmit: _chosenActions.isNotEmpty && !_submitting,
                submitting: _submitting,
                onBack: () {
                  setState(() {
                    switch (_step) {
                      case _CaseStep.interview:
                        _step = _CaseStep.brief;
                      case _CaseStep.instruments:
                        _step = _CaseStep.interview;
                      case _CaseStep.flagAbnormals:
                        _step = _CaseStep.instruments;
                      case _CaseStep.actions:
                        _step = _CaseStep.flagAbnormals;
                      default:
                        break;
                    }
                  });
                },
                onNext: () {
                  setState(() {
                    switch (_step) {
                      case _CaseStep.brief:
                        _step = _CaseStep.interview;
                      case _CaseStep.interview:
                        _step = _CaseStep.instruments;
                      case _CaseStep.instruments:
                        _step = _CaseStep.flagAbnormals;
                      case _CaseStep.flagAbnormals:
                        _step = _CaseStep.actions;
                      default:
                        break;
                    }
                  });
                },
                onSubmit: _submit,
                onDone: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _CaseStep.brief:
        return _BriefPane(scenario: _scenario, patient: _patient);
      case _CaseStep.interview:
        return _InterviewPane(
          keys: _scenario.interviewKeys,
          asked: _askedKeys,
          reply: _activeReply,
          promptFor: _interviewPrompt,
          onAsk: _ask,
        );
      case _CaseStep.instruments:
        return _InstrumentPane(
          findingFor: _scenario.findingFor,
          measured: _measured,
          last: _lastInstrument,
          labelFor: _instrumentLabel,
          iconFor: _instrumentIcon,
          onUse: _useInstrument,
        );
      case _CaseStep.flagAbnormals:
        return _FlagPane(
          measured: _measured,
          findings: _scenario.findings,
          flagged: _flagged,
          labelFor: _instrumentLabel,
          onToggle: (ClinicalInstrument i) {
            setState(() {
              if (_flagged.contains(i)) {
                _flagged.remove(i);
              } else {
                _flagged.add(i);
              }
            });
          },
        );
      case _CaseStep.actions:
        return _ActionsPane(
          actions: _scenario.actions,
          chosen: _chosenActions,
          onToggle: (String id) {
            setState(() {
              if (_chosenActions.contains(id)) {
                _chosenActions.remove(id);
              } else {
                _chosenActions.add(id);
              }
            });
          },
        );
      case _CaseStep.debrief:
        return _DebriefPane(
          scenario: _scenario,
          eval: _eval!,
          chosen: _chosenActions,
        );
    }
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step});

  final _CaseStep step;

  static const List<String> _labels = <String>[
    'Brief',
    'Interview',
    'Vitals',
    'Flags',
    'Care',
    'Debrief',
  ];

  @override
  Widget build(BuildContext context) {
    final int idx = step.index;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: List<Widget>.generate(_labels.length, (int i) {
          final bool active = i == idx;
          final bool done = i < idx;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: MedCosmic.pill(
              _labels[i],
              bg: active
                  ? MedCosmic.clinical.withValues(alpha: 0.28)
                  : done
                      ? MedCosmic.success.withValues(alpha: 0.18)
                      : MedCosmic.panelAlt,
              fg: active
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

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.step,
    required this.canAdvanceInterview,
    required this.canAdvanceInstruments,
    required this.canAdvanceFlags,
    required this.canSubmit,
    required this.submitting,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
    required this.onDone,
  });

  final _CaseStep step;
  final bool canAdvanceInterview;
  final bool canAdvanceInstruments;
  final bool canAdvanceFlags;
  final bool canSubmit;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (step == _CaseStep.debrief) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onDone,
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

    final bool showBack = step != _CaseStep.brief;
    final bool isSubmit = step == _CaseStep.actions;
    bool canNext = true;
    if (step == _CaseStep.interview) canNext = canAdvanceInterview;
    if (step == _CaseStep.instruments) canNext = canAdvanceInstruments;
    if (step == _CaseStep.flagAbnormals) canNext = canAdvanceFlags;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (showBack)
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (showBack) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: isSubmit
                  ? (canSubmit ? onSubmit : null)
                  : (canNext ? onNext : null),
              style: FilledButton.styleFrom(
                backgroundColor: MedCosmic.purple,
                foregroundColor: MedCosmic.ink,
                disabledBackgroundColor: MedCosmic.panelAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                submitting
                    ? 'Scoring…'
                    : isSubmit
                        ? 'Submit care plan'
                        : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BriefPane extends StatelessWidget {
  const _BriefPane({required this.scenario, required this.patient});

  final ClinicalScenario scenario;
  final PatientProfile patient;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: MedCosmic.panelBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: patient.skinTone,
                    child: Text(
                      patient.displayName[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          patient.displayName,
                          style: const TextStyle(
                            color: MedCosmic.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${patient.ageYears} · ${patient.sexLabel}',
                          style: const TextStyle(
                            color: MedCosmic.mute,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MedCosmic.pill('+${scenario.xpReward} XP'),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Chief complaint',
                style: TextStyle(
                  color: MedCosmic.mute,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                patient.chiefComplaint,
                style: const TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                patient.appearanceNotes,
                style: const TextStyle(color: MedCosmic.mute, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                patient.historySummary,
                style: const TextStyle(color: MedCosmic.mute, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  ...patient.allergies.map(
                    (String a) => MedCosmic.pill(
                      'Allergy: $a',
                      bg: MedCosmic.danger.withValues(alpha: 0.2),
                      fg: MedCosmic.danger,
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  ...patient.medications.map(
                    (String m) => MedCosmic.pill(m, bg: MedCosmic.panelAlt),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Learning objectives',
                style: TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...scenario.objectives.map(
                (String o) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: MedCosmic.teal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          o,
                          style: const TextStyle(
                            color: MedCosmic.mute,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InterviewPane extends StatelessWidget {
  const _InterviewPane({
    required this.keys,
    required this.asked,
    required this.reply,
    required this.promptFor,
    required this.onAsk,
  });

  final List<String> keys;
  final Set<String> asked;
  final String? reply;
  final String Function(String) promptFor;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text(
          'Focused history',
          style: TextStyle(
            color: MedCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ask at least 2 questions (${asked.length}/${keys.length}).',
          style: const TextStyle(color: MedCosmic.mute, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...keys.map((String key) {
          final bool done = asked.contains(key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAsk(key),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: MedCosmic.panelBox(
                    color: done ? MedCosmic.panelAlt : MedCosmic.panel,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        done
                            ? Icons.chat_bubble_rounded
                            : Icons.chat_bubble_outline_rounded,
                        color: done ? MedCosmic.teal : MedCosmic.clinical,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          promptFor(key),
                          style: const TextStyle(
                            color: MedCosmic.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (done)
                        const Icon(
                          Icons.check,
                          color: MedCosmic.success,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (reply != null) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MedCosmic.clinical.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: MedCosmic.clinical.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Patient',
                  style: TextStyle(
                    color: MedCosmic.clinical,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reply!,
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InstrumentPane extends StatelessWidget {
  const _InstrumentPane({
    required this.findingFor,
    required this.measured,
    required this.last,
    required this.labelFor,
    required this.iconFor,
    required this.onUse,
  });

  final InstrumentFinding? Function(ClinicalInstrument) findingFor;
  final Set<ClinicalInstrument> measured;
  final ClinicalInstrument? last;
  final String Function(ClinicalInstrument) labelFor;
  final IconData Function(ClinicalInstrument) iconFor;
  final ValueChanged<ClinicalInstrument> onUse;

  @override
  Widget build(BuildContext context) {
    final InstrumentFinding? lastFinding =
        last == null ? null : findingFor(last!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text(
          'Instrument tray',
          style: TextStyle(
            color: MedCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Use at least 3 instruments (${measured.length}/4).',
          style: const TextStyle(color: MedCosmic.mute, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ClinicalInstrument.values.map((ClinicalInstrument i) {
            final bool used = measured.contains(i);
            return SizedBox(
              width: (MediaQuery.sizeOf(context).width - 52) / 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onUse(i),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: used
                          ? MedCosmic.teal.withValues(alpha: 0.15)
                          : MedCosmic.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: used
                            ? MedCosmic.teal
                            : MedCosmic.stroke.withValues(alpha: 0.85),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          iconFor(i),
                          color: used ? MedCosmic.teal : MedCosmic.clinical,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labelFor(i),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: MedCosmic.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        if (used)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Measured',
                              style: TextStyle(
                                color: MedCosmic.teal,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (lastFinding != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: MedCosmic.panelBox(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      labelFor(lastFinding.instrument),
                      style: const TextStyle(
                        color: MedCosmic.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (lastFinding.abnormal)
                      MedCosmic.pill(
                        'Abnormal',
                        bg: MedCosmic.warning.withValues(alpha: 0.22),
                        fg: MedCosmic.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  lastFinding.summary,
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FlagPane extends StatelessWidget {
  const _FlagPane({
    required this.measured,
    required this.findings,
    required this.flagged,
    required this.labelFor,
    required this.onToggle,
  });

  final Set<ClinicalInstrument> measured;
  final List<InstrumentFinding> findings;
  final Set<ClinicalInstrument> flagged;
  final String Function(ClinicalInstrument) labelFor;
  final ValueChanged<ClinicalInstrument> onToggle;

  @override
  Widget build(BuildContext context) {
    final List<InstrumentFinding> visible = findings
        .where((InstrumentFinding f) => measured.contains(f.instrument))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text(
          'Flag abnormal findings',
          style: TextStyle(
            color: MedCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap findings that need clinical attention.',
          style: TextStyle(color: MedCosmic.mute, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: MedCosmic.panelBox(),
            child: const Text(
              'Go back and measure instruments first.',
              style: TextStyle(color: MedCosmic.mute),
            ),
          )
        else
          ...visible.map((InstrumentFinding f) {
            final bool on = flagged.contains(f.instrument);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onToggle(f.instrument),
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: on
                          ? MedCosmic.warning.withValues(alpha: 0.12)
                          : MedCosmic.panel,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: on ? MedCosmic.warning : MedCosmic.stroke,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          on
                              ? Icons.flag_rounded
                              : Icons.outlined_flag_rounded,
                          color: on ? MedCosmic.warning : MedCosmic.mute,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                labelFor(f.instrument),
                                style: const TextStyle(
                                  color: MedCosmic.mute,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                f.summary,
                                style: const TextStyle(
                                  color: MedCosmic.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: on,
                          activeColor: MedCosmic.warning,
                          onChanged: (_) => onToggle(f.instrument),
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
  }
}

class _ActionsPane extends StatelessWidget {
  const _ActionsPane({
    required this.actions,
    required this.chosen,
    required this.onToggle,
  });

  final List<ClinicalAction> actions;
  final Set<String> chosen;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text(
          'Choose care actions',
          style: TextStyle(
            color: MedCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select all safe first actions (multi-select).',
          style: TextStyle(color: MedCosmic.mute, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...actions.map((ClinicalAction a) {
          final bool on = chosen.contains(a.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onToggle(a.id),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Checkbox(
                        value: on,
                        activeColor: MedCosmic.purple,
                        onChanged: (_) => onToggle(a.id),
                      ),
                      Expanded(
                        child: Text(
                          a.label,
                          style: const TextStyle(
                            color: MedCosmic.ink,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
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
  }
}

class _DebriefPane extends StatelessWidget {
  const _DebriefPane({
    required this.scenario,
    required this.eval,
    required this.chosen,
  });

  final ClinicalScenario scenario;
  final ClinicalEvaluation eval;
  final Set<String> chosen;

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = eval.criticalFail
        ? MedCosmic.danger
        : eval.passed
            ? MedCosmic.success
            : MedCosmic.warning;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: MedCosmic.panelBox(),
          child: Column(
            children: <Widget>[
              Text(
                eval.criticalFail
                    ? 'Critical safety fail'
                    : eval.passed
                        ? 'Case cleared'
                        : 'Needs review',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${eval.score} / ${eval.maxScore}',
                style: const TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Score notes',
                style: TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...eval.notes.map(
                (String n) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $n',
                    style: const TextStyle(
                      color: MedCosmic.mute,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: MedCosmic.panelBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Action feedback',
                style: TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...scenario.actions
                  .where((ClinicalAction a) => chosen.contains(a.id))
                  .map(
                    (ClinicalAction a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            a.safe
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 18,
                            color:
                                a.safe ? MedCosmic.success : MedCosmic.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.feedback,
                              style: const TextStyle(
                                color: MedCosmic.mute,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MedCosmic.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: MedCosmic.teal.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            scenario.debrief,
            style: const TextStyle(
              color: MedCosmic.ink,
              height: 1.45,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
