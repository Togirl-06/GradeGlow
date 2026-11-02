import '../models/practice_lab.dart';
import 'practice_lab_scenarios/additional_practice_labs.dart';
import 'practice_lab_scenarios/agriculture_environment_labs.dart';
import 'practice_lab_scenarios/architecture_design_labs.dart';
import 'practice_lab_scenarios/arts_creative_labs.dart';
import 'practice_lab_scenarios/business_labs.dart';
import 'practice_lab_scenarios/communications_media_labs.dart';
import 'practice_lab_scenarios/computer_technology_labs.dart';
import 'practice_lab_scenarios/engineering_labs.dart';
import 'practice_lab_scenarios/health_medical_labs.dart';
import 'practice_lab_scenarios/hospitality_tourism_labs.dart';
import 'practice_lab_scenarios/humanities_labs.dart';
import 'practice_lab_scenarios/law_criminal_justice_labs.dart';
import 'practice_lab_scenarios/mathematics_finance_labs.dart';
import 'practice_lab_scenarios/psychology_social_sciences_labs.dart';
import 'practice_lab_scenarios/public_safety_government_labs.dart';
import 'practice_lab_scenarios/science_labs.dart';

/// Labs for one major split into core, shared field topics, and a custom scenario.
typedef PracticeLabMajorCatalog = ({
  List<PracticeLabType> coreLabs,
  List<PracticeLabType> fieldLabs,
  PracticeLabType customLab,
});

/// Aggregates per-major roleplay simulation labs from every field group into a
/// single lookup keyed by major id. Consumed by [PracticeLabsCatalog] to inject
/// scenario labs into each category.
class PracticeLabScenarios {
  PracticeLabScenarios._();

  static const String customLabId = 'ai_custom_scenario';

  static final Map<String, List<PracticeLabType>> byMajor =
      <String, List<PracticeLabType>>{
    ...healthMedicalLabs,
    ...computerTechnologyLabs,
    ...businessLabs,
    ...lawCriminalJusticeLabs,
    ...psychologySocialSciencesLabs,
    ...scienceLabs,
    ...engineeringLabs,
    ...architectureDesignLabs,
    ...artsCreativeLabs,
    ...communicationsMediaLabs,
    ...humanitiesLabs,
    ...hospitalityTourismLabs,
    ...agricultureEnvironmentLabs,
    ...mathematicsFinanceLabs,
    ...publicSafetyGovernmentLabs,
  };

  static final Map<String, List<String>> _groupMajorIds = <String, List<String>>{
    'health_medical': healthMedicalLabs.keys.toList(),
    'computer_technology': computerTechnologyLabs.keys.toList(),
    'business': businessLabs.keys.toList(),
    'law_criminal_justice': lawCriminalJusticeLabs.keys.toList(),
    'psychology_social_sciences': psychologySocialSciencesLabs.keys.toList(),
    'science': scienceLabs.keys.toList(),
    'engineering': engineeringLabs.keys.toList(),
    'architecture_design': architectureDesignLabs.keys.toList(),
    'arts_creative': artsCreativeLabs.keys.toList(),
    'communications_media': communicationsMediaLabs.keys.toList(),
    'humanities': humanitiesLabs.keys.toList(),
    'hospitality_tourism': hospitalityTourismLabs.keys.toList(),
    'agriculture_environment': agricultureEnvironmentLabs.keys.toList(),
    'mathematics_finance': mathematicsFinanceLabs.keys.toList(),
    'public_safety_government': publicSafetyGovernmentLabs.keys.toList(),
  };

  static final Map<String, List<PracticeLabType>> _groupLabsCache =
      <String, List<PracticeLabType>>{
    for (final MapEntry<String, List<String>> entry in _groupMajorIds.entries)
      entry.key: _dedupeLabs(
        entry.value.expand((String majorId) => _labsForMajorId(majorId)),
      ),
  };

  static List<PracticeLabType> _labsForMajorId(String majorId) {
    final List<PracticeLabType> base = byMajor[majorId] ?? const <PracticeLabType>[];
    final List<PracticeLabType> extra = additionalPracticeLabs[majorId] ?? const <PracticeLabType>[];
    if (extra.isEmpty) return base;
    return <PracticeLabType>[...base, ...extra];
  }

