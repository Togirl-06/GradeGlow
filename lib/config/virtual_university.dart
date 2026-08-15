/// Brand vision, mission, and subject-world positioning for Grade Glow.
abstract final class VirtualUniversity {
  static const String name = 'Grade Glow Virtual University';

  static const String vision =
      'Provide affordable, high-quality education to anyone in the world, '
      'regardless of their financial situation, location, or background.';

  static const String mission =
      'Grade Glow Virtual University exists to provide affordable, high-quality '
      'education to anyone in the world, regardless of their financial situation, '
      'location, or background. Our goal is to give every student access to '
      'world-class education through AI-powered professors, interactive lessons, '
      'and career-focused learning.';

  static const String tagline =
      'World-class education for anyone, anywhere — powered by AI professors.';

  static const String heroHeadline = 'World-class university education — for everyone';

  static const String heroSubhead =
      'AI-powered professors, interactive lessons, and career-focused learning — '
      'so cost, location, or background never block a great education.';

  static const String companyStatement =
      'Grade Glow Virtual University exists to provide affordable, high-quality '
      'education to anyone in the world. We give every student access to world-class '
      'learning through AI-powered professors, interactive lessons, and career-focused '
      'programs — regardless of financial situation, location, or background.';

  /// Who GradeGlow is built for.
  static const List<String> whoWeServe = <String>[
    'Cannot afford university tuition',
    'Live where educational opportunities are limited',
    'Work full-time and cannot attend classes',
    'Dropped out of school',
    'Want a second chance at education',
    'Want university-level knowledge without debt',
  ];

  /// Old pattern vs new pattern — shown on hub screens.
  static const List<String> oldLearningPattern = <String>[
    'Lecture',
    'Notes',
    'Homework',
    'Exam',
    'Forget',
  ];

  static const List<String> learningLoop = <String>[
    'Learn',
    'Practice',
    'Feedback',
    'Master',
    'Apply',
  ];

  static const List<VirtualUniversityValue> coreValues =
      <VirtualUniversityValue>[
        VirtualUniversityValue(
          title: 'Education without debt',
          description: 'University depth for people locked out by tuition.',
          icon: '🌍',
        ),
        VirtualUniversityValue(
          title: 'Real lectures, not chatbots',
          description: 'AI professors teach for 20–40 minutes like faculty.',
          icon: '🎓',
        ),
        VirtualUniversityValue(
          title: 'Learning by Doing',
          description: 'Active practice beats passive reading.',
          icon: '🎯',
        ),
        VirtualUniversityValue(
          title: 'Personalized Education',
          description: 'AI adapts to your pace, gaps, and strengths.',
          icon: '🧠',
        ),
        VirtualUniversityValue(
          title: 'Second chances',
          description: 'Restart your education anytime, from anywhere.',
          icon: '♾️',
        ),
      ];

  /// Immersive positioning per major subject area.
  static SubjectWorld worldFor({
    required String subjectId,
    required String groupId,
  }) {
    return _worldsBySubjectId[subjectId] ??
        _worldsByGroup[groupId] ??
        _defaultWorld;
  }

  static const SubjectWorld _defaultWorld = SubjectWorld(
    id: 'general',
    title: 'Interactive Practice',
    emoji: '🎓',
    headline: 'Hands-on AI scenarios',
    experiences: <String>[
      'Topic-scoped practice labs',
      'AI tutor feedback',
      'Three difficulty levels',
    ],
  );

