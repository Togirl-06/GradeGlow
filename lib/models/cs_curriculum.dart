/// Difficulty band for curriculum progression.
enum CsCurriculumLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const CsCurriculumLevel(this.label);
  final String label;
}

/// A programming or web language track.
class CsCurriculumLanguage {
  const CsCurriculumLanguage({
    required this.id,
    required this.label,
    required this.codingLanguageId,
    this.isWeb = false,
  });

  final String id;
  final String label;
  /// Default language for try-it exercises and LeetCode-style problems.
  final String codingLanguageId;
  final bool isWeb;
}

/// One lesson in a language track: micro-lesson → exercise → problems.
class CsCurriculumTopic {
  const CsCurriculumTopic({
    required this.id,
    required this.languageId,
    required this.title,
    required this.order,
    required this.level,
  });

  final String id;
  final String languageId;
  final String title;
  final int order;
  final CsCurriculumLevel level;
}

/// Shared algorithms track (unlocked after language fundamentals).
class CsAlgorithmsTopic {
  const CsAlgorithmsTopic({
    required this.id,
    required this.title,
    required this.order,
    required this.level,
    required this.problemBankKey,
  });

  final String id;
  final String title;
  final int order;
  final CsCurriculumLevel level;
  final String problemBankKey;
}
