import 'package:flutter/material.dart';

import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_subject.dart';
import '../models/practice_lab_topic.dart';
import '../models/practice_lab_unit.dart';
import 'practice_lab_course_topics.dart';
import 'world_curriculum_topics.dart';

/// Subject → Course → Topic university catalog for Practice Labs.
class PracticeLabUniversityCatalog {
  PracticeLabUniversityCatalog._();

  static final List<PracticeLabSubject> subjects = <PracticeLabSubject>[
    _build(
      'mathematics',
      'Mathematics',
      '📐',
      Icons.calculate_outlined,
      'mathematics_finance',
      _courses('mathematics', _mathCourses),
    ),
    _build(
      'computer_science',
      'Computer Science',
      '💻',
      Icons.code_rounded,
      'computer_technology',
      _courses('computer_science', _csCourses),
    ),
    _build(
      'sciences',
      'School of Sciences',
      '🔬',
      Icons.science_rounded,
      'science',
      _scienceCourses,
    ),
    _build(
      'biology',
      'Biology',
      '🧬',
      Icons.biotech_rounded,
      'science',
      _courses('biology', _bioCourses),
    ),
    _build(
      'chemistry',
      'Chemistry',
      '⚗️',
      Icons.science_outlined,
      'science',
      _courses('chemistry', _chemCourses),
    ),
    _build(
      'physics',
      'Physics',
      '⚛️',
      Icons.bolt_rounded,
      'science',
      _courses('physics', _physicsCourses),
    ),
    _build(
      'environmental_science',
      'Environmental Science',
      '🌍',
      Icons.public_outlined,
      'science',
      _courses('environmental_science', const <String>[]),
    ),
    _build(
      'nursing',
      'Nursing',
      '🩺',
      Icons.medical_services_outlined,
      'health_medical',
      _courses('nursing', _nursingCourses),
    ),
    _build(
      'medicine',
      'Medicine',
      '🏥',
      Icons.local_hospital_outlined,
      'health_medical',
      _courses('medicine', _medicineCourses),
    ),
    _build(
      'psychology',
      'Psychology',
      '🧠',
      Icons.psychology_outlined,
      'psychology_social_sciences',
      _courses('psychology', _psychCourses),
    ),
    _build(
      'business',
      'Business',
      '💼',
      Icons.business_center_outlined,
      'business',
      _courses('business', _businessCourses),
    ),
    _build(
      'law',
      'Law',
      '⚖️',
      Icons.gavel_rounded,
      'law_criminal_justice',
      _courses('law', _lawCourses),
    ),
    _build(
      'engineering',
      'Engineering',
      '⚙️',
      Icons.engineering_outlined,
      'engineering',
      _courses('engineering', _engineeringCourses),
    ),
    _build(
      'english',
      'English',
      '✍️',
      Icons.edit_note_outlined,
      'humanities',
      _courses('english', _englishCourses),
    ),
    _build(
      'political_science',
      'Political Science',
      '🏛️',
      Icons.account_balance_outlined,
      'humanities',
      _courses('political_science', const <String>[]),
    ),
  ];

  /// Prefer world curriculum course lists when available; else fallback.
  static List<String> _courses(String subjectId, List<String> fallback) {
    final List<String> world = WorldCurriculumTopics.coursesFor(subjectId);
    return world.isNotEmpty ? world : fallback;
  }

  static int get totalTopicCount =>
      subjects.fold<int>(0, (int n, PracticeLabSubject s) => n + s.topicCount);

  static String get formattedTopicCountLabel {
    final int total = totalTopicCount;
    if (total >= 1000) return '${(total ~/ 1000)}k+ topics';
    return '$total+ topics';
  }

