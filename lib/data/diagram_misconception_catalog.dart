/// Known diagram misconception pairs (e.g. radius vs ulna).
class DiagramMisconceptionDef {
  const DiagramMisconceptionDef({
    required this.id,
    required this.diagramId,
    required this.regionA,
    required this.regionB,
    required this.labelA,
    required this.labelB,
    required this.reviewSpeech,
    required this.keyPoints,
  });

  final String id;
  final String diagramId;
  final String regionA;
  final String regionB;
  final String labelA;
  final String labelB;
  final String reviewSpeech;
  final List<String> keyPoints;

  bool matchesConfusion({
    required String tappedId,
    required String targetId,
  }) {
    return (tappedId == regionA && targetId == regionB) ||
        (tappedId == regionB && targetId == regionA);
  }

  String? resolve(String tappedId, String targetId) {
    if (tappedId == regionA && targetId == regionB) return id;
    if (tappedId == regionB && targetId == regionA) return id;
    if (tappedId == targetId) return null;
    // Wrong region entirely — map to closest pair if same diagram
    if (targetId == regionA || targetId == regionB) return id;
    return null;
  }
}

abstract final class DiagramMisconceptionCatalog {
  static const List<DiagramMisconceptionDef> all = <DiagramMisconceptionDef>[
    DiagramMisconceptionDef(
      id: 'radius_ulna',
      diagramId: 'skeleton',
      regionA: 'radius',
      regionB: 'ulna',
      labelA: 'Radius',
      labelB: 'Ulna',
      reviewSpeech:
          'I noticed you\'ve confused the radius and ulna. Let\'s fix that now. '
          'The radius is on the lateral forearm — thumb side. It rotates during pronation. '
          'The ulna is medial — little-finger side — and forms the pointed elbow (olecranon). '
          'Mnemonic: radius = reach (thumb side).',
      keyPoints: <String>[
        'Radius — lateral / thumb side',
        'Ulna — medial / pinky side / elbow point',
        'They work together in forearm rotation',
      ],
    ),
    DiagramMisconceptionDef(
      id: 'scapula_clavicle',
      diagramId: 'skeleton',
      regionA: 'scapula',
      regionB: 'clavicle',
      labelA: 'Scapula',
      labelB: 'Clavicle',
      reviewSpeech:
          'You mixed up the scapula and clavicle. The clavicle is the collarbone — anterior and superior. '
          'The scapula is the flat shoulder blade on the posterior thorax.',
      keyPoints: <String>[
        'Clavicle — collarbone, anterior',
        'Scapula — shoulder blade, posterior',
      ],
    ),
    DiagramMisconceptionDef(
      id: 'tibia_fibula',
      diagramId: 'skeleton',
      regionA: 'tibia',
      regionB: 'fibula',
      labelA: 'Tibia',
      labelB: 'Fibula',
      reviewSpeech:
          'The tibia is the thick shinbone — it bears weight. The fibula is slender and lateral, stabilizing the ankle.',
      keyPoints: <String>['Tibia — shin, weight-bearing', 'Fibula — lateral, slim'],
    ),
    DiagramMisconceptionDef(
      id: 'right_left_atrium',
      diagramId: 'heart_detail',
      regionA: 'right_atrium',
      regionB: 'left_atrium',
      labelA: 'Right atrium',
      labelB: 'Left atrium',
      reviewSpeech:
          'Patient\'s right is on your left in standard anterior view — but on the diagram, right atrium is on the viewer\'s left side of the heart.',
      keyPoints: <String>['Right atrium receives deoxygenated blood', 'Left atrium receives from lungs'],
    ),
    DiagramMisconceptionDef(
      id: 'artery_vein',
      diagramId: 'heart_detail',
      regionA: 'pulmonary_artery',
      regionB: 'pulmonary_veins',
      labelA: 'Pulmonary artery',
      labelB: 'Pulmonary veins',
      reviewSpeech:
          'Arteries carry blood away from the heart; veins return blood toward the heart. '
          'Pulmonary artery carries deoxygenated blood to the lungs — the naming reflects direction, not oxygenation.',
      keyPoints: <String>['Artery — away from heart', 'Vein — toward heart'],
    ),
  ];

  static DiagramMisconceptionDef? resolve({
    required String diagramId,
    required String tappedRegionId,
    required String targetRegionId,
  }) {
    for (final DiagramMisconceptionDef d in all) {
      if (d.diagramId != diagramId) continue;
      if (d.resolve(tappedRegionId, targetRegionId) != null) return d;
    }
    return null;
  }

  static DiagramMisconceptionDef? byId(String id) {
    for (final DiagramMisconceptionDef d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}
