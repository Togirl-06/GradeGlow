import '../../../models/english_lesson.dart';

const EnglishLessonScript opinionsLesson = EnglishLessonScript(
  id: 'opinions_1',
  title: 'Giving Opinions',
  skillLabel: 'I think · in my opinion · agree/disagree',
  grammarFocus: 'Opinions',
  vocabularyWords: <String>['I think', 'in my opinion', 'agree', 'disagree'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'op_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.speaking, prompt: 'Learn to share opinions', microTip: 'I think… · In my opinion… · I agree/disagree because…'),
    EnglishActivity(id: 'op_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.speaking, prompt: 'Which sounds polite?', options: <String>['You are wrong.', 'I see your point, but I disagree.', 'Shut up.'], correctIndex: 1, feedbackCorrect: 'Respectful disagreement.', feedbackWrong: 'Acknowledge + disagree.'),
    EnglishActivity(id: 'op_q', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.speaking, prompt: 'Which is the most polite disagreement?', options: <String>['You are wrong.', 'I see your point, but I disagree.', 'That is stupid.'], correctIndex: 1, difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'Acknowledge + disagree politely.', feedbackWrong: 'Use I see your point, but…'),
    EnglishActivity(id: 'op_build', kind: EnglishActivityKind.sentenceBuilder, skill: EnglishSkill.speaking, prompt: 'Build an opinion', wordBank: <String>['In', 'my', 'opinion', 'exercise', 'helps'], correctSentence: 'In my opinion exercise helps', feedbackCorrect: 'Good structure!', feedbackWrong: 'In my opinion exercise helps.'),
    EnglishActivity(id: 'op_c', kind: EnglishActivityKind.miniConversation, skill: EnglishSkill.conversation, prompt: 'Respond: "I think English is important."', acceptableAnswers: <String>['agree', 'disagree', 'i think', 'me too'], minWords: 2, feedbackCorrect: 'Engaged response!', feedbackWrong: 'I agree because… / I\'m not sure…'),
    EnglishActivity(id: 'op_s', kind: EnglishActivityKind.speaking, skill: EnglishSkill.speaking, prompt: 'Give your opinion on homework.', requiresVoice: true, acceptableAnswers: <String>['i think', 'opinion', 'agree'], minWords: 5, feedbackCorrect: 'Strong opinion sentence!', feedbackWrong: 'I think homework is…'),
    EnglishActivity(id: 'op_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.speaking, prompt: '⚡ Softener phrase?', options: <String>['In my opinion', 'You must', 'Go now'], correctIndex: 0, feedbackCorrect: 'In my opinion…', feedbackWrong: 'Opinion phrase needed.'),
  ],
);
