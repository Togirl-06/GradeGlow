class EnglishProgramBlueprint {
  const EnglishProgramBlueprint({
    required this.title,
    required this.subtitle,
    required this.unitFlow,
    required this.lessonComponents,
    required this.units,
    required this.xpRules,
  });

  final String title;
  final String subtitle;
  final List<String> unitFlow;
  final List<String> lessonComponents;
  final List<EnglishUnitBlueprint> units;
  final List<String> xpRules;
}

class EnglishUnitBlueprint {
  const EnglishUnitBlueprint({
    required this.title,
    required this.goal,
    required this.aiProfessorHook,
    required this.interactiveExamples,
    required this.vocabularyFocus,
    required this.speakingFocus,
    required this.listeningFocus,
    required this.readingFocus,
    required this.writingFocus,
    required this.grammarFocus,
    required this.conversationScenarios,
  });

  final String title;
  final String goal;
  final String aiProfessorHook;
  final List<String> interactiveExamples;
  final List<String> vocabularyFocus;
  final List<String> speakingFocus;
  final List<String> listeningFocus;
  final List<String> readingFocus;
  final List<String> writingFocus;
  final List<String> grammarFocus;
  final List<String> conversationScenarios;
}

const EnglishProgramBlueprint englishProgramBlueprint = EnglishProgramBlueprint(
  title: 'English Learning Experience',
  subtitle:
      'University-level English + Duolingo-style interaction: short AI teaching loops, constant practice, and adaptive feedback.',
  unitFlow: <String>[
    'AI Introduction',
    'Interactive Lecture',
    'Vocabulary',
    'Pronunciation',
    'Grammar',
    'Speaking Practice',
    'Listening Activity',
    'Reading Activity',
    'Writing Exercise',
    'AI Conversation',
    'Mini Quiz',
    'Unit Challenge',
    'XP Rewards',
    'Progress Summary',
    'Smart Review',
  ],
  lessonComponents: <String>[
    'AI lecture',
    'Interactive examples',
    'Vocabulary practice',
    'Speaking practice',
    'Listening practice',
    'Reading comprehension',
    'Writing exercises',
    'Grammar exercises',
    'Instant feedback',
    'Progress tracking',
  ],
  xpRules: <String>[
    'Lesson complete +40 XP',
    'Speaking attempt +15 XP',
    'Listening streak +20 XP',
    'Writing submission +30 XP',
    'Mini quiz perfect score +50 XP',
    'Daily streak bonus +25 XP',
  ],
  units: <EnglishUnitBlueprint>[
    EnglishUnitBlueprint(
      title: 'Unit 1 · Present Perfect in Real Life',
      goal: 'Use present perfect naturally in conversation and writing.',
      aiProfessorHook:
          'Have you ever traveled to another country? Great — you just used present perfect.',
      interactiveExamples: <String>[
        'Learn → Practice → Feedback loops every 2-3 minutes',
        'Pause-and-answer checkpoints before the lecture continues',
        'Mini quiz with adaptive hints if student struggles',
      ],
      vocabularyFocus: <String>[
        'already, yet, ever, never, since, for',
        'Pronunciation, meaning, synonyms, antonyms, common mistakes',
        'Image/audio support when relevant',
      ],
      speakingFocus: <String>[
        'Prompted mic responses to life-experience questions',
        'Score pronunciation, fluency, pacing, confidence',
        'AI coaching: one thing done well + one upgrade',
      ],
      listeningFocus: <String>[
        'Short dialogues with multiple accents',
        'Choose what you heard + fill missing words',
      ],
      readingFocus: <String>[
        'Everyday story passage with main-idea and inference checks',
      ],
      writingFocus: <String>[
        'Write 6-8 present perfect sentences about your life',
        'Feedback on grammar, tone, clarity, and sentence variety',
      ],
      grammarFocus: <String>[
        'Form: have/has + past participle',
        'Contrast with simple past in context',
      ],
      conversationScenarios: <String>[
        'Making friends on campus',
        'Airport check-in conversation',
      ],
    ),
    EnglishUnitBlueprint(
      title: 'Unit 2 · Academic Reading and Discussion',
      goal: 'Read academic texts and discuss key ideas with confidence.',
      aiProfessorHook:
          'Today we read like university students: identify argument, evidence, and author purpose.',
      interactiveExamples: <String>[
        'Concept chunk then immediate question set',
        'Reading + vocab in one adaptive flow',
      ],
      vocabularyFocus: <String>[
        'academic terms, transition words, argument verbs',
      ],
      speakingFocus: <String>[
        'Summarize passage in 30-45 seconds',
        'AI feedback on organization and naturalness',
      ],
      listeningFocus: <String>[
        'Lecture snippet + note-taking checks',
        'Identify speaker intention and tone',
      ],
      readingFocus: <String>[
        'Science, business, and news passages (increasing difficulty)',
        'Main idea, inference, context clues, author purpose',
      ],
      writingFocus: <String>[
        'One-paragraph summary + short response',
        'Feedback explains why corrections are needed',
      ],
      grammarFocus: <String>[
        'Complex sentences',
        'Relative clauses',
        'Punctuation for clarity',
      ],
      conversationScenarios: <String>[
        'College discussion section',
        'Classroom debate',
      ],
    ),
    EnglishUnitBlueprint(
      title: 'Unit 3 · Professional Communication',
      goal: 'Communicate professionally in speech and writing.',
      aiProfessorHook:
          'Let us practice real workplace English: clear emails, meetings, and interviews.',
      interactiveExamples: <String>[
        'Roleplay branches based on student responses',
        'Instant coaching after each turn',
      ],
      vocabularyFocus: <String>[
        'business collocations and interview verbs',
      ],
      speakingFocus: <String>[
        'Mock interview answers',
        'Meeting participation prompts',
      ],
      listeningFocus: <String>[
        'Business conversation comprehension',
        'Ordering and reconstructing dialogue',
      ],
      readingFocus: <String>[
        'Emails, reports, and short policy documents',
      ],
      writingFocus: <String>[
        'Professional email and concise report writing',
      ],
      grammarFocus: <String>[
        'Modal verbs for politeness',
        'Reported speech',
        'Active/passive voice choices',
      ],
      conversationScenarios: <String>[
        'Job interview',
        'Business meeting',
        'Doctor appointment',
      ],
    ),
  ],
);
