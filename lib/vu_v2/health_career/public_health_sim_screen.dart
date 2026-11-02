import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';

enum _PhStep { brief, allocate, review, outcome, done }

/// Deterministic outbreak response simulation for a fictional district.
class PublicHealthSimScreen extends StatefulWidget {
  const PublicHealthSimScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<PublicHealthSimScreen> createState() => _PublicHealthSimScreenState();
}

class _PublicHealthSimScreenState extends State<PublicHealthSimScreen> {
  static const String _scenarioId = 'ph_outbreak_v1';
  static const int _budget = 100;

  static const _Baseline _start = _Baseline(
    cases: 420,
    r: 1.45,
    vaccineCoverage: 52,
    sanitation: 48,
  );

  int _vax = 25;
  int _sanitation = 25;
  int _messaging = 25;
  int _isolation = 25;

  _PhStep _step = _PhStep.brief;
  _Outcome? _outcome;
  bool _submitting = false;

  int get _spent => _vax + _sanitation + _messaging + _isolation;
  int get _remaining => _budget - _spent;

  _Outcome _simulate() {
    // Deterministic engine (educational rules, not epidemiology research):
    // - Each $10 vaccination: +2.2 coverage pts, −0.04 R, −8 cases
    // - Each $10 sanitation: +2.5 sanitation pts, −0.03 R, −6 cases
    // - Each $10 messaging: −0.025 R, −4 cases (diminishing if coverage < 40)
    // - Each $10 isolation: −0.05 R, −10 cases; +1 coverage if paired with messaging ≥20
    // Balance bonus if no bucket < 10 and none > 50.
    double r = _start.r;
    double coverage = _start.vaccineCoverage.toDouble();
    double sanitation = _start.sanitation.toDouble();
    double cases = _start.cases.toDouble();
    final List<String> rules = <String>[];

    final double vaxUnits = _vax / 10.0;
    coverage += vaxUnits * 2.2;
    r -= vaxUnits * 0.04;
    cases -= vaxUnits * 8;
    rules.add(
      'Vaccination \$$_vax → coverage +${(vaxUnits * 2.2).toStringAsFixed(1)} pts, '
      'R −${(vaxUnits * 0.04).toStringAsFixed(2)}, cases −${(vaxUnits * 8).round()}.',
    );

    final double sanUnits = _sanitation / 10.0;
    sanitation += sanUnits * 2.5;
    r -= sanUnits * 0.03;
    cases -= sanUnits * 6;
    rules.add(
      'Sanitation \$$_sanitation → sanitation +${(sanUnits * 2.5).toStringAsFixed(1)} pts, '
      'R −${(sanUnits * 0.03).toStringAsFixed(2)}, cases −${(sanUnits * 6).round()}.',
    );

    final double msgUnits = _messaging / 10.0;
    final double msgCaseFactor = coverage < 40 ? 2.5 : 4.0;
    r -= msgUnits * 0.025;
    cases -= msgUnits * msgCaseFactor;
    rules.add(
      'Messaging \$$_messaging → R −${(msgUnits * 0.025).toStringAsFixed(2)}, '
      'cases −${(msgUnits * msgCaseFactor).round()}'
      '${coverage < 40 ? " (reduced impact while coverage low)" : ""}.',
    );

    final double isoUnits = _isolation / 10.0;
    r -= isoUnits * 0.05;
    cases -= isoUnits * 10;
    if (_isolation >= 20 && _messaging >= 20) {
      coverage += 1;
      rules.add(
        'Isolation \$$_isolation → R −${(isoUnits * 0.05).toStringAsFixed(2)}, '
        'cases −${(isoUnits * 10).round()}; +1 coverage (messaging synergy).',
      );
    } else {
      rules.add(
        'Isolation \$$_isolation → R −${(isoUnits * 0.05).toStringAsFixed(2)}, '
        'cases −${(isoUnits * 10).round()}.',
      );
    }

    bool balanced = true;
    for (final int b in <int>[_vax, _sanitation, _messaging, _isolation]) {
      if (b < 10 || b > 50) balanced = false;
    }
    if (balanced) {
      r -= 0.05;
      cases -= 15;
      rules.add('Balance bonus: no bucket <\$10 or >\$50 → R −0.05, cases −15.');
    } else {
      rules.add('No balance bonus (keep each bucket between \$10–\$50 for bonus).');
    }

    if (_remaining != 0) {
      cases += (_remaining.abs() * 0.4);
      rules.add(
        _remaining > 0
            ? 'Unspent \$$_remaining left impact on table (+${(_remaining * 0.4).round()} residual cases).'
            : 'Overspend invalid — capped at budget in UI.',
      );
    }

    coverage = coverage.clamp(0, 100);
    sanitation = sanitation.clamp(0, 100);
    r = r.clamp(0.4, 3.0);
    cases = cases.clamp(40, 800);

    // Score: lower R & cases, higher coverage/sanitation.
    int score = 30;
    if (r < 1.0) {
      score += 25;
    } else if (r < 1.15) {
      score += 18;
    } else if (r < 1.3) {
      score += 10;
    }
    if (cases < 280) {
      score += 20;
    } else if (cases < 320) {
      score += 12;
    } else if (cases < 360) {
      score += 6;
    }
    if (coverage >= 70) {
      score += 12;
    } else if (coverage >= 62) {
      score += 7;
    }
    if (sanitation >= 65) {
      score += 8;
    } else if (sanitation >= 58) {
      score += 4;
    }
    if (balanced && _remaining == 0) score += 5;
    score = score.clamp(0, 100);

    String narrative;
    if (r < 1.0 && cases < 300) {
      narrative =
          'Outbreak trajectory bends down. Transmission likely falls below replacement.';
    } else if (r < 1.2) {
      narrative =
          'Partial control: R trending toward containment; keep reinforcing weak buckets.';
    } else {
      narrative =
          'Transmission remains elevated. Rebalance toward vaccination + isolation support.';
    }

    return _Outcome(
      cases: cases.round(),
      r: double.parse(r.toStringAsFixed(2)),
      vaccineCoverage: coverage.round(),
      sanitation: sanitation.round(),
      score: score,
      rules: rules,
      narrative: narrative,
    );
  }

