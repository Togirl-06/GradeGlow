import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';

const List<PracticeLabTopicArea> educationTopicAreas = <PracticeLabTopicArea>[
  PracticeLabTopicArea(
    id: 'classroom_management',
    name: 'Classroom Management',
    emoji: '🏫',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'student_engagement', name: 'Student Engagement', description: 'Re-engage a disengaged class mid-lesson.', style: SimulationStyle.classroom, aiRole: 'Student'),
      PracticeLabTopic(id: 'disruptive_behavior', name: 'Disruptive Behavior', description: 'Manage repeated disruptions without escalating conflict.', style: SimulationStyle.classroom, aiRole: 'Disruptive Student', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'parent_conflicts', name: 'Parent Conflicts', description: 'Navigate a heated parent-teacher conference about grades.', style: SimulationStyle.classroom, aiRole: 'Upset Parent', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'lesson_planning',
    name: 'Lesson Planning',
    emoji: '📋',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'objectives', name: 'Learning Objectives', description: 'Write measurable objectives and defend them to an administrator.', style: SimulationStyle.classroom, aiRole: 'Principal'),
      PracticeLabTopic(id: 'activities', name: 'Activities', description: 'Design differentiated activities for mixed-ability learners.', style: SimulationStyle.classroom, aiRole: 'Curriculum Coach', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'unit_planning', name: 'Full Unit Planning', description: 'Pitch a complete unit plan with assessments and pacing.', style: SimulationStyle.classroom, aiRole: 'Department Chair', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'special_education',
    name: 'Special Education',
    emoji: '♿',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'accommodations', name: 'Accommodations', description: 'Select appropriate accommodations for a student with ADHD.', style: SimulationStyle.classroom, aiRole: 'Special Ed Coordinator'),
      PracticeLabTopic(id: 'iep_development', name: 'IEP Development', description: 'Lead an IEP meeting with parents and multidisciplinary staff.', style: SimulationStyle.classroom, aiRole: 'Parent Advocate', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'behavioral_intervention', name: 'Behavioral Intervention', description: 'Design a BIP for a student with challenging behaviors.', style: SimulationStyle.classroom, aiRole: 'Behavior Specialist', beginner: false, intermediate: true, advanced: true),
    ],
  ),
];
