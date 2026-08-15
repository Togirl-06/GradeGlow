/// Duolingo-style English lesson runtime models.
library;

import 'english_cefr.dart';

export 'english_cefr.dart';

enum EnglishActivityDifficulty {
  easy('Easy', 1),
  medium('Medium', 2),
  hard('Challenge', 3);

  const EnglishActivityDifficulty(this.label, this.level);
  final String label;
  final int level;
}

enum EnglishActivityKind {
  microPrompt,
  questionCard,
  multipleChoice,
  fillBlank,
  sentenceBuilder,
  speaking,
  listening,
  correction,
  miniConversation,
  rapidReview,
  emailWriting,
  shortWriting,
  readingAloud,
  sentenceRewrite,
  explainError,
  paragraphCorrection,
  bestSentence,
  combineSentences,
  transformWriting,
  readingInference,
  vocabularyContext,
  essayWriting,
  scenarioIntro,
}

enum EnglishWritingTone {
  formal,
  informal,
  any,
}

enum EnglishSkill {
  grammar,
  vocabulary,
  speaking,
  listening,
  reading,
  writing,
  pronunciation,
  conversation,
}

class EnglishActivity {
  const EnglishActivity({
    required this.id,
    required this.kind,
    required this.prompt,
    required this.skill,
    this.microTip,
    this.xpReward = 5,
    this.taskLabel,
    this.options = const <String>[],
    this.correctIndex,
    this.correctAnswer,
    this.acceptableAnswers = const <String>[],
    this.feedbackCorrect,
    this.feedbackWrong,
    this.incorrectSentence,
    this.correctedSentence,
    this.listeningScript,
    this.wordBank = const <String>[],
    this.correctSentence,
    this.minWords = 1,
    this.requiresVoice = false,
    this.vocabularyWord,
    this.difficulty,
    this.writingTone,
    this.pickRecipient = false,
    this.gradingCriteria = const <String>[],
    this.targetName,
    this.cefrLevel,
    this.scenarioTitle,
    this.scenarioStep,
    this.secondaryPrompt,
    this.sourceSentence,
  });

  final String id;
  final EnglishActivityKind kind;
  /// Short AI line — 1–2 sentences max.
  final String prompt;
  /// Micro explanation (1–3 lines) for [microPrompt] steps.
  final String? microTip;
  final int xpReward;
  final EnglishSkill skill;
  final String? taskLabel;
  final List<String> options;
  final int? correctIndex;
  final String? correctAnswer;
  final List<String> acceptableAnswers;
  final String? feedbackCorrect;
  final String? feedbackWrong;
  final String? incorrectSentence;
  final String? correctedSentence;
  /// Passage text the student should read aloud ([readingAloud]).
  /// Also used for listening scripts on [listening] steps.
  final String? listeningScript;
  final List<String> wordBank;
  final String? correctSentence;
  final int minWords;
  final bool requiresVoice;
  final String? vocabularyWord;
  final EnglishActivityDifficulty? difficulty;
  final EnglishWritingTone? writingTone;
  final bool pickRecipient;
  final List<String> gradingCriteria;
  /// Person the student must greet by name (e.g. Luke, Rob).
  final String? targetName;
  /// CEFR band this step targets.
  final EnglishCefrLevel? cefrLevel;
  /// Multi-step scenario label (e.g. "Job interview").
  final String? scenarioTitle;
  final int? scenarioStep;
  /// Extra context: passage, job description, essay prompt detail.
  final String? secondaryPrompt;
  /// Second sentence for combine / transform tasks.
  final String? sourceSentence;

  bool get isMicroOnly => kind == EnglishActivityKind.microPrompt;

  bool get requiresAiGrading =>
      kind == EnglishActivityKind.essayWriting ||
      kind == EnglishActivityKind.emailWriting ||
      kind == EnglishActivityKind.readingAloud ||
      kind == EnglishActivityKind.speaking ||
      kind == EnglishActivityKind.sentenceRewrite ||
      kind == EnglishActivityKind.explainError ||
      kind == EnglishActivityKind.paragraphCorrection ||
      kind == EnglishActivityKind.transformWriting ||
      kind == EnglishActivityKind.readingInference ||
      kind == EnglishActivityKind.shortWriting;

  /// Steps where the student types (not tap-to-choose).
  bool get requiresWriting =>
      kind == EnglishActivityKind.emailWriting ||
      kind == EnglishActivityKind.shortWriting ||
      kind == EnglishActivityKind.essayWriting ||
      kind == EnglishActivityKind.fillBlank ||
      kind == EnglishActivityKind.questionCard ||
      kind == EnglishActivityKind.miniConversation ||
      kind == EnglishActivityKind.correction ||
      kind == EnglishActivityKind.multipleChoice ||
      kind == EnglishActivityKind.rapidReview ||
      kind == EnglishActivityKind.listening ||
      kind == EnglishActivityKind.sentenceRewrite ||
      kind == EnglishActivityKind.explainError ||
      kind == EnglishActivityKind.paragraphCorrection ||
      kind == EnglishActivityKind.combineSentences ||
      kind == EnglishActivityKind.transformWriting ||
      kind == EnglishActivityKind.readingInference ||
      kind == EnglishActivityKind.vocabularyContext;

