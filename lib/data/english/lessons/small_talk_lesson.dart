import '../../../models/english_lesson.dart';

const EnglishLessonScript smallTalkLesson = EnglishLessonScript(
  id: 'small_talk_1',
  title: 'Small Talk',
  skillLabel: 'greetings · weather · polite chat',
  grammarFocus: 'Conversation',
  vocabularyWords: <String>['how are you', 'nice to meet', 'by the way'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'st_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.conversation, prompt: 'Learn small talk', microTip: 'Short friendly exchanges — greetings, weather, follow-up questions.'),
    EnglishActivity(id: 'st_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.conversation, prompt: 'Polite response to "How are you?"', options: <String>['I am name Tom.', 'I\'m good, thanks. And you?', 'Go away.'], correctIndex: 1, feedbackCorrect: 'Friendly + return question.', feedbackWrong: 'I\'m good, thanks. And you?'),
    EnglishActivity(id: 'st_c1', kind: EnglishActivityKind.miniConversation, skill: EnglishSkill.conversation, prompt: 'Say: "Nice to meet you!"', acceptableAnswers: <String>['nice to meet you'], feedbackCorrect: 'Warm opener!', feedbackWrong: 'Nice to meet you!'),
    EnglishActivity(id: 'st_c2', kind: EnglishActivityKind.miniConversation, skill: EnglishSkill.conversation, prompt: 'Reply: "Nice to meet you too. Where are you from?"', acceptableAnswers: <String>['from', 'i am from', 'im from'], minWords: 3, feedbackCorrect: 'Good reply!', feedbackWrong: 'I\'m from…'),
    EnglishActivity(id: 'st_q', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.conversation, prompt: 'Best follow-up after "How was your weekend?"', options: <String>['Fine. Bye.', 'It was great — how about yours?', 'Weekend.'], correctIndex: 1, difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'Answer + return the question.', feedbackWrong: 'Keep the conversation going.'),
    EnglishActivity(id: 'st_s', kind: EnglishActivityKind.speaking, skill: EnglishSkill.speaking, prompt: 'Introduce yourself in two sentences.', requiresVoice: true, minWords: 5, acceptableAnswers: <String>['my name', 'i am', 'im'], feedbackCorrect: 'Great intro!', feedbackWrong: 'Hi, I\'m… I study…'),
    EnglishActivity(id: 'st_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.conversation, prompt: '⚡ Best follow-up?', options: <String>['And you?', 'I am table.', 'Yesterday go.'], correctIndex: 0, feedbackCorrect: 'And you? keeps chat going.', feedbackWrong: 'Return the question.'),
  ],
);
