enum MathPracticeQuestionKind {
  multipleChoice,
  graph,
  freeResponse,
}

enum MathPracticeDifficulty {
  easy,
  intermediate,
  advanced;

  String get label => switch (this) {
        MathPracticeDifficulty.easy => 'Easy',
        MathPracticeDifficulty.intermediate => 'Intermediate',
        MathPracticeDifficulty.advanced => 'Advanced',
      };
}

class MathPracticeQuestion {
  const MathPracticeQuestion({
    required this.id,
    required this.prompt,
    required this.kind,
    required this.difficulty,
    this.options = const <String>[],
    this.correctOptionIndex,
    this.graphNote,
  });

  final String id;
  final String prompt;
  final MathPracticeQuestionKind kind;
  final MathPracticeDifficulty difficulty;
  final List<String> options;
  final int? correctOptionIndex;
  final String? graphNote;

  String get hashKey => prompt.trim().toLowerCase();

  bool get isMultipleChoice =>
      kind == MathPracticeQuestionKind.multipleChoice && options.length >= 2;
}

class MathPracticeAnswer {
  const MathPracticeAnswer({
    required this.question,
    required this.studentAnswer,
    required this.isCorrect,
  });

  final MathPracticeQuestion question;
  final String studentAnswer;
  final bool isCorrect;
}
