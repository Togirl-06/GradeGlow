import '../../../models/english_lesson.dart';

const EnglishLessonScript reportedSpeechLesson = EnglishLessonScript(
  id: 'reported_speech_1',
  title: 'Reported Speech',
  skillLabel: 'He said (that)… · tense shift basics',
  grammarFocus: 'Reported speech',
  vocabularyWords: <String>['said', 'told', 'asked'],
  activities: <EnglishActivity>[
    EnglishActivity(id: 'rs_l', kind: EnglishActivityKind.microPrompt, skill: EnglishSkill.grammar, prompt: 'Learn reported speech', microTip: 'Direct: "I am tired." → Reported: He said (that) he was tired.'),
    EnglishActivity(id: 'rs_m1', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'She said, "I am busy." → She said she ___ busy.', options: <String>['is', 'was', 'will be'], correctIndex: 1, feedbackCorrect: 'Present → past in report.', feedbackWrong: 'am → was.'),
    EnglishActivity(id: 'rs_m2', kind: EnglishActivityKind.multipleChoice, skill: EnglishSkill.grammar, prompt: 'He asked, "Where do you live?" → He asked where I ___', options: <String>['live', 'lived', 'living'], correctIndex: 1, feedbackCorrect: 'do live → lived.', feedbackWrong: 'Tense backshift → lived.'),
    EnglishActivity(id: 'rs_b', kind: EnglishActivityKind.fillBlank, skill: EnglishSkill.grammar, prompt: 'They said they ___ (will) call later.', correctAnswer: 'would', acceptableAnswers: <String>['would'], feedbackCorrect: 'will → would.', feedbackWrong: 'would call.'),
    EnglishActivity(id: 'rs_f', kind: EnglishActivityKind.correction, skill: EnglishSkill.grammar, prompt: 'Fix it', incorrectSentence: 'She told she was late.', correctedSentence: 'She said she was late.', correctAnswer: 'she said she was late', feedbackCorrect: 'say + clause · tell + person.', feedbackWrong: 'said, not told (no person).'),
    EnglishActivity(id: 'rs_r', kind: EnglishActivityKind.rapidReview, skill: EnglishSkill.grammar, prompt: '⚡ Report: "I love this."', options: <String>['He said he loves this.', 'He said he loved this.', 'He tells he loved.'], correctIndex: 1, feedbackCorrect: 'love → loved.', feedbackWrong: 'Backshift past.'),
  ],
);
