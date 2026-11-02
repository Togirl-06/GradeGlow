import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_hub_screen.dart';
import '../shared/professional_theme.dart';
import 'economics_policy_mission.dart';

class EconomicsProHome extends StatefulWidget {
  const EconomicsProHome({super.key});

  @override
  State<EconomicsProHome> createState() => _EconomicsProHomeState();
}

class _EconomicsProHomeState extends State<EconomicsProHome> {
  static const ProSimTheme t = ProSimTheme.economics;
  final ProCaseStore _store = ProCaseStore('economics');
  bool _ready = false;
  String _dept = 'dashboard';
  String _mission = 'inflation';

  static const List<ProDept> _depts = <ProDept>[
    ProDept(id: 'dashboard', icon: '📺', title: 'National Dashboard', blurb: 'Dashboard'),
    ProDept(id: 'data', icon: '🗄️', title: 'Economic Data Center', blurb: 'Data'),
    ProDept(id: 'policy', icon: '🏛️', title: 'Policy Room', blurb: 'Policy'),
    ProDept(id: 'bank', icon: '🏦', title: 'Central Bank', blurb: 'Bank'),
    ProDept(id: 'treasury', icon: '💰', title: 'Treasury', blurb: 'Treasury'),
    ProDept(id: 'map', icon: '🗺️', title: 'Regional Map', blurb: 'Map'),
    ProDept(id: 'forecast', icon: '📈', title: 'Forecast Center', blurb: 'Forecast'),
    ProDept(id: 'notes', icon: '📓', title: 'Policy Notebook', blurb: 'Notes'),
  ];

  static const List<ProMission> _missions = <ProMission>[
    ProMission(
      id: 'inflation',
      icon: '📈',
      title: 'Inflation Shock',
      blurb: 'Inflation Shock',
      npcName: 'Dr. Okada',
      npcRole: 'Senior Advisor',
      briefing:
          'Inflation is 8.2%. Diagnose demand vs supply, move policy levers, RUN ECONOMY, defend tradeoffs.',
      objective: 'Matching diagnosis + policy mix with written memo.',
      checklist: <String>[
        'Read dashboard',
        'Diagnose',
        'Set policy',
        'Run economy',
      ],
      xpReward: 170,
      badgeReward: 'Policy Badge',
    ),
    ProMission(
      id: 'crisis',
      icon: '🌪️',
      title: 'National Economic Crisis',
      blurb: 'Crisis Boss',
      npcName: 'Minister',
      npcRole: 'Government',
      briefing: 'Multi-period crisis: recession, trade shock, confidence collapse.',
      objective: 'Stabilize inflation and unemployment across periods.',
      checklist: <String>['Period 1', 'Shock', 'Adjust', 'Report'],
      xpReward: 250,
      badgeReward: 'Economic Advisor',
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
      'GDP',
      'Inflation',
      'Unemployment',
      'Debt',
      'Confidence',
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
        'GDP',
        'Inflation',
        'Unemployment',
        'Debt',
        'Confidence',
      ],
      workspace: _mission == 'inflation'
          ? EconomicsPolicyMission(
              store: _store,
              onComplete: () => setState(() {}),
            )
          : Center(
              child: Text(
                'Complete Inflation Shock to unlock National Crisis.',
                style: TextStyle(color: t.accent),
              ),
            ),
    );
  }
}