  EnglishActivity copyWith({
    String? id,
    String? prompt,
    String? feedbackWrong,
  }) {
    return EnglishActivity(
      id: id ?? this.id,
      kind: kind,
      prompt: prompt ?? this.prompt,
      skill: skill,
      microTip: microTip,
      xpReward: xpReward,
      taskLabel: taskLabel,
      options: options,
      correctIndex: correctIndex,
      correctAnswer: correctAnswer,
      acceptableAnswers: acceptableAnswers,
      feedbackCorrect: feedbackCorrect,
      feedbackWrong: feedbackWrong ?? this.feedbackWrong,
      incorrectSentence: incorrectSentence,
      correctedSentence: correctedSentence,
      listeningScript: listeningScript,
      wordBank: wordBank,
      correctSentence: correctSentence,
      minWords: minWords,
      requiresVoice: requiresVoice,
      vocabularyWord: vocabularyWord,
      difficulty: difficulty,
      writingTone: writingTone,
      pickRecipient: pickRecipient,
      gradingCriteria: gradingCriteria,
      targetName: targetName,
      cefrLevel: cefrLevel,
      scenarioTitle: scenarioTitle,
      scenarioStep: scenarioStep,
      secondaryPrompt: secondaryPrompt,
      sourceSentence: sourceSentence,
    );
  }
}

class EnglishLessonScript {
  const EnglishLessonScript({
    required this.id,
    required this.title,
    required this.skillLabel,
    required this.activities,
    this.vocabularyWords = const <String>[],
    this.grammarFocus,
    this.cefrLevel = EnglishCefrLevel.b1,
  });

  final String id;
  final String title;
  final String skillLabel;
  final List<EnglishActivity> activities;
  final List<String> vocabularyWords;
  final String? grammarFocus;
  final EnglishCefrLevel cefrLevel;
}

class EnglishMistakeRecord {
  const EnglishMistakeRecord({
    required this.activityId,
    required this.skill,
    required this.note,
    required this.prompt,
  });

  final String activityId;
  final EnglishSkill skill;
  final String note;
  final String prompt;
}

class EnglishLessonResult {
  const EnglishLessonResult({
    required this.xpEarned,
    required this.baseXp,
    required this.bonusXp,
    required this.accuracy,
    required this.grammarMastered,
    required this.wordsLearned,
    required this.mistakes,
    required this.reviewTopics,
    required this.nextSkill,
    required this.stepsCompleted,
    required this.correctCount,
    required this.perfectLesson,
    required this.maxStreak,
    this.readingDetail,
    this.levelAfter,
  });

  final int xpEarned;
  final int baseXp;
  final int bonusXp;
  final double accuracy;
  final bool grammarMastered;
  final List<String> wordsLearned;
  final List<EnglishMistakeRecord> mistakes;
  final List<String> reviewTopics;
  final String nextSkill;
  final int stepsCompleted;
  final int correctCount;
  final bool perfectLesson;
  final int maxStreak;
  final EnglishReadingGradeDetail? readingDetail;
  final EnglishCefrLevel? levelAfter;
}

enum EnglishLessonPhase {
  microPrompt,
  active,
  grading,
  feedback,
  complete,
}

/// Typed answer for emails and longer writing tasks.
class EnglishWrittenSubmission {
  const EnglishWrittenSubmission({
    required this.body,
    this.recipient,
  });

  final String body;
  final String? recipient;
}

/// Duolingo-style XP constants.
abstract final class EnglishXpRules {
  static const int correctAnswer = 5;
  static const int speakingBonus = 3;
  static const int hardBonus = 4;
  static const int easyBonus = 1;
  static const int perfectLessonBonus = 15;
  static const int streakMultiplierThreshold = 3;
}

/// Minimum read-aloud time for a short paragraph (~2 sentences).
const int kEnglishReadingAloudShortMinSeconds = 120;

/// Minimum for longer passages.
const int kEnglishReadingAloudLongMinSeconds = 180;

/// @deprecated Use [readingAloudMinSecondsFor] per activity.
const int kEnglishReadingAloudMinSeconds = kEnglishReadingAloudShortMinSeconds;

/// Required reading time before auto-grade, scaled by passage length.
int readingAloudMinSecondsFor(EnglishActivity activity) {
  if (activity.kind != EnglishActivityKind.readingAloud) {
    return kEnglishReadingAloudShortMinSeconds;
  }
  final String passage = (activity.listeningScript ?? '').trim();
  if (passage.isEmpty) return kEnglishReadingAloudShortMinSeconds;
  final int words =
      passage.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
  // Short paragraph (typical lesson passage) → 2 minutes.
  if (words <= 80) return kEnglishReadingAloudShortMinSeconds;
  if (words <= 160) return kEnglishReadingAloudLongMinSeconds;
  return 240;
}
