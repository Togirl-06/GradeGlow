import '../../../models/english_lesson.dart';

const EnglishLessonScript gerundsInfinitivesLesson = EnglishLessonScript(
  id: 'gerunds_infinitives_1',
  title: 'Gerunds & Infinitives',
  skillLabel: 'enjoy doing · want to do · stop + -ing',
  grammarFocus: 'Gerunds',
  vocabularyWords: <String>['enjoy', 'want', 'decide', 'stop'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'gi_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn -ing vs to + verb', microTip: 'enjoy/finish + -ing · want/decide + to + verb (many patterns!).'),
    EnglishActivity(id: 'gi_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'I enjoy ___ books.', options: <String>['read', 'reading', 'to read'], correctIndex: 1, feedbackCorrect: 'enjoy + -ing.', feedbackWrong: 'enjoy reading.'),
    EnglishActivity(id: 'gi_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'She wants ___ abroad.', options: <String>['study', 'studying', 'to study'], correctIndex: 2, feedbackCorrect: 'want + to study.', feedbackWrong: 'want to + verb.'),
    EnglishActivity(id: 'gi_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'He decided going home early.', correctedSentence: 'He decided to go home early.', correctAnswer: 'he decided to go home early', feedbackCorrect: 'decide + to go.', feedbackWrong: 'decided to go.'),
    EnglishActivity(id: 'gi_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'They finished ___ (eat).', correctAnswer: 'eating', acceptableAnswers: <String>['eating'], feedbackCorrect: 'finish + -ing.', feedbackWrong: 'finished eating.'),
    EnglishActivity(id: 'gi_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ stop ___ smoking (quit)', options: <String>['to', '-ing / smoking', 'for'], correctIndex: 1, feedbackCorrect: 'stop smoking = quit.', feedbackWrong: 'stop + -ing.'),
  ],
);
