import '../../../models/english_lesson.dart';

const EnglishLessonScript comparativesLesson = EnglishLessonScript(
  id: 'comparatives_1',
  title: 'Comparatives & Superlatives',
  skillLabel: 'bigger · more interesting · the best',
  grammarFocus: 'Comparatives',
  vocabularyWords: <String>['than', 'more', 'most', 'better', 'best'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'cmp_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn comparatives & superlatives', microTip: 'short adj + -er · long adj: more/most · irregular: good→better→best'),
    EnglishActivity(id: 'cmp_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'This book is ___ than that one.', options: <String>['interestinger', 'more interesting', 'most interesting'], correctIndex: 1, feedbackCorrect: 'Long adjective → more interesting.', feedbackWrong: 'Use more + adjective.'),
    EnglishActivity(id: 'cmp_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'She is the ___ student in class.', options: <String>['better', 'best', 'goodest'], correctIndex: 1, feedbackCorrect: 'Superlative → the best.', feedbackWrong: 'the best.'),
    EnglishActivity(id: 'cmp_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'Today is ___ (hot) than yesterday.', correctAnswer: 'hotter', acceptableAnswers: <String>['hotter'], feedbackCorrect: 'hot → hotter.', feedbackWrong: 'Double consonant: hotter.'),
    EnglishActivity(id: 'cmp_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'He is more tall than me.', correctedSentence: 'He is taller than me.', correctAnswer: 'he is taller than me', feedbackCorrect: 'Short adj → taller.', feedbackWrong: 'tall → taller.'),
    EnglishActivity(id: 'cmp_q', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'This book is ___ than that one.', options: <String>['interestinger', 'more interesting', 'most interesting'], correctIndex: 1, difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'Long adjective → more interesting.', feedbackWrong: 'Use more + adjective.'),
    EnglishActivity(id: 'cmp_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ good → comparative?', options: <String>['gooder', 'better', 'more good'], correctIndex: 1, feedbackCorrect: 'Irregular: better.', feedbackWrong: 'better, not gooder.'),
  ],
);
