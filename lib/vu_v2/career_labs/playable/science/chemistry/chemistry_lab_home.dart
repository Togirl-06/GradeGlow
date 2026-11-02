import 'package:flutter/material.dart';

import '../biology/biology_lab_home.dart';
import '../physics/physics_lab_home.dart';
import '../shared/science_badges.dart';
import '../shared/science_hub_screen.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_screen.dart';
import '../shared/science_notebook_store.dart';
import 'chemistry_boss_unknown.dart';
import 'chemistry_data_lab.dart';
import 'chemistry_equipment_label.dart';
import 'chemistry_heating_lab.dart';
import 'chemistry_measurement_lab.dart';
import 'chemistry_molecular_builder.dart';
import 'chemistry_reaction_lab.dart';
import 'chemistry_titration_lab.dart';

Widget chemistryScienceLabScreen() => const ChemistryLabHome();

class ChemistryLabHome extends StatefulWidget {
  const ChemistryLabHome({super.key, this.initialStationId});

  final String? initialStationId;

  @override
  State<ChemistryLabHome> createState() => _ChemistryLabHomeState();
}

class _ChemistryLabHomeState extends State<ChemistryLabHome> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');
  bool _ready = false;
  late String _id;
  ScienceLabMode _mode = ScienceLabMode.experiment;

  static const List<ScienceHubStation> _stations = <ScienceHubStation>[
    ScienceHubStation(
      id: 'bench',
      icon: '🧴',
      title: 'Lab Bench',
      blurb: 'Lab Bench',
      missionNumber: 'Mission 01',
      mission: 'Name each piece of glassware and write what it is used for.',
      checklist: <String>['Identify glassware', 'Write uses', 'Submit'],
      xpReward: 140,
      badgeReward: 'Bench Badge',
    ),
    ScienceHubStation(
      id: 'reactions',
      icon: '🔥',
      title: 'Reactions',
      blurb: 'Reactions',
      missionNumber: 'Mission 02',
      mission: 'Combine reactants. Observe color, gas, precipitate. Write CER.',
      checklist: <String>['Mix', 'Observe', 'Record CER'],
      xpReward: 160,
      badgeReward: 'Reactions Badge',
    ),
    ScienceHubStation(
      id: 'molecules',
      icon: '⚛️',
      title: 'Molecules',
      blurb: 'Molecules',
      missionNumber: 'Mission 03',
      mission: 'Build methane and water. Check valence.',
      checklist: <String>['Place atoms', 'Add bonds', 'Check valence'],
      xpReward: 160,
      badgeReward: 'Bond Builder',
    ),
    ScienceHubStation(
      id: 'balance',
      icon: '⚖️',
      title: 'Measurements',
      blurb: 'Measurements',
      missionNumber: 'Mission 04',
      mission: 'Tare, weigh, and log mass precisely.',
      checklist: <String>['Tare', 'Weigh', 'Log mass'],
      xpReward: 140,
      badgeReward: 'Measurement Badge',
    ),
    ScienceHubStation(
      id: 'titration',
      icon: '💧',
      title: 'Acid-Base Titration',
      blurb: 'Titration',
      missionNumber: 'Mission 05',
      mission:
          'Fill the burette, add indicator, drip to pale pink, record volumes, calculate molarity.',
      checklist: <String>[
        'Fill burette',
        'Add indicator',
        'Perform titration',
        'Calculate molarity',
      ],
      xpReward: 180,
      coinReward: 4,
      badgeReward: 'Analyst Badge',
    ),
    ScienceHubStation(
      id: 'heating',
      icon: '🕯️',
      title: 'Thermochemistry',
      blurb: 'Thermochemistry',
      missionNumber: 'Mission 06',
      mission: 'Heat a sample, watch temperature change, explain energy transfer.',
      checklist: <String>['Heat sample', 'Record ΔT', 'Explain'],
      xpReward: 160,
      badgeReward: 'Thermo Badge',
    ),
    ScienceHubStation(
      id: 'data',
      icon: '📊',
      title: 'Data & Graphs',
      blurb: 'Data & Graphs',
      missionNumber: 'Station',
      mission: 'Enter measurements, choose a graph, write a conclusion.',
      checklist: <String>['Enter data', 'Graph', 'Conclude'],
      xpReward: 90,
      badgeReward: 'Data Badge',
    ),
    ScienceHubStation(
      id: 'notebook',
      icon: '📓',
      title: 'Lab Notebook',
      blurb: 'Lab Notebook',
      missionNumber: 'Notebook',
      mission: 'Review notes, XP, and chemistry badges.',
      checklist: <String>['Review notes'],
      xpReward: 40,
      badgeReward: 'Notebook',
    ),
    ScienceHubStation(
      id: 'boss',
      icon: '❓',
      title: 'Quests',
      blurb: 'Quests',
      missionNumber: 'Mission 07',
      mission: 'Limited tests. Eliminate possibilities. Identify the unknown.',
      checklist: <String>['Choose tests', 'Eliminate', 'Identify'],
      xpReward: 220,
      badgeReward: 'Molecular Detective',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final String? initial = widget.initialStationId?.trim();
    String id = (initial != null && initial.isNotEmpty) ? initial : 'titration';
    if (id == 'reaction') id = 'reactions';
    _id = id;
    _boot();
  }

  Future<void> _boot() async {
    await _store.ensureLoaded();
    if (!mounted) return;
    setState(() => _ready = true);
    final String? initial = widget.initialStationId?.trim();
    if (initial != null &&
        initial.isNotEmpty &&
        _id != 'titration' &&
        _id != 'notebook') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFullscreen();
      });
    }
  }

  Future<void> _completeStation(String id) async {
    await _store.markComplete(id);
    await _store.awardXp(25, coins: 3);
    if (id == 'titration') {
      await _store.unlockBadge(ScienceBadges.titrationAce);
    }
    if (id == 'molecules') {
      await _store.unlockBadge(ScienceBadges.bondBuilder);
    }
    if (id == 'boss') {
      await _store.unlockBadge(ScienceBadges.molecularDetective);
    }
    await _store.ensureLoaded();
    if (mounted) setState(() {});
  }

  Widget _workspace() {
    if (_id == 'titration') {
      return ChemistryTitrationLab(
        embedded: true,
        onComplete: () => _completeStation('titration'),
      );
    }
    final ScienceHubStation s = _stations.firstWhere(
      (ScienceHubStation x) => x.id == _id,
      orElse: () => _stations.first,
    );
    return ScienceStationPreview(
      theme: t,
      icon: s.icon,
      title: s.title,
      body: s.mission,
      onOpen: _openFullscreen,
    );
  }

  Widget _fullPage(String id) {
    switch (id) {
      case 'bench':
        return const ChemistryEquipmentLabelLab();
      case 'reactions':
        return const ChemistryReactionLab();
      case 'molecules':
        return const ChemistryMolecularBuilder();
      case 'balance':
        return const ChemistryMeasurementLab();
      case 'heating':
        return const ChemistryHeatingLab();
      case 'titration':
        return const ChemistryTitrationLab();
      case 'data':
        return const ChemistryDataLab();
      case 'boss':
        return const ChemistryBossUnknown();
      default:
        return const ChemistryTitrationLab();
    }
  }

  Future<void> _openFullscreen() async {
    final String id = _id;
    if (id == 'notebook') {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ScienceNotebookScreen(theme: t, store: _store),
        ),
      );
      return;
    }
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => _fullPage(id)),
    );
    if (ok == true) await _completeStation(id);
  }

  void _switchSubject(String id) {
    if (id == 'chemistry') return;
    final Widget page = id == 'biology'
        ? const BiologyLabHomeScreen()
        : const PhysicsLabHome();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: t.bg,
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      );
    }
    return ScienceLabHubScreen(
      theme: t,
      store: _store,
      subjectId: 'chemistry',
      tagline: 'MEASURE · MIX · ANALYZE · INNOVATE',
      skillLabels: const <String>[
        'Lab Technique',
        'Calculations',
        'Problem Solving',
        'Understanding',
      ],
      stations: _stations,
      selectedId: _id,
      onSelect: (String id) => setState(() => _id = id),
      onContinue: _openFullscreen,
      workspace: _workspace(),
      mode: _mode,
      onModeChanged: (ScienceLabMode m) => setState(() => _mode = m),
      onSwitchSubject: _switchSubject,
      badgeIds: const <String>[
        ScienceBadges.titrationAce,
        ScienceBadges.bondBuilder,
        ScienceBadges.molecularDetective,
      ],
    );
  }
}
