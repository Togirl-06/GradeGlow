import '../../../models/english_lesson.dart';
import 'challenge_helpers.dart';
import 'challenge_quiz_questions.dart';

/// University-level challenge pool — varied types, CEFR-tagged, topic-specific.
Map<String, List<EnglishActivity>> buildChallengeQuestionBank() {
  final Map<String, List<EnglishActivity>> bank =
      <String, List<EnglishActivity>>{
      'present_perfect_1': _presentPerfect(),
      'past_simple_1': _pastSimple(),
      'present_continuous_1': _presentContinuous(),
      'past_continuous_1': _pastContinuous(),
      'future_simple_1': _futureSimple(),
      'prepositions_1': _prepositions(),
      'comparatives_1': _comparatives(),
      'conditionals_1': _conditionals(),
      'passive_voice_1': _passiveVoice(),
      'gerunds_infinitives_1': _gerunds(),
      'countable_uncountable_1': _countable(),
      'reported_speech_1': _reportedSpeech(),
      'articles_1': _articles(),
      'phrasal_verbs_1': _phrasalVerbs(),
      'question_words_1': _questionWords(),
      'tag_questions_1': _tagQuestions(),
      'modals_1': _modals(),
      'small_talk_1': _smallTalk(),
      'opinions_1': _opinions(),
      'pronunciation_th_1': _pronunciation(),
      'email_writing_1': _emailWriting(),
      'linking_words_1': _linkingWords(),
      'reading_comp_1': _readingComp(),
    };
  for (final MapEntry<String, List<EnglishActivity>> e
      in challengeQuizBank.entries) {
    bank.putIfAbsent(e.key, () => <EnglishActivity>[]).addAll(e.value);
  }
  return bank;
}

