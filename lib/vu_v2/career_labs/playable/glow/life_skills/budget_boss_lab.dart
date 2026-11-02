import 'package:flutter/material.dart';

import '../glow_models.dart';
import '../glow_shell.dart';
import '../glow_widgets.dart';
import 'budget_boss_engine.dart';

/// Budget Boss — personal finance game for Career & Life Skills.
///
/// Level 1  Needs vs Wants     sort puzzle
/// Level 2  Spot the Fee       spot-the-problem puzzle
/// Level 3  First Paycheck     3-month budget simulator
/// Level 4  Credit Card Trap   6-month debt simulator
/// Level 5  Rent Crisis        boss: 4-month simulator, no hints
Widget budgetBossScreen() => GlowLabScreen(lab: budgetBossLab);

const Color _accent = Color(0xFFA855F7);

final GlowLab budgetBossLab = GlowLab(
  id: 'personal_finance',
  title: 'Budget Boss',
  subtitle: 'Personal Finance · Career & Life Skills',
  emoji: '💸',
  accent: _accent,
  rankTitles: const <String>[
    'Broke Beginner',
    'Penny Pincher',
    'Budget Rookie',
    'Savings Scout',
    'Cash-Flow Captain',
    'Money Master',
  ],
  levels: <GlowLevel>[
    GlowLevel(
      id: 'needs_wants',
      title: 'Needs vs Wants',
      tagline: 'Drag 9 expenses into the right bucket',
      emoji: '🧺',
      mechanic: GlowMechanic.sortPuzzle,
      xp: 80,
      builder: (BuildContext c, GlowFinish finish) =>
          NeedsWantsSortLevel(onFinish: finish),
    ),
    GlowLevel(
      id: 'spot_fee',
      title: 'Spot the Fee',
      tagline: 'Find the 5 charges that should not be on this statement',
      emoji: '🔍',
      mechanic: GlowMechanic.spotPuzzle,
      xp: 80,
      builder: (BuildContext c, GlowFinish finish) =>
          SpotTheFeeLevel(onFinish: finish),
    ),
    GlowLevel(
      id: 'first_paycheck',
      title: 'First Paycheck',
      tagline: 'Run a 3-month budget and survive life events',
      emoji: '💵',
      mechanic: GlowMechanic.simulator,
      xp: 120,
      builder: (BuildContext c, GlowFinish finish) => PaycheckSimLevel(
        scenario: _firstPaycheck,
        onFinish: finish,
        intro: 'Your first real job pays \$2,400 a month after tax. Rent and '
            'bills take \$1,250. Plan the rest, then react when life happens. '
            'Only money you move into Savings counts toward your goal.',
      ),
    ),
    GlowLevel(
      id: 'card_trap',
      title: 'Credit Card Trap',
      tagline: 'Pay down \$1,200 without feeding the interest monster',
      emoji: '💳',
      mechanic: GlowMechanic.simulator,
      xp: 120,
      builder: (BuildContext c, GlowFinish finish) =>
          CardTrapLevel(scenario: _cardTrap, onFinish: finish),
    ),
    GlowLevel(
      id: 'rent_crisis',
      title: 'Rent Crisis',
      tagline: 'Boss: a pay cut, a broken car, and no hints',
      emoji: '🚨',
      mechanic: GlowMechanic.boss,
      xp: 200,
      builder: (BuildContext c, GlowFinish finish) => PaycheckSimLevel(
        scenario: _rentCrisis,
        onFinish: finish,
        showPreview: false,
        intro: 'Boss level. No cash preview this time. Build an emergency '
            'fund early, because something is going to break.',
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Scenarios
// ---------------------------------------------------------------------------

const PaycheckScenario _firstPaycheck = PaycheckScenario(
  startCash: 300,
  fixedCosts: 1250,
  savings3: 900,
  savings2: 600,
  savings1: 300,
  maxStress3: 55,
  months: <PaycheckMonth>[
    PaycheckMonth(
      label: 'Month 1',
      income: 2400,
      event: MonthEvent(
        emoji: '📱',
        title: 'Cracked phone screen',
        body: 'You dropped your phone. It still works, but the screen is '
            'shattered.',
        choices: <MonthEventChoice>[
          MonthEventChoice(label: 'Fix it now (\$120)', cost: 120),
          MonthEventChoice(label: 'Live with it', stress: 10),
        ],
      ),
    ),
    PaycheckMonth(
      label: 'Month 2',
      income: 2400,
      event: MonthEvent(
        emoji: '🎟️',
        title: 'Concert invite',
        body: 'Your friends have tickets for Saturday. They are \$90 each.',
        choices: <MonthEventChoice>[
          MonthEventChoice(label: 'Go (\$90)', cost: 90, stress: -8),
          MonthEventChoice(label: 'Skip it', stress: 5),
        ],
      ),
    ),
    PaycheckMonth(
      label: 'Month 3',
      income: 2400,
      event: MonthEvent(
        emoji: '🦷',
        title: 'Surprise dentist bill',
        body: 'A filling turns into a crown. The bill is \$220.',
        choices: <MonthEventChoice>[
          MonthEventChoice(label: 'Pay in full (\$220)', cost: 220),
          MonthEventChoice(
            label: 'Payment plan (\$80 now)',
            cost: 80,
            stress: 6,
          ),
        ],
      ),
    ),
  ],
);

const PaycheckScenario _rentCrisis = PaycheckScenario(
  startCash: 100,
  fixedCosts: 1250,
  savings3: 1200,
  savings2: 800,
  savings1: 400,
  maxStress3: 55,
  months: <PaycheckMonth>[
    PaycheckMonth(label: 'Month 1', income: 2400),
    PaycheckMonth(
      label: 'Month 2',
      income: 2100,
      event: MonthEvent(
        emoji: '📉',
        title: 'Your hours got cut',
        body: 'Your manager trims your shifts. Income drops to \$2,100 this '
            'month.',
        choices: <MonthEventChoice>[
          MonthEventChoice(
            label: 'Pick up weekend shifts (+\$150)',
            cost: -150,
            stress: 10,
          ),
          MonthEventChoice(label: 'Tighten the belt', stress: 5),
        ],
      ),
    ),
    PaycheckMonth(
      label: 'Month 3',
      income: 2400,
      event: MonthEvent(
        emoji: '🚗',
        title: 'The car breaks down',
        body: 'You need the car to get to work. The shop quotes \$650.',
        choices: <MonthEventChoice>[
          MonthEventChoice(label: 'Full repair (\$650)', cost: 650, stress: 5),
          MonthEventChoice(
            label: 'Used part (\$380)',
            cost: 380,
            stress: 12,
          ),
        ],
      ),
    ),
    PaycheckMonth(
      label: 'Month 4',
      income: 2400,
      event: MonthEvent(
        emoji: '📬',
        title: 'Rent increase letter',
        body: 'Your landlord is raising rent by \$100 a month.',
        choices: <MonthEventChoice>[
          MonthEventChoice(label: 'Accept (\$100)', cost: 100, stress: 4),
          MonthEventChoice(
            label: 'Negotiate (pay \$50)',
            cost: 50,
            stress: 8,
          ),
        ],
      ),
    ),
  ],
);

const CardScenario _cardTrap = CardScenario(
  startBalance: 1200,
  monthlyBudget: 300,
  monthlyRatePercent: 2,
  balance3: 100,
  interest3: 60,
  balance2: 450,
  interest2: 100,
  purchases: <CardPurchase>[
    CardPurchase(emoji: '🎧', title: 'Headphones on sale', amount: 180),
    CardPurchase(emoji: '🏖️', title: 'Weekend trip', amount: 240),
    CardPurchase(emoji: '🍕', title: 'Takeout week', amount: 90),
    CardPurchase(emoji: '📱', title: 'Phone upgrade', amount: 320),
    CardPurchase(emoji: '🎤', title: 'Concert tickets', amount: 110),
    CardPurchase(emoji: '🎁', title: 'Birthday gift', amount: 75),
  ],
);

// ---------------------------------------------------------------------------
// Level 1 — Needs vs Wants (sort puzzle)
// ---------------------------------------------------------------------------

class _SortItem {
  const _SortItem(this.emoji, this.label, this.correct, this.why);

  final String emoji;
  final String label;

  /// 0 = Needs, 1 = Wants, 2 = Savings
  final int correct;
  final String why;
}

const List<String> _bucketTitles = <String>[
  '🏠  Needs — you must pay these',
  '🎉  Wants — nice to have',
  '🏦  Savings — pay your future self',
];

const List<String> _bucketNames = <String>['Needs', 'Wants', 'Savings'];

const List<_SortItem> _sortItems = <_SortItem>[
  _SortItem('🏠', 'Rent', 0, 'Housing is a core need.'),
  _SortItem('🛒', 'Groceries', 0, 'Food is a need. Eating out is the want.'),
  _SortItem('📱', 'Basic phone plan', 0, 'You need a phone for work.'),
  _SortItem('🚌', 'Bus pass to work', 0, 'Getting to your job is a need.'),
  _SortItem('📺', 'Streaming bundle', 1, 'Fun, but you can pause it.'),
  _SortItem('🎟️', 'Concert tickets', 1, 'A treat, not a necessity.'),
  _SortItem('👟', 'Limited-edition sneakers', 1, 'A want, even if you love them.'),
  _SortItem(
    '🛟',
    'Emergency fund deposit',
    2,
    'Saving protects you from surprises.',
  ),
  _SortItem(
    '📈',
    'Retirement contribution',
    2,
    'Saving and investing for later.',
  ),
];

class NeedsWantsSortLevel extends StatefulWidget {
  const NeedsWantsSortLevel({super.key, required this.onFinish});

  final GlowFinish onFinish;

  @override
  State<NeedsWantsSortLevel> createState() => _NeedsWantsSortLevelState();
}

class _NeedsWantsSortLevelState extends State<NeedsWantsSortLevel> {
  final List<int?> _placed = List<int?>.filled(_sortItems.length, null);
  bool _checked = false;
  int _correct = 0;

  void _place(int item, int? bucket) {
    if (_checked) return;
    setState(() => _placed[item] = bucket);
  }

  bool get _allPlaced => _placed.every((int? b) => b != null);

  void _check() {
    int correct = 0;
    for (int i = 0; i < _sortItems.length; i++) {
      if (_placed[i] == _sortItems[i].correct) correct++;
    }
    setState(() {
      _checked = true;
      _correct = correct;
    });
  }

  void _finish() {
    final int total = _sortItems.length;
    final int stars = sortStars(_correct, total);
    widget.onFinish(
      GlowLevelResult(
        stars: stars,
        score: (_correct * 100 / total).round(),
        note: stars == 3
            ? 'Perfect sort. You can tell a need from a want from a savings '
                'goal.'
            : '$_correct of $total were in the right bucket. Needs keep you '
                'alive and employed. Wants are the first thing to trim.',
      ),
    );
  }

  Widget _chip(int i) {
    final _SortItem item = _sortItems[i];
    Color border = GlowColors.stroke;
    Color fill = GlowColors.surfaceHi;
    if (_checked) {
      final bool ok = _placed[i] == item.correct;
      border = ok ? GlowColors.good : GlowColors.bad;
      fill = border.withValues(alpha: 0.18);
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          '${item.emoji} ${item.label}',
          style: const TextStyle(color: GlowColors.ink, fontSize: 13),
        ),
      ),
    );
  }

  Widget _draggable(int i) {
    if (_checked) return _chip(i);
    return Draggable<int>(
      data: i,
      feedback: _chip(i),
      childWhenDragging: Opacity(opacity: 0.3, child: _chip(i)),
      child: _chip(i),
    );
  }

  Widget _zone({
    required String? title,
    required int? bucket,
    required List<int> items,
  }) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> d) => !_checked,
      onAcceptWithDetails: (DragTargetDetails<int> d) => _place(d.data, bucket),
      builder: (
        BuildContext context,
        List<int?> hovering,
        List<dynamic> rejected,
      ) {
        final bool hot = hovering.isNotEmpty;
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hot ? _accent.withValues(alpha: 0.16) : GlowColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hot ? _accent : GlowColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title != null) ...<Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: GlowColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map(_draggable).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> inBucket(int? b) => <int>[
          for (int i = 0; i < _sortItems.length; i++)
            if (_placed[i] == b) i,
        ];

    final List<String> misses = <String>[
      for (int i = 0; i < _sortItems.length; i++)
        if (_checked && _placed[i] != _sortItems[i].correct)
          '${_sortItems[i].emoji} ${_sortItems[i].label} belongs in '
              '${_bucketNames[_sortItems[i].correct]}. ${_sortItems[i].why}',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Drag every expense into a bucket. You can move items around until '
          'you press Check.',
          style: TextStyle(color: GlowColors.mute, height: 1.35),
        ),
        const SizedBox(height: 12),
        _zone(title: null, bucket: null, items: inBucket(null)),
        const SizedBox(height: 12),
        for (int b = 0; b < 3; b++) ...<Widget>[
          _zone(title: _bucketTitles[b], bucket: b, items: inBucket(b)),
          const SizedBox(height: 10),
        ],
        if (_checked) ...<Widget>[
          GlowPanel(
            accent: misses.isEmpty ? GlowColors.good : GlowColors.bad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  misses.isEmpty
                      ? 'Every item is in the right bucket!'
                      : '$_correct of ${_sortItems.length} correct',
                  style: const TextStyle(
                    color: GlowColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                for (final String m in misses) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    m,
                    style: const TextStyle(
                      color: GlowColors.mute,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        GlowButton(
          label: _checked ? 'Finish' : 'Check my sort',
          onPressed: _checked ? _finish : (_allPlaced ? _check : null),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Level 2 — Spot the Fee
// ---------------------------------------------------------------------------

class _StmtLine {
  const _StmtLine(this.date, this.desc, this.amount, [this.issue]);

  final String date;
  final String desc;
  final String amount;

  /// Non-null means this line is a real problem, and says why.
  final String? issue;

  bool get isProblem => issue != null;
}

const List<_StmtLine> _statement = <_StmtLine>[
  _StmtLine('Sep 02', 'Paycheck deposit', '+\$2,400.00'),
  _StmtLine('Sep 03', 'Rent — Maple Court', '-\$1,100.00'),
  _StmtLine('Sep 05', 'Streamly subscription', '-\$12.99'),
  _StmtLine(
    'Sep 05',
    'Streamly subscription',
    '-\$12.99',
    'Duplicate charge: billed twice for the same service on the same day. '
        'Dispute it.',
  ),
  _StmtLine('Sep 09', 'Grocery Mart', '-\$86.40'),
  _StmtLine(
    'Sep 12',
    'Monthly maintenance fee',
    '-\$12.00',
    'A monthly account fee. Many banks waive it with direct deposit, or '
        'offer no-fee accounts.',
  ),
  _StmtLine(
    'Sep 15',
    'Out-of-network ATM surcharge',
    '-\$5.50',
    'Avoidable. Use your own bank\'s ATMs or get cash back at a store.',
  ),
  _StmtLine(
    'Sep 18',
    'Fit24 Gym (cancelled in June)',
    '-\$29.99',
    'A zombie subscription: you cancelled in June but it is still billing.',
  ),
  _StmtLine('Sep 21', 'Gas station', '-\$42.10'),
  _StmtLine(
    'Sep 24',
    'Overdraft fee',
    '-\$35.00',
    'Overdraft fees add up fast. Turn on low-balance alerts.',
  ),
  _StmtLine('Sep 27', 'Coffee Corner', '-\$4.75'),
];

class SpotTheFeeLevel extends StatefulWidget {
  const SpotTheFeeLevel({super.key, required this.onFinish});

  final GlowFinish onFinish;

  @override
  State<SpotTheFeeLevel> createState() => _SpotTheFeeLevelState();
}

class _SpotTheFeeLevelState extends State<SpotTheFeeLevel> {
  final Set<int> _flagged = <int>{};
  bool _submitted = false;

  int get _problems =>
      _statement.where((_StmtLine l) => l.isProblem).length;

  int get _found => _flagged.where((int i) => _statement[i].isProblem).length;

  int get _falseFlags => _flagged.length - _found;

  void _toggle(int i) {
    if (_submitted) return;
    setState(() {
      if (!_flagged.remove(i)) _flagged.add(i);
    });
  }

  void _finish() {
    final int score = spotScore(_found, _falseFlags, _problems);
    final int stars = spotStars(score);
    widget.onFinish(
      GlowLevelResult(
        stars: stars,
        score: score,
        note: 'You caught $_found of $_problems problem charges and flagged '
            '$_falseFlags that were fine. Check your statement every month. '
            'Small leaks sink budgets.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'This is a real-looking bank statement. Tap the charges that '
          'should not be there. Wrong flags cost you points.',
          style: TextStyle(color: GlowColors.mute, height: 1.35),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _statement.length; i++) ...<Widget>[
          _line(i),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        GlowButton(
          label: _submitted ? 'Finish' : 'Submit my flags',
          onPressed: _submitted
              ? _finish
              : (_flagged.isEmpty
                  ? null
                  : () => setState(() => _submitted = true)),
        ),
      ],
    );
  }

  Widget _line(int i) {
    final _StmtLine l = _statement[i];
    final bool flagged = _flagged.contains(i);
    Color border = flagged ? _accent : GlowColors.stroke;
    Color fill = flagged ? _accent.withValues(alpha: 0.14) : GlowColors.surface;
    String? reveal;
    if (_submitted) {
      if (l.isProblem && flagged) {
        border = GlowColors.good;
        fill = GlowColors.good.withValues(alpha: 0.14);
        reveal = 'Caught it. ${l.issue}';
      } else if (l.isProblem) {
        border = GlowColors.gold;
        fill = GlowColors.gold.withValues(alpha: 0.12);
        reveal = 'Missed. ${l.issue}';
      } else if (flagged) {
        border = GlowColors.bad;
        fill = GlowColors.bad.withValues(alpha: 0.14);
        reveal = 'This one is a normal charge.';
      }
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _toggle(i),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  l.date,
                  style: const TextStyle(color: GlowColors.mute, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.desc,
                    style: const TextStyle(
                      color: GlowColors.ink,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  l.amount,
                  style: TextStyle(
                    color: l.amount.startsWith('+')
                        ? GlowColors.good
                        : GlowColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (flagged) ...<Widget>[
                  const SizedBox(width: 8),
                  const Icon(Icons.flag_rounded, color: _accent, size: 18),
                ],
              ],
            ),
            if (reveal != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                reveal,
                style: const TextStyle(
                  color: GlowColors.mute,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Levels 3 and 5 — monthly budget simulator
// ---------------------------------------------------------------------------

class PaycheckSimLevel extends StatefulWidget {
  const PaycheckSimLevel({
    super.key,
    required this.scenario,
    required this.onFinish,
    this.showPreview = true,
    this.intro = '',
  });

  final PaycheckScenario scenario;
  final GlowFinish onFinish;

  /// Boss levels turn this off so the player has to reason without a preview.
  final bool showPreview;
  final String intro;

  @override
  State<PaycheckSimLevel> createState() => _PaycheckSimLevelState();
}

class _PaycheckSimLevelState extends State<PaycheckSimLevel> {
  late PaycheckState _st = PaycheckEngine.start(widget.scenario);
  PaycheckState? _before;
  bool _showRecap = false;
  int? _choice;

  double _groceries = 350;
  double _transport = 100;
  double _fun = 150;
  double _savings = 200;

  PaycheckPlan get _plan => PaycheckPlan(
        groceries: _groceries.round(),
        transport: _transport.round(),
        fun: _fun.round(),
        savings: _savings.round(),
      );

  bool get _finished => PaycheckEngine.isFinished(widget.scenario, _st);

  void _payMonth(MonthEventChoice? choice) {
    final PaycheckState next =
        PaycheckEngine.advance(widget.scenario, _st, _plan, choice);
    setState(() {
      _before = _st;
      _st = next;
      _choice = null;
      _showRecap = true;
    });
  }

  void _afterRecap() {
    if (!_finished) {
      setState(() => _showRecap = false);
      return;
    }
    final PaycheckScenario sc = widget.scenario;
    final int stars = PaycheckEngine.stars(sc, _st);
    final String overdrafts =
        '${_st.overdrafts} overdraft${_st.overdrafts == 1 ? '' : 's'}';
    final String tip;
    if (stars == 3) {
      tip = 'Textbook budgeting. You saved steadily and stayed calm.';
    } else if (_st.cash < 0) {
      tip = 'You ended in the red. Pay yourself first, but keep enough cash '
          'for the month.';
    } else if (_st.overdrafts > 0) {
      tip = 'Overdraft fees ate into your savings. Keep a cash buffer.';
    } else if (_st.cash > 500 && _st.savings < sc.savings1) {
      tip = 'You left ${glowMoney(_st.cash)} sitting in checking. Money you '
          'do not move into savings on purpose tends to get spent. Pay '
          'yourself first.';
    } else {
      tip = 'Safe, but you could save more. Try shaving fun or transport a '
          'little.';
    }
    widget.onFinish(
      GlowLevelResult(
        stars: stars,
        score: PaycheckEngine.score(sc, _st),
        note: 'Saved ${glowMoney(_st.savings)}, stress ${_st.stress}%, '
            '$overdrafts. $tip',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showRecap ? _recapView() : _planView();
  }

  Widget _meters() {
    final PaycheckScenario sc = widget.scenario;
    return GlowPanel(
      child: Column(
        children: <Widget>[
          GlowMeter(
            label: 'Cash',
            valueText: glowMoney(_st.cash),
            fraction: _st.cash / 1500,
            color: _st.cash < 0 ? GlowColors.bad : GlowColors.good,
          ),
          const SizedBox(height: 10),
          GlowMeter(
            label: 'Savings',
            valueText: glowMoney(_st.savings),
            fraction: _st.savings / sc.savings3,
            color: _accent,
          ),
          const SizedBox(height: 10),
          GlowMeter(
            label: 'Stress',
            valueText: '${_st.stress}%',
            fraction: _st.stress / 100,
            color: _st.stress > 60 ? GlowColors.bad : GlowColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _planView() {
    final PaycheckScenario sc = widget.scenario;
    final PaycheckMonth month = sc.months[_st.month];
    final MonthEvent? ev = month.event;
    final MonthEventChoice? choice =
        (ev != null && _choice != null) ? ev.choices[_choice!] : null;
    final PaycheckPlan plan = _plan;
    final int left = PaycheckEngine.leftover(sc, _st, plan, choice);
    final bool isLast = _st.month == sc.months.length - 1;
    final bool ready = ev == null || _choice != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (_st.month == 0 && widget.intro.isNotEmpty) ...<Widget>[
          Text(
            widget.intro,
            style: const TextStyle(color: GlowColors.mute, height: 1.35),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          '${month.label} of ${sc.months.length}',
          style: const TextStyle(
            color: GlowColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Take-home ${glowMoney(month.income)}  ·  Rent & bills '
          '${glowMoney(sc.fixedCosts)}',
          style: const TextStyle(color: GlowColors.mute, fontSize: 13),
        ),
        const SizedBox(height: 12),
        _meters(),
        if (ev != null) ...<Widget>[
          const SizedBox(height: 12),
          GlowPanel(
            accent: GlowColors.gold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${ev.emoji}  ${ev.title}',
                  style: const TextStyle(
                    color: GlowColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ev.body,
                  style: const TextStyle(
                    color: GlowColors.mute,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (int i = 0; i < ev.choices.length; i++)
                      ChoiceChip(
                        label: Text(ev.choices[i].label),
                        selected: _choice == i,
                        selectedColor: _accent.withValues(alpha: 0.35),
                        backgroundColor: GlowColors.surfaceHi,
                        labelStyle: const TextStyle(color: GlowColors.ink),
                        onSelected: (_) => setState(() => _choice = i),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        GlowPanel(
          child: Column(
            children: <Widget>[
              GlowSliderRow(
                emoji: '🛒',
                label: 'Groceries',
                value: _groceries,
                min: 150,
                max: 600,
                step: 10,
                accent: _accent,
                onChanged: (double v) => setState(() => _groceries = v),
              ),
              GlowSliderRow(
                emoji: '🚌',
                label: 'Transport',
                value: _transport,
                min: 50,
                max: 300,
                step: 10,
                accent: _accent,
                onChanged: (double v) => setState(() => _transport = v),
              ),
              GlowSliderRow(
                emoji: '🎉',
                label: 'Fun',
                value: _fun,
                min: 0,
                max: 500,
                step: 10,
                accent: _accent,
                onChanged: (double v) => setState(() => _fun = v),
              ),
              GlowSliderRow(
                emoji: '🏦',
                label: 'Savings',
                value: _savings,
                min: 0,
                max: 800,
                step: 10,
                accent: _accent,
                onChanged: (double v) => setState(() => _savings = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.showPreview
              ? 'Planned spending ${glowMoney(plan.total)}  ·  Cash after this '
                  'month: ${glowMoney(_st.cash + left)}'
              : 'Planned spending ${glowMoney(plan.total)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.showPreview && _st.cash + left < 0
                ? GlowColors.bad
                : GlowColors.mute,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        GlowButton(
          label: isLast ? 'Close the books' : 'Pay the month',
          onPressed: ready ? () => _payMonth(choice) : null,
        ),
      ],
    );
  }

  Widget _recapView() {
    final PaycheckState before = _before!;
    Widget row(String label, String a, String b) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(color: GlowColors.mute, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '$a  →  $b',
                style: const TextStyle(
                  color: GlowColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          '${widget.scenario.months[before.month].label} recap',
          style: const TextStyle(
            color: GlowColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GlowPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              row('Cash', glowMoney(before.cash), glowMoney(_st.cash)),
              row(
                'Savings',
                glowMoney(before.savings),
                glowMoney(_st.savings),
              ),
              row('Stress', '${before.stress}%', '${_st.stress}%'),
              if (_st.lastNote.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _st.lastNote,
                  style: const TextStyle(
                    color: GlowColors.mute,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlowButton(
          label: _finished ? 'See results' : 'Next month',
          onPressed: _afterRecap,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Level 4 — Credit Card Trap
// ---------------------------------------------------------------------------

class CardTrapLevel extends StatefulWidget {
  const CardTrapLevel({
    super.key,
    required this.scenario,
    required this.onFinish,
  });

  final CardScenario scenario;
  final GlowFinish onFinish;

  @override
  State<CardTrapLevel> createState() => _CardTrapLevelState();
}

class _CardTrapLevelState extends State<CardTrapLevel> {
  late CardState _st = CardEngine.start(widget.scenario);
  CardState? _before;
  bool _showRecap = false;
  bool? _buy;
  double? _pay;

  bool get _finished => CardEngine.isFinished(widget.scenario, _st);

  void _makePayment(int payment) {
    final CardState next = CardEngine.advance(
      widget.scenario,
      _st,
      buy: _buy ?? false,
      payment: payment,
    );
    setState(() {
      _before = _st;
      _st = next;
      _buy = null;
      _pay = null;
      _showRecap = true;
    });
  }

  void _afterRecap() {
    if (!_finished) {
      setState(() => _showRecap = false);
      return;
    }
    final CardScenario sc = widget.scenario;
    final int stars = CardEngine.stars(sc, _st);
    widget.onFinish(
      GlowLevelResult(
        stars: stars,
        score: CardEngine.score(sc, _st),
        note: 'Final balance ${glowMoney(_st.balance)} after '
            '${glowMoney(_st.interestPaid)} in interest. '
            '${stars == 3 ? 'You beat the card.' : 'Every dollar above the minimum cuts interest, and every impulse buy adds to it.'}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showRecap ? _recapView() : _planView();
  }

  Widget _planView() {
    final CardScenario sc = widget.scenario;
    final CardPurchase offer = sc.purchases[_st.month];
    final int balanceAfterBuy =
        _st.balance + (_buy == true ? offer.amount : 0);
    final int lo = CardEngine.minPayment(balanceAfterBuy);
    final int hi = CardEngine.maxPayment(sc, balanceAfterBuy);
    final int pay = (_pay ?? lo.toDouble())
        .clamp(lo.toDouble(), hi.toDouble())
        .round();
    final int remaining = balanceAfterBuy - pay;
    final int interestPreview =
        (remaining * sc.monthlyRatePercent / 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (_st.month == 0) ...<Widget>[
          Text(
            'You owe ${glowMoney(sc.startBalance)} on a card charging '
            '${sc.monthlyRatePercent}% a month (about '
            '${sc.monthlyRatePercent * 12}% a year). You can put up to '
            '${glowMoney(sc.monthlyBudget)} a month toward it. Six months, '
            'six temptations.',
            style: const TextStyle(color: GlowColors.mute, height: 1.35),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Month ${_st.month + 1} of ${sc.purchases.length}',
          style: const TextStyle(
            color: GlowColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GlowPanel(
          child: Column(
            children: <Widget>[
              GlowMeter(
                label: 'Card balance',
                valueText: glowMoney(_st.balance),
                fraction: _st.balance / (sc.startBalance * 1.5),
                color: _st.balance > sc.startBalance
                    ? GlowColors.bad
                    : GlowColors.gold,
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Text(
                    'Interest paid so far',
                    style: TextStyle(color: GlowColors.mute, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    glowMoney(_st.interestPaid),
                    style: const TextStyle(
                      color: GlowColors.bad,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlowPanel(
          accent: GlowColors.gold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${offer.emoji}  ${offer.title} · ${glowMoney(offer.amount)}',
                style: const TextStyle(
                  color: GlowColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Put it on the card?',
                style: TextStyle(color: GlowColors.mute, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: Text('Buy it (+${glowMoney(offer.amount)})'),
                    selected: _buy == true,
                    selectedColor: GlowColors.bad.withValues(alpha: 0.35),
                    backgroundColor: GlowColors.surfaceHi,
                    labelStyle: const TextStyle(color: GlowColors.ink),
                    onSelected: (_) => setState(() => _buy = true),
                  ),
                  ChoiceChip(
                    label: const Text('Skip it'),
                    selected: _buy == false,
                    selectedColor: GlowColors.good.withValues(alpha: 0.35),
                    backgroundColor: GlowColors.surfaceHi,
                    labelStyle: const TextStyle(color: GlowColors.ink),
                    onSelected: (_) => setState(() => _buy = false),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlowPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Minimum payment: ${glowMoney(lo)}',
                style: const TextStyle(color: GlowColors.mute, fontSize: 13),
              ),
              const SizedBox(height: 4),
              if (hi > lo)
                GlowSliderRow(
                  emoji: '💳',
                  label: 'Your payment',
                  value: pay.toDouble(),
                  min: lo.toDouble(),
                  max: hi.toDouble(),
                  step: 5,
                  accent: _accent,
                  onChanged: (double v) => setState(() => _pay = v),
                )
              else
                Text(
                  'Your payment: ${glowMoney(lo)}',
                  style: const TextStyle(
                    color: GlowColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                'If you pay ${glowMoney(pay)}, the card will add about '
                '${glowMoney(interestPreview)} in interest.',
                style: const TextStyle(
                  color: GlowColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlowButton(
          label: 'Make payment',
          onPressed: _buy == null ? null : () => _makePayment(pay),
        ),
      ],
    );
  }

  Widget _recapView() {
    final CardState before = _before!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Month ${before.month + 1} recap',
          style: const TextStyle(
            color: GlowColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GlowPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'Balance',
                    style: TextStyle(color: GlowColors.mute, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '${glowMoney(before.balance)}  →  ${glowMoney(_st.balance)}',
                    style: const TextStyle(
                      color: GlowColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _st.lastNote,
                style: const TextStyle(
                  color: GlowColors.mute,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlowButton(
          label: _finished ? 'See results' : 'Next month',
          onPressed: _afterRecap,
        ),
      ],
    );
  }
}
