import 'vu_v2_roadmap_models.dart';

/// Launch degrees + roadmap subject mapping.
/// Only degrees with real synced catalogs are listed — no Studio scaffolds.
class VuV2DegreeDef {
  const VuV2DegreeDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.roadmapSubjectId,
    required this.blurb,
  });

  final String id;
  final String title;
  final String emoji;
  /// Subject id passed to [VuV2RoadmapSync.forSubjectId].
  final String roadmapSubjectId;
  final String blurb;

  /// Kept for older call sites — always false (no stub degrees).
  bool get usesStubRoadmap => false;
}

abstract final class VuV2DegreeCatalog {
  static const List<VuV2DegreeDef> degrees = <VuV2DegreeDef>[
    VuV2DegreeDef(
      id: 'computer_science',
      title: 'Computer Science',
      emoji: '💻',
      roadmapSubjectId: 'computer_science',
      blurb: 'Programming, algorithms, systems, and software craft.',
    ),
    VuV2DegreeDef(
      id: 'business_administration',
      title: 'Business Administration',
      emoji: '📈',
      roadmapSubjectId: 'business',
      blurb: 'Strategy, leadership, finance, marketing, and accounting.',
    ),
    VuV2DegreeDef(
      id: 'psychology',
      title: 'Psychology',
      emoji: '🧠',
      roadmapSubjectId: 'psychology',
      blurb: 'Mind, behavior, research methods, and applied practice.',
    ),
    VuV2DegreeDef(
      id: 'nursing',
      title: 'Nursing',
      emoji: '🩺',
      roadmapSubjectId: 'nursing',
      blurb: 'Patient care, clinical reasoning, and health systems.',
    ),
    VuV2DegreeDef(
      id: 'biology',
      title: 'Biology',
      emoji: '🧬',
      roadmapSubjectId: 'biology',
      blurb: 'Cells to ecosystems with AI lab support.',
    ),
    VuV2DegreeDef(
      id: 'chemistry',
      title: 'Chemistry',
      emoji: '⚗️',
      roadmapSubjectId: 'chemistry',
      blurb: 'Matter, reactions, and molecular problem solving.',
    ),
    VuV2DegreeDef(
      id: 'physics',
      title: 'Physics',
      emoji: '⚛️',
      roadmapSubjectId: 'physics',
      blurb: 'Mechanics, waves, and quantitative models.',
    ),
    VuV2DegreeDef(
      id: 'mathematics',
      title: 'Mathematics',
      emoji: '📐',
      roadmapSubjectId: 'mathematics',
      blurb: 'Proofs, calculus, and problem fluency.',
    ),
  ];

  static VuV2DegreeDef? byId(String id) {
    for (final VuV2DegreeDef d in degrees) {
      if (d.id == id || d.roadmapSubjectId == id) return d;
    }
    return null;
  }

  static VuV2DegreeDef? byRoadmapSubjectId(String subjectId) {
    for (final VuV2DegreeDef d in degrees) {
      if (d.roadmapSubjectId == subjectId) return d;
    }
    return null;
  }

  /// Empty placeholder — never invent fake Studio courses.
  static VuV2DegreeRoadmap emptyRoadmap({
    required String subjectId,
    required String title,
    required String emoji,
    required String blurb,
  }) {
    return VuV2DegreeRoadmap(
      subjectId: subjectId,
      title: title,
      emoji: emoji,
      tagline: blurb,
      sourceLabel: 'Curriculum not synced yet',
      tracks: const <VuV2RoadmapTrack>[],
    );
  }

  /// @Deprecated Prefer real catalogs. Kept as alias to [emptyRoadmap].
  static VuV2DegreeRoadmap stubRoadmap({
    required String subjectId,
    required String title,
    required String emoji,
    required String blurb,
  }) =>
      emptyRoadmap(
        subjectId: subjectId,
        title: title,
        emoji: emoji,
        blurb: blurb,
      );
}
