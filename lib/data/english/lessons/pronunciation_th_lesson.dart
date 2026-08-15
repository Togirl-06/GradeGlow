import '../../../models/english_lesson.dart';

const EnglishLessonScript pronunciationThLesson = EnglishLessonScript(
  id: 'pronunciation_th_1',
  title: 'Pronunciation: TH',
  skillLabel: 'think · this · voiceless & voiced th',
  grammarFocus: 'Pronunciation',
  vocabularyWords: <String>['think', 'three', 'this', 'that'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'th_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.pronunciation, prompt: 'Learn the TH sounds', microTip: 'Voiceless th in think · Voiced th in this.'),
    EnglishActivity(id: 'th_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.pronunciation, prompt: 'Voiceless th (like in think)?', options: <String>['this', 'three', 'that'], correctIndex: 1, feedbackCorrect: 'three = voiceless th.', feedbackWrong: 'three/thank = voiceless.'),
    EnglishActivity(id: 'th_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.pronunciation, prompt: 'Voiced th (like in this)?', options: <String>['think', 'thumb', 'that'], correctIndex: 2, feedbackCorrect: 'that = voiced th.', feedbackWrong: 'this/that/the = voiced.'),
    EnglishActivity(id: 'th_s1', kind: EnglishActivityKind.speaking, skill: EnglishSkill.speaking, prompt: 'Say: "I think this is fun."', requiresVoice: true, acceptableAnswers: <String>['think', 'this', 'fun'], feedbackCorrect: 'Both th sounds!', feedbackWrong: 'I think this is fun.'),
    EnglishActivity(id: 'th_s2', kind: EnglishActivityKind.speaking, skill: EnglishSkill.speaking, prompt: 'Say: "Three of them."', requiresVoice: true, acceptableAnswers: <String>['three', 'them'], feedbackCorrect: 'Nice th practice!', feedbackWrong: 'Three of them.'),
    EnglishActivity(id: 'th_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.pronunciation, prompt: '⚡ Tongue tip for th?', options: <String>['Between teeth lightly', 'Behind closed lips', 'No tongue'], correctIndex: 0, feedbackCorrect: 'Light touch between teeth.', feedbackWrong: 'Tongue between teeth.'),
  ],
);