  static PracticeLabSubject? subjectById(String id) {
    for (final PracticeLabSubject s in subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  static PracticeLabCourse? courseById(String subjectId, String courseId) {
    final PracticeLabSubject? subject = subjectById(subjectId);
    if (subject == null) return null;
    for (final PracticeLabCourse c in subject.courses) {
      if (c.id == courseId) return c;
    }
    return null;
  }

  static List<UniversitySearchHit> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <UniversitySearchHit>[];

    final List<UniversitySearchHit> hits = <UniversitySearchHit>[];
    for (final PracticeLabSubject subject in subjects) {
      if (subject.name.toLowerCase().contains(q)) {
        hits.add(UniversitySearchHit.subject(subject));
      }
      for (final PracticeLabCourse course in subject.courses) {
        if (course.name.toLowerCase().contains(q)) {
          hits.add(UniversitySearchHit.course(subject, course));
        }
        for (final PracticeLabUnit unit in course.units) {
          if (unit.name.toLowerCase().contains(q)) {
            hits.add(UniversitySearchHit.unit(subject, course, unit));
          }
          for (final PracticeLabTopic topic in unit.topics) {
            if (topic.name.toLowerCase().contains(q) ||
                topic.description.toLowerCase().contains(q)) {
              hits.add(UniversitySearchHit.topic(subject, course, unit, topic));
            }
            if (hits.length >= 40) return hits;
          }
        }
      }
    }
    return hits;
  }

  /// Builds a [PracticeLabType] for a university topic session.
  static PracticeLabType labFor({
    required PracticeLabSubject subject,
    required PracticeLabCourse course,
    required PracticeLabUnit unit,
    required PracticeLabTopic topic,
    required PracticeDifficulty difficulty,
  }) {
    final String labLabel = switch (subject.groupId) {
      'law_criminal_justice' => '${difficulty.label} Court Case',
      'computer_technology' => '${difficulty.label} Coding Lab',
      'health_medical' => '${difficulty.label} Clinical Lab',
      _ => '${difficulty.label} Lab',
    };

    return PracticeLabType(
      id: 'uni_${subject.id}_${course.id}_${unit.id}_${topic.id}_${difficulty.name}',
      title: topic.name,
      subtitle: '${course.name} · ${unit.name} · $labLabel',
      style: topic.style,
      codeLab:
          subject.id == 'computer_science' &&
          PracticeLabCourseTopics.codeLabForCourse(subject.id, course.id),
      timed: topic.style == SimulationStyle.erEmergency,
      aiRole: topic.aiRole,
      studentTasks: topic.studentTasks,
      evaluationCriteria: topic.evaluationCriteria,
      difficulty: difficulty.label,
    );
  }

  static PracticeLabSubject _build(
    String id,
    String name,
    String emoji,
    IconData icon,
    String groupId,
    List<String> courseNames,
  ) {
    return PracticeLabSubject(
      id: id,
      name: name,
      emoji: emoji,
      icon: icon,
      groupId: groupId,
      courses: courseNames.map((String courseName) {
        final String courseId = PracticeLabCourseTopics.slug(courseName);
        return PracticeLabCourse(
          id: courseId,
          name: courseName,
          subjectId: id,
          groupId: groupId,
        );
      }).toList(),
    );
  }

  static const List<String> _mathCourses = <String>[
    'College Algebra',
    'Precalculus',
    'Calculus I',
    'Calculus II',
    'Calculus III',
    'Differential Equations',
    'Linear Algebra',
    'Statistics',
    'Discrete Mathematics',
  ];
  static const List<String> _csCourses = <String>[
    'Programming Fundamentals',
    'Data Structures',
    'Algorithms',
    'Databases',
    'Operating Systems',
    'Computer Networks',
    'Software Engineering',
    'Artificial Intelligence',
    'Machine Learning',
    'Cybersecurity',
  ];
  static const List<String> _bioCourses = <String>[
    'General Biology',
    'Cell Biology',
    'Genetics',
    'Microbiology',
    'Anatomy',
    'Physiology',
    'Ecology',
  ];
  static const List<String> _scienceCourses = <String>[
    'Biology',
    'Chemistry',
    'Physics',
  ];
  static const List<String> _chemCourses = <String>[
    'General Chemistry',
    'Organic Chemistry',
    'Biochemistry',
    'Analytical Chemistry',
    'Physical Chemistry',
  ];
  static const List<String> _physicsCourses = <String>[
    'Mechanics',
    'Electricity & Magnetism',
    'Thermodynamics',
    'Modern Physics',
  ];
  static const List<String> _nursingCourses = <String>[
    'Fundamentals',
    'Pharmacology',
    'Health Assessment',
    'Pediatrics',
    'Medical-Surgical Nursing',
    'Obstetrics',
    'Mental Health Nursing',
    'Critical Care',
  ];
  static const List<String> _medicineCourses = <String>[
    'Anatomy',
    'Physiology',
    'Pathology',
    'Pharmacology',
    'Internal Medicine',
    'Surgery',
    'Emergency Medicine',
  ];
  static const List<String> _psychCourses = <String>[
    'General Psychology',
    'Cognitive Psychology',
    'Developmental Psychology',
    'Clinical Psychology',
    'Abnormal Psychology',
  ];
  static const List<String> _businessCourses = <String>[
    'Introduction to Business',
    'Business Mathematics',
    'Business Communication',
    'Principles of Management',
    'Principles of Marketing',
    'Principles of Accounting',
    'Human Resource Management',
    'Organizational Behavior',
    'Operations Management',
    'Business Law',
    'Business Statistics',
    'Information Systems for Business',
    'Strategic Management',
    'Entrepreneurship',
    'International Business',
    'Supply Chain Management',
    'Project Management',
    'Business Analytics',
    'Corporate Governance',
    'Innovation Management',
    'Digital Business',
    'Business Consulting',
    'Leadership',
    'Risk Management',
    'Sustainability',
    'Capstone Project',
    'Business Electives',
    'Modern Business Topics',
    'Essential Business Skills',
  ];
  static const List<String> _lawCourses = <String>[
    'Criminal Law',
    'Constitutional Law',
    'Contract Law',
    'Torts',
    'Civil Procedure',
    'Evidence',
  ];
  static const List<String> _engineeringCourses = <String>[
    'Statics',
    'Dynamics',
    'Thermodynamics',
    'Fluid Mechanics',
    'Circuits',
    'Materials Science',
  ];
  static const List<String> _englishCourses = <String>[
    'Composition',
    'Literature',
    'Creative Writing',
    'Technical Writing',
  ];
}

enum UniversitySearchKind { subject, course, unit, topic }

class UniversitySearchHit {
  const UniversitySearchHit._({
    required this.kind,
    required this.subject,
    this.course,
    this.unit,
    this.topic,
  });

  factory UniversitySearchHit.subject(PracticeLabSubject subject) =>
      UniversitySearchHit._(
        kind: UniversitySearchKind.subject,
        subject: subject,
      );

  factory UniversitySearchHit.course(
    PracticeLabSubject subject,
    PracticeLabCourse course,
  ) => UniversitySearchHit._(
    kind: UniversitySearchKind.course,
    subject: subject,
    course: course,
  );

  factory UniversitySearchHit.unit(
    PracticeLabSubject subject,
    PracticeLabCourse course,
    PracticeLabUnit unit,
  ) => UniversitySearchHit._(
    kind: UniversitySearchKind.unit,
    subject: subject,
    course: course,
    unit: unit,
  );

  factory UniversitySearchHit.topic(
    PracticeLabSubject subject,
    PracticeLabCourse course,
    PracticeLabUnit unit,
    PracticeLabTopic topic,
  ) => UniversitySearchHit._(
    kind: UniversitySearchKind.topic,
    subject: subject,
    course: course,
    unit: unit,
    topic: topic,
  );

  final UniversitySearchKind kind;
  final PracticeLabSubject subject;
  final PracticeLabCourse? course;
  final PracticeLabUnit? unit;
  final PracticeLabTopic? topic;
}
