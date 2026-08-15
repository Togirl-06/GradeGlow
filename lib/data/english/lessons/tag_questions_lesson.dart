import '../../../models/english_lesson.dart';

const EnglishLessonScript tagQuestionsLesson = EnglishLessonScript(
  id: 'tag_questions_1',
  title: 'Tag Questions',
  skillLabel: 'isn\'t it? · don\'t you? · right?',
  grammarFocus: 'Tag questions',
  vocabularyWords: <String>["isn't it", "don't you", 'right'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'tq_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn tag questions', microTip: 'Positive statement → negative tag · negative → positive tag.'),
    EnglishActivity(id: 'tq_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'It\'s cold today, ___?', options: <String>['is it', "isn't it", 'does it'], correctIndex: 1, feedbackCorrect: "Positive → isn't it.", feedbackWrong: "isn't it?"),
    EnglishActivity(id: 'tq_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'You don\'t like coffee, ___?', options: <String>['do you', "don't you", 'are you'], correctIndex: 0, feedbackCorrect: 'Negative → do you.', feedbackWrong: 'do you?'),
    EnglishActivity(id: 'tq_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'She can swim, ___ she?', correctAnswer: "can't", acceptableAnswers: <String>["can't", 'can not'], feedbackCorrect: 'can → can\'t.', feedbackWrong: "can't she?"),
    EnglishActivity(id: 'tq_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix the tag', incorrectSentence: 'You are tired, aren\'t you?', correctedSentence: 'You are tired, aren\'t you?', correctAnswer: 'you are tired arent you', feedbackCorrect: 'This one is correct!', feedbackWrong: 'are → aren\'t you.'),
    EnglishActivity(id: 'tq_c', kind: EnglishActivityKind.miniConversation, skill: EnglishSkill.conversation, prompt: 'Add a tag: "You\'re coming, ___?"', acceptableAnswers: <String>["arent you", "aren't you"], feedbackCorrect: 'Natural tag!', feedbackWrong: "aren't you?"),
    EnglishActivity(id: 'tq_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ He works here, ___?', options: <String>['does he', "doesn't he", 'is he'], correctIndex: 1, feedbackCorrect: "doesn't he.", feedbackWrong: 'Positive → negative tag.'),
  ],
);
