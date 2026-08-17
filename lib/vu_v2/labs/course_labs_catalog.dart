import 'package:flutter/material.dart';

import '../career_labs/playable/playable_router.dart';
import '../career_labs/playable/science/biology/anatomy_3d_viewer_screen.dart';
import '../career_labs/playable/science/biology/biology_anatomy_3d_lab.dart';
import '../career_labs/playable/science/biology/biology_lab_home.dart';
import '../career_labs/playable/science/biology/clinical_viva_quiz_screen.dart';
import '../career_labs/playable/science/chemistry/chemistry_lab_home.dart';
import '../career_labs/playable/science/physics/physics_lab_home.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../../data/university_learning_engine.dart';
import 'simulation/university_sim_flow.dart';
import 'university_practical/practical_catalog.dart';
import 'university_practical/practical_mission.dart';
import 'vu_v2_cs_coding_arena.dart';
import 'winning_career_showcases.dart';
import 'winning_major_showcases.dart';
import 'workplace_immersion.dart';

/// One openable lab inside a course (students get several per major).
class CourseLabEntry {
  const CourseLabEntry({
    required this.id,
    required this.courseId,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.open,
  });

  final String id;
  final String courseId;
  final String emoji;
  final String title;
  final String subtitle;
  final Future<void> Function(BuildContext context) open;
}

/// Multiple working labs for every major — not one showcase and done.
abstract final class CourseLabsCatalog {
  static List<CourseLabEntry> forMajor(String majorId) {
    final String m = majorId.toLowerCase();
    if (m.contains('bio')) return biology;
    if (m.contains('chem')) return chemistry;
    if (m.contains('phys')) return physics;
    if (m == 'cs' ||
        m.startsWith('cs_') ||
        m.contains('computer') ||
        m.contains('software') ||
        m.contains('data_science') ||
        m.contains('artificial') ||
        m.contains('web_dev')) {
      return computerScience;
    }
    if (m.contains('law')) return law;
    if (m.contains('engin') || m.contains('civil') || m.contains('electric')) {
      return engineering;
    }
    if (m.contains('nurs')) return nursing;
    if (m.contains('medicine') || m == 'med') return medicine;
    if (m.contains('bus')) return business;
    if (m.contains('fin')) return finance;
    if (m.contains('account')) return accounting;
    if (m.contains('market')) return marketing;
    if (m.contains('econ')) return economics;
    if (m.contains('pharm')) return pharmacy;
    if (m.contains('mls') || m.contains('lab_science') || m.contains('medical_lab')) {
      return mls;
    }
    if (m.contains('psych')) return psychology;
    if (m.contains('math')) return mathematics;
    if (m.contains('cyber')) return cybersecurity;
    return const <CourseLabEntry>[];
  }

