import 'package:flutter/material.dart';

import '../chemistry/chemistry_lab_home.dart';
import '../physics/physics_lab_home.dart';
import '../shared/science_badges.dart';
import '../shared/science_hub_screen.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_screen.dart';
import '../shared/science_notebook_store.dart';
import '../../../../labs/university_lab_result.dart';
import 'biology_anatomy_3d_lab.dart';
import 'biology_boss_mystery.dart';
import 'biology_cell_diagram_lab.dart';
import 'biology_ecology_lab.dart';
import 'biology_experiment_notebook_flow.dart';
import 'biology_genetics_lab.dart';
import 'biology_heart_lab.dart';
import 'biology_microscope_lab.dart';

class BiologyLabHomeScreen extends StatefulWidget {
  const BiologyLabHomeScreen({super.key, this.initialStationId});

  /// Deep-link from lecture completion (e.g. `cell`, `microscope`, `lab_bench`).
  final String? initialStationId;

  @override
  State<BiologyLabHomeScreen> createState() => _BiologyLabHomeScreenState();
}

class _BiologyLabHomeScreenState extends State<BiologyLabHomeScreen> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  final ScienceNotebookStore _store = ScienceNotebookStore('biology');
  bool _ready = false;
  late String _id;
  ScienceLabMode _mode = ScienceLabMode.experiment;

  static const List<ScienceHubStation> _stations = <ScienceHubStation>[
    ScienceHubStation(
      id: 'microscope',
      icon: '🔬',
      title: 'Microscope',
      blurb: 'Microscope',
      missionNumber: 'Mission 01',
      mission:
          'Bring an unknown slide into focus, identify tissue, mark the nucleus, log observations.',
      checklist: <String>[
        'Focus the specimen',
        'Mark the nucleus',
        'Identify tissue type',
        'Record observation',
      ],
      xpReward: 150,
      badgeReward: 'Master Microscopist',
    ),
    ScienceHubStation(
      id: 'cell',
      icon: '🦠',
      title: 'Animal Cell Investigation',
      blurb: 'Cell Lab',
      missionNumber: 'Mission 02',
      mission:
          'Label organelles on the cell diagram. Use the word bank, then annotate notes on the image.',
      checklist: <String>[
        'Open LABEL mode',
        'Place all organelles',
        'Check labels',
        'Annotate observations',
      ],
      xpReward: 150,
      coinReward: 3,
      badgeReward: 'Cell Expert Badge',
    ),
    ScienceHubStation(
      id: 'genetics',
      icon: '🧬',
      title: 'Genetics',
      blurb: 'Genetics',
      missionNumber: 'Mission 03',
      mission: 'Build complementary DNA, complete a Punnett square, report phenotype %.',
      checklist: <String>['Pair bases', 'Complete Punnett', 'Report phenotype %'],
      xpReward: 160,
      badgeReward: 'Genetics Badge',
    ),
    ScienceHubStation(
      id: 'anatomy_3d',
      icon: '🦴',
      title: 'Clinical Viva · 3D',
      blurb: 'Clinical Practical',
      missionNumber: 'Mission 04b',
      mission:
          'Patient case → required view → diagnose structure → clinical WHY score → labels.',
      checklist: <String>[
        'Accept ED chart',
        'Orbit required views',
        'Clinical viva diagnose',
        'Label drill + submit',
      ],
      xpReward: 175,
      badgeReward: 'Clinical Anatomist',
    ),
    ScienceHubStation(
      id: 'anatomy',
      icon: '❤️',
      title: 'Anatomy',
      blurb: 'Anatomy',
      missionNumber: 'Mission 04',
      mission: 'Label chambers and vessels on a real heart plate. PHOTO · DIAGRAM · ANNOTATE.',
      checklist: <String>['Study PHOTO', 'Switch DIAGRAM', 'Label structures', 'Annotate'],
      xpReward: 170,
      badgeReward: 'Anatomy Badge',
    ),
    ScienceHubStation(
      id: 'ecology',
      icon: '🌿',
      title: 'Ecology',
      blurb: 'Ecology',
      missionNumber: 'Mission 05',
      mission: 'Tune environment variables, RUN the sim, explain population change.',
      checklist: <String>['Set variables', 'Predict', 'RUN', 'Explain graph'],
      xpReward: 160,
      badgeReward: 'Ecosystem Watcher',
    ),
    ScienceHubStation(
      id: 'lab_bench',
      icon: '🧴',
      title: 'Dissection',
      blurb: 'Dissection',
      missionNumber: 'Mission 06',
      mission: 'Full investigation write-up: question → hypothesis → data → conclusion.',
      checklist: <String>['Question', 'Hypothesis', 'Procedure', 'Conclusion'],
      xpReward: 180,
      badgeReward: 'Hypothesis Hero',
    ),
    ScienceHubStation(
      id: 'data',
      icon: '📊',
      title: 'Data & Graphs',
      blurb: 'Data & Graphs',
      missionNumber: 'Station',
      mission: 'Review logged tables, graphs, and conclusions.',
      checklist: <String>['Open tables', 'Review graphs', 'Read conclusions'],
      xpReward: 80,
      badgeReward: 'Data Badge',
    ),
    ScienceHubStation(
      id: 'notebook',
      icon: '📓',
      title: 'Lab Notebook',
      blurb: 'Lab Notebook',
      missionNumber: 'Notebook',
      mission: 'Permanent record of notes, diagrams, XP, and badges.',
      checklist: <String>['Review notes', 'Review diagrams'],
      xpReward: 40,
      badgeReward: 'Notebook',
    ),
    ScienceHubStation(
      id: 'boss',
      icon: '❓',
      title: 'Quests',
      blurb: 'Quests',
      missionNumber: 'Mission 07',
      mission: 'Mystery specimen — limited tests, evidence-based ID. No reveal.',
      checklist: <String>['Run tests', 'Eliminate options', 'Identify specimen'],
      xpReward: 220,
      badgeReward: 'Quest Badge',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final String? initial = widget.initialStationId?.trim();
    _id = (initial != null && initial.isNotEmpty) ? initial : 'cell';
    _boot();
  }

  Future<void> _boot() async {
    await _store.ensureLoaded();
    if (!mounted) return;
    setState(() => _ready = true);
    final String? initial = widget.initialStationId?.trim();
    if (initial != null &&
        initial.isNotEmpty &&
        _id != 'cell' &&
        _id != 'anatomy' &&
        _id != 'anatomy_3d' &&
        _id != 'notebook') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFullscreen();
      });
    }
  }

  Future<void> _completeStation(String id, {int xp = 25, int coins = 3}) async {
    await _store.markComplete(id);
    await _store.awardXp(xp, coins: coins);
    if (id == 'cell' || id == 'anatomy') {
      await _store.unlockBadge(ScienceBadges.cellCartographer);
    }
    if (id == 'anatomy_3d') {
      await _store.unlockBadge(ScienceBadges.cellCartographer);
    }
    if (id == 'microscope') {
      await _store.unlockBadge(ScienceBadges.masterMicroscopist);
    }
    if (id == 'ecology') {
      await _store.unlockBadge(ScienceBadges.ecosystemWatcher);
    }
    await _store.ensureLoaded();
    if (mounted) setState(() {});
  }

  Widget _workspace() {
    switch (_id) {
      case 'cell':
        return BiologyCellDiagramLab(
          embedded: true,
          notebook: _store,
          onComplete: () => _completeStation('cell'),
        );
      case 'anatomy':
        return BiologyHeartLab(
          embedded: true,
          notebook: _store,
          onComplete: () => _completeStation('anatomy'),
        );
      case 'anatomy_3d':
        return BiologyAnatomy3dLab(
          embedded: true,
          diagramId: 'skeleton',
          missionMode: true,
          onComplete: () => _completeStation('anatomy_3d', xp: 175, coins: 8),
        );
      default:
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
  }

  Widget _fullPage(String id) {
    switch (id) {
      case 'lab_bench':
        return const BiologyExperimentNotebookFlow();
      case 'microscope':
        return const BiologyMicroscopeLab();
      case 'genetics':
        return const BiologyGeneticsLab();
      case 'cell':
        return BiologyCellDiagramLab(notebook: _store);
      case 'anatomy':
        return BiologyHeartLab(notebook: _store);
      case 'anatomy_3d':
        return const BiologyAnatomy3dLab(
          diagramId: 'skeleton',
          missionMode: true,
        );
      case 'ecology':
        return const BiologyEcologyLab();
      case 'data':
        return _DataBay(store: _store);
      case 'boss':
        return const BiologyBossMystery();
      default:
        return const BiologyMicroscopeLab();
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
    final Object? raw = await Navigator.of(context).push<Object>(
      MaterialPageRoute<Object>(builder: (_) => _fullPage(id)),
    );
    if (raw == true || raw is UniversityLabResult) {
      final int xp = raw is UniversityLabResult
          ? raw.xpEarned
          : (id == 'anatomy_3d' ? 175 : 25);
      await _completeStation(
        id,
        xp: xp,
        coins: id == 'anatomy_3d' ? 8 : 3,
      );
    }
  }

  void _switchSubject(String id) {
    if (id == 'biology') return;
    final Widget page = id == 'chemistry'
        ? const ChemistryLabHome()
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
      subjectId: 'biology',
      tagline: 'EXPLORE · INVESTIGATE · DISCOVER',
      skillLabels: const <String>[
        'Observation',
        'Knowledge',
        'Accuracy',
        'Analysis',
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
        ScienceBadges.masterMicroscopist,
        ScienceBadges.cellCartographer,
        ScienceBadges.ecosystemWatcher,
        ScienceBadges.hypothesisHero,
      ],
    );
  }
}

class _DataBay extends StatelessWidget {
  const _DataBay({required this.store});
  final ScienceNotebookStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1320),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121C2E),
        foregroundColor: Colors.white,
        title: const Text('Biology Lab  ›  Data & Graphs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Tables: ${store.dataTables.length} · Graphs: ${store.graphsMeta.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (store.dataTables.isEmpty && store.graphsMeta.isEmpty)
            const Text(
              'No data yet. Complete Lab Bench or Ecology first.',
              style: TextStyle(color: Colors.white70),
            ),
          ...store.conclusions.map(
            (String c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(c, style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }
}