List<EnglishActivity> _presentPerfect() => <EnglishActivity>[
      BankCh.rewrite(
        'present_perfect_1',
        'rw1',
        'I finish the report yesterday.',
        'Present Perfect',
        instruction: 'Rewrite using Present Perfect (experience / unfinished time):',
        cefr: EnglishCefrLevel.b2,
        model: 'I have finished the report.',
        accept: <String>['i have finished the report'],
      ),
      BankCh.explain(
        'present_perfect_1',
        'ex1',
        'She have visited Paris twice.',
        <String>[
          'The auxiliary should be "has" with she.',
          'The sentence needs a question mark only.',
          'Past simple is required here.',
        ],
        0,
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.combine(
        'present_perfect_1',
        'cb1',
        'I have studied English',
        'I have never been to Canada',
        'I have studied English, but I have never been to Canada.',
        linker: 'but',
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.bestOf(
        'present_perfect_1',
        'bs1',
        'Which sentence best expresses unfinished time (still this week)?',
        <String>[
          'I went to the library on Monday.',
          'I have been to the library three times this week.',
          'I was going to the library every day.',
        ],
        1,
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.vocabContext(
        'present_perfect_1',
        'vc1',
        'Have you finished your essay ___?',
        <String>['already', 'yesterday', 'last week'],
        0,
        cefr: EnglishCefrLevel.a2,
      ),
      BankCh.speakTask(
        'present_perfect_1',
        'sp1',
        'Defend this opinion in 3–4 sentences: "Learning grammar rules is still essential, even with AI tools."',
        cefr: EnglishCefrLevel.c1,
        criteria: <String>['present perfect', 'opinion', 'because'],
        minWords: 35,
      ),
    ];

List<EnglishActivity> _pastSimple() => <EnglishActivity>[
      BankCh.rewrite(
        'past_simple_1',
        'rw1',
        'Last year I go to Berlin for a conference.',
        'Past Simple',
        instruction: 'Correct the tense:',
        cefr: EnglishCefrLevel.a2,
        model: 'Last year I went to Berlin for a conference.',
      ),
      BankCh.paragraphFix(
        'past_simple_1',
        'pf1',
        'Yesterday I wake up early and eat breakfast. Then I goed to campus and attend three lectures. In the evening I writed an essay.',
        'Yesterday I woke up early and ate breakfast. Then I went to campus and attended three lectures. In the evening I wrote an essay.',
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.transform(
        'past_simple_1',
        'tr1',
        'Hey! I missed class cuz I was sick lol.',
        'I missed class yesterday because I was unwell.',
        taskLabel: 'Rewrite in formal academic English',
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.inference(
        'past_simple_1',
        'inf1',
        'The professor cancelled the tutorial after only three students arrived. '
            'She emailed everyone that attendance had been disappointing all term.',
        'What can you infer about class attendance?',
        <String>[
          'Students always enjoyed the tutorials.',
          'Low attendance was an ongoing problem.',
          'The tutorial was moved to a larger room.',
        ],
        1,
        cefr: EnglishCefrLevel.b2,
      ),
    ];

List<EnglishActivity> _presentContinuous() => <EnglishActivity>[
      BankCh.explain(
        'present_continuous_1',
        'ex1',
        'She is knowing the answer right now.',
        <String>[
          'Stative verbs like "know" are not normally used in continuous form.',
          'The sentence needs "has" instead of "is".',
          'Present continuous cannot describe the present.',
        ],
        0,
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.rewrite(
        'present_continuous_1',
        'rw1',
        'Listen! The baby cries again.',
        'Present Continuous',
        instruction: 'Rewrite to show something happening now:',
        model: 'Listen! The baby is crying again.',
        cefr: EnglishCefrLevel.a2,
      ),
      BankCh.bestOf(
        'present_continuous_1',
        'bs1',
        'Which sentence describes a temporary situation?',
        <String>[
          'I am living with my aunt until I find an apartment.',
          'I live in Toronto.',
          'I lived in Toronto for ten years.',
        ],
        0,
        cefr: EnglishCefrLevel.b2,
      ),
    ];

List<EnglishActivity> _pastContinuous() => <EnglishActivity>[
      BankCh.combine(
        'past_continuous_1',
        'cb1',
        'I was studying in the library',
        'the fire alarm went off',
        'I was studying in the library when the fire alarm went off.',
        linker: 'when',
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.rewrite(
        'past_continuous_1',
        'rw1',
        'While she walked home, it started to rain.',
        'Past Continuous',
        instruction: 'Use past continuous for the longer background action:',
        model: 'While she was walking home, it started to rain.',
        cefr: EnglishCefrLevel.b1,
      ),
    ];

List<EnglishActivity> _futureSimple() => <EnglishActivity>[
      BankCh.bestOf(
        'future_simple_1',
        'bs1',
        'Dark clouds are gathering. Which prediction fits best?',
        <String>[
          'It will rain in a moment — I can see the evidence.',
          'It is going to rain soon.',
          'It rained yesterday.',
        ],
        1,
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.rewrite(
        'future_simple_1',
        'rw1',
        'I think I am calling you later tonight.',
        'will',
        instruction: 'Rewrite with "will" for a spontaneous decision:',
        model: 'I think I will call you later tonight.',
        cefr: EnglishCefrLevel.b1,
      ),
    ];

List<EnglishActivity> _prepositions() => <EnglishActivity>[
      BankCh.vocabContext(
        'prepositions_1',
        'vc1',
        'The research paper was published ___ a leading journal.',
        <String>['in', 'on', 'at'],
        0,
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.bestOf(
        'prepositions_1',
        'bs1',
        'Choose the most natural collocation:',
        <String>[
          'interested on science',
          'interested in science',
          'interested at science',
        ],
        1,
        cefr: EnglishCefrLevel.b1,
      ),
    ];

List<EnglishActivity> _comparatives() => <EnglishActivity>[
      BankCh.rewrite(
        'comparatives_1',
        'rw1',
        'This algorithm is more fast than the previous one.',
        'comparative',
        instruction: 'Correct the comparative form:',
        model: 'This algorithm is faster than the previous one.',
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.explain(
        'comparatives_1',
        'ex1',
        'She is the most tallest person in the room.',
        <String>[
          'Superlative of "tall" is "tallest" — do not use "most" with -est.',
          'Comparatives need "more" with every adjective.',
          'The sentence should use past tense.',
        ],
        0,
        cefr: EnglishCefrLevel.b1,
      ),
    ];

List<EnglishActivity> _conditionals() => <EnglishActivity>[
      BankCh.rewrite(
        'conditionals_1',
        'rw1',
        'If you will study harder, you pass the exam.',
        'first conditional',
        instruction: 'Rewrite as a correct first conditional:',
        model: 'If you study harder, you will pass the exam.',
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.bestOf(
        'conditionals_1',
        'bs1',
        'Which sentence expresses a real future possibility?',
        <String>[
          'If I were rich, I would travel.',
          'If it rains tomorrow, we will cancel the picnic.',
          'If I studied yesterday, I would know.',
        ],
        1,
        cefr: EnglishCefrLevel.b2,
      ),
    ];

List<EnglishActivity> _passiveVoice() => <EnglishActivity>[
      BankCh.transform(
        'passive_voice_1',
        'tr1',
        'The committee approved the new policy yesterday.',
        'The new policy was approved by the committee yesterday.',
        taskLabel: 'Change to passive voice',
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.rewrite(
        'passive_voice_1',
        'rw1',
        'The experiment was conducting by two graduate students.',
        'passive',
        instruction: 'Correct the passive form:',
        model: 'The experiment was conducted by two graduate students.',
        cefr: EnglishCefrLevel.b2,
      ),
    ];

List<EnglishActivity> _gerunds() => <EnglishActivity>[
      BankCh.explain(
        'gerunds_infinitives_1',
        'ex1',
        'She suggested to take a break after the long meeting.',
        <String>[
          '"Suggest" is followed by a gerund (-ing), not infinitive.',
          'The sentence needs past tense only.',
          'Infinitive is always wrong after verbs.',
        ],
        0,
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.bestOf(
        'gerunds_infinitives_1',
        'bs1',
        'Which sentence is correct?',
        <String>[
          'I look forward to meet you.',
          'I look forward to meeting you.',
          'I look forward meet you.',
        ],
        1,
        cefr: EnglishCefrLevel.c1,
      ),
    ];

List<EnglishActivity> _countable() => <EnglishActivity>[
      BankCh.paragraphFix(
        'countable_uncountable_1',
        'pf1',
        'I bought three furnitures for my new apartment. I also need many advices about decorating. There are too much boxes in the hallway.',
        'I bought three pieces of furniture for my new apartment. I also need some advice about decorating. There are too many boxes in the hallway.',
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.vocabContext(
        'countable_uncountable_1',
        'vc1',
        'There is too ___ traffic on the highway this morning.',
        <String>['much', 'many', 'few'],
        0,
        cefr: EnglishCefrLevel.a2,
      ),
    ];

List<EnglishActivity> _reportedSpeech() => <EnglishActivity>[
      BankCh.rewrite(
        'reported_speech_1',
        'rw1',
        'She said, "I will submit the assignment tomorrow."',
        'reported speech',
        instruction: 'Report the statement (backshift tenses):',
        model: 'She said that she would submit the assignment the next day.',
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.explain(
        'reported_speech_1',
        'ex1',
        'He asked me where do I live.',
        <String>[
          'Reported questions use statement word order (where I live).',
          'Reported speech never changes pronouns.',
          'Questions cannot be reported.',
        ],
        0,
        cefr: EnglishCefrLevel.b2,
      ),
    ];

List<EnglishActivity> _articles() => <EnglishActivity>[
      BankCh.bestOf(
        'articles_1',
        'bs1',
        'Choose the correct sentence for a general scientific truth:',
        <String>[
          'The water boils at 100°C.',
          'Water boils at 100°C.',
          'A water boils at 100°C.',
        ],
        1,
        cefr: EnglishCefrLevel.b1,
      ),
      BankCh.vocabContext(
        'articles_1',
        'vc1',
        'She wants to become ___ engineer after graduation.',
        <String>['an', 'a', 'the'],
        0,
        cefr: EnglishCefrLevel.a2,
      ),
    ];

List<EnglishActivity> _phrasalVerbs() => <EnglishActivity>[
      BankCh.vocabContext(
        'phrasal_verbs_1',
        'vc1',
        'The startup had to ___ its expansion plans due to funding cuts.',
        <String>['put off', 'put on', 'put up'],
        0,
        cefr: EnglishCefrLevel.b2,
        blank: 'Choose the phrasal verb meaning "postpone":',
      ),
      BankCh.bestOf(
        'phrasal_verbs_1',
        'bs1',
        'Replace "investigate" with a natural phrasal verb:',
        <String>[
          'look into',
          'look after',
          'look down',
        ],
        0,
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.speakTask(
        'phrasal_verbs_1',
        'sp1',
        'Explain a problem you had to "deal with" recently. Use at least two phrasal verbs naturally.',
        cefr: EnglishCefrLevel.b2,
        minWords: 40,
      ),
    ];

List<EnglishActivity> _questionWords() => <EnglishActivity>[
      BankCh.rewrite(
        'question_words_1',
        'rw1',
        'Where you went on vacation last summer?',
        'question',
        instruction: 'Write the correct question:',
        model: 'Where did you go on vacation last summer?',
        cefr: EnglishCefrLevel.a2,
      ),
      BankCh.inference(
        'question_words_1',
        'inf1',
        'Student: "I\'m not sure how to cite this source."\n'
            'Librarian: "Have you checked the style guide on the website?"',
        'What is the librarian suggesting the student do?',
        <String>[
          'Ignore the citation rules',
          'Look up the citation format online',
          'Change the research topic',
        ],
        1,
        cefr: EnglishCefrLevel.b1,
      ),
    ];

List<EnglishActivity> _tagQuestions() => <EnglishActivity>[
      BankCh.explain(
        'tag_questions_1',
        'ex1',
        'You\'re coming to the meeting, aren\'t you?',
        <String>[
          'This sentence is actually correct.',
          'Tags must always be positive.',
          'The auxiliary verb is wrong.',
        ],
        0,
        cefr: EnglishCefrLevel.b2,
        bad: 'Read carefully — this one follows the rule correctly.',
      ),
      BankCh.rewrite(
        'tag_questions_1',
        'rw1',
        'She doesn\'t like spicy food, does she?',
        'tag',
        instruction: 'Fix the tag question:',
        model: 'She doesn\'t like spicy food, does she?',
        accept: <String>['she doesnt like spicy food does she'],
        cefr: EnglishCefrLevel.b1,
      ),
    ];

List<EnglishActivity> _modals() => <EnglishActivity>[
      BankCh.bestOf(
        'modals_1',
        'bs1',
        'Which modal best expresses strong advice about academic integrity?',
        <String>[
          'You might copy from the internet.',
          'You must not plagiarize under any circumstances.',
          'You can plagiarize if you are busy.',
        ],
        1,
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.vocabContext(
        'modals_1',
        'vc1',
        'Students ___ submit drafts before the final deadline.',
        <String>['should', 'might', 'would'],
        0,
        cefr: EnglishCefrLevel.b1,
        blank: 'Choose the modal for recommendation:',
      ),
    ];

List<EnglishActivity> _smallTalk() => <EnglishActivity>[
      BankCh.mc(
        'small_talk_1',
        'sc1',
        'Scenario: University networking event.\n\nSomeone asks "What do you study?" Best reply?',
        <String>[
          'I study computer science. What about you?',
          'Study.',
          'No.',
        ],
        0,
        cefr: EnglishCefrLevel.b1,
        skill: EnglishSkill.conversation,
      ),
      BankCh.speakTask(
        'small_talk_1',
        'sp1',
        'Role-play: A classmate asks about your research interests. Respond naturally and ask them a follow-up question.',
        cefr: EnglishCefrLevel.b2,
        minWords: 35,
      ),
    ];

List<EnglishActivity> _opinions() => <EnglishActivity>[
      BankCh.speakTask(
        'opinions_1',
        'sp1',
        'Persuade your study group that online lectures are as effective as in-person classes. Give two reasons.',
        cefr: EnglishCefrLevel.c1,
        criteria: <String>['because', 'however', 'believe'],
        minWords: 45,
      ),
      BankCh.essay(
        'opinions_1',
        'es1',
        'Should social media be banned for students during exam periods? '
            'Write a short argumentative paragraph (120+ words) with a clear position and supporting reasons.',
        <String>['thesis', 'evidence', 'counterargument', 'conclusion'],
        cefr: EnglishCefrLevel.c1,
        minWords: 120,
      ),
    ];

List<EnglishActivity> _pronunciation() => <EnglishActivity>[
      BankCh.speakTask(
        'pronunciation_th_1',
        'sp1',
        'Read aloud with clear TH sounds: "I think that three of them thanked the therapist."',
        cefr: EnglishCefrLevel.b1,
        minWords: 10,
      ),
    ];

List<EnglishActivity> _emailWriting() => <EnglishActivity>[
      BankCh.mc(
        'email_writing_1',
        'sc1',
        'Scenario: You interviewed for a marketing internship yesterday.\n\n'
            'Which line best opens a follow-up email to HR?',
        <String>[
          'Hey, whats up?',
          'Dear Ms. Patel, Thank you for meeting with me yesterday.',
          'I want the job lol',
        ],
        1,
        cefr: EnglishCefrLevel.b2,
        skill: EnglishSkill.writing,
      ),
      EnglishActivity(
        id: 'ch_email_writing_1_em1',
        kind: EnglishActivityKind.emailWriting,
        skill: EnglishSkill.writing,
        prompt:
            'Write a formal follow-up email to Ms. Patel, HR manager at NovaTech. '
            'Thank her for the interview, mention one strength you discussed, '
            'and politely ask about the timeline for a decision.',
        taskLabel: 'Professional follow-up · formal tone',
        writingTone: EnglishWritingTone.formal,
        pickRecipient: true,
        minWords: 60,
        cefrLevel: EnglishCefrLevel.b2,
        difficulty: EnglishActivityDifficulty.hard,
        gradingCriteria: <String>[
          'thank',
          'interview',
          'timeline',
          'regards',
        ],
        feedbackCorrect: 'Professional and complete follow-up!',
        feedbackWrong: 'Include greeting, thanks, one detail from the interview, and a polite closing.',
      ),
      BankCh.transform(
        'email_writing_1',
        'tr1',
        'hey can u send me the report asap thx',
        'Could you please send me the report at your earliest convenience? Thank you.',
        taskLabel: 'Rewrite as a professional business email opening line',
        cefr: EnglishCefrLevel.b2,
      ),
    ];

List<EnglishActivity> _linkingWords() => <EnglishActivity>[
      BankCh.rewrite(
        'linking_words_1',
        'rw1',
        'The data was incomplete. We published the findings.',
        'linking word',
        instruction: 'Combine using "Nevertheless," to show contrast:',
        model: 'The data was incomplete; nevertheless, we published the findings.',
        cefr: EnglishCefrLevel.c1,
      ),
      BankCh.paragraphFix(
        'linking_words_1',
        'pf1',
        'The experiment failed. We learned useful information. The team was discouraged. They planned a new trial.',
        'Although the experiment failed, we learned useful information. Nevertheless, the team was discouraged and planned a new trial.',
        cefr: EnglishCefrLevel.c1,
      ),
      BankCh.essay(
        'linking_words_1',
        'es1',
        'Discuss the importance of environmental protection in urban areas. '
            'Use at least three linking words (however, therefore, furthermore). 150+ words.',
        <String>['however', 'therefore', 'furthermore', 'conclusion'],
        cefr: EnglishCefrLevel.c1,
        minWords: 150,
      ),
    ];

List<EnglishActivity> _readingComp() => <EnglishActivity>[
      BankCh.inference(
        'reading_comp_1',
        'inf1',
        'Universities are expanding hybrid learning models, but faculty surveys show mixed enthusiasm. '
            'While younger lecturers adapt quickly, senior professors cite concerns about engagement and academic rigor. '
            'Administrators, meanwhile, highlight cost savings and wider access.',
        'What is the author\'s tone toward hybrid learning?',
        <String>[
          'Unquestioningly enthusiastic',
          'Balanced — acknowledging both benefits and concerns',
          'Completely opposed to any change',
        ],
        1,
        cefr: EnglishCefrLevel.c1,
        ok: 'You identified the balanced, analytical tone.',
      ),
      BankCh.inference(
        'reading_comp_1',
        'inf2',
        'The study found that students who reviewed notes within 24 hours retained 40% more material than those who waited a week. '
            'However, the researchers cautioned that the sample size was small and further replication is needed.',
        'What limitation does the author emphasize?',
        <String>[
          'Students never take notes',
          'The sample size was limited',
          'Reviewing notes is always ineffective',
        ],
        1,
        cefr: EnglishCefrLevel.b2,
      ),
      BankCh.essay(
        'reading_comp_1',
        'es1',
        'Summarize the main argument of a recent news article you have read about technology in education. '
            'Include the author\'s main claim, one supporting detail, and your brief evaluation. 100+ words.',
        <String>['main idea', 'supporting', 'summary'],
        cefr: EnglishCefrLevel.c1,
        minWords: 100,
      ),
    ];

final Map<String, List<EnglishActivity>> challengeQuestionBank =
    buildChallengeQuestionBank();
