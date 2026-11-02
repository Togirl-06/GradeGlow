import '../../../models/english_lesson.dart';

/// Compact factories for question-bank activities.
class BankQ {
  const BankQ._();

  static EnglishActivity mc(
    String lessonId,
    String key,
    String prompt,
    List<String> options,
    int correct, {
    EnglishActivityDifficulty? difficulty,
    String? ok,
    String? bad,
    EnglishSkill skill = EnglishSkill.grammar,
  }) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: EnglishActivityKind.multipleChoice,
        skill: skill,
        prompt: prompt,
        options: options,
        correctIndex: correct,
        difficulty: difficulty ?? EnglishActivityDifficulty.hard,
        feedbackCorrect: ok ?? 'Correct!',
        feedbackWrong: bad ?? 'Try again.',
      );

  /// Challenge-level multiple choice — always marked hard for the mixer.
  static EnglishActivity hardMc(
    String lessonId,
    String key,
    String prompt,
    List<String> options,
    int correct, {
    String? ok,
    String? bad,
    EnglishSkill skill = EnglishSkill.grammar,
  }) =>
      mc(
        lessonId,
        key,
        prompt,
        options,
        correct,
        difficulty: EnglishActivityDifficulty.hard,
        ok: ok,
        bad: bad,
        skill: skill,
      );

  static EnglishActivity fill(
    String lessonId,
    String key,
    String prompt,
    String answer, {
    List<String> also = const <String>[],
    EnglishActivityDifficulty? difficulty,
    String? ok,
    String? bad,
    EnglishSkill skill = EnglishSkill.grammar,
  }) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: EnglishActivityKind.fillBlank,
        skill: skill,
        prompt: prompt,
        correctAnswer: answer,
        acceptableAnswers: <String>[answer, ...also],
        difficulty: difficulty ?? EnglishActivityDifficulty.hard,
        feedbackCorrect: ok ?? 'Right!',
        feedbackWrong: bad ?? 'Check the form.',
      );

  static EnglishActivity rapid(
    String lessonId,
    String key,
    String prompt,
    List<String> options,
    int correct, {
    String? ok,
    String? bad,
    EnglishSkill skill = EnglishSkill.grammar,
  }) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: EnglishActivityKind.rapidReview,
        skill: skill,
        prompt: '⚡ $prompt',
        options: options,
        correctIndex: correct,
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: ok ?? 'Nice!',
        feedbackWrong: bad ?? 'Not quite.',
      );

  static EnglishActivity ask(
    String lessonId,
    String key,
    String prompt, {
    List<String> accept = const <String>[],
    int minWords = 3,
    EnglishActivityDifficulty? difficulty,
    EnglishSkill skill = EnglishSkill.conversation,
  }) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: EnglishActivityKind.questionCard,
        skill: skill,
        prompt: prompt,
        acceptableAnswers: accept,
        minWords: minWords,
        difficulty: difficulty ?? EnglishActivityDifficulty.hard,
        feedbackCorrect: 'Good answer!',
        feedbackWrong: 'Try a short natural answer.',
      );

  static EnglishActivity readAloud(
    String lessonId,
    String key,
    String passage, {
    String? prompt,
    String? ok,
    String? bad,
  }) =>
      EnglishActivity(
        id: 'sup_${lessonId}_${key}_aloud',
        kind: EnglishActivityKind.readingAloud,
        skill: EnglishSkill.reading,
        prompt: prompt ?? 'Read this passage aloud clearly and naturally.',
        listeningScript: passage,
        requiresVoice: true,
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: ok ?? 'Excellent reading!',
        feedbackWrong: bad ??
            'Read the full passage — match the words and keep a steady pace.',
        gradingCriteria: const <String>['complete', 'clear', 'accurate'],
      );

  /// Topic-only reading: read aloud (AI graded) + hard comprehension check.
  static List<EnglishActivity> reading(
    String lessonId,
    String key,
    String passage,
    String question,
    List<String> options,
    int correct, {
    String? ok,
    String? bad,
  }) =>
      <EnglishActivity>[
        readAloud(
          lessonId,
          key,
          passage,
          ok: ok != null ? 'Clear read — $ok' : null,
          bad: bad,
        ),
        hardMc(
          lessonId,
          key,
          question,
          options,
          correct,
          ok: ok,
          bad: bad,
          skill: EnglishSkill.reading,
        ),
      ];
  static EnglishActivity fix(
    String lessonId,
    String key,
    String wrong,
    String right, {
    String? bad,
  }) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: EnglishActivityKind.correction,
        skill: EnglishSkill.grammar,
        prompt: 'Fix this sentence',
        incorrectSentence: wrong,
        correctedSentence: right,
        correctAnswer: right.toLowerCase(),
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: 'Fixed!',
        feedbackWrong: bad ?? 'Use: $right',
      );

  static EnglishActivity write(
    String lessonId,
    String key,
    String prompt, {
    List<String> accept = const <String>[],
    List<String> criteria = const <String>[],
    int minWords = 4,
    EnglishWritingTone? tone,
    bool pickRecipient = false,
    String? targetName,
    EnglishSkill skill = EnglishSkill.grammar,
    EnglishActivityDifficulty? difficulty,
  }) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: pickRecipient
            ? EnglishActivityKind.emailWriting
            : EnglishActivityKind.shortWriting,
        skill: skill,
        prompt: prompt,
        acceptableAnswers: accept,
        gradingCriteria: criteria,
        minWords: minWords,
        writingTone: tone,
        pickRecipient: pickRecipient,
        targetName: targetName,
        difficulty: difficulty ?? EnglishActivityDifficulty.hard,
        feedbackCorrect: 'Good answer!',
        feedbackWrong: 'Try again with a fuller written response.',
      );

  static EnglishActivity listen(
    String lessonId,
    String key,
    String script,
    String prompt,
    List<String> options,
    int correct,
  ) =>
      EnglishActivity(
        id: 'bank_${lessonId}_$key',
        kind: EnglishActivityKind.listening,
        skill: EnglishSkill.listening,
        prompt: prompt,
        listeningScript: script,
        options: options,
        correctIndex: correct,
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: 'You got it!',
        feedbackWrong: 'Listen again carefully.',
      );

  /// Topic-only email writing tied to the current lesson.
  static EnglishActivity topicEmail(
    String lessonId,
    String key,
    String scenario,
    String prompt, {
    EnglishWritingTone tone = EnglishWritingTone.formal,
    int minWords = 20,
    List<String> criteria = const <String>[],
    bool pickRecipient = true,
  }) =>
      EnglishActivity(
        id: 'sup_${lessonId}_$key',
        kind: EnglishActivityKind.emailWriting,
        skill: EnglishSkill.writing,
        prompt: '$scenario\n\n$prompt',
        taskLabel: 'Email — same topic',
        writingTone: tone,
        pickRecipient: pickRecipient,
        minWords: minWords,
        gradingCriteria: criteria,
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: 'Strong email — on topic!',
        feedbackWrong: 'Use today\'s topic in your email: grammar, vocabulary, and tone.',
      );
}
