import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_hub_screen.dart';
import '../shared/professional_theme.dart';
import 'marketing_campaign_mission.dart';

class MarketingProHome extends StatefulWidget {
  const MarketingProHome({super.key});

  @override
  State<MarketingProHome> createState() => _MarketingProHomeState();
}

class _MarketingProHomeState extends State<MarketingProHome> {
  static const ProSimTheme t = ProSimTheme.marketing;
  final ProCaseStore _store = ProCaseStore('marketing');
  bool _ready = false;
  String _dept = 'client';
  String _mission = 'campaign';

  static const List<ProDept> _depts = <ProDept>[
    ProDept(id: 'lobby', icon: '🏛️', title: 'Agency Lobby', blurb: 'Lobby'),
    ProDept(id: 'client', icon: '🤝', title: 'Client Room', blurb: 'Client'),
    ProDept(id: 'strategy', icon: '♟️', title: 'Strategy Room', blurb: 'Strategy'),
    ProDept(id: 'studio', icon: '🎨', title: 'Creative Studio', blurb: 'Studio'),
    ProDept(id: 'analytics', icon: '📊', title: 'Analytics Dashboard', blurb: 'Analytics'),
    ProDept(id: 'campaign', icon: '🚀', title: 'Campaign Workspace', blurb: 'Campaign'),
    ProDept(id: 'present', icon: '🎤', title: 'Presentation Room', blurb: 'Pitch'),
  ];

  static const List<ProMission> _missions = <ProMission>[
    ProMission(
      id: 'campaign',
      icon: '📣',
      title: 'Interview · Build · Launch · Rescue',
      blurb: 'Campaign',
      npcName: 'Sol Rivera',
      npcRole: 'Client',
      briefing:
          'Interview the client, build persona + campaign, launch, read analytics, optimize.',
      objective: 'Evidence-based campaign with rescue optimization and ROI lift.',
      checklist: <String>[
        'Interview client',
        'Build campaign',
        'Launch',
        'Optimize',
      ],
      xpReward: 160,
      badgeReward: 'Strategist Badge',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _store.ensureLoaded();
    for (final String k in <String>['Impressions', 'CTR', 'Conversions', 'ROI']) {
      _store.meters.putIfAbsent(k, () => 40);
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
      meterLabels: const <String>['Impressions', 'CTR', 'Conversions', 'ROI'],
      workspace: MarketingCampaignMission(
        store: _store,
        onComplete: () => setState(() {}),
      ),
    );
  }
}