  static Future<void> openCoursePicker(
    BuildContext context, {
    required String majorId,
    VuV2Session? session,
    VuV2ProgressStore? progress,
  }) async {
    final List<CourseLabEntry> labs = forMajor(majorId);
    if (labs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labs for this program are not ready yet.')),
        );
      }
      return;
    }
    if (labs.length == 1) {
      await labs.first.open(context);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0B1622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            shrinkWrap: true,
            children: <Widget>[
              const Text(
                'Choose a lab',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${labs.length} practicals available for this course',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 12),
              ...labs.map((CourseLabEntry lab) {
                return ListTile(
                  leading: Text(lab.emoji, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    lab.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    lab.subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    lab.open(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _push(BuildContext context, Widget screen) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  static Future<void> _practical(
    BuildContext context,
    UniversityPracticalMission mission,
  ) {
    final UniversityLabLink link = UniversityLabLink(
      labId: mission.courseId,
      stationId: 'practical',
      title: mission.title,
      purpose: mission.briefingBody,
      objectives: mission.steps.map((PracticalStep s) => s.phaseLabel).toList(),
      estimatedMinutes: 32,
      difficulty: 'Professional',
    );
    return UniversitySimulationFlow.open(
      context: context,
      link: link,
      subjectId: mission.courseId,
      courseTitle: mission.courseId,
      topicTitle: mission.title,
      level: 3,
    );
  }

  // ── Biology (5+) ──────────────────────────────────────────────────────────

  static final List<CourseLabEntry> biology = <CourseLabEntry>[
    CourseLabEntry(
      id: 'bio_viva_shoulder',
      courseId: 'biology',
      emoji: '🦴',
      title: 'Clinical Viva · Shoulder trauma',
      subtitle: 'Walk into Anatomy Theater → scapula case',
      open: (BuildContext c) => WorkplaceEntranceGate.openThen(
        c,
        kind: WorkplaceKind.anatomyTheater,
        builder: () => const BiologyAnatomy3dLab(
          caseId: 'shoulder_scapula',
          missionMode: true,
        ),
      ),
    ),
    CourseLabEntry(
      id: 'bio_viva_foosh',
      courseId: 'biology',
      emoji: '🖐️',
      title: 'Clinical Viva · FOOSH fracture',
      subtitle: 'Anatomy Theater → radius case',
      open: (BuildContext c) => WorkplaceEntranceGate.openThen(
        c,
        kind: WorkplaceKind.anatomyTheater,
        builder: () => const BiologyAnatomy3dLab(
          caseId: 'forearm_fall',
          missionMode: true,
        ),
      ),
    ),
    CourseLabEntry(
      id: 'bio_viva_heart',
      courseId: 'biology',
      emoji: '❤️',
      title: 'Clinical Viva · LV pump failure',
      subtitle: 'Anatomy Theater → heart case',
      open: (BuildContext c) => WorkplaceEntranceGate.openThen(
        c,
        kind: WorkplaceKind.anatomyTheater,
        builder: () => const BiologyAnatomy3dLab(
          caseId: 'lv_pump',
          missionMode: true,
        ),
      ),
    ),
    CourseLabEntry(
      id: 'bio_quiz',
      courseId: 'biology',
      emoji: '📝',
      title: 'Clinical Viva Quiz battery',
      subtitle: 'MCQs + live 3D diagnose items',
      open: (BuildContext c) => ClinicalVivaQuizScreen.open(c),
    ),
    CourseLabEntry(
      id: 'bio_viewers',
      courseId: 'biology',
      emoji: '🔄',
      title: '3D anatomy viewers',
      subtitle: 'Free orbit skeleton + heart, then launch cases',
      open: (BuildContext c) => Anatomy3dViewerHubScreen.open(c),
    ),
    CourseLabEntry(
      id: 'bio_microscope',
      courseId: 'biology',
      emoji: '🔬',
      title: 'Microscope station',
      subtitle: 'Focus, identify tissue, log observations',
      open: (BuildContext c) => _push(
        c,
        const BiologyLabHomeScreen(initialStationId: 'microscope'),
      ),
    ),
    CourseLabEntry(
      id: 'bio_cell',
      courseId: 'biology',
      emoji: '🦠',
      title: 'Animal cell investigation',
      subtitle: 'Label organelles on the cell diagram',
      open: (BuildContext c) => _push(
        c,
        const BiologyLabHomeScreen(initialStationId: 'cell'),
      ),
    ),
    CourseLabEntry(
      id: 'bio_genetics',
      courseId: 'biology',
      emoji: '🧬',
      title: 'Genetics station',
      subtitle: 'DNA pairing + Punnett square',
      open: (BuildContext c) => _push(
        c,
        const BiologyLabHomeScreen(initialStationId: 'genetics'),
      ),
    ),
  ];

  // ── Chemistry ─────────────────────────────────────────────────────────────

  static final List<CourseLabEntry> chemistry = <CourseLabEntry>[
    CourseLabEntry(
      id: 'chem_titration_board',
      courseId: 'chemistry',
      emoji: '🧪',
      title: 'Titration board practical',
      subtitle: 'Indicator → endpoint → equivalence viva',
      open: (BuildContext c) => WinningMajorShowcases.openChemistry(c),
    ),
    CourseLabEntry(
      id: 'chem_titration_bench',
      courseId: 'chemistry',
      emoji: '💧',
      title: 'Titration bench',
      subtitle: 'Hands-on titration station',
      open: (BuildContext c) => _push(
        c,
        const ChemistryLabHome(initialStationId: 'titration'),
      ),
    ),
    CourseLabEntry(
      id: 'chem_molecules',
      courseId: 'chemistry',
      emoji: '⚛️',
      title: 'Molecular builder',
      subtitle: 'Build bonds and structures',
      open: (BuildContext c) => _push(
        c,
        const ChemistryLabHome(initialStationId: 'molecules'),
      ),
    ),
    CourseLabEntry(
      id: 'chem_reactions',
      courseId: 'chemistry',
      emoji: '🔥',
      title: 'Reactions lab',
      subtitle: 'Mix, observe, explain',
      open: (BuildContext c) => _push(
        c,
        const ChemistryLabHome(initialStationId: 'reactions'),
      ),
    ),
    CourseLabEntry(
      id: 'chem_equipment',
      courseId: 'chemistry',
      emoji: '🧴',
      title: 'Equipment labeling',
      subtitle: 'Know your glassware before the board',
      open: (BuildContext c) => _push(
        c,
        const ChemistryLabHome(initialStationId: 'bench'),
      ),
    ),
    CourseLabEntry(
      id: 'chem_practical',
      courseId: 'chemistry',
      emoji: '📋',
      title: 'Unknown acid case practical',
      subtitle: 'Case → diagnose → WHY score',
      open: (BuildContext c) => _practical(c, UniversityPracticalCatalog.chemistry),
    ),
  ];

  // ── Physics ───────────────────────────────────────────────────────────────

  static final List<CourseLabEntry> physics = <CourseLabEntry>[
    CourseLabEntry(
      id: 'phys_energy_board',
      courseId: 'physics',
      emoji: '⚡',
      title: 'Energy board practical',
      subtitle: 'Model → conservation → defend WHY',
      open: (BuildContext c) => WinningMajorShowcases.openPhysics(c),
    ),
    CourseLabEntry(
      id: 'phys_energy',
      courseId: 'physics',
      emoji: '🎢',
      title: 'Energy / projectile bay',
      subtitle: 'Live energy bench',
      open: (BuildContext c) =>
          _push(c, const PhysicsLabHome(initialStationId: 'energy')),
    ),
    CourseLabEntry(
      id: 'phys_motion',
      courseId: 'physics',
      emoji: '🚀',
      title: 'Motion bay',
      subtitle: 'Kinematics station',
      open: (BuildContext c) =>
          _push(c, const PhysicsLabHome(initialStationId: 'motion')),
    ),
    CourseLabEntry(
      id: 'phys_electricity',
      courseId: 'physics',
      emoji: '💡',
      title: 'Electricity bay',
      subtitle: 'Circuits and current',
      open: (BuildContext c) =>
          _push(c, const PhysicsLabHome(initialStationId: 'electricity')),
    ),
    CourseLabEntry(
      id: 'phys_waves',
      courseId: 'physics',
      emoji: '🌊',
      title: 'Waves bay',
      subtitle: 'Wave bench practical',
      open: (BuildContext c) =>
          _push(c, const PhysicsLabHome(initialStationId: 'waves')),
    ),
    CourseLabEntry(
      id: 'phys_practical',
      courseId: 'physics',
      emoji: '📋',
      title: 'Mechanics case practical',
      subtitle: 'Case → diagnose → WHY score',
      open: (BuildContext c) => _practical(c, UniversityPracticalCatalog.physics),
    ),
  ];

  // ── CS ────────────────────────────────────────────────────────────────────

  static final List<CourseLabEntry> computerScience = <CourseLabEntry>[
    CourseLabEntry(
      id: 'cs_incident',
      courseId: 'computer_science',
      emoji: '🚨',
      title: 'Production incident practical',
      subtitle: 'Logs → fix → eng-review viva',
      open: (BuildContext c) => WinningCareerShowcases.openCs(c),
    ),
    CourseLabEntry(
      id: 'cs_arena_easy',
      courseId: 'computer_science',
      emoji: '💻',
      title: 'Coding Arena · Easy',
      subtitle: 'Warm-up problems',
      open: (BuildContext c) => _push(
        c,
        const VuV2CsCodingArenaScreen(
          title: 'Coding Arena · Easy',
          difficultyFilter: 'Easy',
        ),
      ),
    ),
    CourseLabEntry(
      id: 'cs_arena_medium',
      courseId: 'computer_science',
      emoji: '🧩',
      title: 'Coding Arena · Medium',
      subtitle: 'Standard interview pace',
      open: (BuildContext c) => _push(
        c,
        const VuV2CsCodingArenaScreen(
          title: 'Coding Arena · Medium',
          difficultyFilter: 'Medium',
        ),
      ),
    ),
    CourseLabEntry(
      id: 'cs_arena_hard',
      courseId: 'computer_science',
      emoji: '🔥',
      title: 'Coding Arena · Hard',
      subtitle: 'Stretch problems',
      open: (BuildContext c) => _push(
        c,
        const VuV2CsCodingArenaScreen(
          title: 'Coding Arena · Hard',
          difficultyFilter: 'Hard',
        ),
      ),
    ),
    CourseLabEntry(
      id: 'cs_floor',
      courseId: 'computer_science',
      emoji: '🏢',
      title: 'Full CS career floor',
      subtitle: 'Workplace simulation hub',
      open: (BuildContext c) =>
          WinningCareerShowcases.openFullWorkplace(c, 'cs_career'),
    ),
    CourseLabEntry(
      id: 'cs_practical',
      courseId: 'computer_science',
      emoji: '📋',
      title: 'Incident case practical',
      subtitle: 'Case → diagnose → WHY score',
      open: (BuildContext c) =>
          _practical(c, UniversityPracticalCatalog.computerScience),
    ),
  ];

  // ── Law / Eng ─────────────────────────────────────────────────────────────

  static final List<CourseLabEntry> law = <CourseLabEntry>[
    CourseLabEntry(
      id: 'law_case',
      courseId: 'law',
      emoji: '⚖️',
      title: 'Case file practical',
      subtitle: 'Evidence → timeline → partner viva',
      open: (BuildContext c) => WinningCareerShowcases.openLaw(c),
    ),
    CourseLabEntry(
      id: 'law_firm',
      courseId: 'law',
      emoji: '🏛️',
      title: 'Law firm floor',
      subtitle: 'Full workplace simulation',
      open: (BuildContext c) =>
          WinningCareerShowcases.openFullWorkplace(c, 'law_firm'),
    ),
    CourseLabEntry(
      id: 'law_practical',
      courseId: 'law',
      emoji: '📋',
      title: 'Issue-spotting practical',
      subtitle: 'Case → diagnose → WHY score',
      open: (BuildContext c) => _practical(c, UniversityPracticalCatalog.law),
    ),
  ];

  static final List<CourseLabEntry> engineering = <CourseLabEntry>[
    CourseLabEntry(
      id: 'eng_bridge',
      courseId: 'engineering',
      emoji: '🌉',
      title: 'Bridge load practical',
      subtitle: 'Design → load test → safety viva',
      open: (BuildContext c) => WinningCareerShowcases.openEngineering(c),
    ),
    CourseLabEntry(
      id: 'eng_studio',
      courseId: 'engineering',
      emoji: '🛠️',
      title: 'Engineering studio',
      subtitle: 'Full workplace floor',
      open: (BuildContext c) =>
          WinningCareerShowcases.openFullWorkplace(c, 'engineering'),
    ),
    CourseLabEntry(
      id: 'eng_civil',
      courseId: 'engineering',
      emoji: '🏗️',
      title: 'Civil engineering floor',
      subtitle: 'Civil workplace simulation',
      open: (BuildContext c) {
        final Widget? w = playableScreenFor('civil_engineering');
        if (w == null) {
          return WinningCareerShowcases.openEngineering(c);
        }
        return _push(c, w);
      },
    ),
    CourseLabEntry(
      id: 'eng_ee',
      courseId: 'engineering',
      emoji: '🔌',
      title: 'Electrical engineering floor',
      subtitle: 'EE workplace simulation',
      open: (BuildContext c) {
        final Widget? w = playableScreenFor('electrical_engineering');
        if (w == null) {
          return WinningCareerShowcases.openEngineering(c);
        }
        return _push(c, w);
      },
    ),
    CourseLabEntry(
      id: 'eng_practical',
      courseId: 'engineering',
      emoji: '📋',
      title: 'Load-path case practical',
      subtitle: 'Case → diagnose → WHY score',
      open: (BuildContext c) =>
          _practical(c, UniversityPracticalCatalog.engineering),
    ),
  ];

  // ── Health / business family ──────────────────────────────────────────────

  static List<CourseLabEntry> _proFamily({
    required String courseId,
    required String labId,
    required String emoji,
    required String boardTitle,
    required String boardSubtitle,
    required Future<void> Function(BuildContext) openBoard,
    required UniversityPracticalMission mission,
  }) {
    return <CourseLabEntry>[
      CourseLabEntry(
        id: '${courseId}_board',
        courseId: courseId,
        emoji: emoji,
        title: boardTitle,
        subtitle: boardSubtitle,
        open: openBoard,
      ),
      CourseLabEntry(
        id: '${courseId}_workplace',
        courseId: courseId,
        emoji: '🏢',
        title: 'Full workplace floor',
        subtitle: 'Multi-mission professional hub',
        open: (BuildContext c) {
          final Widget? w = playableScreenFor(labId);
          if (w == null) return openBoard(c);
          return _push(c, w);
        },
      ),
      CourseLabEntry(
        id: '${courseId}_case',
        courseId: courseId,
        emoji: '📋',
        title: 'Case practical',
        subtitle: 'Case → diagnose → professional WHY',
        open: (BuildContext c) => _practical(c, mission),
      ),
    ];
  }

  static final List<CourseLabEntry> nursing = <CourseLabEntry>[
    ..._proFamily(
      courseId: 'nursing',
      labId: 'nursing_ed',
      emoji: '🩺',
      boardTitle: 'ED triage practical',
      boardSubtitle: 'Prioritize → ABC → escalate viva',
      openBoard: WinningMajorShowcases.openNursing,
      mission: UniversityPracticalCatalog.nursing,
    ),
    CourseLabEntry(
      id: 'nursing_medicine_cross',
      courseId: 'nursing',
      emoji: '🏥',
      title: 'Chest pain differential (cross-train)',
      subtitle: 'Shared clinical reasoning with medicine',
      open: WinningMajorShowcases.openMedicine,
    ),
  ];

  static final List<CourseLabEntry> medicine = <CourseLabEntry>[
    ..._proFamily(
      courseId: 'medicine',
      labId: 'medicine',
      emoji: '🏥',
      boardTitle: 'Chest pain differential',
      boardSubtitle: 'Can’t-miss first → tests → viva',
      openBoard: WinningMajorShowcases.openMedicine,
      mission: UniversityPracticalCatalog.medicine,
    ),
    CourseLabEntry(
      id: 'med_triage_cross',
      courseId: 'medicine',
      emoji: '🩺',
      title: 'ED triage (cross-train)',
      subtitle: 'Shared acute care judgment',
      open: WinningMajorShowcases.openNursing,
    ),
  ];

  static final List<CourseLabEntry> business = _proFamily(
    courseId: 'business',
    labId: 'business',
    emoji: '📊',
    boardTitle: 'War-room practical',
    boardSubtitle: 'Diagnose drop → allocate → ROI viva',
    openBoard: WinningMajorShowcases.openBusiness,
    mission: UniversityPracticalCatalog.business,
  );

  static final List<CourseLabEntry> finance = _proFamily(
    courseId: 'finance',
    labId: 'finance',
    emoji: '💹',
    boardTitle: 'Finance desk practical',
    boardSubtitle: 'Rate shock → rebalance → fiduciary viva',
    openBoard: WinningMajorShowcases.openFinance,
    mission: UniversityPracticalCatalog.finance,
  );

  static final List<CourseLabEntry> accounting = _proFamily(
    courseId: 'accounting',
    labId: 'accounting',
    emoji: '📒',
    boardTitle: 'Audit practical',
    boardSubtitle: 'Misstatement → correct → control viva',
    openBoard: WinningMajorShowcases.openAccounting,
    mission: UniversityPracticalCatalog.accounting,
  );

  static final List<CourseLabEntry> marketing = _proFamily(
    courseId: 'marketing',
    labId: 'marketing',
    emoji: '📣',
    boardTitle: 'Campaign practical',
    boardSubtitle: 'Segment → KPI → measurement viva',
    openBoard: WinningMajorShowcases.openMarketing,
    mission: UniversityPracticalCatalog.marketing,
  );

  static final List<CourseLabEntry> economics = _proFamily(
    courseId: 'economics',
    labId: 'economics',
    emoji: '📈',
    boardTitle: 'Policy practical',
    boardSubtitle: 'Tradeoffs → evidence → memo viva',
    openBoard: WinningMajorShowcases.openEconomics,
    mission: UniversityPracticalCatalog.economics,
  );

  static final List<CourseLabEntry> pharmacy = _proFamily(
    courseId: 'pharmacy',
    labId: 'pharmacy',
    emoji: '💊',
    boardTitle: 'Rx safety practical',
    boardSubtitle: 'Interaction → hold → prescriber viva',
    openBoard: WinningMajorShowcases.openPharmacy,
    mission: UniversityPracticalCatalog.pharmacy,
  );

  static final List<CourseLabEntry> mls = _proFamily(
    courseId: 'medical_lab_science',
    labId: 'medical_lab_science',
    emoji: '🧫',
    boardTitle: 'Critical value practical',
    boardSubtitle: 'Validate → call → hemolysis viva',
    openBoard: WinningMajorShowcases.openMls,
    mission: UniversityPracticalCatalog.mls,
  );

  static final List<CourseLabEntry> psychology = _proFamily(
    courseId: 'psychology',
    labId: 'psychology',
    emoji: '🧠',
    boardTitle: 'Methods practical',
    boardSubtitle: 'Confound → control → causal viva',
    openBoard: WinningMajorShowcases.openPsychology,
    mission: UniversityPracticalCatalog.psychology,
  );

  static final List<CourseLabEntry> mathematics = _proFamily(
    courseId: 'mathematics',
    labId: 'mathematics',
    emoji: '∫',
    boardTitle: 'Model-defend practical',
    boardSubtitle: 'Assumptions → limits → viva',
    openBoard: WinningMajorShowcases.openMathematics,
    mission: UniversityPracticalCatalog.mathematics,
  );

  static final List<CourseLabEntry> cybersecurity = _proFamily(
    courseId: 'cybersecurity',
    labId: 'cybersecurity',
    emoji: '🛡️',
    boardTitle: 'SOC practical',
    boardSubtitle: 'Contain → evidence → IR viva',
    openBoard: WinningMajorShowcases.openCyber,
    mission: UniversityPracticalCatalog.cybersecurity,
  );
}
