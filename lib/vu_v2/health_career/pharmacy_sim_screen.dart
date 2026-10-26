import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';

enum _RxStep {
  review,
  dosing,
  interaction,
  allergy,
  counsel,
  decision,
  done,
}

/// Teaching pharmacy dispense simulation with deterministic scoring.
class PharmacySimScreen extends StatefulWidget {
  const PharmacySimScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<PharmacySimScreen> createState() => _PharmacySimScreenState();
}

class _PharmacySimScreenState extends State<PharmacySimScreen> {
  static const String _scenarioId = 'pharmacy_dispense_v1';

  // Fictional Rx: amoxicillin suspension for child; weight-based dosing.
  // Weight 20 kg · 40 mg/kg/day ÷ BID = 400 mg/dose · 250 mg/5 mL → 8 mL BID
  static const int _weightKg = 20;
  static const int _mgPerKgDay = 40;
  static const int _dosesPerDay = 2;
  static const int _concMgPer5ml = 250;
  static const double _correctMl = 8.0; // 400 mg / (250/5) = 8 mL

  static const List<_Choice> _doseOptions = <_Choice>[
    _Choice(id: '4', label: '4 mL BID'),
    _Choice(id: '8', label: '8 mL BID (correct)'),
    _Choice(id: '10', label: '10 mL BID'),
    _Choice(id: '16', label: '16 mL BID'),
  ];

  static const List<_Choice> _interactions = <_Choice>[
    _Choice(id: 'none', label: 'No clinically relevant interaction flagged'),
    _Choice(
      id: 'warfarin_amox',
      label: 'Amoxicillin + warfarin: monitor INR (moderate)',
    ),
    _Choice(
      id: 'methotrexate',
      label: 'Amoxicillin + methotrexate: dangerous — hold / call (trap OK)',
    ),
    _Choice(
      id: 'ssri_fatal',
      label: 'Amoxicillin + sertraline: fatal serotonin syndrome (false trap)',
    ),
  ];

  // Patient allergy: penicillin rash — amoxicillin is contraindicated.
  static const List<_Choice> _allergyGates = <_Choice>[
    _Choice(id: 'ok', label: 'Allergy cleared — dispense as written'),
    _Choice(
      id: 'contraindicated',
      label: 'Penicillin allergy — do NOT dispense amoxicillin',
    ),
    _Choice(id: 'ignore', label: 'Allergy listed but likely irrelevant'),
  ];

  static const List<_Choice> _counsel = <_Choice>[
    _Choice(id: 'finish', label: 'Finish full course even if feeling better'),
    _Choice(id: 'shake', label: 'Shake suspension well before each dose'),
    _Choice(id: 'fridge', label: 'Refrigerate; discard after labeled days'),
    _Choice(id: 'alcohol', label: 'Take with grapefruit juice for absorption'),
    _Choice(id: 'double', label: 'Double next dose if one is missed'),
  ];

  static const Set<String> _goodCounsel = <String>{
    'finish',
    'shake',
    'fridge',
  };

  _RxStep _step = _RxStep.review;
  String? _dosePick;
  String? _interactionPick;
  String? _allergyPick;
  final Set<String> _counselPicks = <String>{};
  bool? _dispense; // true dispense, false refuse
  String? _refuseReason;
  int? _score;
  List<String> _feedback = <String>[];
  bool _submitting = false;