  static const Map<String, SubjectWorld> _worldsBySubjectId =
      <String, SubjectWorld>{
        'nursing': SubjectWorld(
          id: 'nursing',
          title: 'Health Sciences',
          emoji: '🩺',
          headline: 'Virtual hospitals & clinical floors',
          experiences: <String>[
            'AI patients',
            'Vital signs & triage',
            'Care plans & documentation',
          ],
        ),
        'medicine': SubjectWorld(
          id: 'medicine',
          title: 'Health Sciences',
          emoji: '🏥',
          headline: 'Teaching hospitals & diagnosis',
          experiences: <String>[
            'ER simulations',
            'Anatomy labeling',
            'Case workups',
          ],
        ),
        'biology': SubjectWorld(
          id: 'biology',
          title: 'Biology',
          emoji: '🧬',
          headline: 'Cells, organs & living systems',
          experiences: <String>[
            'Diagram labeling',
            'Microbiology ID',
            'Genetics labs',
          ],
        ),
        'chemistry': SubjectWorld(
          id: 'chemistry',
          title: 'Chemistry',
          emoji: '🧪',
          headline: 'Virtual laboratories',
          experiences: <String>[
            'Safe experiments',
            'Equipment drag-and-drop',
            'Reaction scenarios',
          ],
        ),
        'physics': SubjectWorld(
          id: 'physics',
          title: 'Physics',
          emoji: '⚛️',
          headline: 'Foundations → research — the complete physics universe',
          experiences: <String>[
            '376-topic master curriculum',
            'AI Professor lectures',
            '3D simulators & virtual labs',
            'Engineering projects & lab reports',
          ],
        ),
        'computer_science': SubjectWorld(
          id: 'computer_science',
          title: 'Computer Science',
          emoji: '💻',
          headline: 'Coding workspaces',
          experiences: <String>[
            'AI technical interviews',
            'Debugging labs',
            'Algorithm practice',
          ],
        ),
        'law': SubjectWorld(
          id: 'law',
          title: 'Law',
          emoji: '⚖️',
          headline: 'Virtual courtrooms',
          experiences: <String>[
            'Mock trials',
            'Case analysis',
            'Legal reasoning drills',
          ],
        ),
        'engineering': SubjectWorld(
          id: 'engineering',
          title: 'Engineering',
          emoji: '⚙️',
          headline: 'Design workshops',
          experiences: <String>[
            'Structural scenarios',
            'CAD-style challenges',
            'Systems thinking',
          ],
        ),
        'business': SubjectWorld(
          id: 'business',
          title: 'Business',
          emoji: '💼',
          headline: 'Company leadership academy',
          experiences: <String>[
            'AI professor lectures',
            'Whiteboard video lessons',
            'Strategy and operations cases',
          ],
        ),
        'english': SubjectWorld(
          id: 'english',
          title: 'English',
          emoji: '✍️',
          headline: 'AI language studio',
          experiences: <String>[
            'AI professor lectures',
            'Speaking/listening practice',
            'Writing and grammar coaching',
          ],
        ),
        'psychology': SubjectWorld(
          id: 'psychology',
          title: 'Psychology',
          emoji: '🧠',
          headline: 'Human behavior labs',
          experiences: <String>[
            'Case studies',
            'Assessment practice',
            'Therapeutic scenarios',
          ],
        ),
      };

  static const Map<String, SubjectWorld> _worldsByGroup =
      <String, SubjectWorld>{
        'health_medical': SubjectWorld(
          id: 'health',
          title: 'Health Sciences',
          emoji: '🏥',
          headline: 'Virtual hospitals',
          experiences: <String>[
            'AI patients',
            'Clinical simulations',
            'Anatomy labs',
          ],
        ),
        'law_criminal_justice': SubjectWorld(
          id: 'law',
          title: 'Law & Justice',
          emoji: '⚖️',
          headline: 'Virtual courtrooms',
          experiences: <String>[
            'AI judges & witnesses',
            'Mock trials',
            'Legal analysis',
          ],
        ),
        'computer_technology': SubjectWorld(
          id: 'cs',
          title: 'Technology',
          emoji: '💻',
          headline: 'Developer workspaces',
          experiences: <String>[
            'Live coding',
            'System design',
            'Interview prep',
          ],
        ),
        'science': SubjectWorld(
          id: 'science',
          title: 'Science',
          emoji: '🔬',
          headline: 'Interactive science worlds',
          experiences: <String>[
            'Virtual labs',
            'Diagram labeling',
            'Experiment scenarios',
          ],
        ),
        'engineering': SubjectWorld(
          id: 'engineering',
          title: 'Engineering',
          emoji: '🏗️',
          headline: 'Build & simulate',
          experiences: <String>[
            'Design challenges',
            'Structural labs',
            'Robotics scenarios',
          ],
        ),
        'business': SubjectWorld(
          id: 'business',
          title: 'Business',
          emoji: '📊',
          headline: 'Executive simulations',
          experiences: <String>[
            'Company strategy',
            'Marketing labs',
            'Leadership cases',
          ],
        ),
      };

  /// Featured worlds for the hub carousel (subject ids).
  static const List<String> featuredSubjectIds = <String>[
    'nursing',
    'medicine',
    'law',
    'computer_science',
    'chemistry',
    'biology',
    'physics',
    'english',
    'engineering',
    'business',
  ];
}

class SubjectWorld {
  const SubjectWorld({
    required this.id,
    required this.title,
    required this.emoji,
    required this.headline,
    required this.experiences,
  });

  final String id;
  final String title;
  final String emoji;
  final String headline;
  final List<String> experiences;
}

class VirtualUniversityValue {
  const VirtualUniversityValue({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final String icon;
}
