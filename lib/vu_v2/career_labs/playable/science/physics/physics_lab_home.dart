import 'package:flutter/material.dart';

import '../biology/biology_lab_home.dart';
import '../chemistry/chemistry_lab_home.dart';
import '../shared/science_badges.dart';
import '../shared/science_hub_screen.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_screen.dart';
import '../shared/science_notebook_store.dart';
import 'physics_boss_rescue.dart';
import 'physics_circuit_lab.dart';
import 'physics_force_diagram_lab.dart';
import 'physics_graph_predict.dart';
import 'physics_motion_lab.dart';
import 'physics_optics_lab.dart';
import 'physics_projectile_lab.dart';
import 'physics_wave_lab.dart';

Widget physicsScienceLabScreen() => const PhysicsLabHome();

class PhysicsLabHome extends StatefulWidget {
  const PhysicsLabHome({super.key, this.initialStationId});

  final String? initialStationId;

  @override
  State<PhysicsLabHome> createState() => _PhysicsLabHomeState();
}

class _PhysicsLabHomeState extends State<PhysicsLabHome> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');
  bool _ready = false;
  late String _id;
  ScienceLabMode _mode = ScienceLabMode.experiment;

  static const List<ScienceHubStation> _stations = <ScienceHubStation>[
    ScienceHubStation(
      id: 'motion',
      icon: '🏎️',
      title: 'Motion',
      blurb: 'Motion',
      missionNumber: 'Mission 01',
      mission: 'Tune force, mass, and friction. RUN the cart and explain the graphs.',
      checklist: <String>['Set variables', 'RUN', 'Explain graphs'],
      xpReward: 150,
      badgeReward: 'Motion Badge',
    ),
    ScienceHubStation(
      id: 'forces',
      icon: '↗️',
      title: 'Forces',
      blurb: 'Forces',
      missionNumber: 'Mission 02',
      mission: 'Place weight, normal, friction, and applied-force arrows.',
      checklist: <String>['Draw forces', 'Check directions', 'Submit'],
      xpReward: 160,
      badgeReward: 'Force Mapper',
    ),
    ScienceHubStation(
      id: 'electricity',
      icon: '🔌',
      title: 'Electricity',
      blurb: 'Electricity',
      missionNumber: 'Mission 03',
      mission: 'Build a circuit until the bulb lights. Troubleshoot connections.',
      checklist: <String>['Place components', 'Wire circuit', 'Test bulb'],
      xpReward: 170,
      badgeReward: 'Circuit Badge',
    ),
    ScienceHubStation(
      id: 'waves',
      icon: '🌊',
      title: 'Waves',
      blurb: 'Waves',
      missionNumber: 'Mission 04',
      mission: 'Control amplitude and frequency. Measure wavelength. Label crest/trough.',
      checklist: <String>['Set A & f', 'Measure λ', 'Label wave'],
      xpReward: 150,
      badgeReward: 'Waves Badge',
    ),
    ScienceHubStation(
      id: 'optics',
      icon: '🔭',
      title: 'Optics',
      blurb: 'Optics',
      missionNumber: 'Mission 05',
      mission: 'Move light, lens, and screen until you get a focused image.',
      checklist: <String>['Place optics', 'Focus image', 'Record setup'],
      xpReward: 160,
      badgeReward: 'Optics Badge',
    ),
    ScienceHubStation(
      id: 'energy',
      icon: '🚀',
      title: 'Projectile Motion',
      blurb: 'Projectile',
      missionNumber: 'Mission 06',
      mission:
          'Set angle, velocity, and gravity. Launch. Hit the target.',
      checklist: <String>[
        'Set launch conditions',
        'Predict path',
        'Launch projectile',
        'Analyze results',
      ],
      xpReward: 200,
      coinReward: 5,
      badgeReward: 'Physics Ranger Badge',
    ),
    ScienceHubStation(
      id: 'data',
      icon: '📈',
      title: 'Data & Graphs',
      blurb: 'Data & Graphs',
      missionNumber: 'Station',
      mission: 'Predict v–t shape BEFORE the run, then compare to measured.',
      checklist: <String>['Predict', 'Run', 'Compare'],
      xpReward: 120,
      badgeReward: 'Data Badge',
    ),
    ScienceHubStation(
      id: 'notebook',
      icon: '📓',
      title: 'Lab Notebook',
      blurb: 'Lab Notebook',
      missionNumber: 'Notebook',
      mission: 'Review logged runs, XP, and physics badges.',
      checklist: <String>['Review runs'],
      xpReward: 40,
      badgeReward: 'Notebook',
    ),
    ScienceHubStation(
      id: 'boss',
      icon: '⚙️',
      title: 'Quests',
      blurb: 'Quests',
      missionNumber: 'Mission 07',
      mission: '40 m rescue launch. Miss → analyze → retry.',
      checklist: <String>['Model', 'Launch', 'Improve'],
      xpReward: 250,
      badgeReward: 'Physics Engineer',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final String? initial = widget.initialStationId?.trim();
    String id = (initial != null && initial.isNotEmpty) ? initial : 'energy';
    if (id == 'projectile') id = 'energy';
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
        _id != 'energy' &&
        _id != 'notebook') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFullscreen();
      });
    }
  }

  Future<void> _completeStation(String id) async {
    await _store.markComplete(id);
    await _store.awardXp(25, coins: 3);
    if (id == 'forces') {
      await _store.unlockBadge(ScienceBadges.forceMapper);
    }
    if (id == 'energy') {
      await _store.unlockBadge(ScienceBadges.trajectoryAce);
    }
    if (id == 'boss') {
      await _store.unlockBadge(ScienceBadges.physicsEngineer);
    }
    await _store.ensureLoaded();
    if (mounted) setState(() {});
  }

  Widget _workspace() {
    if (_id == 'energy') {
      return PhysicsProjectileLab(
        embedded: true,
        onComplete: () => _completeStation('energy'),
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
      case 'motion':
        return const PhysicsMotionLab();
      case 'forces':
        return const PhysicsForceDiagramLab();
      case 'electricity':
        return const PhysicsCircuitLab();
      case 'waves':
        return const PhysicsWaveLab();
      case 'optics':
        return const PhysicsOpticsLab();
      case 'energy':
        return const PhysicsProjectileLab();
      case 'data':
        return const PhysicsGraphPredictLab();
      case 'boss':
        return const PhysicsBossRescue();
      default:
        return const PhysicsProjectileLab();
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
    if (id == 'physics') return;
    final Widget page = id == 'biology'
        ? const BiologyLabHomeScreen()
        : const ChemistryLabHome();
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
      subjectId: 'physics',
      tagline: 'EXPERIMENT · MODEL · UNDERSTAND · APPLY',
      skillLabels: const <String>[
        'Experimentation',
        'Analysis',
        'Calculation',
        'Critical Thinking',
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
        ScienceBadges.forceMapper,
        ScienceBadges.trajectoryAce,
        ScienceBadges.physicsEngineer,
      ],
    );
  }
}
