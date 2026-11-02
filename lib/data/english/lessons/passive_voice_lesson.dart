import '../../../models/english_lesson.dart';

const EnglishLessonScript passiveVoiceLesson = EnglishLessonScript(
  id: 'passive_voice_1',
  title: 'Passive Voice',
  skillLabel: 'is made · was built · focus on action',
  grammarFocus: 'Passive',
  vocabularyWords: <String>['by', 'was', 'were', 'is'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'pv_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn: Passive voice', microTip: 'be + past participle — focus on what happens, not who does it.'),
    EnglishActivity(id: 'pv_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'English ___ all over the world.', options: <String>['speaks', 'is spoken', 'spoke'], correctIndex: 1, feedbackCorrect: 'is spoken = passive.', feedbackWrong: 'be + past participle.'),
    EnglishActivity(id: 'pv_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'The bridge ___ (build) in 1990.', correctAnswer: 'was built', acceptableAnswers: <String>['was built'], feedbackCorrect: 'was built.', feedbackWrong: 'was + built.'),
    EnglishActivity(id: 'pv_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'The cake was bake yesterday.', correctedSentence: 'The cake was baked yesterday.', correctAnswer: 'the cake was baked yesterday', feedbackCorrect: 'baked = past participle.', feedbackWrong: 'was baked.'),
    EnglishActivity(id: 'pv_lis', kind: EnglishActivityKind.listening, skill: EnglishSkill.listening, prompt: 'Passive or active?', listeningScript: 'The email was sent this morning.', options: <String>['Active', 'Passive', 'Future'], correctIndex: 1, feedbackCorrect: 'was sent = passive.', feedbackWrong: 'was + sent.'),
    EnglishActivity(id: 'pv_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ Papers ___ every Friday.', options: <String>['are collected', 'collect', 'collecting'], correctIndex: 0, feedbackCorrect: 'are collected.', feedbackWrong: 'are + past participle.'),
  ],
);