  Future<void> _submit() async {
    if (_submitting || _remaining != 0) return;
    setState(() => _submitting = true);
    final _Outcome out = _simulate();
    await widget.progress.completeScenario(
      _scenarioId,
      score: out.score,
      xpGain: 85 + (out.score ~/ 4),
    );
    await widget.progress.completeSkill('ph_outbreak_alloc', xpGain: 25);
    if (!mounted) return;
    setState(() {
      _outcome = out;
      _step = _PhStep.outcome;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Public Health Outbreak',
        icon: Icons.public_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _PhDots(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<_PhStep>(_step),
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
      case _PhStep.brief:
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
                    'Riverbend District — fictional outbreak',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You have a fixed educational budget of \$100 units. '
                    'Allocate across vaccination, sanitation, public messaging, '
                    'and isolation support. Outcomes use a transparent deterministic engine.',
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
            _MetricGrid(baseline: _start, title: 'Baseline week 0'),
          ],
        );
      case _PhStep.allocate:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
              child: Row(
                children: <Widget>[
                  MedCosmic.pill(
                    'Spent \$$_spent / $_budget',
                    bg: MedCosmic.purple.withValues(alpha: 0.22),
                    fg: MedCosmic.electric,
                  ),
                  const SizedBox(width: 8),
                  MedCosmic.pill(
                    _remaining == 0
                        ? 'Budget exact'
                        : 'Left \$$_remaining',
                    bg: _remaining == 0
                        ? MedCosmic.success.withValues(alpha: 0.2)
                        : MedCosmic.warning.withValues(alpha: 0.2),
                    fg: _remaining == 0 ? MedCosmic.success : MedCosmic.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _BudgetSlider(
              label: 'Vaccination campaigns',
              value: _vax,
              color: MedCosmic.clinical,
              onChanged: (int v) => setState(() => _vax = v),
              maxAffordable: _vax + _remaining,
            ),
            _BudgetSlider(
              label: 'Sanitation & water',
              value: _sanitation,
              color: MedCosmic.teal,
              onChanged: (int v) => setState(() => _sanitation = v),
              maxAffordable: _sanitation + _remaining,
            ),
            _BudgetSlider(
              label: 'Risk messaging',
              value: _messaging,
              color: MedCosmic.gold,
              onChanged: (int v) => setState(() => _messaging = v),
              maxAffordable: _messaging + _remaining,
            ),
            _BudgetSlider(
              label: 'Isolation support',
              value: _isolation,
              color: MedCosmic.warning,
              onChanged: (int v) => setState(() => _isolation = v),
              maxAffordable: _isolation + _remaining,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: \$10–\$50 per bucket unlocks a balance bonus.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 12),
            ),
          ],
        );
      case _PhStep.review:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Present your plan',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 10),
            _PlanRow(label: 'Vaccination', amount: _vax),
            _PlanRow(label: 'Sanitation', amount: _sanitation),
            _PlanRow(label: 'Messaging', amount: _messaging),
            _PlanRow(label: 'Isolation support', amount: _isolation),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: MedCosmic.panelBox(),
              child: Text(
                _remaining == 0
                    ? 'Budget fully allocated. Run the deterministic engine to see week-4 metrics.'
                    : 'Allocate every dollar before running the outcome engine.',
                style: const TextStyle(
                  color: MedCosmic.mute,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      case _PhStep.outcome:
        final _Outcome o = _outcome!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            _MetricGrid(
              baseline: _Baseline(
                cases: o.cases,
                r: o.r,
                vaccineCoverage: o.vaccineCoverage,
                sanitation: o.sanitation,
              ),
              title: 'Week-4 projected metrics',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: MedCosmic.panelBox(),
              child: Text(
                o.narrative,
                style: const TextStyle(
                  color: MedCosmic.ink,
                  height: 1.4,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Engine rules applied',
              style: TextStyle(
                color: MedCosmic.mute,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ...o.rules.map(
              (String r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                  child: Text(
                    r,
                    style: const TextStyle(
                      color: MedCosmic.mute,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case _PhStep.done:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.health_and_safety_rounded,
                    color: MedCosmic.teal,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Outbreak plan scored',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score ${_outcome?.score ?? 0}/100 · $_scenarioId',
                    style: const TextStyle(color: MedCosmic.mute),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _footer() {
    if (_step == _PhStep.done) {
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
      _PhStep.brief => true,
      _PhStep.allocate => _remaining == 0,
      _PhStep.review => _remaining == 0 && !_submitting,
      _PhStep.outcome => true,
      _PhStep.done => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_step != _PhStep.brief && _step != _PhStep.outcome)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _step = _PhStep.values[_step.index - 1];
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (_step != _PhStep.brief && _step != _PhStep.outcome)
            const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext
                  ? null
                  : () {
                      if (_step == _PhStep.review) {
                        _submit();
                        return;
                      }
                      if (_step == _PhStep.outcome) {
                        setState(() => _step = _PhStep.done);
                        return;
                      }
                      setState(() {
                        _step = _PhStep.values[_step.index + 1];
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
                    ? 'Running…'
                    : _step == _PhStep.review
                        ? 'Run outcome engine'
                        : _step == _PhStep.outcome
                            ? 'See final score'
                            : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Baseline {
  const _Baseline({
    required this.cases,
    required this.r,
    required this.vaccineCoverage,
    required this.sanitation,
  });

  final int cases;
  final double r;
  final int vaccineCoverage;
  final int sanitation;
}

class _Outcome {
  const _Outcome({
    required this.cases,
    required this.r,
    required this.vaccineCoverage,
    required this.sanitation,
    required this.score,
    required this.rules,
    required this.narrative,
  });

  final int cases;
  final double r;
  final int vaccineCoverage;
  final int sanitation;
  final int score;
  final List<String> rules;
  final String narrative;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.baseline, required this.title});

  final _Baseline baseline;
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<({String k, String v})> items = <({String k, String v})>[
      (k: 'Active cases', v: '${baseline.cases}'),
      (k: 'Est. R', v: baseline.r.toStringAsFixed(2)),
      (k: 'Vaccine coverage', v: '${baseline.vaccineCoverage}%'),
      (k: 'Sanitation index', v: '${baseline.sanitation}'),
    ];
    return Column(
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (({String k, String v}) e) => Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: MedCosmic.panelBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        e.k,
                        style: const TextStyle(
                          color: MedCosmic.mute,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.v,
                        style: const TextStyle(
                          color: MedCosmic.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _BudgetSlider extends StatelessWidget {
  const _BudgetSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    required this.maxAffordable,
  });

  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;
  final int maxAffordable;

  @override
  Widget build(BuildContext context) {
    final int max = maxAffordable.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        decoration: MedCosmic.panelBox(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '\$$value',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: MedCosmic.stroke,
              ),
              child: Slider(
                value: value.toDouble().clamp(0, max.toDouble()),
                min: 0,
                max: max < 1 ? 1 : max.toDouble(),
                divisions: max < 1 ? 1 : max,
                onChanged: max < 1
                    ? null
                    : (double v) => onChanged(v.round().clamp(0, max)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: MedCosmic.panelBox(),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '\$$amount',
              style: const TextStyle(
                color: MedCosmic.clinical,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhDots extends StatelessWidget {
  const _PhDots({required this.step});

  final _PhStep step;

  static const List<String> _labels = <String>[
    'Brief',
    'Allocate',
    'Plan',
    'Outcome',
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
