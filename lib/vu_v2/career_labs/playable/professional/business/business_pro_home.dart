import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_hub_screen.dart';
import '../shared/professional_theme.dart';
import '../../../../labs/university_practical/practical_catalog.dart';
import '../../../../labs/university_practical/university_practical_lab.dart';
import 'business_sales_drop_mission.dart';

class BusinessProHome extends StatefulWidget {
  const BusinessProHome({super.key});

  @override
  State<BusinessProHome> createState() => _BusinessProHomeState();
}

class _BusinessProHomeState extends State<BusinessProHome> {
  static const ProSimTheme t = ProSimTheme.business;
  final ProCaseStore _store = ProCaseStore('business');
  bool _ready = false;
  String _dept = 'warroom';
  String _mission = 'sales_drop';

  static const List<ProDept> _depts = <ProDept>[
    ProDept(id: 'reception', icon: '🏢', title: 'Reception', blurb: 'Lobby'),
    ProDept(id: 'ceo', icon: '🚪', title: 'Executive Office', blurb: 'CEO'),
    ProDept(id: 'analyst', icon: '💻', title: 'Analyst Workspace', blurb: 'Desk'),
    ProDept(id: 'marketing', icon: '📣', title: 'Marketing', blurb: 'Campaigns'),
    ProDept(id: 'finance', icon: '💹', title: 'Finance', blurb: 'Cash'),
    ProDept(id: 'ops', icon: '⚙️', title: 'Operations', blurb: 'Ops'),
    ProDept(id: 'hr', icon: '👥', title: 'Human Resources', blurb: 'People'),
    ProDept(id: 'warroom', icon: '📊', title: 'Conference Room', blurb: 'War room'),
    ProDept(id: 'data', icon: '🗄️', title: 'Data Center', blurb: 'Data'),
    ProDept(id: 'dash', icon: '📺', title: 'Company Dashboard', blurb: 'Pulse'),
  ];

  static const List<ProMission> _missions = <ProMission>[
    ProMission(
      id: 'sales_drop',
      icon: '📉',
      title: 'Why Did Sales Drop?',
      blurb: 'Sales Drop',
      npcName: 'Maya Reed',
      npcRole: 'CEO',
      briefing:
          'Sales dropped 20% this quarter. Dig into sales, customers, competitors, and ops. Pin evidence. Then set strategy and RUN NEXT QUARTER.',
      objective:
          'Identify the root cause with evidence, choose a strategy, run the quarter, and write a recommendation.',
      checklist: <String>[
        'Open dashboards',
        'Pin evidence',
        'Name root cause',
        'Run next quarter',
      ],
      xpReward: 150,
      badgeReward: 'Analyst Badge',
    ),
    ProMission(
      id: 'employee_crisis',
      icon: '🚪',
      title: 'Employee Crisis',
      blurb: 'Turnover',
      npcName: 'Priya Shah',
      npcRole: 'HR Manager',
      briefing:
          'Turnover spiked. Interview departments, review surveys, find the real driver — then propose a fix.',
      objective: 'Diagnose turnover drivers and recommend a retention plan.',
      checklist: <String>['Read surveys', 'Interview AI staff', 'Propose fix'],
      xpReward: 160,
      badgeReward: 'People Badge',
    ),
    ProMission(
      id: 'expansion',
      icon: '🌍',
      title: 'Market Expansion',
      blurb: 'Expansion',
      npcName: 'Maya Reed',
      npcRole: 'CEO',
      briefing:
          'Should we enter a new market? Size demand, cost, risk, and projected revenue. Present to execs.',
      objective: 'Build a go/no-go recommendation with risk tradeoffs.',
      checklist: <String>['Market size', 'Risks', 'Present'],
      xpReward: 180,
      badgeReward: 'Strategy Badge',
    ),
    ProMission(
      id: 'run_company',
      icon: '👑',
      title: 'Run the Company',
      blurb: 'Boss Mission',
      npcName: 'Board',
      npcRole: 'Directors',
      briefing:
          'You are Acting Manager for multiple quarters. Shocks will hit. Adapt.',
      objective: 'Survive 4 simulated quarters with balanced meters.',
      checklist: <String>['Period 1', 'Shock event', 'Adapt', 'Report'],
      xpReward: 250,
      badgeReward: 'Acting Manager',
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
      'Revenue',
      'Profit',
      'Customers',
      'Market share',
      'Cash',
      'Brand',
    ]) {
      _store.meters.putIfAbsent(k, () => 50);
    }
    if (mounted) setState(() => _ready = true);
  }

  Widget _workspace() {
    switch (_mission) {
      case 'sales_drop':
        return BusinessSalesDropMission(
          store: _store,
          onComplete: () => setState(() {}),
        );
      case 'employee_crisis':
        return _PracticalLaunch(
          theme: t,
          title: 'Employee Crisis Practical',
          body: _missions.firstWhere((ProMission m) => m.id == _mission).briefing,
          onOpen: () => UniversityPracticalLabScreen.open(
            context,
            mission: UniversityPracticalCatalog.business,
          ),
        );
      case 'expansion':
        return _PracticalLaunch(
          theme: t,
          title: 'Market Expansion Practical',
          body: _missions.firstWhere((ProMission m) => m.id == _mission).briefing,
          onOpen: () => UniversityPracticalLabScreen.open(
            context,
            mission: UniversityPracticalCatalog.economics,
          ),
        );
      case 'run_company':
        return _PracticalLaunch(
          theme: t,
          title: 'Acting Manager Practical',
          body: _missions.firstWhere((ProMission m) => m.id == _mission).briefing,
          onOpen: () => UniversityPracticalLabScreen.open(
            context,
            mission: UniversityPracticalCatalog.business,
          ),
        );
      default:
        return _PracticalLaunch(
          theme: t,
          title: _missions.firstWhere((ProMission m) => m.id == _mission).title,
          body: _missions.firstWhere((ProMission m) => m.id == _mission).briefing,
          onOpen: () => UniversityPracticalLabScreen.open(
            context,
            mission: UniversityPracticalCatalog.business,
          ),
        );
    }
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
      workspace: _workspace(),
      meterLabels: const <String>[
        'Revenue',
        'Profit',
        'Customers',
        'Market share',
        'Cash',
        'Brand',
      ],
    );
  }
}

class _PracticalLaunch extends StatelessWidget {
  const _PracticalLaunch({
    required this.theme,
    required this.title,
    required this.body,
    required this.onOpen,
  });

  final ProSimTheme theme;
  final String title;
  final String body;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: theme.accent,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onOpen,
              style: FilledButton.styleFrom(backgroundColor: theme.accent),
              child: const Text(
                'ENTER BOARD PRACTICAL',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF04110C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
