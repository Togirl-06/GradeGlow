/// Course → Unit → Chapter architecture. Notes follow this tree; they are not random.
abstract final class TextbookArchitecture {
  static CourseOutline outlineFor({
    required String subjectId,
    required String courseTitle,
    required String topicTitle,
  }) {
    final String s = subjectId.toLowerCase();
    final String course = courseTitle.toLowerCase();
    if (s.contains('bio') || course.contains('biology')) {
      return _biology(topicTitle);
    }
    if (s.contains('chem') || course.contains('chem')) {
      return _chemistry(topicTitle);
    }
    if (s.contains('phys') || course.contains('phys')) {
      return _physics(topicTitle);
    }
    if (s.contains('nurs') || s.contains('med') || course.contains('nurs')) {
      return _clinical(topicTitle);
    }
    if (s.contains('law')) return _law(topicTitle);
    if (s.contains('bus') ||
        s.contains('fin') ||
        s.contains('account') ||
        s.contains('market')) {
      return _business(topicTitle);
    }
    return CourseOutline(
      courseCode: _shortCode(courseTitle),
      courseTitle: courseTitle,
      unitTitle: 'Unit — Core studies',
      chapterTitle: topicTitle,
      chapterNumber: 1,
    );
  }

  static String _shortCode(String courseTitle) {
    final String raw =
        courseTitle.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '-');
    return raw.length <= 12 ? raw : raw.substring(0, 12);
  }

  static CourseOutline _biology(String topic) {
    final List<(String, List<String>, String)> units = <(String, List<String>, String)>[
      (
        'Unit 1 — Foundations of Biology',
        <String>[
          'What Is Biology?',
          'The Characteristics of Life',
          'Scientific Method',
          'Experimental Design',
          'Data and Scientific Reasoning',
        ],
        'BIO-101',
      ),
      (
        'Unit 2 — Chemistry of Life',
        <String>[
          'Atoms and Elements',
          'Chemical Bonds',
          'Water',
          'Acids and Bases',
          'Macromolecules',
          'Carbohydrates',
          'Lipids',
          'Proteins',
          'Nucleic Acids',
        ],
        'BIO-101',
      ),
      (
        'Unit 3 — Cell Biology',
        <String>[
          'Cell Theory',
          'Cell Structure',
          'Prokaryotic vs Eukaryotic Cells',
          'Cell Membrane',
          'Membrane Transport',
          'Transport',
          'Organelles',
          'Cellular Energy',
          'Cellular Respiration',
          'Photosynthesis',
          'Cell Communication',
        ],
        'BIO-101',
      ),
      (
        'Unit 4 — Genetics',
        <String>[
          'DNA',
          'DNA Structure',
          'DNA Replication',
          'Transcription',
          'Translation',
          'Gene Expression',
          'Mendelian Genetics',
          'Genetic Disorders',
        ],
        'BIO-101',
      ),
    ];
    return _match('BIO-101', 'General Biology', topic, units);
  }

  static CourseOutline _chemistry(String topic) {
    return _match(
      'CHEM-101',
      'General Chemistry',
      topic,
      <(String, List<String>, String)>[
        (
          'Unit — Stoichiometry and solutions',
          <String>['Molarity', 'Titration', 'Acid-Base', 'pH', 'Buffers'],
          'CHEM-101',
        ),
      ],
    );
  }

  static CourseOutline _physics(String topic) {
    return _match(
      'PHYS-101',
      'Introductory Physics',
      topic,
      <(String, List<String>, String)>[
        (
          'Unit — Mechanics',
          <String>['Kinematics', 'Gravity', 'Free Fall', 'Newton', 'Energy'],
          'PHYS-101',
        ),
      ],
    );
  }

  static CourseOutline _clinical(String topic) {
    return _match(
      'NURS-201',
      'Clinical Practice',
      topic,
      <(String, List<String>, String)>[
        (
          'Unit — Acute care',
          <String>['Vital Signs', 'Chest Pain', 'ABC', 'Triage', 'Cardiac'],
          'NURS-201',
        ),
      ],
    );
  }

  static CourseOutline _law(String topic) {
    return _match(
      'LAW-101',
      'Introduction to Law',
      topic,
      <(String, List<String>, String)>[
        (
          'Unit — Private law',
          <String>['Contracts', 'Consideration', 'Torts', 'Evidence', 'Negligence'],
          'LAW-101',
        ),
      ],
    );
  }

  static CourseOutline _business(String topic) {
    return _match(
      'BUS-101',
      'Business Analysis',
      topic,
      <(String, List<String>, String)>[
        (
          'Unit — Firm performance',
          <String>['Revenue', 'Strategy', 'Marketing', 'Finance', 'Customers'],
          'BUS-101',
        ),
      ],
    );
  }

  static CourseOutline _match(
    String code,
    String course,
    String topic,
    List<(String, List<String>, String)> units,
  ) {
    final String t = topic.toLowerCase();
    for (final (String unit, List<String> chapters, String c) in units) {
      for (int i = 0; i < chapters.length; i++) {
        if (t.contains(chapters[i].toLowerCase()) ||
            chapters[i].toLowerCase().contains(t) ||
            _tokensOverlap(t, chapters[i].toLowerCase())) {
          return CourseOutline(
            courseCode: c,
            courseTitle: course,
            unitTitle: unit,
            chapterTitle: topic,
            chapterNumber: i + 1,
          );
        }
      }
    }
    return CourseOutline(
      courseCode: code,
      courseTitle: course,
      unitTitle: units.first.$1,
      chapterTitle: topic,
      chapterNumber: 1,
    );
  }

  static bool _tokensOverlap(String a, String b) {
    final Set<String> sa = a
        .split(RegExp(r'[^a-z0-9]+'))
        .where((String w) => w.length > 3)
        .toSet();
    final Set<String> sb = b
        .split(RegExp(r'[^a-z0-9]+'))
        .where((String w) => w.length > 3)
        .toSet();
    return sa.intersection(sb).isNotEmpty;
  }
}

class CourseOutline {
  const CourseOutline({
    required this.courseCode,
    required this.courseTitle,
    required this.unitTitle,
    required this.chapterTitle,
    required this.chapterNumber,
  });

  final String courseCode;
  final String courseTitle;
  final String unitTitle;
  final String chapterTitle;
  final int chapterNumber;

  String get heading =>
      '$courseCode  ·  $unitTitle  ·  Chapter $chapterNumber — $chapterTitle';
}

