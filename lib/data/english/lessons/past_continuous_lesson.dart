import '../../../models/english_lesson.dart';

const EnglishLessonScript pastContinuousLesson = EnglishLessonScript(
  id: 'past_continuous_1',
  title: 'Past Continuous',
  skillLabel: 'was / were + -ing · background actions',
  grammarFocus: 'Past Continuous',
  vocabularyWords: <String>['while', 'when', 'at that moment'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'pco_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: "Learn: was/were + -ing", microTip: 'A longer action in the past, often interrupted.'),
    EnglishActivity(id: 'pco_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'I ___ TV when you called.', options: <String>['watched', 'was watching', 'watch'], correctIndex: 1, feedbackCorrect: 'Interrupted action → was watching.', feedbackWrong: 'when + past continuous.'),
    EnglishActivity(id: 'pco_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'They ___ (play) soccer at 4 p.m.', correctAnswer: 'were playing', acceptableAnswers: <String>['were playing'], feedbackCorrect: 'They were playing.', feedbackWrong: 'were + -ing.'),
    EnglishActivity(id: 'pco_build', kind: EnglishActivityKind.sentenceBuilder, skill: EnglishSkill.grammar, prompt: 'Build the sentence', wordBank: <String>['She', 'was', 'studying', 'all', 'night'], correctSentence: 'She was studying all night', feedbackCorrect: 'Perfect!', feedbackWrong: 'She was studying all night.'),
    EnglishActivity(id: 'pco_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'He were sleeping when I arrived.', correctedSentence: 'He was sleeping when I arrived.', correctAnswer: 'he was sleeping when i arrived', feedbackCorrect: 'He → was.', feedbackWrong: 'He was, not were.'),
    EnglishActivity(id: 'pco_lis', kind: EnglishActivityKind.listening, skill: EnglishSkill.listening, prompt: 'What was happening?', listeningScript: 'While I was cooking, the phone rang.', options: <String>['Cooking', 'Phone rang only', 'Future plan'], correctIndex: 0, feedbackCorrect: 'was cooking = background.', feedbackWrong: 'While I was cooking…'),
    EnglishActivity(id: 'pco_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ We ___ not listening.', options: <String>['was', 'were', 'are'], correctIndex: 1, feedbackCorrect: 'We were.', feedbackWrong: 'We → were.'),
  ],
);
