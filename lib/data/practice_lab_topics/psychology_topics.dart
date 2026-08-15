import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';

const List<PracticeLabTopicArea> psychologyTopicAreas = <PracticeLabTopicArea>[
  PracticeLabTopicArea(
    id: 'general_psychology',
    name: 'General Psychology',
    emoji: '🧠',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'behavior_analysis', name: 'Behavior Analysis', description: 'Apply learning theory to explain and modify a behavior pattern.', style: SimulationStyle.classroom, aiRole: 'Professor'),
      PracticeLabTopic(id: 'cognitive_assessment', name: 'Cognitive Assessment', description: 'Administer and interpret cognitive screening results.', style: SimulationStyle.counseling, aiRole: 'Client', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'complex_cases', name: 'Complex Case Studies', description: 'Formulate a biopsychosocial formulation for a multifaceted case.', style: SimulationStyle.counseling, aiRole: 'Client', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'clinical_psychology',
    name: 'Clinical Psychology',
    emoji: '🛋️',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'anxiety_disorders', name: 'Anxiety Disorders', description: 'Conduct an intake for generalized anxiety and plan CBT interventions.', style: SimulationStyle.counseling, aiRole: 'Anxious Client'),
      PracticeLabTopic(id: 'depression_cases', name: 'Depression Cases', description: 'Assess suicide risk and develop a safety plan with a depressed client.', style: SimulationStyle.counseling, aiRole: 'Depressed Client', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'crisis_intervention', name: 'Crisis Intervention', description: 'De-escalate an acute psychiatric crisis over the phone.', style: SimulationStyle.counseling, aiRole: 'Crisis Caller', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'developmental_psychology',
    name: 'Developmental Psychology',
    emoji: '👨‍👩‍👧',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'child_development', name: 'Child Development', description: 'Evaluate developmental milestones with concerned parents.', style: SimulationStyle.counseling, aiRole: 'Parent'),
      PracticeLabTopic(id: 'adolescence', name: 'Adolescence', description: 'Counsel a teen struggling with identity and peer pressure.', style: SimulationStyle.counseling, aiRole: 'Teen Client', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'lifespan_assessments', name: 'Lifespan Assessments', description: 'Integrate developmental stages into a comprehensive case conceptualization.', style: SimulationStyle.classroom, aiRole: 'Supervisor', beginner: false, intermediate: true, advanced: true),
    ],
  ),
];
