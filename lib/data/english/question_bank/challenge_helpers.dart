import '../../../models/english_lesson.dart';

/// University-level challenge activity factories.
class BankCh {
  const BankCh._();

  static EnglishActivity _base({
    required String lessonId,
    required String key,
    required EnglishActivityKind kind,
    required String prompt,
    required EnglishSkill skill,
    EnglishCefrLevel cefr = EnglishCefrLevel.b1,
    String? taskLabel,
    List<String> options = const <String>[],
    int? correctIndex,
    String? correctAnswer,
    List<String> acceptable = const <String>[],
    String? passage,
    String? wrong,
    String? right,
    String? source,
    String? secondary,
    String? scenario,
    int? step,
    List<String> criteria = const <String>[],
    int minWords = 12,
    EnglishWritingTone? tone,
    bool pickRecipient = false,
    String? ok,
    String? bad,
  }) =>
      EnglishActivity(
        id: 'ch_${lessonId}_$key',
        kind: kind,
        skill: skill,
        prompt: prompt,
        taskLabel: taskLabel,
        options: options,
        correctIndex: correctIndex,
        correctAnswer: correctAnswer,
        acceptableAnswers: acceptable,
        listeningScript: passage,
        incorrectSentence: wrong,
        correctedSentence: right,
        sourceSentence: source,
        secondaryPrompt: secondary,
        scenarioTitle: scenario,
        scenarioStep: step,
        gradingCriteria: criteria,
        minWords: minWords,
        writingTone: tone,
        pickRecipient: pickRecipient,
        cefrLevel: cefr,
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: ok ?? 'Excellent analysis!',
        feedbackWrong: bad ?? 'Review the explanation and try the pattern again.',
      );

  static EnglishActivity mc(
    String lessonId,
    String key,
    String prompt,
    List<String> options,
    int correct, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b1,
    EnglishSkill skill = EnglishSkill.grammar,
    String? ok,
    String? bad,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.multipleChoice,
        skill: skill,
        prompt: prompt,
        options: options,
        correctIndex: correct,
        cefr: cefr,
        ok: ok,
        bad: bad,
      );

