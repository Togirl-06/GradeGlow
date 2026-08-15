import '../../../models/english_lesson.dart';

const EnglishLessonScript countableUncountableLesson = EnglishLessonScript(
  id: 'countable_uncountable_1',
  title: 'Countable & Uncountable',
  skillLabel: 'some · much/many · a lot of',
  grammarFocus: 'Nouns',
  vocabularyWords: <String>['much', 'many', 'some', 'a few', 'a little'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'cu_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn count vs uncount nouns', microTip: 'many + plural count · much + uncount · some works for both.'),
    EnglishActivity(id: 'cu_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'How ___ apples do you have?', options: <String>['much', 'many', 'little'], correctIndex: 1, feedbackCorrect: 'apples = countable → many.', feedbackWrong: 'Countable plural → many.'),
    EnglishActivity(id: 'cu_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'There isn\'t ___ water left.', options: <String>['many', 'much', 'few'], correctIndex: 1, feedbackCorrect: 'water = uncountable → much.', feedbackWrong: 'Uncount → much.'),
    EnglishActivity(id: 'cu_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'I need ___ (some) advice.', correctAnswer: 'some', acceptableAnswers: <String>['some', 'a little'], feedbackCorrect: 'advice uncountable → some.', feedbackWrong: 'some advice.'),
    EnglishActivity(id: 'cu_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'I have many homework tonight.', correctedSentence: 'I have a lot of homework tonight.', correctAnswer: 'i have a lot of homework tonight', feedbackCorrect: 'homework uncountable.', feedbackWrong: 'a lot of homework.'),
    EnglishActivity(id: 'cu_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ a few vs a little', options: <String>['a few = count nouns', 'a few = uncount only', 'same meaning'], correctIndex: 0, feedbackCorrect: 'a few books · a little water.', feedbackWrong: 'few/count · little/uncount.'),
  ],
);
