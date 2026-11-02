import '../models/virtual_lecture.dart';
import '../models/science_diagram.dart';
import 'lecture_diagram_teaching.dart';
import 'science_diagram_catalog.dart';
import 'virtual_lecture_topic_profile.dart';

/// How the professor uses a diagram during lecture (not all labels at once).
enum DiagramLectureMode {
  cleanOverview,
  regionOverview,
  partFocus,
  relationship,
  identifyTap,
  labelDrill,
  clinicalApply,
}

/// One progressive teaching beat on a diagram plate.
class DiagramTeachingBeat {
  const DiagramTeachingBeat({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.speech,
    this.highlightRegionIds = const <String>[],
    this.visibleRegionIds = const <String>[],
    this.keyPoints = const <String>[],
    this.seconds = 75,
    this.knowledgeCheck,
    this.slideType = LectureSlideType.diagram,
    this.interactiveActivity,
    this.activityRegionIds = const <String>[],
  });

  final DiagramLectureMode mode;
  final String title;
  final String subtitle;
  final String speech;
  final List<String> highlightRegionIds;
  final List<String> visibleRegionIds;
  final List<String> keyPoints;
  final int seconds;
  final LectureKnowledgeCheck? knowledgeCheck;
  final LectureSlideType slideType;
  final String? interactiveActivity;
  final List<String> activityRegionIds;
}

/// Progressive diagram teaching for every catalog diagram — not 28 labels at once.
abstract final class LectureDiagramProgression {
  static bool supports(String? diagramId) {
    if (diagramId == null || diagramId.trim().isEmpty) return false;
    return ScienceDiagramCatalog.diagramById(diagramId.trim()) != null;
  }

