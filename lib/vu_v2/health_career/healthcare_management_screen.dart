import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';

enum _HmStep { brief, decide, report, done }

class _Decision {
  const _Decision({
    required this.id,
    required this.label,
    required this.blurb,
    required this.deltaBeds,
    required this.deltaEdWaitMin,
    required this.deltaNurses,
    required this.deltaBudget,
    required this.deltaQuality,
    required this.narrative,
  });

  final String id;
  final String label;
  final String blurb;
  final int deltaBeds;
  final int deltaEdWaitMin;
  final int deltaNurses;
  final int deltaBudget;
  final int deltaQuality;
  final String narrative;
}

/// Hospital operations day — deterministic staffing / flow / quality sim.
class HealthcareManagementScreen extends StatefulWidget {
  const HealthcareManagementScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<HealthcareManagementScreen> createState() =>
      _HealthcareManagementScreenState();
}

class _HealthcareManagementScreenState
    extends State<HealthcareManagementScreen> {
  static const String _scenarioId = 'hm_ops_v1';

  static const int _startBeds = 18; // available med-surg
  static const int _startEdWait = 95; // minutes
  static const int _startNurses = 14;
  static const int _startBudget = 100; // units remaining
  static const int _startQuality = 72;

  static const List<_Decision> _catalog = <_Decision>[
    _Decision(
      id: 'float_nurse',
      label: 'Hire float nurse (shift)',
      blurb: '+1 nurse · −\$18 · ED wait −12 · quality +3',
      deltaBeds: 0,
      deltaEdWaitMin: -12,
      deltaNurses: 1,
      deltaBudget: -18,
      deltaQuality: 3,
      narrative:
          'Float coverage reduces boarding pressure and supports safer ratios.',
    ),
    _Decision(
      id: 'divert_elective',
      label: 'Divert elective admissions',
      blurb: '+4 beds · ED wait −8 · quality −2 · budget +5',
      deltaBeds: 4,
      deltaEdWaitMin: -8,
      deltaNurses: 0,
      deltaBudget: 5,
      deltaQuality: -2,
      narrative:
          'Elective diversion frees beds for ED admits but may frustrate electives.',
    ),
    _Decision(
      id: 'expand_ed',
      label: 'Expand ED capacity (fast track)',
      blurb: 'ED wait −22 · −\$25 · quality +4 · nurses −1 (redeploy)',
      deltaBeds: 0,
      deltaEdWaitMin: -22,
      deltaNurses: -1,
      deltaBudget: -25,
      deltaQuality: 4,
      narrative:
          'Fast-track opens flow for low-acuity; pulls one nurse from floor.',
    ),
    _Decision(
      id: 'cut_ot',
      label: 'Cut overtime',
      blurb: 'Budget +20 · nurses −2 · ED wait +15 · quality −6',
      deltaBeds: 0,
      deltaEdWaitMin: 15,
      deltaNurses: -2,
      deltaBudget: 20,
      deltaQuality: -6,
      narrative:
          'OT cut saves money short-term but worsens waits and fatigue risk.',
    ),
    _Decision(
      id: 'discharge_plan',
      label: 'Invest in discharge planning',
      blurb: '+3 beds · ED wait −10 · −\$15 · quality +5',
      deltaBeds: 3,
      deltaEdWaitMin: -10,
      deltaNurses: 0,
      deltaBudget: -15,
      deltaQuality: 5,
      narrative:
          'Earlier discharge planning frees beds and improves care transitions.',
    ),
  ];

  _HmStep _step = _HmStep.brief;
  final Set<String> _chosen = <String>{};
  int? _score;
  List<String> _narratives = <String>[];
  _DayState? _end;
  bool _submitting = false;

  _DayState get _projected {
    int beds = _startBeds;
    int ed = _startEdWait;
    int nurses = _startNurses;
    int budget = _startBudget;
    int quality = _startQuality;
    for (final String id in _chosen) {
      final _Decision d = _catalog.firstWhere((_Decision x) => x.id == id);
      beds += d.deltaBeds;
      ed += d.deltaEdWaitMin;
      nurses += d.deltaNurses;
      budget += d.deltaBudget;
      quality += d.deltaQuality;
    }
    return _DayState(
      beds: beds.clamp(0, 40),
      edWait: ed.clamp(20, 180),
      nurses: nurses.clamp(0, 30),
      budget: budget.clamp(-20, 150),
      quality: quality.clamp(40, 100),
    );
  }

  Future<void> _closeDay() async {
    if (_submitting || _chosen.isEmpty) return;
    setState(() => _submitting = true);
    final _DayState end = _projected;
    final List<String> narr = _catalog
        .where((_Decision d) => _chosen.contains(d.id))
        .map((_Decision d) => d.narrative)
        .toList();

    int score = 25;
    if (end.edWait <= 70) {
      score += 20;
    } else if (end.edWait <= 85) {
      score += 12;
    } else if (end.edWait >= 110) {
      score -= 10;
    }
    if (end.beds >= 22) {
      score += 12;
    } else if (end.beds >= 20) {
      score += 6;
    }
    if (end.nurses >= 14) {
      score += 12;
    } else if (end.nurses < 12) {
      score -= 12;
    }
    if (end.quality >= 78) {
      score += 15;
    } else if (end.quality >= 72) {
      score += 8;
    } else if (end.quality < 68) {
      score -= 8;
    }
    if (end.budget >= 0) {
      score += 8;
    } else {
      score -= 10;
    }
    // Synergy: float + discharge without cut OT
    if (_chosen.contains('float_nurse') &&
        _chosen.contains('discharge_plan') &&
        !_chosen.contains('cut_ot')) {
      score += 8;
    }
    // Trap: cut OT + expand ED without float
    if (_chosen.contains('cut_ot') &&
        _chosen.contains('expand_ed') &&
        !_chosen.contains('float_nurse')) {
      score -= 8;
    }
    score = score.clamp(0, 100);

    await widget.progress.completeScenario(
      _scenarioId,
      score: score,
      xpGain: 85 + (score ~/ 4),
    );
    await widget.progress.completeSkill('hm_ops_day', xpGain: 25);

    if (!mounted) return;
    setState(() {
      _end = end;
      _score = score;
      _narratives = narr;
      _step = _HmStep.report;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Hospital Command',
        icon: Icons.apartment_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _HmDots(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<_HmStep>(_step),
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
      case _HmStep.brief:
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
                    'Northvale Teaching Hospital — Day shift',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ED is boarding. Choose 2–3 operational levers. '
                    'Each applies deterministic deltas. Educational only.',
                    style: TextStyle(
                      color: MedCosmic.mute,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _MetricsCard(
              state: const _DayState(
                beds: _startBeds,
                edWait: _startEdWait,
                nurses: _startNurses,
                budget: _startBudget,
                quality: _startQuality,
              ),
              title: '07:00 baseline',
            ),
          ],
        );
      case _HmStep.decide:
        final _DayState proj = _projected;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            _MetricsCard(state: proj, title: 'Projected end-of-day'),
            const SizedBox(height: 12),
            Text(
              'Select 2–3 decisions (${_chosen.length} selected)',
              style: const TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            ..._catalog.map((_Decision d) {
              final bool on = _chosen.contains(d.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (on) {
                          _chosen.remove(d.id);
                        } else if (_chosen.length < 3) {
                          _chosen.add(d.id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: on
                            ? MedCosmic.gold.withValues(alpha: 0.16)
                            : MedCosmic.panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: on ? MedCosmic.gold : MedCosmic.stroke,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                on
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: on ? MedCosmic.gold : MedCosmic.mute,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d.label,
                                  style: const TextStyle(
                                    color: MedCosmic.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            d.blurb,
                            style: const TextStyle(
                              color: MedCosmic.mute,
                              fontSize: 12,
                              height: 1.35,
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
      case _HmStep.report:
        final _DayState end = _end!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.assessment_rounded,
                    color: MedCosmic.gold,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'End-of-day report',
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
            _MetricsCard(state: end, title: '19:00 metrics'),
            const SizedBox(height: 12),
            const Text(
              'Decision narratives',
              style: TextStyle(
                color: MedCosmic.mute,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ..._narratives.map(
              (String n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                  child: Text(
                    n,
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
      case _HmStep.done:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: const Text(
                'Operations day closed. XP saved to Health Career progress.',
                textAlign: TextAlign.center,
                style: TextStyle(color: MedCosmic.mute, height: 1.4),
              ),
            ),
          ],
        );
    }
  }

  Widget _footer() {
    if (_step == _HmStep.done) {
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

    if (_step == _HmStep.report) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _step = _HmStep.done),
            style: FilledButton.styleFrom(
              backgroundColor: MedCosmic.purple,
              foregroundColor: MedCosmic.ink,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Finish'),
          ),
        ),
      );
    }

    final bool canNext = switch (_step) {
      _HmStep.brief => true,
      _HmStep.decide =>
        _chosen.length >= 2 && _chosen.length <= 3 && !_submitting,
      _HmStep.report => true,
      _HmStep.done => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_step == _HmStep.decide)
            OutlinedButton(
              onPressed: () => setState(() => _step = _HmStep.brief),
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (_step == _HmStep.decide) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext
                  ? null
                  : () {
                      if (_step == _HmStep.decide) {
                        _closeDay();
                        return;
                      }
                      setState(() => _step = _HmStep.decide);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: MedCosmic.purple,
                foregroundColor: MedCosmic.ink,
                disabledBackgroundColor: MedCosmic.panelAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _submitting
                    ? 'Closing day…'
                    : _step == _HmStep.decide
                        ? 'Generate end-of-day report'
                        : 'Choose decisions',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayState {
  const _DayState({
    required this.beds,
    required this.edWait,
    required this.nurses,
    required this.budget,
    required this.quality,
  });

  final int beds;
  final int edWait;
  final int nurses;
  final int budget;
  final int quality;
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.state, required this.title});

  final _DayState state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<({String k, String v, Color c})> rows =
        <({String k, String v, Color c})>[
      (k: 'Open beds', v: '${state.beds}', c: MedCosmic.clinical),
      (k: 'ED wait', v: '${state.edWait} min', c: MedCosmic.warning),
      (k: 'Nurses on shift', v: '${state.nurses}', c: MedCosmic.teal),
      (k: 'Budget units', v: '${state.budget}', c: MedCosmic.gold),
      (k: 'Quality score', v: '${state.quality}', c: MedCosmic.success),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MedCosmic.panelBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: MedCosmic.mute,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map(
            (({String k, String v, Color c}) e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      e.k,
                      style: const TextStyle(color: MedCosmic.mute, fontSize: 13),
                    ),
                  ),
                  Text(
                    e.v,
                    style: TextStyle(
                      color: e.c,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HmDots extends StatelessWidget {
  const _HmDots({required this.step});

  final _HmStep step;

  static const List<String> _labels = <String>[
    'Brief',
    'Decide',
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