  Future<void> _finalize() async {
    if (_submitting || _dispense == null) return;
    if (_dispense == false &&
        (_refuseReason == null || _refuseReason!.trim().length < 8)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a short refuse reason.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final List<String> fb = <String>[];
    int score = 10;
    bool critical = false;

    // Dosing
    if (_dosePick == '8') {
      score += 20;
      fb.add(
        'Dose math correct: $_weightKg kg × $_mgPerKgDay mg/kg/day '
        '÷ $_dosesPerDay = 400 mg → ${_correctMl.toStringAsFixed(0)} mL of '
        '$_concMgPer5ml mg/5 mL.',
      );
    } else {
      score -= 5;
      fb.add('Dose should be 8 mL BID for this educational Rx.');
    }

    // Interaction — dangerous false claim is wrong; methotrexate note is acceptable teaching;
    // best answer with this fictional med list (omeprazole only on profile? we'll use case meds)
    // Case meds listed on review: omeprazole + sertraline (fictional). No MTX.
    // Correct: none OR warfarin if present — patient has sertraline → ssri_fatal is WRONG trap.
    if (_interactionPick == 'none') {
      score += 12;
      fb.add('No high-risk interaction with listed meds.');
    } else if (_interactionPick == 'ssri_fatal') {
      score -= 12;
      fb.add('False: amoxicillin does not cause fatal serotonin syndrome with sertraline.');
    } else if (_interactionPick == 'methotrexate') {
      score -= 5;
      fb.add('Methotrexate not on this patient\'s list — do not invent.');
    } else if (_interactionPick == 'warfarin_amox') {
      score -= 3;
      fb.add('Warfarin not prescribed here.');
    }

    // Allergy gate — CRITICAL
    if (_allergyPick == 'contraindicated') {
      score += 25;
      fb.add('Correct: penicillin-class allergy blocks amoxicillin.');
    } else {
      critical = true;
      score = 20;
      fb.add('CRITICAL: patient has penicillin rash allergy — amoxicillin contraindicated.');
    }

    // Counseling
    final int good =
        _counselPicks.intersection(_goodCounsel).length;
    final int bad = _counselPicks.difference(_goodCounsel).length;
    score += good * 6;
    score -= bad * 8;
    fb.add('Counseling: $good/3 key points'
        '${bad > 0 ? ", $bad unsafe tip(s)" : ""}.');

    // Dispense decision
    if (_allergyPick == 'contraindicated' && _dispense == false) {
      score += 15;
      fb.add('Correctly refused dispense due to allergy.');
      if ((_refuseReason ?? '').toLowerCase().contains('allerg') ||
          (_refuseReason ?? '').toLowerCase().contains('penicillin')) {
        score += 5;
        fb.add('Refuse reason cites allergy.');
      }
    } else if (_dispense == true) {
      critical = true;
      score = score.clamp(0, 30);
      fb.add('CRITICAL: dispensing despite penicillin allergy is unsafe.');
    } else {
      score -= 8;
      fb.add('Refusal reasoning incomplete relative to allergy gate.');
    }

    if (critical) score = score.clamp(0, 35);
    score = score.clamp(0, 100);

    await widget.progress.completeScenario(
      _scenarioId,
      score: score,
      xpGain: critical ? 45 : (90 + (score ~/ 4)),
    );
    await widget.progress.completeSkill('pharmacy_dispense_flow', xpGain: 25);

    if (!mounted) return;
    setState(() {
      _score = score;
      _feedback = fb;
      _step = _RxStep.done;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Pharmacy Dispense',
        icon: Icons.local_pharmacy_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _RxDots(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<_RxStep>(_step),
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
      case _RxStep.review:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: MedCosmic.panelBox(),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Rx #EDU-2041 (fictional)',
                    style: TextStyle(
                      color: MedCosmic.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patient: Noah Patel, 7 years · 20 kg',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Amoxicillin suspension 250 mg/5 mL\n'
                    'Sig: 40 mg/kg/day divided BID × 7 days\n'
                    'Qty: 140 mL\n\n'
                    'Allergies: Penicillin (rash)\n'
                    'Current meds: Cetirizine 5 mg daily; sertraline — none '
                    '(parent takes sertraline — not the child)\n'
                    'Indication: otitis media (educational)',
                    style: TextStyle(
                      color: MedCosmic.mute,
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case _RxStep.dosing:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Calculate the dose volume',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '20 kg × 40 mg/kg/day ÷ 2 doses → mg per dose → mL of 250 mg/5 mL.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._doseOptions.map((_Choice c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RadioTile(
                  selected: _dosePick == c.id,
                  title: c.label,
                  onTap: () => setState(() => _dosePick = c.id),
                ),
              );
            }),
          ],
        );
      case _RxStep.interaction:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Drug interaction check',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Based only on this patient\'s listed medicines.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._interactions.map((_Choice c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RadioTile(
                  selected: _interactionPick == c.id,
                  title: c.label,
                  danger: c.id == 'ssri_fatal',
                  onTap: () => setState(() => _interactionPick = c.id),
                ),
              );
            }),
          ],
        );
      case _RxStep.allergy:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Allergy contraindication gate',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: MedCosmic.panelBox(
                color: MedCosmic.danger.withValues(alpha: 0.12),
              ),
              child: const Text(
                'Profile lists: Penicillin (rash). Amoxicillin is penicillin-class.',
                style: TextStyle(color: MedCosmic.danger, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            ..._allergyGates.map((_Choice c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RadioTile(
                  selected: _allergyPick == c.id,
                  title: c.label,
                  danger: c.id == 'ok' || c.id == 'ignore',
                  onTap: () => setState(() => _allergyPick = c.id),
                ),
              );
            }),
          ],
        );
      case _RxStep.counsel:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Select counseling points',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Multi-select safe teaching points (avoid unsafe tips).',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._counsel.map((_Choice c) {
              final bool on = _counselPicks.contains(c.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CheckTile(
                  selected: on,
                  title: c.label,
                  onTap: () {
                    setState(() {
                      if (on) {
                        _counselPicks.remove(c.id);
                      } else {
                        _counselPicks.add(c.id);
                      }
                    });
                  },
                ),
              );
            }),
          ],
        );
      case _RxStep.decision:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Dispense or refuse?',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _BigChoice(
                    label: 'Dispense',
                    selected: _dispense == true,
                    color: MedCosmic.warning,
                    onTap: () => setState(() => _dispense = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BigChoice(
                    label: 'Refuse',
                    selected: _dispense == false,
                    color: MedCosmic.success,
                    onTap: () => setState(() => _dispense = false),
                  ),
                ),
              ],
            ),
            if (_dispense == false) ...<Widget>[
              const SizedBox(height: 14),
              TextField(
                onChanged: (String v) => _refuseReason = v,
                maxLines: 3,
                style: const TextStyle(color: MedCosmic.ink),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MedCosmic.panel,
                  hintText: 'Reason for refusal…',
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
          ],
        );
      case _RxStep.done:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.medication_rounded,
                    color: MedCosmic.warning,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pharmacy simulation complete',
                    style: TextStyle(
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
    if (_step == _RxStep.done) {
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
      _RxStep.review => true,
      _RxStep.dosing => _dosePick != null,
      _RxStep.interaction => _interactionPick != null,
      _RxStep.allergy => _allergyPick != null,
      _RxStep.counsel => _counselPicks.length >= 2,
      _RxStep.decision => _dispense != null && !_submitting,
      _RxStep.done => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_step != _RxStep.review)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _step = _RxStep.values[_step.index - 1];
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (_step != _RxStep.review) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext
                  ? null
                  : () {
                      if (_step == _RxStep.decision) {
                        _finalize();
                        return;
                      }
                      setState(() {
                        _step = _RxStep.values[_step.index + 1];
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
                    ? 'Saving…'
                    : _step == _RxStep.decision
                        ? 'Submit decision'
                        : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice {
  const _Choice({required this.id, required this.label});

  final String id;
  final String label;
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.selected,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color accent = danger && selected ? MedCosmic.danger : MedCosmic.purple;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.16) : MedCosmic.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? accent : MedCosmic.stroke),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? accent : MedCosmic.mute,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.3,
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

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? MedCosmic.teal.withValues(alpha: 0.16)
                : MedCosmic.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? MedCosmic.teal : MedCosmic.stroke,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: selected ? MedCosmic.teal : MedCosmic.mute,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
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
    );
  }
}

class _BigChoice extends StatelessWidget {
  const _BigChoice({
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : MedCosmic.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : MedCosmic.stroke),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : MedCosmic.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _RxDots extends StatelessWidget {
  const _RxDots({required this.step});

  final _RxStep step;

  static const List<String> _labels = <String>[
    'Rx',
    'Dose',
    'Interact',
    'Allergy',
    'Counsel',
    'Decide',
    'Score',
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
