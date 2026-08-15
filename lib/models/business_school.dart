import 'package:flutter/material.dart';

enum BusinessMajor {
  businessAdministration(
    'Management',
    '💼',
    Color(0xFFEA580C),
    'Build companies, lead teams, manage operations, and make board-level decisions.',
  ),
  economics(
    'Economics',
    '📈',
    Color(0xFF2563EB),
    'Run economies, markets, trade policy, and crisis response.',
  ),
  finance(
    'Finance',
    '💹',
    Color(0xFF059669),
    'Manage portfolios, banks, valuation, and corporate capital.',
  ),
  marketing(
    'Marketing',
    '📣',
    Color(0xFFDB2777),
    'Build brands, launch products, and optimize growth.',
  ),
  accounting(
    'Accounting',
    '🧾',
    Color(0xFF7C3AED),
    'Operate ledgers, statements, audits, tax, and cost systems.',
  );

  const BusinessMajor(this.title, this.emoji, this.color, this.tagline);

  final String title;
  final String emoji;
  final Color color;
  final String tagline;

  static BusinessMajor? fromId(String id) {
    for (final BusinessMajor major in values) {
      if (major.name == id) return major;
    }
    return null;
  }
}

enum BusinessActivityKind {
  professor(
    'Lecture',
    '🎓',
    'AI professor · full textbook explanation · voice narration',
    20,
  ),
  video(
    'Whiteboard Video',
    '🎥',
    'Animated whiteboard · chaptered video lessons',
    15,
  ),
  aiTutor('AI Tutor', '🤖', 'Step-by-step help on demand', 10),
  notes('Textbook Notes', '📖', 'Full textbook chapter · study anytime', 8),
  interactive(
    'Interactive Lesson',
    '🧠',
    'Manipulate concepts · guided examples',
    10,
  ),
  simulation(
    'Professional Simulation',
    '🧮',
    'Make decisions · observe consequences',
    15,
  ),
  ceoMentor(
    'AI CEO Mentor',
    '🧑‍💼',
    'Executive challenge · strategy · consequences',
    10,
  ),
  companySimulator(
    'Company Simulator',
    '🏭',
    'Build and operate a company over time',
    18,
  ),
  management(
    'Management Simulator',
    '👥',
    'Lead roles, people, projects, and stores',
    10,
  ),
  entrepreneurship(
    'Entrepreneurship Lab',
    '🚀',
    'Idea · business model · pitch · growth',
    10,
  ),
  operations(
    'Operations Management',
    '⚙️',
    'Inventory · suppliers · production · logistics',
    10,
  ),
  leadership(
    'Leadership Simulator',
    '🧭',
    'Resolve crises, conflict, and change',
    8,
  ),
  negotiation(
    'Negotiation Simulator',
    '🤝',
    'Negotiate with adaptive AI stakeholders',
    8,
  ),
  caseStudy(
    'Case Study',
    '💼',
    'Analyze evidence · defend a recommendation',
    10,
  ),
  dashboard(
    'Analytics Dashboard',
    '📊',
    'KPIs · charts · live operating data',
    8,
  ),
  homework('Homework', '📝', 'Progressive problems · detailed feedback', 7),
  project('Applied Project', '📑', 'Produce a professional deliverable', 7),
  internship(
    'Internship Simulation',
    '🏢',
    'Complete realistic workplace tasks',
    8,
  ),
  exam('Comprehensive Exam', '🎓', 'University-standard assessment', 3),
  capstone(
    'Final Capstone',
    '🏆',
    'Integrate theory, strategy, and execution',
    2,
  );

  const BusinessActivityKind(
    this.title,
    this.emoji,
    this.subtitle,
    this.weight,
  );

  final String title;
  final String emoji;
  final String subtitle;
  final int weight;

  int get xp => weight * 2;
}

/// Visible workspaces in each lesson hub.
List<BusinessActivityKind> businessActivityFlow(BusinessMajor _) {
  return const <BusinessActivityKind>[
    BusinessActivityKind.professor,
    BusinessActivityKind.video,
    BusinessActivityKind.notes,
    BusinessActivityKind.aiTutor,
    BusinessActivityKind.homework,
    BusinessActivityKind.exam,
  ];
}

/// Activities that count toward mastery, certificate, and badge.
List<BusinessActivityKind> businessRequiredActivities(BusinessMajor _) {
  return const <BusinessActivityKind>[
    BusinessActivityKind.professor,
    BusinessActivityKind.video,
    BusinessActivityKind.homework,
    BusinessActivityKind.exam,
  ];
}

bool businessActivityIsSupplemental(BusinessActivityKind kind) =>
    kind == BusinessActivityKind.notes || kind == BusinessActivityKind.aiTutor;

class BusinessTextbookSection {
  const BusinessTextbookSection({required this.title, required this.body});

  final String title;
  final String body;
}

class BusinessLectureNote {
  const BusinessLectureNote({
    required this.lessonId,
    required this.overview,
    required this.keyConcepts,
    required this.formulas,
    required this.workedExample,
    required this.application,
    required this.commonMistakes,
    required this.summary,
    required this.reviewQuestions,
    this.definitions = const <String>[],
    this.sections = const <BusinessTextbookSection>[],
    this.practiceProblems = const <String>[],
  });

  final String lessonId;
  final String overview;
  final List<String> keyConcepts;
  final List<String> formulas;
  final String workedExample;
  final String application;
  final List<String> commonMistakes;
  final String summary;
  final List<String> reviewQuestions;
  final List<String> definitions;
  final List<BusinessTextbookSection> sections;
  final List<String> practiceProblems;
}

class BusinessLesson {
  const BusinessLesson({
    required this.id,
    required this.title,
    required this.outcomes,
  });

  final String id;
  final String title;
  final List<String> outcomes;
}

class BusinessCourse {
  const BusinessCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.year,
    required this.emoji,
    required this.lessons,
  });

  final String id;
  final String code;
  final String title;
  final int year;
  final String emoji;
  final List<BusinessLesson> lessons;
}

class BusinessLessonPath {
  const BusinessLessonPath({
    required this.major,
    required this.course,
    required this.lesson,
  });

  final BusinessMajor major;
  final BusinessCourse course;
  final BusinessLesson lesson;

  String get breadcrumb => '${major.title} · ${course.code} ${course.title}';
}
