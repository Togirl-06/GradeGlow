import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_hub_screen.dart';
import '../shared/professional_theme.dart';
import 'finance_markets_mission.dart';

class FinanceProHome extends StatefulWidget {
  const FinanceProHome({super.key});

  @override
  State<FinanceProHome> createState() => _FinanceProHomeState();
}

class _FinanceProHomeState extends State<FinanceProHome> {
  static const ProSimTheme t = ProSimTheme.finance;
  final ProCaseStore _store = ProCaseStore('finance');
  bool _ready = false;
  String _dept = 'desk';
  String _mission = 'markets';

  static const List<ProDept> _depts = <ProDept>[
    ProDept(id: 'desk', icon: '🖥️', title: 'Markets Desk', blurb: 'Desk'),
    ProDept(id: 'portfolio', icon: '📦', title: 'Portfolio Terminal', blurb: 'Portfolio'),
    ProDept(id: 'statements', icon: '📑', title: 'Financial Statements', blurb: 'Statements'),
    ProDept(id: 'research', icon: '🔍', title: 'Research Desk', blurb: 'Research'),
    ProDept(id: 'risk', icon: '⚠️', title: 'Risk Center', blurb: 'Risk'),
    ProDept(id: 'news', icon: '📰', title: 'News Terminal', blurb: 'News'),
    ProDept(id: 'trade', icon: '⚖️', title: 'Allocation Workspace', blurb: 'Trade'),
    ProDept(id: 'notebook', icon: '📓', title: 'Analyst Notebook', blurb: 'Notes'),
  ];

  static const List<ProMission> _missions = <ProMission>[
    ProMission(
      id: 'markets',
      icon: '📉',
      title: 'Analyze · Allocate · Survive Shock',
      blurb: 'Markets Mission',
      npcName: 'Hale Chen',
      npcRole: 'Portfolio Manager',
      briefing:
          'Analyze NovaGrid statements, build a \$100k sleeve, then respond to a market shock. Defend risk — not just return.',
      objective: 'Balanced allocation + reasoned shock response with written explanation.',
      checklist: <String>[
        'Read statements',
        'Allocate portfolio',
        'Respond to alert',
        'Run market sim',
      ],
      xpReward: 160,
      badgeReward: 'Risk Badge',
    ),
    ProMission(
      id: 'crisis',
      icon: '🚨',
      title: 'Market Crisis Boss',
      blurb: 'Crisis Boss',
      npcName: 'Desk Head',
      npcRole: 'Managing Director',
      briefing: 'Multi-period crisis. Liquidity, risk, diversification all count.',
      objective: 'Navigate three shocks without blowing risk limits.',
      checklist: <String>['Period 1', 'Shock 2', 'Rebalance', 'Report'],
      xpReward: 240,
      badgeReward: 'Strategist',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _store.ensureLoaded();
    for (final String k in <String>[
      'Portfolio',
      'Risk',
      'Liquidity',
      'Diversification',
    ]) {
      _store.meters.putIfAbsent(k, () => 50);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: t.bg,
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      );
    }
    return ProSimHubScreen(
      theme: t,
      store: _store,
      departments: _depts,
      missions: _missions,
      selectedDeptId: _dept,
      selectedMissionId: _mission,
      onSelectDept: (String id) => setState(() => _dept = id),
      onSelectMission: (String id) => setState(() => _mission = id),
      onContinue: () => setState(() {}),
      meterLabels: const <String>[
        'Portfolio',
        'Risk',
        'Liquidity',
        'Diversification',
      ],
      workspace: _mission == 'markets'
          ? FinanceMarketsMission(
              store: _store,
              onComplete: () => setState(() {}),
            )
          : Center(
              child: Text(
                'Complete Markets Mission to unlock Crisis Boss.',
                style: TextStyle(color: t.accent),
              ),
            ),
    );
  }
}
