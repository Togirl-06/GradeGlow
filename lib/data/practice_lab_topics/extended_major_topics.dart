import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

/// Builds distinct topic areas for majors without a full curated catalog yet.
/// Each major gets unique area/topic IDs and major-specific descriptions.
List<PracticeLabTopicArea> distinctGenericTopicsForMajor({
  required String majorId,
  required String majorName,
  required String groupId,
}) {
  final String label = majorName;
  final String slug = majorId;

  final List<({String id, String name, String emoji, List<({String id, String name, String desc})> topics})> templates =
      _templatesForGroup(groupId, label);

  return majorTopicAreas(
    majorId: slug,
    areas: templates
        .map(
          (({String id, String name, String emoji, List<({String id, String name, String desc})> topics}) area) => (
                id: area.id,
                name: area.name,
                emoji: area.emoji,
                topics: area.topics
                    .map(
                      (({String id, String name, String desc}) t) => labTopic(
                            id: t.id,
                            name: t.name,
                            description: t.desc,
                            style: _styleForGroup(groupId),
                            aiRole: _roleForGroup(groupId),
                          ),
                    )
                    .toList(),
              ),
        )
        .toList(),
  );
}

SimulationStyle _styleForGroup(String groupId) {
  return switch (groupId) {
    'arts_creative' || 'communications_media' || 'humanities' => SimulationStyle.customerScenario,
    'architecture_design' => SimulationStyle.systemDesign,
    'hospitality_tourism' => SimulationStyle.customerScenario,
    'agriculture_environment' => SimulationStyle.diagnosis,
    'mathematics_finance' => SimulationStyle.classroom,
    'public_safety_government' => SimulationStyle.erEmergency,
    _ => SimulationStyle.customerScenario,
  };
}

String _roleForGroup(String groupId) {
  return switch (groupId) {
    'arts_creative' => 'Creative Director',
    'communications_media' => 'Editor',
    'humanities' => 'Professor',
    'architecture_design' => 'Design Client',
    'hospitality_tourism' => 'Guest',
    'agriculture_environment' => 'Farm Manager',
    'mathematics_finance' => 'Department Chair',
    'public_safety_government' => 'Incident Commander',
    _ => 'Supervisor',
  };
}

List<({String id, String name, String emoji, List<({String id, String name, String desc})> topics})> _templatesForGroup(
  String groupId,
  String label,
) {
  return switch (groupId) {
    'architecture_design' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'design_studio',
        name: '$label Design Studio',
        emoji: '🏛️',
        topics: <({String id, String name, String desc})>[
          (id: 'concept', name: 'Design Concept', desc: 'Present a design concept and defend spatial decisions to a client.'),
          (id: 'codes', name: 'Building Codes', desc: 'Resolve code compliance conflicts in a proposed $label project.'),
          (id: 'sustainability', name: 'Sustainable Design', desc: 'Integrate sustainability goals without exceeding budget in $label.'),
        ],
      ),
      (
        id: 'professional_practice',
        name: '$label Professional Practice',
        emoji: '📐',
        topics: <({String id, String name, String desc})>[
          (id: 'client_mgmt', name: 'Client Management', desc: 'Manage scope creep and client expectations on a $label commission.'),
          (id: 'portfolio', name: 'Portfolio Review', desc: 'Present portfolio work to a hiring committee for $label roles.'),
        ],
      ),
    ],
    'arts_creative' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'creative_process',
        name: '$label Creative Process',
        emoji: '🎨',
        topics: <({String id, String name, String desc})>[
          (id: 'brief', name: 'Creative Brief', desc: 'Interpret a vague creative brief and pitch direction for $label.'),
          (id: 'critique', name: 'Studio Critique', desc: 'Present work and respond to critique in a $label studio review.'),
          (id: 'collaboration', name: 'Creative Collaboration', desc: 'Navigate creative differences on a collaborative $label project.'),
        ],
      ),
    ],
    'communications_media' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'media_production',
        name: '$label Production',
        emoji: '📢',
        topics: <({String id, String name, String desc})>[
          (id: 'story_pitch', name: 'Story Pitch', desc: 'Pitch a $label story angle to skeptical editors.'),
          (id: 'crisis_comms', name: 'Crisis Communications', desc: 'Draft holding statement for breaking $label crisis.'),
          (id: 'audience', name: 'Audience Strategy', desc: 'Redesign content strategy when $label audience engagement drops.'),
        ],
      ),
    ],
    'humanities' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'analysis',
        name: '$label Analysis',
        emoji: '📖',
        topics: <({String id, String name, String desc})>[
          (id: 'textual', name: 'Textual Analysis', desc: 'Construct a thesis analyzing primary texts in $label.'),
          (id: 'debate', name: 'Scholarly Debate', desc: 'Defend interpretive position in $label seminar debate.'),
          (id: 'research', name: 'Humanities Research', desc: 'Design archival research methodology for $label thesis.'),
        ],
      ),
    ],
    'hospitality_tourism' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'guest_experience',
        name: '$label Guest Experience',
        emoji: '🍽️',
        topics: <({String id, String name, String desc})>[
          (id: 'service_recovery', name: 'Service Recovery', desc: 'Recover from service failure with an angry $label guest.'),
          (id: 'ops', name: 'Operations', desc: 'Manage staffing crisis during peak $label season.'),
          (id: 'revenue', name: 'Revenue Management', desc: 'Optimize pricing strategy for $label property.'),
        ],
      ),
    ],
    'agriculture_environment' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'field_practice',
        name: '$label Field Practice',
        emoji: '🌱',
        topics: <({String id, String name, String desc})>[
          (id: 'crop_mgmt', name: 'Resource Management', desc: 'Manage resources and inputs for sustainable $label operations.'),
          (id: 'pest', name: 'Pest & Disease', desc: 'Diagnose crop or livestock issue and recommend IPM for $label.'),
          (id: 'market', name: 'Agribusiness Decisions', desc: 'Make planting or investment decisions amid $label market volatility.'),
        ],
      ),
    ],
    'mathematics_finance' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'quantitative',
        name: '$label Quantitative Methods',
        emoji: '➗',
        topics: <({String id, String name, String desc})>[
          (id: 'proof', name: 'Proof & Reasoning', desc: 'Construct rigorous proof for a $label problem set.'),
          (id: 'modeling', name: 'Mathematical Modeling', desc: 'Build model for real-world $label application and validate assumptions.'),
          (id: 'data_math', name: 'Statistical Application', desc: 'Apply statistical methods to $label dataset with interpretation.'),
        ],
      ),
    ],
    'public_safety_government' => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'public_service',
        name: '$label Public Service',
        emoji: '🚔',
        topics: <({String id, String name, String desc})>[
          (id: 'incident', name: 'Incident Response', desc: 'Coordinate multi-agency response in $label emergency scenario.'),
          (id: 'policy_impl', name: 'Policy Implementation', desc: 'Implement new $label policy amid stakeholder resistance.'),
          (id: 'ethics_public', name: 'Public Sector Ethics', desc: 'Navigate ethical dilemma in $label public service role.'),
        ],
      ),
    ],
    _ => <({String id, String name, String emoji, List<({String id, String name, String desc})> topics})>[
      (
        id: 'foundations',
        name: '$label Foundations',
        emoji: '📚',
        topics: <({String id, String name, String desc})>[
          (id: 'core', name: 'Core Concepts', desc: 'Apply foundational $label knowledge in a realistic professional scenario.'),
          (id: 'case_study', name: 'Case Study', desc: 'Analyze a $label case study and recommend evidence-based action.'),
        ],
      ),
      (
        id: 'applied',
        name: '$label Applied Practice',
        emoji: '🎯',
        topics: <({String id, String name, String desc})>[
          (id: 'real_world', name: 'Real-World Challenge', desc: 'Handle a workplace challenge specific to $label practice.'),
          (id: 'communication', name: 'Professional Communication', desc: 'Present $label findings to a demanding stakeholder audience.'),
        ],
      ),
    ],
  };
}