  static EnglishActivity fill(
    String lessonId,
    String key,
    String prompt,
    String answer, {
    List<String> also = const <String>[],
    EnglishCefrLevel cefr = EnglishCefrLevel.b1,
    EnglishSkill skill = EnglishSkill.grammar,
    String? taskLabel,
    String? ok,
    String? bad,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.fillBlank,
        skill: skill,
        prompt: prompt,
        taskLabel: taskLabel,
        correctAnswer: answer,
        acceptable: <String>[answer, ...also],
        cefr: cefr,
        ok: ok,
        bad: bad,
        minWords: 1,
      );

  static EnglishActivity rewrite(
    String lessonId,
    String key,
    String original,
    String target, {
    required String instruction,
    EnglishCefrLevel cefr = EnglishCefrLevel.b1,
    List<String> accept = const <String>[],
    String? model,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.sentenceRewrite,
        skill: EnglishSkill.grammar,
        prompt: '$instruction\n\nOriginal: "$original"',
        correctAnswer: model,
        acceptable: accept.isEmpty && model != null ? <String>[model] : accept,
        cefr: cefr,
        minWords: 4,
      );

  static EnglishActivity explain(
    String lessonId,
    String key,
    String sentence,
    List<String> reasons,
    int correct, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
    String? bad,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.explainError,
        skill: EnglishSkill.grammar,
        prompt: 'Why is this sentence incorrect?\n"$sentence"',
        options: reasons,
        correctIndex: correct,
        cefr: cefr,
        bad: bad,
        minWords: 8,
      );

  static EnglishActivity paragraphFix(
    String lessonId,
    String key,
    String paragraph,
    String fixed, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.paragraphCorrection,
        skill: EnglishSkill.grammar,
        prompt: 'Correct all grammar mistakes in this paragraph:',
        wrong: paragraph,
        right: fixed,
        correctAnswer: fixed.toLowerCase(),
        cefr: cefr,
        minWords: 20,
      );

  static EnglishActivity bestOf(
    String lessonId,
    String key,
    String context,
    List<String> options,
    int correct, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
    EnglishSkill skill = EnglishSkill.grammar,
    String? ok,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.bestSentence,
        skill: skill,
        prompt: context,
        options: options,
        correctIndex: correct,
        cefr: cefr,
        ok: ok,
      );

  static EnglishActivity combine(
    String lessonId,
    String key,
    String a,
    String b,
    String model, {
    required String linker,
    EnglishCefrLevel cefr = EnglishCefrLevel.b1,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.combineSentences,
        skill: EnglishSkill.grammar,
        prompt: 'Combine into one sentence using "$linker":\n1. $a\n2. $b',
        source: b,
        correctAnswer: model,
        acceptable: <String>[model],
        cefr: cefr,
        minWords: 6,
      );

  static EnglishActivity transform(
    String lessonId,
    String key,
    String text,
    String model, {
    required String taskLabel,
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
    List<String> accept = const <String>[],
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.transformWriting,
        skill: EnglishSkill.writing,
        taskLabel: taskLabel,
        prompt: 'Transform the text below:\n"$text"',
        correctAnswer: model,
        acceptable: accept.isEmpty ? <String>[model] : accept,
        cefr: cefr,
        minWords: 8,
      );

  static EnglishActivity inference(
    String lessonId,
    String key,
    String passage,
    String question,
    List<String> options,
    int correct, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
    String? ok,
    String? bad,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.readingInference,
        skill: EnglishSkill.reading,
        prompt: 'Read carefully:\n"$passage"\n\n$question',
        passage: passage,
        options: options,
        correctIndex: correct,
        cefr: cefr,
        ok: ok,
        bad: bad,
      );

  static EnglishActivity vocabContext(
    String lessonId,
    String key,
    String sentence,
    List<String> options,
    int correct, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
    String? blank,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.vocabularyContext,
        skill: EnglishSkill.vocabulary,
        prompt: blank ?? 'Choose the word that best fits the context:\n"$sentence"',
        options: options,
        correctIndex: correct,
        cefr: cefr,
      );

  static EnglishActivity essay(
    String lessonId,
    String key,
    String prompt,
    List<String> criteria, {
    EnglishCefrLevel cefr = EnglishCefrLevel.c1,
    int minWords = 120,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.essayWriting,
        skill: EnglishSkill.writing,
        prompt: prompt,
        criteria: criteria,
        cefr: cefr,
        minWords: minWords,
      );

  static EnglishActivity scenarioIntro(
    String lessonId,
    String key,
    String title,
    String briefing, {
    int step = 1,
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
  }) =>
      _base(
        lessonId: lessonId,
        key: key,
        kind: EnglishActivityKind.scenarioIntro,
        skill: EnglishSkill.conversation,
        prompt: briefing,
        scenario: title,
        step: step,
        cefr: cefr,
        secondary: briefing,
      );

  static EnglishActivity speakTask(
    String lessonId,
    String key,
    String prompt, {
    EnglishCefrLevel cefr = EnglishCefrLevel.b2,
    List<String> criteria = const <String>[],
    int minWords = 30,
  }) =>
      EnglishActivity(
        id: 'ch_${lessonId}_$key',
        kind: EnglishActivityKind.speaking,
        skill: EnglishSkill.speaking,
        prompt: prompt,
        requiresVoice: true,
        gradingCriteria: criteria,
        minWords: minWords,
        cefrLevel: cefr,
        difficulty: EnglishActivityDifficulty.hard,
        feedbackCorrect: 'Strong spoken response!',
        feedbackWrong: 'Organize your ideas with clearer grammar and vocabulary.',
      );
}
