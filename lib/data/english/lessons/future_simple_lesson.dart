import '../../../models/english_lesson.dart';

const EnglishLessonScript futureSimpleLesson = EnglishLessonScript(
  id: 'future_simple_1',
  title: 'Future: will & going to',
  skillLabel: 'plans · predictions · will vs going to',
  grammarFocus: 'Future',
  vocabularyWords: <String>['tomorrow', 'next week', 'will', 'going to'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'fs_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: "Learn: will / going to", microTip: 'going to = plan · will = sudden decision or prediction.'),
    EnglishActivity(id: 'fs_q', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'Look at those clouds — it ___ rain soon.', options: <String>['will', 'is going to', 'rained'], correctIndex: 1, difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'Evidence now → going to.', feedbackWrong: 'Dark clouds = going to rain.'),
    EnglishActivity(id: 'fs_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'Look at those clouds — it ___ rain.', options: <String>['will', 'is going to', 'rained'], correctIndex: 1, feedbackCorrect: 'Evidence now → going to.', feedbackWrong: 'Dark clouds = going to rain.'),
    EnglishActivity(id: 'fs_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'I\'ll help you! (decision now)', options: <String>['will', 'am going to', 'was'], correctIndex: 0, feedbackCorrect: 'Spontaneous → will.', feedbackWrong: 'Instant decision → will.'),
    EnglishActivity(id: 'fs_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'She ___ study medicine next year.', taskLabel: 'Type is going to or will', correctAnswer: 'is going to', acceptableAnswers: <String>['is going to', 'will'], feedbackCorrect: 'Plan → going to works best.', feedbackWrong: 'is going to study…'),
    EnglishActivity(id: 'fs_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'I will to travel tomorrow.', correctedSentence: 'I will travel tomorrow.', correctAnswer: 'i will travel tomorrow', feedbackCorrect: 'will + base verb (no to).', feedbackWrong: 'Remove to after will.'),
    EnglishActivity(id: 'fs_s', kind: EnglishActivityKind.speaking, skill: EnglishSkill.speaking, prompt: 'Say: "I will call you tomorrow."', requiresVoice: true, acceptableAnswers: <String>['will call', 'i will call'], minWords: 4, difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'Good future sentence!', feedbackWrong: 'I will call you tomorrow.'),
    EnglishActivity(id: 'fs_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ We ___ meet at 6.', options: <String>['are going to', 'going', 'went'], correctIndex: 0, feedbackCorrect: 'are going to meet.', feedbackWrong: 'are going to + verb.'),
  ],
);