/// Per-major overrides for extended catalog majors (unique from generic group templates).
final Map<String, List<PracticeLabTopicArea>> extendedMajorOverrides = <String, List<PracticeLabTopicArea>>{
  'architecture': majorTopicAreas(
    majorId: 'architecture',
    areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
      (
        id: 'arch_design',
        name: 'Architectural Design',
        emoji: '🏛️',
        topics: <PracticeLabTopic>[
          labTopic(id: 'schematic', name: 'Schematic Design', description: 'Present massing and program layout to design jury.', style: SimulationStyle.systemDesign, aiRole: 'Design Juror'),
          labTopic(id: 'structural_coord', name: 'Structural Coordination', description: 'Resolve clash between architectural vision and structural constraints.', style: SimulationStyle.customerScenario, aiRole: 'Structural Engineer', advanced: true),
        ],
      ),
    ],
  ),
  'graphic_design': majorTopicAreas(
    majorId: 'graphic_design',
    areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
      (
        id: 'visual_design',
        name: 'Visual Design',
        emoji: '🎨',
        topics: <PracticeLabTopic>[
          labTopic(id: 'brand_identity', name: 'Brand Identity', description: 'Pitch logo system and brand guidelines to startup founder.', style: SimulationStyle.customerScenario, aiRole: 'Client'),
          labTopic(id: 'typography', name: 'Typography', description: 'Defend typographic hierarchy choices in editorial layout critique.', style: SimulationStyle.classroom, aiRole: 'Art Director'),
        ],
      ),
    ],
  ),
  'journalism': majorTopicAreas(
    majorId: 'journalism',
    areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
      (
        id: 'reporting',
        name: 'Investigative Reporting',
        emoji: '📰',
        topics: <PracticeLabTopic>[
          labTopic(id: 'source', name: 'Source Development', description: 'Persuade reluctant source to go on record for investigation.', style: SimulationStyle.customerScenario, aiRole: 'Anonymous Source'),
          labTopic(id: 'fact_check', name: 'Fact Checking', description: 'Verify contested claims before publication deadline.', style: SimulationStyle.diagnosis, aiRole: 'Editor', advanced: true),
        ],
      ),
    ],
  ),
  'mathematics': majorTopicAreas(
    majorId: 'mathematics',
    areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
      (
        id: 'pure_math',
        name: 'Pure Mathematics',
        emoji: '➗',
        topics: <PracticeLabTopic>[
          labTopic(id: 'proof_writing', name: 'Proof Writing', description: 'Present proof of theorem at graduate seminar.', style: SimulationStyle.classroom, aiRole: 'Professor'),
          labTopic(id: 'abstract_algebra', name: 'Abstract Algebra', description: 'Classify algebraic structure from given operation table.', style: SimulationStyle.classroom, aiRole: 'TA', advanced: true),
        ],
      ),
    ],
  ),
};
