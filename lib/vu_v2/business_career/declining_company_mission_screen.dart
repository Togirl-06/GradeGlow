import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';

/// Signature BA mission: diagnose decline → allocate budget → see outcomes.
class DecliningCompanyMissionScreen extends StatefulWidget {
  const DecliningCompanyMissionScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<DecliningCompanyMissionScreen> createState() =>
      _DecliningCompanyMissionScreenState();
}

class _DecliningCompanyMissionScreenState
    extends State<DecliningCompanyMissionScreen> {
  static const BizMissionDef _mission = BizMissionCatalog.decliningCompany;
  static const CompanyKpis _before = CompanyKpis.decliningBaseline;

  late int _step;
  bool _metManager = false;
  bool _reviewedData = false;
  bool _gatheredSignals = false;
  RecoveryStrategy? _strategy;
  int _retention = 30000;
  int _ops = 25000;
  int _product = 25000;
  CompanyKpis? _after;
  String? _feedback;
  int? _score;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _step = widget.progress.activeMissionId == _mission.id
        ? widget.progress.activeMissionStep.clamp(0, 6)
        : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.progress.activeMissionId != _mission.id) {
        await widget.progress.startMission(_mission.id);
      }
    });
  }

  int get _budgetLeft => 80000 - _retention - _ops - _product;

  Future<void> _go(int step) async {
    setState(() => _step = step);
    await widget.progress.setMissionStep(step);
  }

  Future<void> _runSimulation() async {
    if (_strategy == null || _budgetLeft != 0) return;
    setState(() => _submitting = true);
    final CompanyKpis after = DecliningCompanyEngine.simulate(
      strategy: _strategy!,
      retentionSpend: _retention,
      opsSpend: _ops,
      productSpend: _product,
    );
    final String fb = DecliningCompanyEngine.feedback(
      strategy: _strategy!,
      before: _before,
      after: after,
    );
    final int score = DecliningCompanyEngine.score(before: _before, after: after);
    await widget.progress.saveSimState(<String, dynamic>{
      'strategy': _strategy!.name,
      'retention': _retention,
      'ops': _ops,
      'product': _product,
      'score': score,
      'afterProfit': after.profit,
      'afterCustomers': after.customers,
    });
    if (!mounted) return;
    setState(() {
      _after = after;
      _feedback = fb;
      _score = score;
      _submitting = false;
    });
    await _go(6);
  }

  Future<void> _finish() async {
    final int score = _score ?? 0;
    final int xp = (_mission.xpReward * (0.55 + score / 200)).round();
    await widget.progress.completeMission(
      _mission.id,
      xpGain: xp,
      skills: _mission.learningGoals,
      badge: 'Strategic Thinker',
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: BizCosmic.panel,
        title: const Text(
          'Mission complete',
          style: TextStyle(color: BizCosmic.ink, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Score $score/100 · +$xp XP\nBadge unlocked: Strategic Thinker\n'
          'Rank: ${widget.progress.stageLabel}',
          style: const TextStyle(color: BizCosmic.mute, height: 1.4),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(backgroundColor: BizCosmic.emerald),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: _mission.title,
        icon: Icons.flag_rounded,
      ),
      body: BizStarfield(
        child: Column(
          children: <Widget>[
            _ObjectiveBar(step: _step, objectives: _mission.objectives),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: KeyedSubtree(
                  key: ValueKey<int>(_step),
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _TalkStep(
          title: 'Meet Morgan Chen',
          body:
              '"Revenue is soft and costs keep rising. I need a recovery plan '
              'in 48 hours — diagnose first, then put every dollar of an '
              '\$80,000 budget to work."',
          actionLabel: 'Accept briefing',
          onAction: () async {
            setState(() => _metManager = true);
            await _go(1);
          },
        );
      case 1:
        return _DataStep(
          kpis: _before,
          onContinue: () async {
            setState(() => _reviewedData = true);
            await _go(2);
          },
        );
      case 2:
        return _SignalsStep(
          onContinue: () async {
            setState(() => _gatheredSignals = true);
            await _go(3);
          },
        );
      case 3:
        return _StrategyStep(
          selected: _strategy,
          onSelect: (RecoveryStrategy s) => setState(() => _strategy = s),
          onContinue: _strategy == null
              ? null
              : () => _go(4),
        );
      case 4:
        return _BudgetStep(
          retention: _retention,
          ops: _ops,
          product: _product,
          left: _budgetLeft,
          onChanged: (int r, int o, int p) {
            setState(() {
              _retention = r;
              _ops = o;
              _product = p;
            });
          },
          onContinue: _budgetLeft == 0 ? () => _go(5) : null,
        );
      case 5:
        return _PresentStep(
          strategy: _strategy!,
          retention: _retention,
          ops: _ops,
          product: _product,
          submitting: _submitting,
          onPresent: _runSimulation,
        );
      default:
        return _ResultsStep(
          before: _before,
          after: _after!,
          feedback: _feedback!,
          score: _score!,
          metManager: _metManager,
          reviewedData: _reviewedData,
          gatheredSignals: _gatheredSignals,
          onFinish: _finish,
        );
    }
  }
}

class _ObjectiveBar extends StatelessWidget {
  const _ObjectiveBar({required this.step, required this.objectives});
  final int step;
  final List<String> objectives;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BizCosmic.panelBox(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Objective ${step + 1}/${objectives.length}',
            style: const TextStyle(
              color: BizCosmic.gold,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            objectives[step.clamp(0, objectives.length - 1)],
            style: const TextStyle(
              color: BizCosmic.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (step + 1) / objectives.length,
              minHeight: 6,
              backgroundColor: BizCosmic.panelAlt,
              color: BizCosmic.emerald,
            ),
          ),
        ],
      ),
    );
  }
}

class _TalkStep extends StatelessWidget {
  const _TalkStep({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BizCosmic.panelBox(radius: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: BizCosmic.royal.withValues(alpha: 0.3),
                    child: const Text('M', style: TextStyle(color: BizCosmic.ink)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Morgan Chen · Operations Manager',
                      style: TextStyle(
                        color: BizCosmic.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: BizCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(color: BizCosmic.mute, height: 1.45),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: BizCosmic.emerald,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataStep extends StatelessWidget {
  const _DataStep({required this.kpis, required this.onContinue});
  final CompanyKpis kpis;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Company performance dashboard',
          style: TextStyle(
            color: BizCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Northwind Retail — last 90 days (simulated training data)',
          style: TextStyle(color: BizCosmic.mute, fontSize: 13),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _KpiCard('Customers', '${kpis.customers}', BizCosmic.royal),
            _KpiCard(
              'Revenue / mo',
              '\$${kpis.monthlyRevenue.round()}',
              BizCosmic.emerald,
            ),
            _KpiCard(
              'Cost / mo',
              '\$${kpis.monthlyCost.round()}',
              BizCosmic.warning,
            ),
            _KpiCard(
              'Profit / mo',
              '\$${kpis.profit.round()}',
              kpis.profit >= 0 ? BizCosmic.success : BizCosmic.danger,
            ),
            _KpiCard(
              'Satisfaction',
              '${(kpis.satisfaction * 100).round()}%',
              BizCosmic.gold,
            ),
            _KpiCard(
              'Productivity',
              '${(kpis.productivity * 100).round()}%',
              BizCosmic.purple,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BizCosmic.panelBox(),
          child: const Text(
            'Signal: churn is rising while support tickets and returns climb. '
            'Cash is still healthy enough for an \$80k intervention.',
            style: TextStyle(color: BizCosmic.mute, height: 1.4),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: BizCosmic.royal,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Continue to interviews'),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, this.accent);
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BizCosmic.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: BizCosmic.mute, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalsStep extends StatelessWidget {
  const _SignalsStep({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const _QuoteCard(
          who: 'Alex Rivera · Customer Success',
          quote:
              '"Repeat buyers say shipping is late and the product feel '
              'cheaper than last year. Loyalty offers help briefly, then churn resumes."',
        ),
        const SizedBox(height: 10),
        const _QuoteCard(
          who: 'Priya Nair · Finance',
          quote:
              '"We can fund \$80k once. Overspend on ads without fixing ops and '
              'we burn cash. Underfund the product and satisfaction stays stuck."',
        ),
        const SizedBox(height: 10),
        const _QuoteCard(
          who: 'Customer feedback sample',
          quote:
              '"Support wait times are long. I liked the brand, but competitors '
              'feel more reliable right now."',
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: BizCosmic.emerald,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Choose a recovery strategy'),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.who, required this.quote});
  final String who;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BizCosmic.panelBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            who,
            style: const TextStyle(
              color: BizCosmic.gold,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(quote, style: const TextStyle(color: BizCosmic.ink, height: 1.4)),
        ],
      ),
    );
  }
}

class _StrategyStep extends StatelessWidget {
  const _StrategyStep({
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });
  final RecoveryStrategy? selected;
  final ValueChanged<RecoveryStrategy> onSelect;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Choose a recovery strategy',
          style: TextStyle(
            color: BizCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your choice shapes how the \$80k budget and KPI model respond.',
          style: TextStyle(color: BizCosmic.mute),
        ),
        const SizedBox(height: 12),
        ...RecoveryStrategy.values.map((RecoveryStrategy s) {
          final bool on = selected == s;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onSelect(s),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: on
                      ? BizCosmic.emerald.withValues(alpha: 0.18)
                      : BizCosmic.panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: on ? BizCosmic.emerald : BizCosmic.stroke,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.label,
                      style: const TextStyle(
                        color: BizCosmic.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.detail,
                      style: const TextStyle(color: BizCosmic.mute, height: 1.35),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: BizCosmic.royal,
            disabledBackgroundColor: BizCosmic.stroke,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Allocate budget'),
        ),
      ],
    );
  }
}

class _BudgetStep extends StatelessWidget {
  const _BudgetStep({
    required this.retention,
    required this.ops,
    required this.product,
    required this.left,
    required this.onChanged,
    required this.onContinue,
  });

  final int retention;
  final int ops;
  final int product;
  final int left;
  final void Function(int r, int o, int p) onChanged;
  final VoidCallback? onContinue;

  void _setRetention(int v) {
    final int clamped = v.clamp(0, 80000);
    final int remain = 80000 - clamped;
    final int o = (ops / (ops + product + 0.001) * remain).round();
    final int p = remain - o;
    onChanged(clamped, o, p);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          left == 0
              ? 'Budget fully allocated · \$80,000'
              : 'Unallocated: \$$left',
          style: TextStyle(
            color: left == 0 ? BizCosmic.success : BizCosmic.warning,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _SpendSlider(
          label: 'Retention & support',
          value: retention,
          onChanged: _setRetention,
        ),
        _SpendSlider(
          label: 'Ops efficiency',
          value: ops,
          onChanged: (int v) {
            final int clamped = v.clamp(0, 80000 - retention);
            final int p = 80000 - retention - clamped;
            onChanged(retention, clamped, p);
          },
        ),
        _SpendSlider(
          label: 'Product refresh',
          value: product,
          onChanged: (int v) {
            final int clamped = v.clamp(0, 80000 - retention);
            final int o = 80000 - retention - clamped;
            onChanged(retention, o, clamped);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Retention \$$retention · Ops \$$ops · Product \$$product',
          style: const TextStyle(color: BizCosmic.mute, fontSize: 13),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: BizCosmic.emerald,
            foregroundColor: Colors.black,
            disabledBackgroundColor: BizCosmic.stroke,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Prepare presentation'),
        ),
      ],
    );
  }
}

class _SpendSlider extends StatelessWidget {
  const _SpendSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label · \$$value',
            style: const TextStyle(
              color: BizCosmic.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 80000,
            divisions: 16,
            activeColor: BizCosmic.gold,
            onChanged: (double v) {
              HapticFeedback.selectionClick();
              onChanged((v / 5000).round() * 5000);
            },
          ),
        ],
      ),
    );
  }
}

class _PresentStep extends StatelessWidget {
  const _PresentStep({
    required this.strategy,
    required this.retention,
    required this.ops,
    required this.product,
    required this.submitting,
    required this.onPresent,
  });

  final RecoveryStrategy strategy;
  final int retention;
  final int ops;
  final int product;
  final bool submitting;
  final VoidCallback onPresent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BizCosmic.panelBox(radius: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Present to the manager',
                style: TextStyle(
                  color: BizCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Strategy: ${strategy.label}',
                style: const TextStyle(color: BizCosmic.gold, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Budget: Retention \$$retention · Ops \$$ops · Product \$$product',
                style: const TextStyle(color: BizCosmic.mute, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Morgan will run your plan through the company model and share '
                'what changed — profit, customers, satisfaction, and productivity.',
                style: TextStyle(color: BizCosmic.mute, height: 1.4),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: submitting ? null : onPresent,
                icon: submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.present_to_all_rounded),
                label: Text(submitting ? 'Simulating…' : 'Present recommendation'),
                style: FilledButton.styleFrom(
                  backgroundColor: BizCosmic.royal,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultsStep extends StatelessWidget {
  const _ResultsStep({
    required this.before,
    required this.after,
    required this.feedback,
    required this.score,
    required this.metManager,
    required this.reviewedData,
    required this.gatheredSignals,
    required this.onFinish,
  });

  final CompanyKpis before;
  final CompanyKpis after;
  final String feedback;
  final int score;
  final bool metManager;
  final bool reviewedData;
  final bool gatheredSignals;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Results · Score $score/100',
          style: const TextStyle(
            color: BizCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _KpiCard(
              'Profit Δ',
              '\$${(after.profit - before.profit).round()}',
              after.profit >= before.profit
                  ? BizCosmic.success
                  : BizCosmic.danger,
            ),
            _KpiCard(
              'Customers Δ',
              '${after.customers - before.customers}',
              after.customers >= before.customers
                  ? BizCosmic.success
                  : BizCosmic.danger,
            ),
            _KpiCard(
              'Satisfaction',
              '${(after.satisfaction * 100).round()}%',
              BizCosmic.gold,
            ),
            _KpiCard(
              'Productivity',
              '${(after.productivity * 100).round()}%',
              BizCosmic.purple,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BizCosmic.panelBox(),
          child: Text(
            feedback,
            style: const TextStyle(color: BizCosmic.mute, height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Checklist: Manager ${metManager ? '✓' : '·'} · Data ${reviewedData ? '✓' : '·'} · '
          'Signals ${gatheredSignals ? '✓' : '·'}',
          style: const TextStyle(color: BizCosmic.mute, fontSize: 12),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onFinish,
          style: FilledButton.styleFrom(
            backgroundColor: BizCosmic.emerald,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Collect XP & return'),
        ),
      ],
    );
  }
}
