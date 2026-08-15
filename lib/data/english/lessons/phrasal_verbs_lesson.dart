import '../../../models/english_lesson.dart';

const EnglishLessonScript phrasalVerbsLesson = EnglishLessonScript(
  id: 'phrasal_verbs_1',
  title: 'Phrasal Verbs',
  skillLabel: 'get up · turn off · look for',
  grammarFocus: 'Phrasal verbs',
  vocabularyWords: <String>['get up', 'turn off', 'look for', 'give up'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'ph_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.vocabulary, prompt: 'Learn phrasal verbs', microTip: 'Verb + particle = new meaning (get up, turn on).'),
    EnglishActivity(id: 'ph_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.vocabulary, prompt: 'I ___ at 7 a.m. every day.', options: <String>['get up', 'get on', 'get over'], correctIndex: 0, vocabularyWord: 'get up', feedbackCorrect: 'get up = leave bed.', feedbackWrong: 'Morning → get up.'),
    EnglishActivity(id: 'ph_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.vocabulary, prompt: 'Please ___ the lights when you leave.', options: <String>['turn on', 'turn off', 'turn up'], correctIndex: 1, vocabularyWord: 'turn off', feedbackCorrect: 'turn off = stop power.', feedbackWrong: 'Leave → turn off.'),
    EnglishActivity(id: 'ph_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.vocabulary, prompt: 'She is ___ her keys. (searching)', correctAnswer: 'looking for', acceptableAnswers: <String>['looking for', 'look for'], feedbackCorrect: 'look for = search.', feedbackWrong: 'looking for.'),
    EnglishActivity(id: 'ph_q', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.vocabulary, prompt: 'We need to ___ the meeting because of the storm.', options: <String>['call off', 'call on', 'call up'], correctIndex: 0, difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'call off = cancel.', feedbackWrong: 'Cancel → call off.'),
    EnglishActivity(id: 'ph_s', kind: EnglishActivityKind.speaking, skill: EnglishSkill.speaking, prompt: 'Say: "Don\'t give up!"', requiresVoice: true, acceptableAnswers: <String>['give up', 'dont give up'], feedbackCorrect: 'Nice phrasal verb!', feedbackWrong: 'Don\'t give up!'),
    EnglishActivity(id: 'ph_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.vocabulary, prompt: '⚡ give up means…', options: <String>['start', 'quit / stop trying', 'give a gift'], correctIndex: 1, feedbackCorrect: 'give up = quit.', feedbackWrong: 'Stop trying → give up.'),
  ],
);