  static List<PracticeLabType> _dedupeLabs(Iterable<PracticeLabType> labs) {
    final Set<String> seen = <String>{};
    final List<PracticeLabType> unique = <PracticeLabType>[];
    for (final PracticeLabType lab in labs) {
      if (seen.add(lab.id)) unique.add(lab);
    }
    return unique;
  }

  static PracticeLabType _customLab(String majorName) {
    return PracticeLabType(
      id: customLabId,
      title: 'Custom AI Scenario',
      subtitle: 'Generate a fresh, unique simulation tailored to $majorName.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Role varies',
      difficulty: 'Intermediate',
      studentTasks: const <String>[
        'Respond professionally in character',
        'Apply your field knowledge',
        'Make sound decisions under pressure',
      ],
      evaluationCriteria: const <String>[
        'Communication',
        'Critical thinking',
        'Domain knowledge',
      ],
    );
  }

  static List<PracticeLabType> _defaultLabs(String majorName) {
    return <PracticeLabType>[
      PracticeLabType(
        id: 'default_professional_beginner',
        title: 'Professional Challenge',
        subtitle: 'A straightforward workplace scenario for $majorName students.',
        style: SimulationStyle.customerScenario,
        aiRole: 'Supervisor',
        difficulty: 'Beginner',
        studentTasks: const <String>[
          'Analyze the situation',
          'Communicate your reasoning',
          'Recommend next steps',
        ],
        evaluationCriteria: const <String>[
          'Communication',
          'Critical thinking',
          'Decision making',
        ],
      ),
      PracticeLabType(
        id: 'default_professional_intermediate',
        title: 'Complex Case Study',
        subtitle: 'Handle competing priorities in a realistic $majorName setting.',
        style: SimulationStyle.customerScenario,
        aiRole: 'Stakeholder',
        difficulty: 'Intermediate',
        studentTasks: const <String>[
          'Identify the key issues and trade-offs',
          'Propose a justified plan of action',
          'Address pushback professionally',
        ],
        evaluationCriteria: const <String>[
          'Problem analysis',
          'Professional judgment',
          'Persuasion',
        ],
      ),
      PracticeLabType(
        id: 'default_professional_advanced',
        title: 'High-Stakes Decision',
        subtitle: 'Navigate ambiguity and pressure in an advanced $majorName scenario.',
        style: SimulationStyle.customerScenario,
        aiRole: 'Senior Leader',
        difficulty: 'Advanced',
        studentTasks: const <String>[
          'Make decisions with incomplete information',
          'Defend your reasoning under scrutiny',
          'Balance ethics, risk, and outcomes',
        ],
        evaluationCriteria: const <String>[
          'Judgment under pressure',
          'Ethical reasoning',
          'Leadership communication',
        ],
      ),
    ];
  }

  /// Core, field-shared, and custom labs for a major.
  static PracticeLabMajorCatalog resolveForMajor({
    required String majorId,
    String? groupId,
    required String majorName,
  }) {
    List<PracticeLabType> core = _labsForMajorId(majorId);
    if (core.isEmpty) {
      core = _defaultLabs(majorName);
    }

    final Set<String> coreIds = core.map((PracticeLabType lab) => lab.id).toSet();
    final List<PracticeLabType> field = <PracticeLabType>[];
    if (groupId != null) {
      for (final PracticeLabType lab in _groupLabsCache[groupId] ?? const <PracticeLabType>[]) {
        if (!coreIds.contains(lab.id)) field.add(lab);
      }
    }

    return (
      coreLabs: core,
      fieldLabs: field,
      customLab: _customLab(majorName),
    );
  }

  /// All simulations a major can practice: core + every topic in the field + custom AI.
  static List<PracticeLabType> forMajor(
    String majorId, {
    String? groupId,
    String? majorName,
  }) {
    final PracticeLabMajorCatalog catalog = resolveForMajor(
      majorId: majorId,
      groupId: groupId,
      majorName: majorName ?? majorId,
    );
    return <PracticeLabType>[
      ...catalog.coreLabs,
      ...catalog.fieldLabs,
      catalog.customLab,
    ];
  }
}
