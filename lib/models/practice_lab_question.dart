import 'leetcode_problem.dart';

/// One practice question within a topic session.
class PracticeLabQuestion {
  const PracticeLabQuestion({
    required this.id,
    required this.prompt,
    this.leetcode,
  });

  final String id;
  final String prompt;
  final LeetcodeProblem? leetcode;

  bool get isLeetcode => leetcode != null;

  /// Runnable test harness (Run / Submit / Test Result) — only for structured LC problems.
  bool get needsTestRunner => isLeetcode;

  /// Dark code editor — only when a structured problem supplies starter code and tests.
  bool get needsCodeEditor => isLeetcode;
}

/// Student response to a single question.
class PracticeLabQuestionResponse {
  const PracticeLabQuestionResponse({
    required this.question,
    required this.answer,
    required this.skipped,
    this.feedback,
  });

  final PracticeLabQuestion question;
  final String answer;
  final bool skipped;
  final String? feedback;
}
