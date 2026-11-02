import '../../config/vu_schools_catalog.dart';
import 'vu_v2_roadmap_models.dart';

/// Launch degrees + roadmap subject mapping.
///
/// Built from [VuSchoolsCatalog] so every Virtual University program can be
/// chosen at onboarding — not only the original eight.
class VuV2DegreeDef {
  const VuV2DegreeDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.roadmapSubjectId,
    required this.blurb,
    this.schoolId = '',
    this.schoolTitle = '',
  });

  final String id;
  final String title;
  final String emoji;
  /// Subject id passed to [VuV2RoadmapSync.forSubjectId].
  final String roadmapSubjectId;
  final String blurb;
  final String schoolId;
  final String schoolTitle;

  /// Kept for older call sites — always false (no stub degrees).
  bool get usesStubRoadmap => false;
}

abstract final class VuV2DegreeCatalog {
  /// Preferred order for the original launch majors (shown first).
  static const List<String> _launchProgramIds = <String>[
    'computer_science',
    'business_administration',
    'psychology',
    'nursing',
    'biology',
    'chemistry',
    'physics',
    'mathematics',
  ];

  static const Map<String, String> _emojiOverrides = <String, String>{
    'computer_science': '💻',
    'software_engineering': '🛠️',
    'artificial_intelligence': '🤖',
    'data_science': '📊',
    'cybersecurity': '🔐',
    'information_technology': '🖥️',
    'web_development': '🌐',
    'mobile_app_development': '📱',
    'mechanical_engineering': '⚙️',
    'civil_engineering': '🏗️',
    'electrical_engineering': '⚡',
    'chemical_engineering': '🧪',
    'aerospace_engineering': '🚀',
    'industrial_engineering': '🏭',
    'business_administration': '📈',
    'accounting': '📒',
    'finance': '💰',
    'economics': '📉',
    'entrepreneurship': '🚀',
    'marketing': '📣',
    'human_resource_management': '👥',
    'international_business': '🌍',
    'nursing': '🩺',
    'public_health': '🏥',
    'nutrition': '🥗',
    'anatomy_physiology': '🫀',
    'healthcare_management': '🏨',
    'pharmacy_fundamentals': '💊',
    'medicine': '🩺',
    'medical_lab_science': '🧫',
    'mathematics': '📐',
    'physics': '⚛️',
    'chemistry': '⚗️',
    'biology': '🧬',
    'environmental_science': '🌿',
    'statistics': '📐',
    'graphic_design': '🎨',
    'ui_ux_design': '✨',
    'animation': '🎬',
    'digital_illustration': '🖌️',
    'psychology': '🧠',
    'sociology': '🏘️',
    'political_science': '🏛️',
    'history': '📜',
    'philosophy': '💭',
    'anthropology': '🗿',
    'introduction_to_law': '⚖️',
    'criminal_justice': '🚔',
    'public_policy': '📋',
    'international_relations': '🌐',
    'journalism': '📰',
    'english': '📚',
  };

  static List<VuV2DegreeDef>? _cached;

  /// Every school program, launch majors first.
  static List<VuV2DegreeDef> get degrees {
    final List<VuV2DegreeDef>? hit = _cached;
    if (hit != null) return hit;

    final Map<String, VuV2DegreeDef> byId = <String, VuV2DegreeDef>{};
    for (final VuSchool school in VuSchoolsCatalog.schools) {
      for (final VuSchoolProgram program in school.programs) {
        byId[program.id] = VuV2DegreeDef(
          id: program.id,
          title: program.title,
          emoji: _emojiOverrides[program.id] ?? school.emoji,
          roadmapSubjectId: program.roadmapSubjectId,
          blurb: program.blurb ?? school.blurb ?? program.title,
          schoolId: school.id,
          schoolTitle: school.title,
        );
      }
    }

    final List<VuV2DegreeDef> ordered = <VuV2DegreeDef>[];
    final Set<String> used = <String>{};
    for (final String id in _launchProgramIds) {
      final VuV2DegreeDef? d = byId[id];
      if (d != null && used.add(id)) ordered.add(d);
    }
    for (final VuSchool school in VuSchoolsCatalog.schools) {
      for (final VuSchoolProgram program in school.programs) {
        if (used.add(program.id)) ordered.add(byId[program.id]!);
      }
    }

    _cached = ordered;
    return ordered;
  }

  static VuV2DegreeDef? byId(String id) {
    for (final VuV2DegreeDef d in degrees) {
      if (d.id == id || d.roadmapSubjectId == id) return d;
    }
    return null;
  }

  static VuV2DegreeDef? byRoadmapSubjectId(String subjectId) {
    for (final VuV2DegreeDef d in degrees) {
      if (d.roadmapSubjectId == subjectId || d.id == subjectId) return d;
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
