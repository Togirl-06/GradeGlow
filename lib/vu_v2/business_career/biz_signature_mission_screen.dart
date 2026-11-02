import 'package:flutter/material.dart';

import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';

/// 5-step signature mission unique per major (non-BA majors).
class BizSignatureMissionScreen extends StatefulWidget {
  const BizSignatureMissionScreen({
    super.key,
    required this.progress,
    required this.majorId,
  });

  final BusinessCareerProgress progress;
  final String majorId;

  @override
  State<BizSignatureMissionScreen> createState() =>
      _BizSignatureMissionScreenState();
}

class _BizSignatureMissionScreenState extends State<BizSignatureMissionScreen> {
  late final _MissionSpec _spec;
  int _step = 0;
  final Map<int, String> _choices = <int, String>{};
  bool _submitting = false;
  int? _score;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _spec = _MissionSpec.forMajor(widget.majorId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Optional: progress may expose startMission while rewriting persistence.
      try {
        // ignore: avoid_dynamic_calls
        final dynamic p = widget.progress;
        if (p.activeMissionId != _spec.id) {
          await p.startMission(_spec.id);
        }
      } catch (_) {}
    });
  }

  int _computeScore() {
    int score = 40;
    for (int i = 0; i < _spec.steps.length; i++) {
      final _StepSpec s = _spec.steps[i];
      final String? pick = _choices[i];
      if (pick == null) continue;
      if (pick == s.bestId) {
        score += 12;
      } else if (pick == s.okId) {
        score += 6;
      } else {
        score -= 4;
      }
    }
    return score.clamp(0, 100);
  }

  Future<void> _complete() async {
    if (_submitting) return;
    for (int i = 0; i < _spec.steps.length; i++) {
      if (!_choices.containsKey(i)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Make a choice on step ${i + 1} first.')),
        );
        setState(() => _step = i);
        return;
      }
    }
    setState(() => _submitting = true);
    final int score = _computeScore();
    final String fb = score >= 75
        ? _spec.winFeedback
        : score >= 55
            ? _spec.midFeedback
            : _spec.loseFeedback;
    final int xp = 100 + (score ~/ 2);
    await widget.progress.completeMission(
      _spec.id,
      xpGain: xp,
      skills: _spec.skills,
      badge: score >= 70 ? _spec.badge : null,
    );
    if (!mounted) return;
    setState(() {
      _score = score;
      _feedback = fb;
      _submitting = false;
      _step = _spec.steps.length; // results pane
    });
  }

  @override
  Widget build(BuildContext context) {
    final BusinessMajor major = BusinessMajors.byId(widget.majorId);
    final bool done = widget.progress.isMissionComplete(_spec.id);

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: _spec.title,
        icon: major.icon,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BizCosmic.pill(major.title),
          ),
        ],
      ),
      body: BizStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Text(
              _spec.hook,
              style: const TextStyle(
                color: BizCosmic.mute,
                height: 1.4,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 12),
            if (done && _score == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BizCosmic.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You already cleared this signature mission. Replaying awards no extra XP.',
                  style: TextStyle(color: BizCosmic.success),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List<Widget>.generate(_spec.steps.length + 1, (int i) {
                  final bool results = i == _spec.steps.length;
                  final bool on = _step == i;
                  final String label = results ? 'Results' : '${i + 1}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: results && _score == null
                          ? null
                          : () => setState(() => _step = i),
                      child: BizCosmic.pill(
                        label,
                        bg: on
                            ? BizCosmic.emerald.withValues(alpha: 0.3)
                            : BizCosmic.panelAlt,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            if (_step >= _spec.steps.length && _score != null)
              _buildResults()
            else if (_step < _spec.steps.length)
              _buildStep(_spec.steps[_step])
            else
              const Text(
                'Complete all five decisions, then submit.',
                style: TextStyle(color: BizCosmic.mute),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(_StepSpec s) {
    final String? pick = _choices[_step];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BizCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Step ${_step + 1} · ${s.title}',
            style: const TextStyle(
              color: BizCosmic.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.prompt,
            style: const TextStyle(color: BizCosmic.mute, height: 1.4),
          ),
          const SizedBox(height: 14),
          ...s.options.map((({String id, String label}) o) {
            final bool on = pick == o.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _choices[_step] = o.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: on
                        ? BizCosmic.royal.withValues(alpha: 0.22)
                        : BizCosmic.panelAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: on ? BizCosmic.electric : BizCosmic.stroke,
                    ),
                  ),
                  child: Text(
                    o.label,
                    style: const TextStyle(
                      color: BizCosmic.ink,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BizCosmic.ink,
                    side: const BorderSide(color: BizCosmic.stroke),
                  ),
                  child: const Text('Back'),
                ),
              const Spacer(),
              if (_step < _spec.steps.length - 1)
                FilledButton(
                  onPressed: pick == null
                      ? null
                      : () => setState(() => _step++),
                  style: FilledButton.styleFrom(
                    backgroundColor: BizCosmic.emerald,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Next'),
                )
              else
                FilledButton(
                  onPressed: _submitting ? null : _complete,
                  style: FilledButton.styleFrom(
                    backgroundColor: BizCosmic.gold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(_submitting ? 'Scoring…' : 'Submit mission'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BizCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Score $_score / 100',
            style: const TextStyle(
              color: BizCosmic.gold,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _feedback ?? '',
            style: const TextStyle(color: BizCosmic.ink, height: 1.45),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: FilledButton.styleFrom(
              backgroundColor: BizCosmic.emerald,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(46),
            ),
            child: const Text('Return to workplace'),
          ),
        ],
      ),
    );
  }
}

class _StepSpec {
  const _StepSpec({
    required this.title,
    required this.prompt,
    required this.options,
    required this.bestId,
    required this.okId,
  });

  final String title;
  final String prompt;
  final List<({String id, String label})> options;
  final String bestId;
  final String okId;
}

class _MissionSpec {
  const _MissionSpec({
    required this.id,
    required this.title,
    required this.hook,
    required this.steps,
    required this.skills,
    required this.badge,
    required this.winFeedback,
    required this.midFeedback,
    required this.loseFeedback,
  });

  final String id;
  final String title;
  final String hook;
  final List<_StepSpec> steps;
  final List<String> skills;
  final String badge;
  final String winFeedback;
  final String midFeedback;
  final String loseFeedback;

  static _MissionSpec forMajor(String majorId) {
    switch (majorId) {
      case 'accounting':
        return _accounting();
      case 'finance':
        return _finance();
      case 'economics':
        return _economics();
      case 'entrepreneurship':
        return _entrepreneurship();
      case 'marketing':
        return _marketing();
      case 'human_resource_management':
        return _hr();
      case 'international_business':
        return _intl();
      default:
        return _accounting();
    }
  }

  static _StepSpec _s({
    required String title,
    required String prompt,
    required List<({String id, String label})> options,
    required String bestId,
    required String okId,
  }) =>
      _StepSpec(
        title: title,
        prompt: prompt,
        options: options,
        bestId: bestId,
        okId: okId,
      );

  static _MissionSpec _accounting() => _MissionSpec(
        id: 'sig_accounting_12k',
        title: 'The Missing \$12,000',
        hook:
            'A client cash account is \$12,000 short after month-end. Trace, test, and report without torching the relationship.',
        skills: const <String>['Reconciliation', 'Audit', 'Communication'],
        badge: 'Ledger Detective',
        winFeedback:
            'You isolated the variance, documented controls, and briefed the partner cleanly. Client trust holds.',
        midFeedback:
            'You found most of the gap but left a few control findings soft. Tighten workpapers next time.',
        loseFeedback:
            'Rushing past evidence left the \$12k unexplained. Rebuild the trail before filing.',
        steps: <_StepSpec>[
          _s(
            title: 'Scope',
            prompt: 'Where do you start?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Blame AP and demand a write-off today'),
              (id: 'b', label: 'Reconcile bank + GL, then isolate timing vs error'),
              (id: 'c', label: 'Ignore until next quarter close'),
            ],
            bestId: 'b',
            okId: 'a',
          ),
          _s(
            title: 'Evidence',
            prompt: 'A matching \$12k wire lacks an invoice. Next?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Book it as revenue to clear the variance'),
              (id: 'b', label: 'Pull authorization + counterparty confirmation'),
              (id: 'c', label: 'Delete the journal so the books balance'),
            ],
            bestId: 'b',
            okId: 'a',
          ),
          _s(
            title: 'Controls',
            prompt: 'Dual approval was skipped twice this month. You…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Note exception, recommend control redesign'),
              (id: 'b', label: 'Hide it to keep the engagement happy'),
              (id: 'c', label: 'Fire the bookkeeper immediately without facts'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Adjust',
            prompt: 'Root cause: misposted intercompany. Best entry?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Correcting entry with clear support and date'),
              (id: 'b', label: 'Plug to miscellaneous expense forever'),
              (id: 'c', label: 'Leave it; “immaterial” without testing'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Report',
            prompt: 'Partner asks for the client narrative.',
            options: <({String id, String label})>[
              (id: 'a', label: 'Facts, impact, remediation — no drama'),
              (id: 'b', label: 'Accuse fraud in the first sentence'),
              (id: 'c', label: 'Say everything is fine; skip findings'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );

  static _MissionSpec _finance() => _MissionSpec(
        id: 'sig_finance_50k',
        title: 'The \$50,000 Portfolio',
        hook:
            'Allocate \$50k across risk buckets for a young professional with a 7-year horizon.',
        skills: const <String>['Portfolio', 'Risk', 'Valuation'],
        badge: 'Portfolio Builder',
        winFeedback:
            'Allocation matches horizon, diversification, and rebalancing rules. Client can sleep at night.',
        midFeedback:
            'Decent mix, but fees or concentration still bite. Revisit weights.',
        loseFeedback:
            'All-in speculation or all-cash missed the brief. Rebuild the IPS.',
        steps: <_StepSpec>[
          _s(
            title: 'IPS',
            prompt: 'First deliverable?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Investment policy: goals, risk, constraints'),
              (id: 'b', label: 'Buy whatever is trending on social'),
              (id: 'c', label: 'Promise 40% annual returns in writing'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Mix',
            prompt: 'Core allocation for 7-year horizon?',
            options: <({String id, String label})>[
              (id: 'a', label: '70% diversified equity / 25% bonds / 5% cash'),
              (id: 'b', label: '100% single meme stock'),
              (id: 'c', label: '100% cash under the mattress'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Risk',
            prompt: 'Equity sleeve drops 18% in a month. You…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Panic sell everything at the bottom'),
              (id: 'b', label: 'Rebalance to targets; review IPS calmly'),
              (id: 'c', label: 'Double down with leverage'),
            ],
            bestId: 'b',
            okId: 'c',
          ),
          _s(
            title: 'Fees',
            prompt: 'Two funds same exposure — 0.05% vs 1.4% expense.',
            options: <({String id, String label})>[
              (id: 'a', label: 'Prefer low-cost unless active edge is proven'),
              (id: 'b', label: 'Always pick the expensive “premium” brand'),
              (id: 'c', label: 'Ignore fees; they never compound'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Review',
            prompt: 'Annual check-in focus?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Goals progress, drift, tax lots, life changes'),
              (id: 'b', label: 'Only brag about last month’s winners'),
              (id: 'c', label: 'Skip reviews forever'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );

  static _MissionSpec _economics() => _MissionSpec(
        id: 'sig_econ_inflation',
        title: 'The Inflation Challenge',
        hook:
            'CPI is running hot. Advise a city council on trade-offs without magical thinking.',
        skills: const <String>['Analysis', 'Policy', 'Data'],
        badge: 'Policy Analyst',
        winFeedback:
            'You framed incentives clearly and proposed measurable pilots.',
        midFeedback:
            'Directionally right, but measurement was fuzzy. Tighten indicators.',
        loseFeedback:
            'Wishful price freezes without supply fixes made shortages worse.',
        steps: <_StepSpec>[
          _s(
            title: 'Diagnose',
            prompt: 'Inflation spike looks…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Demand pull + supply shocks — separate channels'),
              (id: 'b', label: 'Only greed; ignore money and bottlenecks'),
              (id: 'c', label: 'Fake news; CPI is meaningless'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Tool',
            prompt: 'Best short-run demand coolant?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Tighter monetary stance if demand-driven'),
              (id: 'b', label: 'Print more cash to “help spending”'),
              (id: 'c', label: 'Ban price increases citywide forever'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Supply',
            prompt: 'Housing rents surge. You advise…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Speed permits / zoning to expand supply'),
              (id: 'b', label: 'Hard rent freeze with no maintenance carve-outs'),
              (id: 'c', label: 'Do nothing and hope'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Equity',
            prompt: 'Protect vulnerable households via…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Targeted transfers, not blanket price controls'),
              (id: 'b', label: 'Subsidize everyone including luxury buyers'),
              (id: 'c', label: 'Cut all safety nets during inflation'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Measure',
            prompt: 'Success metrics?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Core CPI trend, vacancies, real wages, fiscal cost'),
              (id: 'b', label: 'Only Twitter sentiment'),
              (id: 'c', label: 'No metrics — vibes'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );

  static _MissionSpec _entrepreneurship() => _MissionSpec(
        id: 'sig_entre_startup',
        title: 'Launch a Startup',
        hook:
            'Validate a campus marketplace idea before burning runway.',
        skills: const <String>['Validation', 'Modeling', 'Finance'],
        badge: 'Founder Badge',
        winFeedback:
            'You validated demand, controlled burn, and pitched with evidence.',
        midFeedback:
            'Some traction, but unit economics still fuzzy.',
        loseFeedback:
            'Built features nobody asked for and ran out of cash.',
        steps: <_StepSpec>[
          _s(
            title: 'Problem',
            prompt: 'Week 1 focus?',
            options: <({String id, String label})>[
              (id: 'a', label: '15 customer interviews before coding'),
              (id: 'b', label: 'Hire a 12-person engineering team'),
              (id: 'c', label: 'Rent a fancy office for vibes'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'MVP',
            prompt: 'Ship what?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Manual concierge MVP proving willingness to pay'),
              (id: 'b', label: 'Full AI platform with 40 screens'),
              (id: 'c', label: 'Nothing — keep ideating forever'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Cash',
            prompt: 'Runway is 4 months. Priority?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Cut burn; hit revenue milestone; then raise'),
              (id: 'b', label: 'Spend on merch and launch party'),
              (id: 'c', label: 'Ignore burn rate'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Metric',
            prompt: 'North-star early?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Paid retention / repeat orders'),
              (id: 'b', label: 'Vanity downloads with 0% activation'),
              (id: 'c', label: 'Number of pitch decks sent'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Pitch',
            prompt: 'Investor ask structure?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Problem → proof → model → ask → use of funds'),
              (id: 'b', label: 'Only hype slides, no numbers'),
              (id: 'c', label: 'Refuse questions; “trust the vision”'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );

  static _MissionSpec _marketing() => _MissionSpec(
        id: 'sig_mkt_sneaker',
        title: 'Launch a Sneaker Brand',
        hook:
            'Position a limited drop for 18–24 campus athletes without torching margin.',
        skills: const <String>['Research', 'Brand', 'Analytics'],
        badge: 'Brand Launch',
        winFeedback:
            'Positioning, creative, and channel mix converted without overspending.',
        midFeedback:
            'Awareness rose, but conversion lagged. Fix funnel friction.',
        loseFeedback:
            'Spray-and-pray ads burned budget with no brand spine.',
        steps: <_StepSpec>[
          _s(
            title: 'Insight',
            prompt: 'Research first move?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Segment jobs-to-be-done + competitive whitespace'),
              (id: 'b', label: 'Copy the biggest brand logo-for-logo'),
              (id: 'c', label: 'Skip research; “creatives know”'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Position',
            prompt: 'Brand promise?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Performance + campus identity at accessible price'),
              (id: 'b', label: 'Everything for everyone'),
              (id: 'c', label: 'Luxury only, no story'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Channel',
            prompt: 'Launch mix with \$8k?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Creators + campus ambassadors + retargeting'),
              (id: 'b', label: 'One Super Bowl ad'),
              (id: 'c', label: 'Print 50,000 flyers with no CTA'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Creative',
            prompt: 'Hero message?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Show athletes + proof of comfort/grip + scarcity'),
              (id: 'b', label: 'Only stock photos of empty shoes'),
              (id: 'c', label: 'All-caps “BUY NOW!!!” with no product shot'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Learn',
            prompt: 'Week-1 read?',
            options: <({String id, String label})>[
              (id: 'a', label: 'CAC, conversion, return rate, creative winners'),
              (id: 'b', label: 'Only likes'),
              (id: 'c', label: 'Never look at data'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );

  static _MissionSpec _hr() => _MissionSpec(
        id: 'sig_hr_retention',
        title: 'The Employee Retention Crisis',
        hook:
            'Turnover spiked on a mid-size ops team. Diagnose before throwing money.',
        skills: const <String>['Recruitment', 'Relations', 'Performance'],
        badge: 'People Partner',
        winFeedback:
            'You fixed root causes and rebuilt trust with measurable retention gains.',
        midFeedback:
            'Some wins, but managers still need coaching cadence.',
        loseFeedback:
            'Bonuses without listening left attrition high.',
        steps: <_StepSpec>[
          _s(
            title: 'Listen',
            prompt: 'First 48 hours?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Stay interviews + exit themes + manager 1:1 audit'),
              (id: 'b', label: 'Announce random pizza Fridays and stop'),
              (id: 'c', label: 'Ignore data; blame “Gen Z”'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Cause',
            prompt: 'Top theme: unclear growth + weekend overtime.',
            options: <({String id, String label})>[
              (id: 'a', label: 'Career paths + staffing model + OT policy'),
              (id: 'b', label: 'Only a one-time \$50 gift card'),
              (id: 'c', label: 'Threaten people who quit'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Manager',
            prompt: 'Enable managers by…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Coaching toolkit + weekly feedback ritual'),
              (id: 'b', label: 'Remove all manager accountability'),
              (id: 'c', label: 'Publicly shame them in Slack'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Fairness',
            prompt: 'Promotion process is opaque. Fix?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Transparent criteria + calibration panels'),
              (id: 'b', label: 'Promote whoever is loudest'),
              (id: 'c', label: 'Freeze all promotions forever'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Measure',
            prompt: '90-day KPIs?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Regrettable attrition, eNPS, OT hours, time-to-fill'),
              (id: 'b', label: 'Only party attendance'),
              (id: 'c', label: 'No HR metrics'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );

  static _MissionSpec _intl() => _MissionSpec(
        id: 'sig_intl_expand',
        title: 'Expand Into a New Country',
        hook:
            'Evaluate entering a new market with tariffs, FX, and partner risk.',
        skills: const <String>['Market entry', 'Trade', 'Negotiation'],
        badge: 'Global Operator',
        winFeedback:
            'You chose a staged entry with clear risk hedges and local partners.',
        midFeedback:
            'Entry works, but FX and compliance buffers were thin.',
        loseFeedback:
            'Full build-out without due diligence burned capital.',
        steps: <_StepSpec>[
          _s(
            title: 'Screen',
            prompt: 'Market screen criteria?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Demand, competition, regulation, logistics cost'),
              (id: 'b', label: 'Pick the country with the coolest flag'),
              (id: 'c', label: 'Enter all continents at once'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
          _s(
            title: 'Mode',
            prompt: 'Entry mode for first 12 months?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Distributor pilot + option to JV'),
              (id: 'b', label: 'Build 3 factories day one'),
              (id: 'c', label: 'Export with zero local support'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Trade',
            prompt: 'New tariff hits landed cost +18%. You…',
            options: <({String id, String label})>[
              (id: 'a', label: 'Reprice, HS classify, seek drawback / alternate origin'),
              (id: 'b', label: 'Ignore compliance and under-invoice'),
              (id: 'c', label: 'Exit overnight with no plan'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'FX',
            prompt: 'Currency swings ±12%. Hedge how?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Forward contracts on known receivables + natural hedge'),
              (id: 'b', label: 'Speculate with max leverage'),
              (id: 'c', label: 'Hope the FX gods are kind'),
            ],
            bestId: 'a',
            okId: 'c',
          ),
          _s(
            title: 'Partner',
            prompt: 'Local partner diligence?',
            options: <({String id, String label})>[
              (id: 'a', label: 'Financials, references, anti-bribery, exit clauses'),
              (id: 'b', label: 'Handshake only'),
              (id: 'c', label: 'Give them exclusive forever with no KPIs'),
            ],
            bestId: 'a',
            okId: 'b',
          ),
        ],
      );
}
