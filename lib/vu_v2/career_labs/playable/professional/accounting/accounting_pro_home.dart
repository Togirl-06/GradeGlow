import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_hub_screen.dart';
import '../shared/professional_theme.dart';
import 'accounting_audit_mission.dart';

class AccountingProHome extends StatefulWidget {
  const AccountingProHome({super.key});

  @override
  State<AccountingProHome> createState() => _AccountingProHomeState();
}

class _AccountingProHomeState extends State<AccountingProHome> {
  static const ProSimTheme t = ProSimTheme.accounting;
  final ProCaseStore _store = ProCaseStore('accounting');
  bool _ready = false;
  String _dept = 'floor';
  String _mission = 'audit';

  static const List<ProDept> _depts = <ProDept>[
    ProDept(id: 'floor', icon: '🏢', title: 'Accounting Floor', blurb: 'Floor'),
    ProDept(id: 'client', icon: '🗂️', title: 'Client Workspace', blurb: 'Client'),
    ProDept(id: 'ledger', icon: '📘', title: 'General Ledger', blurb: 'Ledger'),
    ProDept(id: 'statements', icon: '📑', title: 'Statement Center', blurb: 'Statements'),
    ProDept(id: 'audit', icon: '🔎', title: 'Audit Room', blurb: 'Audit'),
    ProDept(id: 'archive', icon: '🗄️', title: 'Document Archive', blurb: 'Archive'),
    ProDept(id: 'partner', icon: '🚪', title: "Partner's Office", blurb: 'Partner'),
  ];

  static const List<ProMission> _missions = <ProMission>[
    ProMission(
      id: 'audit',
      icon: '🧾',
      title: 'Classify · Journal · Find Discrepancy',
      blurb: 'The Audit',
      npcName: 'Helen Moss',
      npcRole: 'Partner',
      briefing:
          'Client statements don’t balance. Classify documents, post a balanced entry, trace the error.',
      objective: 'Correct classification + balanced JE + identify misclassified draw.',
      checklist: <String>[
        'Classify docs',
        'Post journal entry',
        'Trace audit trail',
        'Submit findings',
      ],
      xpReward: 170,
      badgeReward: 'Audit Badge',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _store.ensureLoaded();
    for (final String k in <String>['Accuracy', 'Balance', 'Trail completeness']) {
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
      meterLabels: const <String>['Accuracy', 'Balance', 'Trail completeness'],
      workspace: AccountingAuditMission(
        store: _store,
        onComplete: () => setState(() {}),
      ),
    );
  }
}