  static List<LectureSegment> buildProgressiveLecture({
    required VirtualLectureTopicProfile profile,
    required String diagramId,
    bool anatomy = false,
    bool judgeDemo = false,
  }) {
    List<DiagramTeachingBeat> beats = planFor(
      diagramId: diagramId,
      topic: profile.topic,
      anatomy: anatomy,
    );
    if (beats.isEmpty) return const <LectureSegment>[];

    if (judgeDemo) {
      // Keep the wow arc; drop the slowest mid beats for a 90-sec demo.
      beats = beats.where((DiagramTeachingBeat b) {
        if (b.mode == DiagramLectureMode.relationship &&
            b.title.contains('RELATIONSHIP') &&
            b.highlightRegionIds.contains('femur')) {
          return false;
        }
        return true;
      }).map((DiagramTeachingBeat b) {
        final int sec = (b.seconds * 0.45).round().clamp(18, 42);
        return DiagramTeachingBeat(
          mode: b.mode,
          title: b.title,
          subtitle: b.subtitle,
          speech: b.speech,
          highlightRegionIds: b.highlightRegionIds,
          visibleRegionIds: b.visibleRegionIds,
          keyPoints: b.keyPoints,
          seconds: sec,
          knowledgeCheck: b.knowledgeCheck,
          slideType: b.slideType,
          interactiveActivity: b.interactiveActivity,
          activityRegionIds: b.activityRegionIds,
        );
      }).toList(growable: false);
    }

    return beats
        .map(
          (DiagramTeachingBeat b) => LectureSegment(
            phase: _phaseFor(b.mode),
            professorSpeech: b.speech,
            caption: b.subtitle,
            durationSeconds: b.seconds,
            knowledgeCheck: b.knowledgeCheck,
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.diagram,
              title: b.title,
              subtitle: b.subtitle,
              slideType: b.slideType,
              diagramId: diagramId,
              keyPoints: b.keyPoints,
              highlightRegionIds: b.highlightRegionIds,
              visibleRegionIds: const <String>[],
              diagramInteractive: b.mode == DiagramLectureMode.identifyTap,
              dimDiagramBackground: b.mode != DiagramLectureMode.cleanOverview &&
                  b.mode != DiagramLectureMode.identifyTap &&
                  b.mode != DiagramLectureMode.labelDrill,
              diagramTeachingMode: b.mode.name,
              interactiveActivity: b.interactiveActivity,
              activityRegionIds: b.activityRegionIds,
            ),
          ),
        )
        .toList(growable: false);
  }

  static LecturePhase _phaseFor(DiagramLectureMode mode) => switch (mode) {
        DiagramLectureMode.cleanOverview ||
        DiagramLectureMode.regionOverview =>
          LecturePhase.visualDemonstration,
        DiagramLectureMode.partFocus ||
        DiagramLectureMode.relationship =>
          LecturePhase.conceptExplanation,
        DiagramLectureMode.identifyTap ||
        DiagramLectureMode.labelDrill =>
          LecturePhase.knowledgeCheck,
        DiagramLectureMode.clinicalApply => LecturePhase.guidedExamples,
      };

  static List<DiagramTeachingBeat> planFor({
    required String diagramId,
    required String topic,
    bool anatomy = false,
  }) {
    final String id = diagramId.trim().toLowerCase();
    return switch (id) {
      'skeleton' => _skeletonPlan(topic),
      'heart_detail' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'HEART ANATOMY',
          overviewSpeech:
              'Before we name every chamber, understand the pump: atria receive, ventricles eject, valves prevent backflow, vessels carry blood.',
          groups: _heartGroups,
        ),
      'animal_cell' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'ANIMAL CELL',
          overviewSpeech:
              'Do not memorize organelles in random order. Start with the boundary, then genetic control, then energy, then shipping.',
          groups: _animalCellGroups,
        ),
      'plant_cell' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'PLANT CELL',
          overviewSpeech:
              'Plant cells add a wall and chloroplasts — compare each structure to the animal cell you already know.',
          groups: _plantCellGroups,
        ),
      'atom' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'ATOMIC STRUCTURE',
          overviewSpeech:
              'Start at the nucleus, then subatomic particles, then electron shells — build outward.',
          groups: _atomGroups,
        ),
      'molecule' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'MOLECULAR STRUCTURE',
          overviewSpeech:
              'Identify each atom and bond before discussing polarity and hydrogen bonding.',
          groups: _moleculeGroups,
        ),
      'human_organs' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'ORGAN SYSTEMS',
          overviewSpeech:
              'Organize the body by region: thoracic, abdominal, then support systems — not a random list.',
          groups: _organGroups,
        ),
      'respiratory' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'RESPIRATORY PATHWAY',
          overviewSpeech:
              'Follow the air pathway from nose to alveoli — superior to inferior, outside to inside.',
          groups: _respiratoryGroups,
        ),
      'neuron' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'NEURON STRUCTURE',
          overviewSpeech:
              'Trace a signal: dendrites receive, cell body integrates, axon conducts, synapse transmits.',
          groups: _neuronGroups,
        ),
      'dc_circuit' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'DC CIRCUIT',
          overviewSpeech:
              'Build the circuit mentally: source → conductor → load → return path.',
          groups: _circuitGroups,
        ),
      'wave' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'WAVE PROPERTIES',
          overviewSpeech:
              'Read the graph systematically: amplitude, wavelength, crest, trough — then predict behavior.',
          groups: _waveGroups,
        ),
      'force' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'FORCES ON AN OBJECT',
          overviewSpeech:
              'Look at the whole free-body diagram first — the object sits in the middle, and every arrow is a force. '
              'We will not hide the object when we name a force. You always keep the full picture, then watch one arrow light up as I name it.',
          groups: _forceGroups,
        ),
      'bacteria' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'BACTERIAL CELL',
          overviewSpeech:
              'Start with the whole prokaryotic cell — wall, interior, and motility structures stay on the plate while we name each part.',
          groups: _bacteriaGroups,
        ),
      'dna' => _groupedPlan(
          diagramId: id,
          topic: topic,
          overviewTitle: 'DNA STRUCTURE',
          overviewSpeech:
              'Antiparallel strands, complementary bases, major and minor grooves — one layer at a time.',
          groups: _dnaGroups,
        ),
      _ => _genericPlan(diagramId: id, topic: topic),
    };
  }

  // ── Skeleton (full university flow from spec) ───────────────────────────

  static List<DiagramTeachingBeat> _skeletonPlan(String topic) {
    return <DiagramTeachingBeat>[
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.cleanOverview,
        title: 'Axial and Appendicular Skeletons',
        subtitle: 'Clean plate — the whole body stays in view',
        speech:
            'Look at the complete skeleton with me. '
            'The human skeleton is divided into two major divisions: the axial skeleton and the appendicular skeleton. '
            'Keep the whole figure in view so you can see each part in relation to the rest of the body.',
        keyPoints: <String>[
          'Skull',
          'Sternum',
          'Rib cage',
          'Vertebral column',
          'Scapula',
          'Humerus',
          'Pelvis',
          'Femur',
        ],
        seconds: 80,
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.regionOverview,
        title: 'AXIAL SKELETON',
        subtitle: 'Central axis of the body',
        speech:
            'The axial skeleton forms the central axis of the body. It includes the skull, vertebral column, and thoracic cage. '
            'Watch the plate: when I say skull, that vault lights. When I say vertebral column, the spine lights. '
            'When I say thoracic cage, the ribs and sternum light together. Everything else stays visible, just quieter.',
        highlightRegionIds: <String>['skull', 'spine', 'ribs', 'sternum', 'sacrum'],
        keyPoints: <String>['Skull', 'Vertebral column', 'Thoracic cage'],
        seconds: 90,
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.regionOverview,
        title: 'APPENDICULAR SKELETON',
        subtitle: 'Limbs and girdles',
        speech:
            'Now shift attention to the appendicular skeleton — the bones that hang off the axis. '
            'It includes the pectoral girdle: scapula and clavicle; the upper limb: humerus, radius, and ulna; '
            'the pelvis; and the lower limb: femur, tibia, and fibula. '
            'Each name you hear will light that bone against the still-visible rest of the skeleton.',
        highlightRegionIds: <String>[
          'clavicle',
          'scapula',
          'humerus',
          'radius',
          'ulna',
          'pelvis',
          'femur',
          'tibia',
          'fibula',
        ],
        keyPoints: <String>[
          'Shoulder girdle',
          'Upper limb',
          'Pelvic girdle',
          'Lower limb',
        ],
        seconds: 90,
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.partFocus,
        title: 'THE SKULL',
        subtitle: 'Start at the top of the body',
        speech:
            'Let\'s start at the top of the body. This is the skull. '
            'The skull is much more than simply a collection of bones. Its primary job is to protect one of the body\'s most important organs: the brain. '
            'Notice how the skull surrounds the brain almost completely, creating a protective enclosure. '
            'The mandible is the lower jaw — unlike most cranial bones, it moves for chewing and speech.',
        highlightRegionIds: <String>['skull', 'mandible'],
        keyPoints: <String>[
          'Cranium protects the brain',
          'Mandible = movable lower jaw',
        ],
        seconds: 85,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: 'Which bone forms the lower jaw?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>['Maxilla', 'Mandible', 'Clavicle', 'Sternum'],
          correctIndex: 1,
          explanation: 'Exactly. The mandible is the lower jaw.',
          timeLimitSeconds: 20,
        ),
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.partFocus,
        title: 'VERTEBRAL COLUMN',
        subtitle: 'Moving inferiorly',
        speech:
            'Now follow the skeleton downward. Directly beneath the skull is the vertebral column — the backbone. '
            'Stay with the spine: cervical vertebrae form the neck, lumbar vertebrae carry trunk weight, and the sacrum links the spine to the pelvis. '
            'The rest of the skeleton stays on the plate so you can see how the column sits in the midline.',
        highlightRegionIds: <String>['cervical', 'spine', 'lumbar', 'sacrum'],
        keyPoints: <String>['Cervical — neck', 'Thoracic — chest', 'Lumbar — lower back', 'Sacral — pelvis'],
        seconds: 95,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: 'Which region of the vertebral column is located in the neck?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>['Lumbar', 'Cervical', 'Sacral', 'Thoracic'],
          correctIndex: 1,
          explanation: 'Correct. Cervical vertebrae form the neck region.',
          timeLimitSeconds: 20,
        ),
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.partFocus,
        title: 'SCAPULA',
        subtitle: 'Shoulder blade',
        speech:
            'This is the scapula — the shoulder blade. Notice it on the posterior thorax while the rest of the skeleton remains visible. '
            'The scapula is a flat, triangular bone. It provides muscle attachment and articulates with the clavicle and humerus at the shoulder.',
        highlightRegionIds: <String>['scapula'],
        keyPoints: <String>[
          'Location: posterior thorax',
          'Type: flat bone',
          'Function: shoulder attachment',
          'Articulates: clavicle & humerus',
        ],
        seconds: 100,
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.relationship,
        title: 'SHOULDER RELATIONSHIPS',
        subtitle: 'Scapula → Clavicle → Humerus',
        speech:
            'Do not memorize scapula in isolation. Superior and anterior is the clavicle. Laterally the scapula articulates with the humerus at the shoulder joint.',
        highlightRegionIds: <String>['scapula', 'clavicle', 'humerus'],
        keyPoints: <String>['Pectoral girdle links limb to axial skeleton'],
        seconds: 80,
      ),
      DiagramTeachingBeat(
        mode: DiagramLectureMode.identifyTap,
        title: 'FIND THE SCAPULA',
        subtitle: 'Tap the structure on the model',
        speech: 'Now locate the scapula yourself. Tap the shoulder blade on the diagram.',
        highlightRegionIds: const <String>[],
        keyPoints: const <String>['No labels — use spatial reasoning'],
        seconds: 45,
        slideType: LectureSlideType.label,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: 'Tap the scapula on the skeleton.',
          kind: KnowledgeCheckKind.graphIdentify,
          correctAnswer: 'scapula',
          explanation: 'Excellent. You found the scapula on the posterior shoulder.',
          timeLimitSeconds: 25,
          diagramId: 'skeleton',
          targetRegionId: 'scapula',
        ),
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.partFocus,
        title: 'FOREARM BONES',
        subtitle: 'Radius vs ulna',
        speech:
            'Now look at the forearm against the still-visible upper limb. The radius is lateral — thumb side. The ulna is medial — little-finger side and forms the elbow point. If you confuse them, remember: the radius rotates during pronation.',
        highlightRegionIds: <String>['radius', 'ulna'],
        keyPoints: <String>['Radius — lateral / thumb', 'Ulna — medial / elbow'],
        seconds: 85,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: 'Tap the radius (thumb-side forearm bone).',
          kind: KnowledgeCheckKind.graphIdentify,
          correctAnswer: 'radius',
          explanation:
              'The radius is lateral — thumb side. If you picked the ulna, remember: ulna is medial at the elbow.',
          timeLimitSeconds: 25,
          diagramId: 'skeleton',
          targetRegionId: 'radius',
        ),
      ),
      DiagramTeachingBeat(
        mode: DiagramLectureMode.labelDrill,
        title: 'DRAG-AND-DROP LABELING',
        subtitle: 'Place each bone name on the model',
        speech:
            'Excellent progress. Now drag each label onto the correct bone — radius, ulna, and humerus. '
            'This is how lab practicals are graded: spatial accuracy, not just memorizing a list.',
        highlightRegionIds: const <String>['radius', 'ulna', 'humerus'],
        keyPoints: const <String>['Drag labels to hotspots', 'No hints on exam day'],
        seconds: 55,
        slideType: LectureSlideType.label,
        interactiveActivity: 'label_drag',
        activityRegionIds: const <String>['radius', 'ulna', 'humerus'],
      ),
      DiagramTeachingBeat(
        mode: DiagramLectureMode.partFocus,
        title: '3D SKELETON ROTATION',
        subtitle: 'Orbit the model like the anatomy lab',
        speech:
            'In the university anatomy lab you rotate the skeleton — anterior, lateral, posterior. '
            'Open the 3D rotation view now. Drag horizontally to orbit. Find the scapula from the posterior view.',
        highlightRegionIds: const <String>['scapula', 'spine', 'pelvis'],
        keyPoints: const <String>['Rotate to see posterior structures', 'Spatial reasoning'],
        seconds: 60,
        interactiveActivity: 'anatomy_3d',
        activityRegionIds: const <String>['scapula', 'clavicle', 'humerus', 'radius', 'ulna', 'spine'],
      ),
      const DiagramTeachingBeat(
        mode: DiagramLectureMode.clinicalApply,
        title: 'CLINICAL APPLICATION',
        subtitle: 'Why location matters',
        speech:
            'Why does scapula location matter? A patient falls onto the shoulder with posterior pain — the clinician must know which bones and joints may be injured: scapula, clavicle, humerus, and the glenoid cavity.',
        highlightRegionIds: <String>['scapula', 'clavicle', 'humerus'],
        slideType: LectureSlideType.clinicalCase,
        keyPoints: <String>[
          'Posterior shoulder pain after fall',
          'Identify bones at risk',
          'Apply anatomy to the case',
        ],
        seconds: 90,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt:
              'Fall onto the posterior shoulder — which structures are most at risk?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>[
            'Only the femur and tibia',
            'Scapula, clavicle, humerus (and glenoid region)',
            'Digestive organs only',
            'Ignore the view — guess radius',
          ],
          correctIndex: 1,
          explanation:
              'Posterior shoulder trauma implicates the scapula, clavicle, humerus, '
              'and glenoid — clinical anatomy, not flashcard trivia.',
          timeLimitSeconds: 22,
        ),
      ),
    ];
  }

  // ── Generic grouped plan for any catalog diagram ────────────────────────

  static List<DiagramTeachingBeat> _groupedPlan({
    required String diagramId,
    required String topic,
    required String overviewTitle,
    required String overviewSpeech,
    required List<({String title, String speech, List<String> regionIds})> groups,
  }) {
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(diagramId);
    if (diagram == null) return const <DiagramTeachingBeat>[];

    final List<DiagramTeachingBeat> beats = <DiagramTeachingBeat>[
      DiagramTeachingBeat(
        mode: DiagramLectureMode.cleanOverview,
        title: overviewTitle,
        subtitle: topic,
        speech: overviewSpeech,
        seconds: 70,
      ),
    ];

    for (final ({String title, String speech, List<String> regionIds}) g in groups) {
      final List<String> validIds = g.regionIds
          .where((String id) => diagram.regions.any((ScienceDiagramRegion r) => r.id == id))
          .toList(growable: false);
      if (validIds.isEmpty) continue;

      beats.add(
        DiagramTeachingBeat(
          mode: DiagramLectureMode.partFocus,
          title: g.title.toUpperCase(),
          subtitle: 'Progressive diagram teaching',
          speech: g.speech,
          highlightRegionIds: validIds,
          keyPoints: validIds
              .map(
                (String id) => diagram.regions
                    .firstWhere((ScienceDiagramRegion r) => r.id == id)
                    .name,
              )
              .toList(growable: false),
          seconds: 80,
        ),
      );

      // One tap-to-find for the first region in each group when anatomy-related.
      final String targetId = validIds.first;
      final ScienceDiagramRegion region =
          diagram.regions.firstWhere((ScienceDiagramRegion r) => r.id == targetId);
      beats.add(
        DiagramTeachingBeat(
          mode: DiagramLectureMode.identifyTap,
          title: 'LOCATE: ${region.name.toUpperCase()}',
          subtitle: 'Tap the structure',
          speech: 'Now locate ${region.name} yourself. Tap it on the diagram.',
          slideType: LectureSlideType.label,
          seconds: 40,
          knowledgeCheck: LectureKnowledgeCheck(
            prompt: 'Tap ${region.name} on the diagram.',
            kind: KnowledgeCheckKind.graphIdentify,
            correctAnswer: targetId,
            targetRegionId: targetId,
            diagramId: diagramId,
            explanation: 'Correct. You identified ${region.name}.',
            timeLimitSeconds: 25,
          ),
        ),
      );
    }

    // 3D rotation for asset-backed anatomy plates.
    if (diagramId == 'skeleton' || diagramId == 'heart_detail') {
      final List<String> focusIds =
          diagram.regions.take(8).map((ScienceDiagramRegion r) => r.id).toList();
      beats.add(
        DiagramTeachingBeat(
          mode: DiagramLectureMode.partFocus,
          title: '3D MODEL ROTATION',
          subtitle: 'Orbit the structure like the anatomy lab',
          speech:
              'In the lab you rotate the model to see relationships from every angle. '
              'Open the 3D view and drag to orbit — then identify structures from the new perspective.',
          highlightRegionIds: focusIds.take(4).toList(growable: false),
          seconds: 55,
          interactiveActivity: 'anatomy_3d',
          activityRegionIds: focusIds,
        ),
      );
    }

    // Final drag-and-drop label drill for the whole diagram.
    if (diagram.regions.length >= 3) {
      final List<String> drillIds = diagram.regions.take(6).map((ScienceDiagramRegion r) => r.id).toList();
      beats.add(
        DiagramTeachingBeat(
          mode: DiagramLectureMode.labelDrill,
          title: 'LABEL DRILL',
          subtitle: 'Drag names onto the diagram',
          speech:
              'Before we connect this to the lab, place each structure name on the diagram. '
              'Drag from the word bank — accuracy matters.',
          slideType: LectureSlideType.label,
          seconds: 50,
          interactiveActivity: 'label_drag',
          activityRegionIds: drillIds,
        ),
      );
    }

    return beats;
  }

  static List<DiagramTeachingBeat> _genericPlan({
    required String diagramId,
    required String topic,
  }) {
    final List<LectureDiagramPart> parts = LectureDiagramTeaching.partsFor(
      diagramId: diagramId,
      topic: topic,
    );
    if (parts.isEmpty) return const <DiagramTeachingBeat>[];

    final List<List<LectureDiagramPart>> chunks = LectureDiagramTeaching.chunk(parts, size: 4);
    return chunks.asMap().entries.map((MapEntry<int, List<LectureDiagramPart>> e) {
      final int i = e.key;
      final List<LectureDiagramPart> chunk = e.value;
      return DiagramTeachingBeat(
        mode: i == 0 ? DiagramLectureMode.cleanOverview : DiagramLectureMode.partFocus,
        title: topic.toUpperCase(),
        subtitle: 'Part ${i + 1} of ${chunks.length}',
        speech: LectureDiagramTeaching.speechForChunk(
          chunk: chunk,
          partIndex: i,
          partCount: chunks.length,
          diagramTitle: topic,
        ),
        keyPoints: chunk.map((LectureDiagramPart p) => p.bullet).toList(growable: false),
        seconds: 70 + chunk.length * 12,
      );
    }).toList(growable: false);
  }

  static const List<({String title, String speech, List<String> regionIds})> _heartGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Receiving chambers',
      speech:
          'Blood returns to the receiving chambers. The right atrium collects blood from the body. The left atrium collects blood from the lungs. Watch each atrium light while the rest of the heart stays in view.',
      regionIds: <String>['right_atrium', 'left_atrium'],
    ),
    (
      title: 'Pumping chambers',
      speech:
          'Now the pumps. The blood leaves the right ventricle through the pulmonary artery. The left ventricle is thicker because it must drive blood through the body via the aorta.',
      regionIds: <String>['right_ventricle', 'left_ventricle', 'pulmonary_artery', 'aorta'],
    ),
    (
      title: 'Valves',
      speech:
          'Valves stop backflow. The tricuspid valve sits between the right atrium and right ventricle. The mitral valve sits between the left atrium and left ventricle.',
      regionIds: <String>['mitral_valve', 'tricuspid_valve'],
    ),
    (
      title: 'Great vessels',
      speech:
          'Trace the great vessels: the pulmonary artery, the pulmonary veins, and the aorta. Each name lights that vessel against the still-visible heart.',
      regionIds: <String>['aorta', 'pulmonary_artery', 'pulmonary_veins'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _animalCellGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Cell boundary',
      speech:
          'Start at the edge of the cell. The cell membrane controls what enters and leaves. The rest of the organelles stay visible inside that boundary.',
      regionIds: <String>['membrane'],
    ),
    (
      title: 'Genetic control',
      speech:
          'Now the nucleus. The nucleus stores DNA and directs cell activities. Keep the rest of the cell in view so you see where the nucleus sits.',
      regionIds: <String>['nucleus'],
    ),
    (
      title: 'Energy',
      speech:
          'The mitochondria are responsible for producing most of the cell\'s ATP. Watch the mitochondria illuminate while the surrounding cytoplasm stays dim but visible.',
      regionIds: <String>['mitochondria'],
    ),
    (
      title: 'Protein shipping',
      speech:
          'Follow the shipping line. Ribosomes assemble protein. The endoplasmic reticulum folds and processes it. The Golgi apparatus packages and ships it.',
      regionIds: <String>['ribosome', 'er', 'golgi'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _plantCellGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Plant boundary',
      speech:
          'Begin at the cell wall. The rigid cell wall supports the plant. Inside it, the nucleus still directs the cell. The rest of the cell stays visible.',
      regionIds: <String>['cell_wall', 'nucleus'],
    ),
    (
      title: 'Photosynthesis',
      speech:
          'Now the chloroplast. Chloroplasts capture light energy for photosynthesis. Keep the rest of the plant cell around it so you see where that organelle sits.',
      regionIds: <String>['chloroplast'],
    ),
    (
      title: 'Storage',
      speech:
          'The central vacuole stores water and maintains turgor. Mitochondria still sit nearby, dim but visible.',
      regionIds: <String>['vacuole'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _atomGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Nucleus',
      speech:
          'Start at the nucleus. Protons carry positive charge. Neutrons add mass without charge. Both live in that dense center.',
      regionIds: <String>['nucleus', 'proton', 'neutron'],
    ),
    (
      title: 'Electrons',
      speech:
          'Now the electron. Electrons occupy an electron shell at specific energy levels around the nucleus. The whole atom remains on the plate.',
      regionIds: <String>['electron', 'shell'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _moleculeGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Atoms',
      speech:
          'Identify the oxygen atom first, then the hydrogen atoms. The molecule stays complete while each atom lights in turn.',
      regionIds: <String>['oxygen', 'hydrogen_left', 'hydrogen_right'],
    ),
    (
      title: 'Bonds',
      speech:
          'The covalent bond between oxygen and hydrogen creates polarity. Watch each O–H bond light without erasing the rest of the molecule.',
      regionIds: <String>['bond_left', 'bond_right'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _organGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Thoracic organs',
      speech:
          'In the chest, the heart and the lungs occupy the thoracic cavity. Each organ lights while the rest of the body stays mapped around it.',
      regionIds: <String>['heart', 'lungs'],
    ),
    (
      title: 'Abdominal organs',
      speech:
          'Move down to the abdomen. The liver, the stomach, and the kidneys keep working relationships you can see because we never hide the rest of the torso.',
      regionIds: <String>['liver', 'stomach', 'kidneys'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _respiratoryGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Airway',
      speech:
          'Follow the air. First the nasal cavity, then the trachea. The pathway stays on the plate the whole time.',
      regionIds: <String>['nasal', 'trachea'],
    ),
    (
      title: 'Gas exchange',
      speech:
          'Bronchi branch into the lungs, and the diaphragm powers the breath. When I name each structure it lights; the pathway behind it stays dim but visible.',
      regionIds: <String>['bronchi', 'lungs', 'diaphragm'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _neuronGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Input',
      speech:
          'Start where the signal arrives. Dendrites receive signals from other neurons. The rest of the neuron stays in view.',
      regionIds: <String>['dendrites'],
    ),
    (
      title: 'Integration',
      speech:
          'The cell body integrates incoming signals. Notice how it sits between dendrites and axon.',
      regionIds: <String>['cell_body'],
    ),
    (
      title: 'Output',
      speech:
          'The axon conducts the action potential, and the axon terminals release neurotransmitters at the synapse.',
      regionIds: <String>['axon', 'terminal'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _circuitGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Power & path',
      speech:
          'Trace current from the battery along the conducting wire. The whole circuit stays drawn while each part lights.',
      regionIds: <String>['battery', 'wire'],
    ),
    (
      title: 'Load & control',
      speech:
          'The light bulb converts energy, and the switch controls flow. Name, light, keep the rest of the loop.',
      regionIds: <String>['bulb', 'switch'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _waveGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Amplitude',
      speech:
          'Amplitude measures maximum displacement from the equilibrium line. The whole wave stays on the graph.',
      regionIds: <String>['amplitude'],
    ),
    (
      title: 'Wavelength',
      speech:
          'Wavelength is the crest-to-crest distance. Watch the crest, then the trough, then the wavelength itself.',
      regionIds: <String>['wavelength', 'crest', 'trough'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _dnaGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Backbone',
      speech:
          'The sugar-phosphate backbone forms the sides of the double helix. The rest of the molecule stays visible.',
      regionIds: <String>['backbone'],
    ),
    (
      title: 'Base pairs',
      speech:
          'Complementary bases pair across the helix: adenine with thymine. Watch each base light in turn.',
      regionIds: <String>['adenine', 'thymine'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _forceGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Gravity',
      speech:
          'The force of gravity pulls the object toward the Earth. Watch the weight arrow light downward while the object stays visible in the middle of the diagram.',
      regionIds: <String>['weight', 'object'],
    ),
    (
      title: 'Contact forces',
      speech:
          'The normal force pushes perpendicular to the surface. Friction opposes motion. An applied force is an extra push or pull. Each named arrow lights; the others dim.',
      regionIds: <String>['normal', 'friction', 'applied'],
    ),
  ];

  static const List<({String title, String speech, List<String> regionIds})> _bacteriaGroups =
      <({String title, String speech, List<String> regionIds})>[
    (
      title: 'Envelope',
      speech:
          'Start with the cell wall, then look at the cytoplasm inside it. The whole bacterium remains on the plate.',
      regionIds: <String>['cell_wall', 'cytoplasm'],
    ),
    (
      title: 'Genetic & motion',
      speech:
          'The nucleoid holds the chromosome. Ribosomes make protein. The flagellum provides motility.',
      regionIds: <String>['nucleoid', 'ribosome', 'flagellum'],
    ),
  ];
}
