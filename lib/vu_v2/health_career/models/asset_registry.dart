/// Registry of anatomy / clinical visual assets with license metadata.
///
/// Phase 2 uses existing Flutter image/SVG assets. Phase 3 adds glTF/GLB
/// entries under `assets/health_3d/` once licensed meshes are packaged.
class MedAssetEntry {
  const MedAssetEntry({
    required this.id,
    required this.label,
    required this.path,
    required this.kind,
    required this.license,
    required this.source,
    this.interactions = const <String>['select', 'orbit'],
    this.glbReady = false,
  });

  final String id;
  final String label;
  final String path;
  final String kind; // image | svg | glb
  final String license;
  final String source;
  final List<String> interactions;
  final bool glbReady;
}

abstract final class MedAssetRegistry {
  static const List<MedAssetEntry> all = <MedAssetEntry>[
    MedAssetEntry(
      id: 'body',
      label: 'Human body overview',
      path: 'assets/anatomy/organs_real.png',
      kind: 'image',
      license: 'Project educational asset',
      source: 'GradeGlow assets/anatomy',
    ),
    MedAssetEntry(
      id: 'heart',
      label: 'Heart',
      path: 'assets/anatomy/heart_real.png',
      kind: 'image',
      license: 'Project educational asset',
      source: 'GradeGlow assets/anatomy',
      interactions: <String>['select', 'orbit', 'highlight'],
    ),
    MedAssetEntry(
      id: 'respiratory',
      label: 'Respiratory system',
      path: 'assets/anatomy/respiratory_real.png',
      kind: 'image',
      license: 'Project educational asset',
      source: 'GradeGlow assets/anatomy',
    ),
    MedAssetEntry(
      id: 'skeleton',
      label: 'Skeleton',
      path: 'assets/anatomy/skeleton_real.png',
      kind: 'image',
      license: 'Project educational asset',
      source: 'GradeGlow assets/anatomy',
    ),
    MedAssetEntry(
      id: 'organs',
      label: 'Abdominal organs',
      path: 'assets/anatomy/organs_real.png',
      kind: 'image',
      license: 'Project educational asset',
      source: 'GradeGlow assets/anatomy',
    ),
    MedAssetEntry(
      id: 'neuron',
      label: 'Neuron / nervous tissue',
      path: 'assets/anatomy/neuron_real.png',
      kind: 'image',
      license: 'Project educational asset',
      source: 'GradeGlow assets/anatomy',
    ),
    // Phase 3 placeholders — paths reserved; glbReady false until files ship.
    MedAssetEntry(
      id: 'glb_full_body',
      label: 'Full body mesh (planned)',
      path: 'assets/health_3d/models/full_body.glb',
      kind: 'glb',
      license: 'TBD — must be educational/commercial licensed before ship',
      source: 'Pending procurement',
      interactions: <String>['orbit', 'zoom', 'select', 'layers'],
      glbReady: false,
    ),
    MedAssetEntry(
      id: 'glb_heart',
      label: 'Heart mesh (planned)',
      path: 'assets/health_3d/models/heart.glb',
      kind: 'glb',
      license: 'TBD — must be educational/commercial licensed before ship',
      source: 'Pending procurement',
      interactions: <String>['orbit', 'zoom', 'select', 'cross_section'],
      glbReady: false,
    ),
  ];

  static MedAssetEntry? byId(String id) {
    for (final MedAssetEntry e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  static MedAssetEntry fallbackFor(String assetKey) =>
      byId(assetKey) ?? byId('body')!;
}
