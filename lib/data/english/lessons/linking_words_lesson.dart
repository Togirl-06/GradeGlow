import '../../../models/english_lesson.dart';

const EnglishLessonScript linkingWordsLesson = EnglishLessonScript(
  id: 'linking_words_1',
  title: 'Linking Words',
  skillLabel: 'however · because · although · therefore',
  grammarFocus: 'Writing',
  vocabularyWords: <String>['however', 'because', 'although', 'therefore'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'lw_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.writing, prompt: 'Learn linking words', microTip: 'because = reason · however = contrast · therefore = result.'),
    EnglishActivity(id: 'lw_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.writing, prompt: 'I stayed home ___ I was sick.', options: <String>['because', 'however', 'therefore'], correctIndex: 0, feedbackCorrect: 'because = reason.', feedbackWrong: 'Reason → because.'),
    EnglishActivity(id: 'lw_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.writing, prompt: 'It was raining. ___, we went out.', options: <String>['Because', 'However', 'Therefore'], correctIndex: 1, feedbackCorrect: 'Contrast → However.', feedbackWrong: 'Unexpected → However.'),
    EnglishActivity(id: 'lw_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.writing, prompt: 'She studied hard; ___, she passed.', correctAnswer: 'therefore', acceptableAnswers: <String>['therefore', 'so'], feedbackCorrect: 'Result → therefore.', feedbackWrong: 'therefore / so.'),
    EnglishActivity(id: 'lw_build', kind: EnglishActivityKind.sentenceBuilder, skill: EnglishSkill.writing, prompt: 'Build the sentence', wordBank: <String>['Although', 'it', 'was', 'late', 'we', 'finished'], correctSentence: 'Although it was late we finished', feedbackCorrect: 'Nice linker!', feedbackWrong: 'Although it was late, we finished.'),
    EnglishActivity(id: 'lw_w', kind: EnglishActivityKind.sentenceBuilder, skill: EnglishSkill.writing, prompt: 'Build the sentence with because', wordBank: <String>['I', 'stayed', 'home', 'because', 'it', 'rained'], correctSentence: 'I stayed home because it rained', difficulty: EnglishActivityDifficulty.hard, feedbackCorrect: 'Linked ideas!', feedbackWrong: 'I stayed home because it rained.'),
    EnglishActivity(id: 'lw_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.writing, prompt: '⚡ Contrast word?', options: <String>['however', 'because', 'and'], correctIndex: 0, feedbackCorrect: 'however.', feedbackWrong: 'Contrast → however.'),
  ],
);
