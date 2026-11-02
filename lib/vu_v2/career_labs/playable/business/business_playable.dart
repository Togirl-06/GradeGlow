import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Northline Ventures HQ — Junior Business Analyst.
class BusinessPlayableScreen extends StatelessWidget {
  const BusinessPlayableScreen({super.key});

  static const Color accent = Color(0xFF38BDF8);
  static const Color bg = Color(0xFF071018);
  static const Color surface = Color(0xFF0F1C28);

  static const PlayableCareer career = PlayableCareer(
    id: 'business',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Northline Ventures',
    clockLine: 'Monday — 9:12 AM',
    roleTitle: 'Junior Business Analyst',
    supervisorName: 'Maya Reed',
    supervisorRole: 'CEO',
    hireTagline: 'This is not a quiz. Protect the company. Then grow it.',
    supervisorBrief:
        '“Revenue is down 20%. I need someone who can dig into the data — '
        'sales, customers, competitors, people — and tell me what is actually broken.\n\n'
        'War room. Start with the dashboard.”',
    enterCta: 'ENTER HQ',
    startCta: 'OPEN THE DASHBOARD',
    startLocationId: 'warroom',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'HQ Lobby',
        icon: '🏢',
        blurb: 'Glass atrium. Badge readers. Quiet tension.',
        atmosphere:
            'Northline Ventures. The lobby screen still shows last quarter\'s wins. '
            'This quarter tells a different story.',
      ),
      PlayableRoom(
        id: 'ceo',
        name: 'CEO Office',
        icon: '🚪',
        blurb: 'Maya Reed\'s glass corner.',
        atmosphere:
            'Maya\'s calendar is blocked red. She wants a root cause — and a plan.',
      ),
      PlayableRoom(
        id: 'finance',
        name: 'Finance',
        icon: '💹',
        blurb: 'Cash, forecasts, burn.',
        atmosphere: 'Controllers argue about runway. Cash is tighter than the slides admit.',
      ),
      PlayableRoom(
        id: 'marketing',
        name: 'Marketing',
        icon: '📣',
        blurb: 'Campaign boards and CAC charts.',
        atmosphere: 'Spend is up. Conversions are flat. The team wants more budget anyway.',
      ),
      PlayableRoom(
        id: 'sales',
        name: 'Sales',
        icon: '📞',
        blurb: 'Pipeline boards and call noise.',
        atmosphere: 'Quota missed. Reps say churn kills every win before it compounds.',
      ),
      PlayableRoom(
        id: 'hr',
        name: 'HR',
        icon: '👥',
        blurb: 'People ops and tickets.',
        atmosphere: 'Support staffing is thin. Exit interviews mention burnout and SLA misses.',
      ),
      PlayableRoom(
        id: 'ops',
        name: 'Ops',
        icon: '⚙️',
        blurb: 'Fulfillment and ticket queues.',
        atmosphere: 'Ticket backlog is climbing. CSAT dropped after the last release.',
      ),
      PlayableRoom(
        id: 'warroom',
        name: 'War Room',
        icon: '📊',
        blurb: 'Whiteboards and the company pulse.',
        atmosphere:
            'The dashboard blinks: Revenue ↓20%. Open the reports. Form a hypothesis.',
      ),
      PlayableRoom(
        id: 'boardroom',
        name: 'Boardroom',
        icon: '🪑',
        blurb: 'Present the plan.',
        atmosphere: 'Empty chairs. Strategy decks wait for someone who did the homework.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'warroom',
        bannerTitle: 'ACTIVE SITUATION',
        bannerBody:
            'Company orientation + problem: Revenue ↓20%. Dig into the reports and name the root cause.',
        cta: 'Investigate the drop',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'boardroom',
        bannerTitle: 'STRATEGY BRIEF',
        bannerBody:
            'Choose pricing, marketing budget, and staffing. Watch the meters. Present to Maya.',
        cta: 'Build the strategy',
        unlockKey: 'lab2',
        requiresKey: 'lab1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return PlayableWorkplaceScreen(
      career: augmentCareerWithVisualLabs(career),
      onOpenStage: (BuildContext ctx, PlayableStage stage) async {
        final bool? visual = await tryRunVisualStage(ctx, stage);
        if (visual != null) return visual;
        if (!ctx.mounted) return false;
        if (stage.id == 'lab1') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _BusinessLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _BusinessLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

// ─── Lab 1: Orientation + root cause ───────────────────────────────────────

class _BusinessLab1Screen extends StatefulWidget {
  const _BusinessLab1Screen();

  @override
  State<_BusinessLab1Screen> createState() => _BusinessLab1ScreenState();
}

class _BusinessLab1ScreenState extends State<_BusinessLab1Screen> {
  final Set<String> _opened = <String>{};
  String? _selectedCause;
  final TextEditingController _hypothesis = TextEditingController();
  String? _feedback;

  static const List<_Report> _reports = <_Report>[
    _Report(
      id: 'sales',
      title: 'Sales reports',
      body:
          'New logos are flat, not collapsing. Expansion deals stalled. '
          'Win rate vs last quarter: −4%. Pipeline coverage still above 2.5×.',
    ),
    _Report(
      id: 'customers',
      title: 'Customer data',
      body:
          'Logo churn +11 pts. NPS among accounts with open support tickets: 18. '
          'Top cancel reason coded: “response time / unresolved issues.” '
          'Usage drops 2–3 weeks before cancel.',
    ),
    _Report(
      id: 'competitor',
      title: 'Competitor brief',
      body:
          'Rival cut list price 8%. We lost 2 deals on price — not enough to explain −20% revenue. '
          'Their support CSAT is higher. Messaging focuses on “reliability.”',
    ),
    _Report(
      id: 'employees',
      title: 'Employee reports',
      body:
          'Support team is understaffed after two exits. Average first-response: 19h (target 4h). '
          'Product bugs filed are mostly P3. No P0 outage this quarter.',
    ),
  ];

  @override
  void dispose() {
    _hypothesis.dispose();
    super.dispose();
  }

  Future<void> _openReport(_Report r) async {
    setState(() => _opened.add(r.id));
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BusinessPlayableScreen.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                r.title.toUpperCase(),
                style: const TextStyle(
                  color: BusinessPlayableScreen.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(r.body, style: const TextStyle(color: Colors.white, height: 1.45)),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    final String free = _hypothesis.text.toLowerCase();
    final bool freeOk = free.contains('churn') &&
        (free.contains('support') || free.contains('ticket') || free.contains('response'));
    final bool selectOk = _selectedCause == 'churn';
    if (_opened.length < 3) {
      setState(() => _feedback = 'Open at least three reports before you brief Maya.');
      return;
    }
    if (!selectOk && !freeOk) {
      setState(() {
        _feedback =
            'Maya: “Not buying it. Re-read customer data and employee reports. '
            'What actually drives the revenue drop?”';
      });
      return;
    }
    setState(() => _feedback = null);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: BusinessPlayableScreen.surface,
          title: const Text(
            'Maya Reed — Brief accepted',
            style: TextStyle(color: BusinessPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Churn from support failures. That matches the data.\n\n'
            'Next: build a strategy — pricing, marketing spend, staffing — and present it in the boardroom.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: BusinessPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: BusinessPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Company pulse', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BusinessPlayableScreen.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'DASHBOARD',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Revenue  ↓ 20%',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'QoQ · Northline Ventures core product',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'OPEN REPORTS',
            style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          ..._reports.map((_Report r) {
            final bool seen = _opened.contains(r.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: BusinessPlayableScreen.surface,
                leading: Icon(
                  seen ? Icons.folder_open : Icons.folder,
                  color: BusinessPlayableScreen.accent,
                ),
                title: Text(r.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text(
                  seen ? 'Reviewed' : 'Tap to open',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                ),
                onTap: () => _openReport(r),
              ),
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'ROOT CAUSE',
            style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          ...const <(String, String)>[
            ('pricing', 'Competitor pricing'),
            ('churn', 'Churn from support failures'),
            ('bug', 'Product bug / outage'),
          ].map(((String, String) o) {
            final bool on = _selectedCause == o.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: on ? BusinessPlayableScreen.accent : Colors.transparent,
                  ),
                ),
                tileColor: BusinessPlayableScreen.surface,
                leading: Icon(
                  on ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: BusinessPlayableScreen.accent,
                ),
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                onTap: () => setState(() => _selectedCause = o.$1),
              ),
            );
          }),
          TextField(
            controller: _hypothesis,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Or write your hypothesis…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: BusinessPlayableScreen.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24), height: 1.4)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: BusinessPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('BRIEF THE CEO', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _Report {
  const _Report({required this.id, required this.title, required this.body});
  final String id;
  final String title;
  final String body;
}

// ─── Lab 2: Strategy meters + present ──────────────────────────────────────

class _BusinessLab2Screen extends StatefulWidget {
  const _BusinessLab2Screen();

  @override
  State<_BusinessLab2Screen> createState() => _BusinessLab2ScreenState();
}

class _BusinessLab2ScreenState extends State<_BusinessLab2Screen> {
  double _pricing = 0.5; // 0 cut · 0.5 hold · 1 raise
  double _marketing = 0.4;
  double _staffing = 0.55;

  int get _revenue {
    final double price = 40 + (_pricing - 0.5) * 30;
    final double mkt = _marketing * 35;
    final double staff = _staffing * 40;
    return (55 + price * 0.4 + mkt + staff * 0.7 - (_pricing > 0.7 ? 12 : 0)).round().clamp(20, 100);
  }

  int get _morale {
    final double cut = _pricing < 0.35 ? 8 : 0;
    return (45 + _staffing * 50 - _marketing * 10 + cut - (_pricing > 0.75 ? 15 : 0))
        .round()
        .clamp(15, 100);
  }

  int get _cash {
    return (70 - _marketing * 35 - _staffing * 25 + (_pricing - 0.5) * 20).round().clamp(10, 100);
  }

  void _present() {
    final bool balanced = _revenue >= 55 && _morale >= 45 && _cash >= 35;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: BusinessPlayableScreen.surface,
          title: Text(
            balanced ? 'Maya Reed — Plan locked' : 'Maya Reed — Notes',
            style: const TextStyle(color: BusinessPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            balanced
                ? '“Pricing, spend, and support staffing are coherent. '
                    'We\'ll fund support first — that\'s where churn dies.\n\n'
                    'Good work in the boardroom.”'
                : '“We\'ll adjust, but you presented a full package. '
                    'Remember: support capacity has to move with the growth plan.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: BusinessPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('LEAVE BOARDROOM', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _meter(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))),
            Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 10,
            backgroundColor: Colors.white12,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: BusinessPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Strategy levers', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            'Set the plan. Meters update live. Then present to Maya.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), height: 1.4),
          ),
          const SizedBox(height: 16),
          _meter('Revenue outlook', _revenue, const Color(0xFF34D399)),
          const SizedBox(height: 12),
          _meter('Team morale', _morale, const Color(0xFFFBBF24)),
          const SizedBox(height: 12),
          _meter('Cash runway', _cash, BusinessPlayableScreen.accent),
          const SizedBox(height: 24),
          const Text('Pricing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _pricing,
            onChanged: (double v) => setState(() => _pricing = v),
            activeColor: BusinessPlayableScreen.accent,
            label: _pricing < 0.33 ? 'Cut' : (_pricing > 0.66 ? 'Raise' : 'Hold'),
          ),
          Text(
            _pricing < 0.33 ? 'Cut prices' : (_pricing > 0.66 ? 'Raise prices' : 'Hold pricing'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 12),
          const Text('Marketing budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _marketing,
            onChanged: (double v) => setState(() => _marketing = v),
            activeColor: BusinessPlayableScreen.accent,
          ),
          const SizedBox(height: 12),
          const Text('Support staffing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _staffing,
            onChanged: (double v) => setState(() => _staffing = v),
            activeColor: BusinessPlayableScreen.accent,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _present,
            style: FilledButton.styleFrom(
              backgroundColor: BusinessPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('PRESENT TO CEO', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
