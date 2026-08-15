import '../../../models/english_lesson.dart';

const EnglishLessonScript conditionalsLesson = EnglishLessonScript(
  id: 'conditionals_1',
  title: 'First Conditional',
  skillLabel: 'If + present, will + verb',
  grammarFocus: 'Conditionals',
  vocabularyWords: <String>['if', 'unless', 'when'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'c1_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn: First Conditional', microTip: 'If + present simple, will + base verb (real future possibility).'),
    EnglishActivity(id: 'c1_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'If it rains, we ___ home.', options: <String>['stay', 'will stay', 'stayed'], correctIndex: 1, feedbackCorrect: 'Result clause → will stay.', feedbackWrong: 'If present, will future.'),
    EnglishActivity(id: 'c1_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'If you ___ (study), you will pass.', correctAnswer: 'study', acceptableAnswers: <String>['study'], feedbackCorrect: 'If clause = present.', feedbackWrong: 'If you study…'),
    EnglishActivity(id: 'c1_build', kind: EnglishActivityKind.sentenceBuilder, skill: EnglishSkill.grammar, prompt: 'Build it', wordBank: <String>['If', 'I', 'win', 'I', 'will', 'celebrate'], correctSentence: 'If I win I will celebrate', feedbackCorrect: 'Great!', feedbackWrong: 'If I win, I will celebrate.'),
    EnglishActivity(id: 'c1_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'If you will call me, I help you.', correctedSentence: 'If you call me, I will help you.', correctAnswer: 'if you call me i will help you', feedbackCorrect: 'No will in if-clause.', feedbackWrong: 'If you call me, I will help.'),
    EnglishActivity(id: 'c1_c', kind: EnglishActivityKind.miniConversation, skill: EnglishSkill.conversation, prompt: 'Complete: If I have time tomorrow, I ___', acceptableAnswers: <String>['will', 'll'], minWords: 3, feedbackCorrect: 'Good conditional!', feedbackWrong: '…I will study / call you.'),
    EnglishActivity(id: 'c1_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ Real future possibility?', options: <String>['If I was rich…', 'If I study, I will improve.', 'If I studied yesterday…'], correctIndex: 1, feedbackCorrect: 'First conditional.', feedbackWrong: 'If + present, will…'),
  ],
);
