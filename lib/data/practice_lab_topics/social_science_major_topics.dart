import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

final List<PracticeLabTopicArea> psychologyMajorTopics = majorTopicAreas(
  majorId: 'psychology',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'general',
      name: 'General Psychology',
      emoji: '🧠',
      topics: <PracticeLabTopic>[
        labTopic(id: 'behavior', name: 'Behavior Analysis', description: 'Apply learning theory to explain and modify a behavior pattern.', style: SimulationStyle.classroom, aiRole: 'Professor'),
        labTopic(id: 'cognitive', name: 'Cognitive Assessment', description: 'Administer and interpret cognitive screening results.', style: SimulationStyle.counseling, aiRole: 'Client', advanced: true),
        labTopic(id: 'research_methods', name: 'Research Methods', description: 'Design an experiment controlling for confounds and bias.', style: SimulationStyle.classroom, aiRole: 'Research Advisor', advanced: true),
      ],
    ),
    (
      id: 'clinical',
      name: 'Clinical Psychology',
      emoji: '🛋️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'anxiety', name: 'Anxiety Disorders', description: 'Conduct intake for generalized anxiety and plan CBT interventions.', style: SimulationStyle.counseling, aiRole: 'Anxious Client'),
        labTopic(id: 'depression', name: 'Depression Cases', description: 'Assess suicide risk and develop a safety plan.', style: SimulationStyle.counseling, aiRole: 'Depressed Client', advanced: true),
        labTopic(id: 'crisis', name: 'Crisis Intervention', description: 'De-escalate an acute psychiatric crisis over the phone.', style: SimulationStyle.counseling, aiRole: 'Crisis Caller', advanced: true),
      ],
    ),
    (
      id: 'developmental',
      name: 'Developmental Psychology',
      emoji: '👨‍👩‍👧',
      topics: <PracticeLabTopic>[
        labTopic(id: 'child_dev', name: 'Child Development', description: 'Evaluate developmental milestones with concerned parents.', style: SimulationStyle.counseling, aiRole: 'Parent'),
        labTopic(id: 'adolescence', name: 'Adolescence', description: 'Counsel a teen struggling with identity and peer pressure.', style: SimulationStyle.counseling, aiRole: 'Teen Client', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> sociologyMajorTopics = majorTopicAreas(
  majorId: 'sociology',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'social_structures',
      name: 'Social Structures',
      emoji: '🏙️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'inequality', name: 'Social Inequality', description: 'Analyze structural causes of inequality in a case community.', style: SimulationStyle.classroom, aiRole: 'Sociology Professor'),
        labTopic(id: 'institutions', name: 'Social Institutions', description: 'Explain how institutions reproduce social stratification.', style: SimulationStyle.classroom, aiRole: 'Department Chair', advanced: true),
      ],
    ),
    (
      id: 'research',
      name: 'Sociological Research',
      emoji: '📊',
      topics: <PracticeLabTopic>[
        labTopic(id: 'ethnography', name: 'Ethnographic Methods', description: 'Design fieldwork respecting community boundaries and ethics.', style: SimulationStyle.classroom, aiRole: 'IRB Reviewer'),
        labTopic(id: 'policy_analysis', name: 'Social Policy Analysis', description: 'Evaluate a welfare policy\'s unintended consequences.', style: SimulationStyle.customerScenario, aiRole: 'Policy Analyst', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> socialWorkMajorTopics = majorTopicAreas(
  majorId: 'social_work',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'case_management',
      name: 'Case Management',
      emoji: '🤝',
      topics: <PracticeLabTopic>[
        labTopic(id: 'intake_assessment', name: 'Intake Assessment', description: 'Complete biopsychosocial assessment for a new client.', style: SimulationStyle.counseling, aiRole: 'Client in Crisis'),
        labTopic(id: 'resource_linkage', name: 'Resource Linkage', description: 'Connect a homeless family to housing and benefits.', style: SimulationStyle.counseling, aiRole: 'Family Client'),
        labTopic(id: 'documentation', name: 'Case Documentation', description: 'Write court-ready documentation for a child welfare case.', style: SimulationStyle.diagnosis, aiRole: 'Supervisor', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> counselingMajorTopics = majorTopicAreas(
  majorId: 'counseling',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'therapeutic_skills',
      name: 'Therapeutic Skills',
      emoji: '💬',
      topics: <PracticeLabTopic>[
        labTopic(id: 'active_listening', name: 'Active Listening', description: 'Practice reflective listening with a resistant client.', style: SimulationStyle.counseling, aiRole: 'Resistant Client'),
        labTopic(id: 'boundaries', name: 'Professional Boundaries', description: 'Navigate dual-relationship ethical dilemmas.', style: SimulationStyle.counseling, aiRole: 'Ethics Board'),
        labTopic(id: 'motivational', name: 'Motivational Interviewing', description: 'Use MI techniques with ambivalent substance use client.', style: SimulationStyle.counseling, aiRole: 'Ambivalent Client', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> anthropologyMajorTopics = majorTopicAreas(
  majorId: 'anthropology',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'cultural',
      name: 'Cultural Anthropology',
      emoji: '🌍',
      topics: <PracticeLabTopic>[
        labTopic(id: 'fieldwork', name: 'Fieldwork Ethics', description: 'Navigate informed consent in a sensitive cultural setting.', style: SimulationStyle.classroom, aiRole: 'IRB Chair'),
        labTopic(id: 'cultural_relativism', name: 'Cultural Analysis', description: 'Interpret ritual practice without imposing ethnocentric bias.', style: SimulationStyle.classroom, aiRole: 'Anthropology Professor', advanced: true),
      ],
    ),
    (
      id: 'applied',
      name: 'Applied Anthropology',
      emoji: '🏛️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'org_culture', name: 'Organizational Culture', description: 'Diagnose cultural friction in a post-merger organization.', style: SimulationStyle.customerScenario, aiRole: 'CEO'),
        labTopic(id: 'heritage', name: 'Heritage Preservation', description: 'Balance development with indigenous heritage protection.', style: SimulationStyle.customerScenario, aiRole: 'Tribal Representative', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> humanServicesMajorTopics = majorTopicAreas(
  majorId: 'human_services',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'community_services',
      name: 'Community Services',
      emoji: '🏘️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'program_design', name: 'Program Design', description: 'Design a community program for at-risk youth with limited funding.', style: SimulationStyle.customerScenario, aiRole: 'Nonprofit Director'),
        labTopic(id: 'advocacy', name: 'Client Advocacy', description: 'Advocate for a client denied disability benefits.', style: SimulationStyle.customerScenario, aiRole: 'Benefits Examiner', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> behavioralScienceMajorTopics = majorTopicAreas(
  majorId: 'behavioral_science',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'aba',
      name: 'Applied Behavior Analysis',
      emoji: '📈',
      topics: <PracticeLabTopic>[
        labTopic(id: 'behavior_plans', name: 'Behavior Intervention Plans', description: 'Design BIP for aggressive behavior in school settings.', style: SimulationStyle.classroom, aiRole: 'BCBA Supervisor'),
        labTopic(id: 'data_collection', name: 'Behavioral Data Collection', description: 'Choose measurement systems and interpret trend data.', style: SimulationStyle.diagnosis, aiRole: 'Program Director', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> politicalScienceMajorTopics = majorTopicAreas(
  majorId: 'political_science',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'government',
      name: 'Government & Policy',
      emoji: '🏛️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'policy_memo', name: 'Policy Memo Writing', description: 'Write a policy memo recommending action on climate legislation.', style: SimulationStyle.customerScenario, aiRole: 'Legislative Staffer'),
        labTopic(id: 'campaigns', name: 'Political Campaigns', description: 'Develop messaging strategy for a competitive local election.', style: SimulationStyle.customerScenario, aiRole: 'Campaign Manager', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> internationalRelationsMajorTopics = majorTopicAreas(
  majorId: 'international_relations',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'diplomacy',
      name: 'Diplomacy & Conflict',
      emoji: '🌐',
      topics: <PracticeLabTopic>[
        labTopic(id: 'negotiation', name: 'Diplomatic Negotiation', description: 'Mediate a territorial dispute between allied nations.', style: SimulationStyle.customerScenario, aiRole: 'Foreign Minister'),
        labTopic(id: 'sanctions', name: 'Sanctions Strategy', description: 'Evaluate economic sanctions effectiveness and humanitarian impact.', style: SimulationStyle.customerScenario, aiRole: 'UN Delegate', advanced: true),
        labTopic(id: 'peacekeeping', name: 'Peacekeeping Operations', description: 'Plan peacekeeping mandate for a post-conflict zone.', style: SimulationStyle.erEmergency, aiRole: 'Security Council Advisor', advanced: true),
      ],
    ),
  ],
);

final Map<String, List<PracticeLabTopicArea>> socialScienceTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'psychology': psychologyMajorTopics,
  'sociology': sociologyMajorTopics,
  'social_work': socialWorkMajorTopics,
  'counseling': counselingMajorTopics,
  'anthropology': anthropologyMajorTopics,
  'human_services': humanServicesMajorTopics,
  'behavioral_science': behavioralScienceMajorTopics,
  'political_science': politicalScienceMajorTopics,
  'international_relations': internationalRelationsMajorTopics,
};
