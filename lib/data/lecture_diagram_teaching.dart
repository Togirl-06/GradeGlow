import '../models/science_diagram.dart';
import 'science_diagram_catalog.dart';

/// One labeled structure the professor must teach on a diagram plate.
class LectureDiagramPart {
  const LectureDiagramPart({
    required this.name,
    required this.teach,
    this.family,
  });

  final String name;
  final String teach;
  final String? family;

  String get bullet {
    if (family == null || family!.isEmpty) return '$name — $teach';
    return '$name ($family) — $teach';
  }

  String get spoken {
    if (family == null || family!.isEmpty) {
      return 'Find the $name. $teach';
    }
    return 'Find the $name — that is $family. $teach';
  }
}

/// Builds thorough, part-by-part diagram teaching for AI lectures.
abstract final class LectureDiagramTeaching {
  /// Prefer rich authored parts; fall back to science-catalog regions.
  static List<LectureDiagramPart> partsFor({
    required String? diagramId,
    String topic = '',
  }) {
    final String id = (diagramId ?? '').trim().toLowerCase();
    if (id == 'skeleton' ||
        topic.toLowerCase().contains('skeleton') ||
        topic.toLowerCase().contains('axial') ||
        topic.toLowerCase().contains('appendicular') ||
        topic.toLowerCase().contains('skeletal')) {
      return skeletonParts;
    }
    if (id == 'heart' || id == 'heart_detail') {
      return _fromCatalog('heart_detail');
    }
    if (id == 'human_organs' || id == 'human_body') {
      return _fromCatalog('human_organs');
    }
    if (id == 'respiratory') return _fromCatalog('respiratory');
    if (id == 'neuron') return _fromCatalog('neuron');
    if (id == 'animal_cell') return _fromCatalog('animal_cell');
    if (id == 'plant_cell') return _fromCatalog('plant_cell');
    if (id == 'dna') return _fromCatalog('dna');
    if (id == 'atom') return _fromCatalog('atom');
    if (id.isNotEmpty) {
      final List<LectureDiagramPart> fromCatalog = _fromCatalog(id);
      if (fromCatalog.isNotEmpty) return fromCatalog;
    }
    return const <LectureDiagramPart>[];
  }

  static List<List<LectureDiagramPart>> chunk(
    List<LectureDiagramPart> parts, {
    int size = 5,
  }) {
    if (parts.isEmpty) return const <List<LectureDiagramPart>>[];
    final List<List<LectureDiagramPart>> out = <List<LectureDiagramPart>>[];
    for (int i = 0; i < parts.length; i += size) {
      out.add(parts.sublist(i, (i + size).clamp(0, parts.length)));
    }
    return out;
  }

  static String speechForChunk({
    required List<LectureDiagramPart> chunk,
    required int partIndex,
    required int partCount,
    required String diagramTitle,
  }) {
    final StringBuffer buf = StringBuffer();
    if (partCount > 1) {
      buf.write(
        'This is part ${partIndex + 1} of $partCount on the $diagramTitle. The whole diagram stays on the plate. ',
      );
    } else {
      buf.write('Look at the $diagramTitle with me. The whole diagram stays on the plate. ');
    }
    for (int i = 0; i < chunk.length; i++) {
      final LectureDiagramPart p = chunk[i];
      if (i == 0) {
        buf.write('Let us start with the ${p.name}. ${p.teach} ');
      } else {
        buf.write('Next, look at the ${p.name}. ${p.teach} ');
      }
    }
    buf.write(
      'Notice each structure in relation to the rest of the figure — we dim the background, we never erase it.',
    );
    return buf.toString().trim();
  }

  static List<LectureDiagramPart> _fromCatalog(String diagramId) {
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(diagramId);
    if (diagram == null || diagram.regions.isEmpty) {
      return const <LectureDiagramPart>[];
    }
    return diagram.regions
        .map(
          (ScienceDiagramRegion r) => LectureDiagramPart(
            name: r.name,
            teach: r.funFact.trim().isEmpty
                ? 'Identify this structure and state its role.'
                : r.funFact.trim(),
          ),
        )
        .toList(growable: false);
  }

  /// Full teaching map for the numbered human-skeleton plate used in lecture.
  static const List<LectureDiagramPart> skeletonParts = <LectureDiagramPart>[
    LectureDiagramPart(
      name: 'Axial skeleton (overview)',
      teach:
          'This is the central axis: skull, vertebral column, and rib cage — built for protection and posture.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Skull / cranium',
      teach: 'Protects the brain and forms the face; major axial landmark.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Mandible',
      teach: 'The jawbone — moves for chewing and speech while still part of the axial head.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Cervical vertebrae',
      teach: 'Seven neck vertebrae that support the head and protect the upper spinal cord.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Thoracic vertebrae & rib cage',
      teach: 'Ribs and thoracic spine form a cage around the heart and lungs.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Sternum',
      teach: 'Breastbone in the front of the chest that anchors the ribs anteriorly.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Lumbar vertebrae',
      teach: 'Large lower-back vertebrae that carry much of the trunk weight.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Sacrum',
      teach: 'Fused triangular bone at the base of the spine that links spine to pelvis.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Coccyx',
      teach: 'The tailbone at the end of the vertebral column.',
      family: 'axial',
    ),
    LectureDiagramPart(
      name: 'Pectoral girdle',
      teach: 'Clavicle and scapula attach each upper limb to the trunk.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Clavicle',
      teach: 'Collarbone — braces the shoulder and is a common fracture site.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Scapula',
      teach: 'Shoulder blade — provides a socket for the humerus and muscle attachment.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Humerus',
      teach: 'Upper-arm bone between shoulder and elbow.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Radius',
      teach: 'Forearm bone on the thumb side; rotates in pronation and supination.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Ulna',
      teach: 'Forearm bone on the pinky side; forms the pointed elbow (olecranon).',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Carpals, metacarpals, phalanges (hand)',
      teach: 'Wrist, palm, and finger bones that enable grip and fine movement.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Pelvic girdle',
      teach: 'Hip bones transfer weight from spine to legs and protect pelvic organs.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Femur',
      teach: 'Thigh bone — longest and strongest bone; critical for standing and gait.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Patella',
      teach: 'Kneecap that protects the knee joint and improves quadriceps leverage.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Tibia',
      teach: 'Shinbone — the main weight-bearing bone of the lower leg.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Fibula',
      teach: 'Slender lateral lower-leg bone that stabilizes the ankle.',
      family: 'appendicular',
    ),
    LectureDiagramPart(
      name: 'Tarsals, metatarsals, phalanges (foot)',
      teach: 'Ankle, midfoot, and toe bones that support balance and push-off in walking.',
      family: 'appendicular',
    ),
  ];
}
