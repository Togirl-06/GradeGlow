import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

final List<PracticeLabTopicArea> elementaryEducationMajorTopics = majorTopicAreas(
  majorId: 'elementary_education',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'elementary_classroom',
      name: 'Elementary Classroom',
      emoji: '🍎',
      topics: <PracticeLabTopic>[
        labTopic(id: 'engagement', name: 'Student Engagement', description: 'Re-engage a disengaged 3rd-grade class mid-lesson.', style: SimulationStyle.classroom, aiRole: 'Student'),
        labTopic(id: 'literacy', name: 'Literacy Instruction', description: 'Differentiate reading instruction for mixed ability groups.', style: SimulationStyle.classroom, aiRole: 'Reading Specialist'),
        labTopic(id: 'math_manipulatives', name: 'Hands-On Math', description: 'Teach fractions using manipulatives to struggling learners.', style: SimulationStyle.classroom, aiRole: 'Student', advanced: true),
      ],
    ),
    (
      id: 'elementary_mgmt',
      name: 'Classroom Management',
      emoji: '🏫',
      topics: <PracticeLabTopic>[
        labTopic(id: 'disruption', name: 'Disruptive Behavior', description: 'Manage repeated disruptions without escalating conflict.', style: SimulationStyle.classroom, aiRole: 'Disruptive Student'),
        labTopic(id: 'parent_conf', name: 'Parent Conferences', description: 'Navigate a heated parent-teacher conference about grades.', style: SimulationStyle.classroom, aiRole: 'Upset Parent', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> secondaryEducationMajorTopics = majorTopicAreas(
  majorId: 'secondary_education',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'secondary_instruction',
      name: 'Secondary Instruction',
      emoji: '📚',
      topics: <PracticeLabTopic>[
        labTopic(id: 'lesson_design', name: 'Lesson Design', description: 'Design a 50-minute lesson with formative checks for understanding.', style: SimulationStyle.classroom, aiRole: 'Department Chair'),
        labTopic(id: 'discourse', name: 'Academic Discourse', description: 'Facilitate Socratic discussion on a controversial historical topic.', style: SimulationStyle.classroom, aiRole: 'Student', advanced: true),
        labTopic(id: 'assessment', name: 'Assessment Design', description: 'Create rubrics that measure higher-order thinking skills.', style: SimulationStyle.classroom, aiRole: 'Principal'),
      ],
    ),
    (
      id: 'secondary_mgmt',
      name: 'Secondary Classroom Management',
      emoji: '🎓',
      topics: <PracticeLabTopic>[
        labTopic(id: 'cell_phones', name: 'Digital Distractions', description: 'Enforce phone policy while maintaining student rapport.', style: SimulationStyle.classroom, aiRole: 'High School Student'),
        labTopic(id: 'cheating', name: 'Academic Integrity', description: 'Address suspected cheating with restorative approach.', style: SimulationStyle.classroom, aiRole: 'Student', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> specialEducationMajorTopics = majorTopicAreas(
  majorId: 'special_education',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'sped_practice',
      name: 'Special Education Practice',
      emoji: '♿',
      topics: <PracticeLabTopic>[
        labTopic(id: 'accommodations', name: 'Accommodations', description: 'Select accommodations for a student with ADHD.', style: SimulationStyle.classroom, aiRole: 'Special Ed Coordinator'),
        labTopic(id: 'iep', name: 'IEP Development', description: 'Lead an IEP meeting with parents and multidisciplinary staff.', style: SimulationStyle.classroom, aiRole: 'Parent Advocate', advanced: true),
        labTopic(id: 'bip', name: 'Behavioral Intervention', description: 'Design a BIP for challenging behaviors with data targets.', style: SimulationStyle.classroom, aiRole: 'Behavior Specialist', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> earlyChildhoodMajorTopics = majorTopicAreas(
  majorId: 'early_childhood_education',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'early_learning',
      name: 'Early Childhood Learning',
      emoji: '🧸',
      topics: <PracticeLabTopic>[
        labTopic(id: 'play_based', name: 'Play-Based Learning', description: 'Design play centers that develop social-emotional skills.', style: SimulationStyle.classroom, aiRole: 'Center Director'),
        labTopic(id: 'developmental_screen', name: 'Developmental Screening', description: 'Discuss screening results sensitively with concerned parents.', style: SimulationStyle.counseling, aiRole: 'Parent'),
        labTopic(id: 'inclusion_ece', name: 'Inclusive Early Childhood', description: 'Adapt activities for children with diverse developmental needs.', style: SimulationStyle.classroom, aiRole: 'Early Intervention Specialist', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> educationalLeadershipMajorTopics = majorTopicAreas(
  majorId: 'educational_leadership',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'school_leadership',
      name: 'School Leadership',
      emoji: '🏛️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'budget', name: 'School Budget Crisis', description: 'Make cuts while preserving instructional quality.', style: SimulationStyle.customerScenario, aiRole: 'School Board'),
        labTopic(id: 'teacher_eval', name: 'Teacher Evaluation', description: 'Conduct difficult evaluation conversation with tenured teacher.', style: SimulationStyle.customerScenario, aiRole: 'Teacher'),
        labTopic(id: 'community', name: 'Community Relations', description: 'Address community backlash over curriculum changes.', style: SimulationStyle.customerScenario, aiRole: 'Community Leader', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> tesolMajorTopics = majorTopicAreas(
  majorId: 'tesol',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'esl_instruction',
      name: 'ESL Instruction',
      emoji: '🗣️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'scaffolding', name: 'Language Scaffolding', description: 'Scaffold content for newcomers with minimal English.', style: SimulationStyle.classroom, aiRole: 'ELL Student'),
        labTopic(id: 'pronunciation', name: 'Pronunciation Coaching', description: 'Provide corrective feedback without discouraging learners.', style: SimulationStyle.classroom, aiRole: 'Adult Learner'),
        labTopic(id: 'assessment_ell', name: 'ELL Assessment', description: 'Distinguish language proficiency from content knowledge in grading.', style: SimulationStyle.classroom, aiRole: 'Department Lead', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> curriculumInstructionMajorTopics = majorTopicAreas(
  majorId: 'curriculum_instruction',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'curriculum_design',
      name: 'Curriculum Design',
      emoji: '📋',
      topics: <PracticeLabTopic>[
        labTopic(id: 'objectives', name: 'Learning Objectives', description: 'Write measurable objectives and defend them to an administrator.', style: SimulationStyle.classroom, aiRole: 'Principal'),
        labTopic(id: 'unit_plan', name: 'Unit Planning', description: 'Pitch a complete unit with assessments and pacing.', style: SimulationStyle.classroom, aiRole: 'Department Chair', advanced: true),
        labTopic(id: 'standards_align', name: 'Standards Alignment', description: 'Align district curriculum to new state standards.', style: SimulationStyle.customerScenario, aiRole: 'Curriculum Director', advanced: true),
      ],
    ),
  ],
);

final Map<String, List<PracticeLabTopicArea>> educationTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'elementary_education': elementaryEducationMajorTopics,
  'secondary_education': secondaryEducationMajorTopics,
  'special_education': specialEducationMajorTopics,
  'early_childhood_education': earlyChildhoodMajorTopics,
  'educational_leadership': educationalLeadershipMajorTopics,
  'tesol': tesolMajorTopics,
  'curriculum_instruction': curriculumInstructionMajorTopics,
};
