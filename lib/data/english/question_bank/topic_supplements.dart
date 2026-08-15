import '../../../models/english_lesson.dart';
import 'bank_helpers.dart';

/// Reading + email activities keyed to each lesson topic — never cross-topic.
Map<String, List<EnglishActivity>> buildTopicSupplements() =>
    <String, List<EnglishActivity>>{
      'present_perfect_1': _pp,
      'past_simple_1': _ps,
      'present_continuous_1': _pc,
      'past_continuous_1': _pcont,
      'future_simple_1': _fs,
      'prepositions_1': _prep,
      'comparatives_1': _comp,
      'conditionals_1': _cond,
      'passive_voice_1': _pass,
      'gerunds_infinitives_1': _gi,
      'countable_uncountable_1': _cu,
      'reported_speech_1': _rs,
      'articles_1': _art,
      'phrasal_verbs_1': _pv,
      'question_words_1': _qw,
      'tag_questions_1': _tag,
      'modals_1': _mod,
      'small_talk_1': _st,
      'opinions_1': _op,
      'pronunciation_th_1': _th,
      'linking_words_1': _link,
    };

// --- Present Perfect ---
final List<EnglishActivity> _pp = <EnglishActivity>[
  ...BankQ.reading(
    'present_perfect_1',
    'rd',
    'I have visited twelve countries. I have never tried skydiving, but I have always wanted to.',
    'Which tense is used throughout?',
    <String>['Past Simple', 'Present Perfect', 'Future'],
    1,
    ok: 'The passage uses Present Perfect (have + past participle).',
  ),
  BankQ.write(
    'present_perfect_1',
    'rds',
    'Summarize the passage using at least one Present Perfect sentence.',
    accept: <String>['have', 'has', 'never', 'ever'],
    criteria: <String>['have', 'has'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'present_perfect_1',
    'em',
    'Scenario: Email a friend about places you have visited.',
    'Write a short email using Present Perfect at least three times '
        '(e.g. I have been…, I have never…).',
    tone: EnglishWritingTone.informal,
    criteria: <String>['have', 'has', 'visited', 'never', 'ever'],
    minWords: 25,
  ),
];

// --- Past Simple ---
final List<EnglishActivity> _ps = <EnglishActivity>[
  ...BankQ.reading(
    'past_simple_1',
    'rd',
    'Yesterday I woke up early, ate breakfast, and walked to class. The lecture started at nine.',
    'When did the lecture start?',
    <String>['Yesterday at eight', 'At nine', 'Tomorrow'],
    1,
  ),
  BankQ.write(
    'past_simple_1',
    'rds',
    'Write two Past Simple sentences about what you did yesterday.',
    accept: <String>['yesterday', 'ed', 'went', 'did'],
    criteria: <String>['yesterday'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'past_simple_1',
    'em',
    'Scenario: Tell your teacher what you studied last weekend.',
    'Write a short formal email describing what you did last weekend. Use Past Simple.',
    criteria: <String>['last', 'weekend', 'studied', 'wrote', 'went'],
    minWords: 25,
  ),
];

// --- Present Continuous ---
final List<EnglishActivity> _pc = <EnglishActivity>[
  ...BankQ.reading(
    'present_continuous_1',
    'rd',
    'Right now the students are taking a test. The teacher is walking between the rows.',
    'What are the students doing?',
    <String>['Leaving', 'Taking a test', 'Sleeping'],
    1,
  ),
  BankQ.write(
    'present_continuous_1',
    'rds',
    'Describe what people in your classroom are doing right now. Use Present Continuous.',
    accept: <String>['is', 'are', 'ing'],
    criteria: <String>['ing'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'present_continuous_1',
    'em',
    'Scenario: You cannot meet a friend because you are busy.',
    'Write a short informal email explaining what you are doing right now (Present Continuous).',
    tone: EnglishWritingTone.informal,
    criteria: <String>['am', 'are', 'ing', 'right now'],
    minWords: 20,
  ),
];

// --- Past Continuous ---
final List<EnglishActivity> _pcont = <EnglishActivity>[
  ...BankQ.reading(
    'past_continuous_1',
    'rd',
    'While I was studying, my phone rang. I was listening to music when the power went out.',
    'What was the speaker doing when the phone rang?',
    <String>['Sleeping', 'Studying', 'Cooking'],
    1,
  ),
  BankQ.write(
    'past_continuous_1',
    'rds',
    'Write one sentence with while + Past Continuous.',
    accept: <String>['while', 'was', 'were', 'ing'],
    criteria: <String>['while', 'was'],
    minWords: 6,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'past_continuous_1',
    'em',
    'Scenario: Explain why you missed a call.',
    'Write an email: you were doing something when they called (Past Continuous).',
    criteria: <String>['was', 'were', 'when', 'ing'],
    minWords: 22,
  ),
];

// --- Future ---
final List<EnglishActivity> _fs = <EnglishActivity>[
  ...BankQ.reading(
    'future_simple_1',
    'rd',
    'Next week we are going to start a new unit. I think it will be challenging but useful.',
    'How does the writer describe the future unit?',
    <String>['Easy and boring', 'Challenging but useful', 'Already finished'],
    1,
  ),
  BankQ.write(
    'future_simple_1',
    'rds',
    'Write three sentences about your plans for next month (will or going to).',
    accept: <String>['will', 'going to', 'plan'],
    criteria: <String>['will'],
    minWords: 10,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'future_simple_1',
    'em',
    'Scenario: Confirm plans for a study group next week.',
    'Write an email about what you will do or are going to do at the study session.',
    criteria: <String>['will', 'going to', 'next week'],
    minWords: 22,
  ),
];

// --- Prepositions ---
final List<EnglishActivity> _prep = <EnglishActivity>[
  ...BankQ.reading(
    'prepositions_1',
    'rd',
    'The café is next to the library. The bus stop is in front of the school, on Main Street.',
    'Where is the bus stop?',
    <String>['Behind the school', 'In front of the school', 'Inside the library'],
    1,
  ),
  BankQ.write(
    'prepositions_1',
    'rds',
    'Describe your room using at least four prepositions (in, on, under, next to…).',
    accept: <String>['in', 'on', 'under', 'next to', 'between'],
    criteria: <String>['in', 'on'],
    minWords: 12,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'prepositions_1',
    'em',
    'Scenario: Give directions to a visitor.',
    'Write an email explaining where to meet you. Use prepositions of place.',
    criteria: <String>['in', 'on', 'at', 'next to', 'near'],
    minWords: 25,
  ),
];

// --- Comparatives ---
final List<EnglishActivity> _comp = <EnglishActivity>[
  ...BankQ.reading(
    'comparatives_1',
    'rd',
    'Online classes are more flexible than morning lectures. However, face-to-face lessons are often more engaging.',
    'What is more flexible according to the text?',
    <String>['Morning lectures', 'Online classes', 'Both equally'],
    1,
  ),
  BankQ.write(
    'comparatives_1',
    'rds',
    'Compare two subjects you study using than or more… than.',
    accept: <String>['than', 'more', 'better', 'harder'],
    criteria: <String>['than'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'comparatives_1',
    'em',
    'Scenario: Recommend one course over another to a friend.',
    'Write an email comparing two courses. Use comparative adjectives.',
    tone: EnglishWritingTone.informal,
    criteria: <String>['than', 'more', 'better', 'easier'],
    minWords: 22,
  ),
];

// --- Conditionals ---
final List<EnglishActivity> _cond = <EnglishActivity>[
  ...BankQ.reading(
    'conditionals_1',
    'rd',
    'If you review a little every day, you will remember more. If you cram the night before, you might feel stressed.',
    'What happens if you review every day?',
    <String>['You will remember more', 'You will forget everything', 'Nothing changes'],
    0,
  ),
  BankQ.write(
    'conditionals_1',
    'rds',
    'Write an If…, I will… sentence about studying.',
    accept: <String>['if', 'will'],
    criteria: <String>['if', 'will'],
    minWords: 6,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'conditionals_1',
    'em',
    'Scenario: Ask a professor what happens if you miss a deadline.',
    'Write a formal email with at least one conditional (If…, will/would…).',
    criteria: <String>['if', 'will', 'would'],
    minWords: 25,
  ),
];

// --- Passive Voice ---
final List<EnglishActivity> _pass = <EnglishActivity>[
  ...BankQ.reading(
    'passive_voice_1',
    'rd',
    'The new library was opened last month. Books are sorted by subject. Wi-Fi is provided throughout the building.',
    'How are books organized?',
    <String>['By color', 'By subject', 'Randomly'],
    1,
    ok: 'Notice the Passive Voice: was opened, are sorted, is provided.',
  ),
  BankQ.write(
    'passive_voice_1',
    'rds',
    'Find two Passive Voice sentences in the passage and write them.',
    accept: <String>['was', 'are', 'is', 'sorted', 'opened'],
    criteria: <String>['was', 'are'],
    minWords: 6,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'passive_voice_1',
    'em',
    'Scenario: Report project progress to a manager.',
    'Write a formal email using at least three Passive Voice sentences.',
    criteria: <String>['was', 'were', 'is', 'are', 'been'],
    minWords: 30,
  ),
];

// --- Gerunds / Infinitives ---
final List<EnglishActivity> _gi = <EnglishActivity>[
  ...BankQ.reading(
    'gerunds_infinitives_1',
    'rd',
    'She enjoys reading before bed. He decided to study abroad. They finished writing the report yesterday.',
    'What does she enjoy?',
    <String>['To read before bed', 'Reading before bed', 'Read before bed'],
    1,
  ),
  BankQ.write(
    'gerunds_infinitives_1',
    'rds',
    'Write one sentence with enjoy + -ing and one with want + to.',
    accept: <String>['enjoy', 'ing', 'want', 'to'],
    criteria: <String>['enjoy', 'to'],
    minWords: 10,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'gerunds_infinitives_1',
    'em',
    'Scenario: Tell a friend about hobbies and goals.',
    'Write an email using enjoy + -ing and plan + to at least once each.',
    tone: EnglishWritingTone.informal,
    criteria: <String>['enjoy', 'ing', 'to'],
    minWords: 25,
  ),
];

// --- Countable / Uncountable ---
final List<EnglishActivity> _cu = <EnglishActivity>[
  ...BankQ.reading(
    'countable_uncountable_1',
    'rd',
    'There is some milk in the fridge and a few apples on the table. We need more bread but we have enough eggs.',
    'What is uncountable in the passage?',
    <String>['Apples', 'Milk and bread', 'Eggs only'],
    1,
  ),
  BankQ.write(
    'countable_uncountable_1',
    'rds',
    'List three countable and three uncountable nouns from the passage.',
    accept: <String>['milk', 'bread', 'apples', 'eggs'],
    criteria: <String>['milk', 'apples'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'countable_uncountable_1',
    'em',
    'Scenario: Request supplies for a class party.',
    'Write an email listing items using much/many, some, a few correctly.',
    criteria: <String>['some', 'many', 'much', 'few'],
    minWords: 25,
  ),
];

// --- Reported Speech ---
final List<EnglishActivity> _rs = <EnglishActivity>[
  ...BankQ.reading(
    'reported_speech_1',
    'rd',
    'The teacher said the test would be on Friday. Maria told me she had already finished her essay.',
    'What did Maria say about her essay?',
    <String>['She will start it', 'She had already finished it', 'She hates essays'],
    1,
  ),
  BankQ.write(
    'reported_speech_1',
    'rds',
    'Report this: "I am tired," said Tom. (Write reported speech)',
    accept: <String>['said', 'was', 'tired'],
    criteria: <String>['said', 'was'],
    minWords: 5,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'reported_speech_1',
    'em',
    'Scenario: Forward what a classmate told you to the teacher.',
    'Write a formal email reporting what someone said (reported speech).',
    criteria: <String>['said', 'told', 'that'],
    minWords: 28,
  ),
];

// --- Articles ---
final List<EnglishActivity> _art = <EnglishActivity>[
  ...BankQ.reading(
    'articles_1',
    'rd',
    'A student found an umbrella in the hallway. The umbrella belonged to a professor in the science department.',
    'Why is "an" used before umbrella?',
    <String>['Umbrella starts with a vowel sound', 'It is plural', 'It is always an'],
    0,
  ),
  BankQ.write(
    'articles_1',
    'rds',
    'Write three sentences using a, an, and the correctly.',
    accept: <String>['a', 'an', 'the'],
    criteria: <String>['the'],
    minWords: 10,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'articles_1',
    'em',
    'Scenario: Describe a problem you saw on campus.',
    'Write an email using a/an/the correctly throughout.',
    criteria: <String>['a', 'an', 'the'],
    minWords: 25,
  ),
];

// --- Phrasal Verbs ---
final List<EnglishActivity> _pv = <EnglishActivity>[
  ...BankQ.reading(
    'phrasal_verbs_1',
    'rd',
    'I woke up late, so I had to hurry up. I picked up my friend and we headed out to class.',
    'What did the writer do after waking up late?',
    <String>['Went back to sleep', 'Had to hurry up', 'Cancelled class'],
    1,
  ),
  BankQ.write(
    'phrasal_verbs_1',
    'rds',
    'Write two sentences using phrasal verbs from the passage.',
    accept: <String>['woke up', 'hurry up', 'picked up', 'headed'],
    criteria: <String>['up'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'phrasal_verbs_1',
    'em',
    'Scenario: Tell a friend about your morning using phrasal verbs.',
    'Write a short informal email about your morning. Use at least two phrasal verbs.',
    tone: EnglishWritingTone.informal,
    criteria: <String>['up', 'out', 'off'],
    minWords: 22,
  ),
];

// --- Question Words ---
final List<EnglishActivity> _qw = <EnglishActivity>[
  ...BankQ.reading(
    'question_words_1',
    'rd',
    'Who teaches the course? What time does it start? Where is the classroom? Why is attendance important?',
    'Which question asks about time?',
    <String>['Who', 'What time', 'Where'],
    1,
  ),
  BankQ.write(
    'question_words_1',
    'rds',
    'Write four questions about your school using Who, What, Where, and Why.',
    accept: <String>['who', 'what', 'where', 'why'],
    criteria: <String>['who', 'what'],
    minWords: 12,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'question_words_1',
    'em',
    'Scenario: Email admin with questions about registration.',
    'Write an email with at least three question words (Who/What/When/Where/Why/How).',
    criteria: <String>['what', 'when', 'how'],
    minWords: 25,
  ),
];

// --- Tag Questions ---
final List<EnglishActivity> _tag = <EnglishActivity>[
  ...BankQ.reading(
    'tag_questions_1',
    'rd',
    'You\'re coming to the review session, aren\'t you? It\'s not difficult, is it? We have practiced, haven\'t we?',
    'What is the tag in "You\'re coming…, aren\'t you?"',
    <String>['aren\'t you', 'is it', 'haven\'t we'],
    0,
  ),
  BankQ.write(
    'tag_questions_1',
    'rds',
    'Write two sentences with tag questions.',
    accept: <String>['isn', 'aren', 'don', 'won'],
    criteria: <String>['you'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'tag_questions_1',
    'em',
    'Scenario: Confirm meeting details with a classmate.',
    'Write a casual email confirming plans. Include at least one tag question.',
    tone: EnglishWritingTone.informal,
    criteria: <String>['isn', 'aren', 'will'],
    minWords: 20,
  ),
];

// --- Modals ---
final List<EnglishActivity> _mod = <EnglishActivity>[
  ...BankQ.reading(
    'modals_1',
    'rd',
    'Students must submit work on time. You should ask for help early. You may use the lab after class.',
    'What are students required to do?',
    <String>['Skip deadlines', 'Submit work on time', 'Never ask for help'],
    1,
  ),
  BankQ.write(
    'modals_1',
    'rds',
    'Write advice for new students using should, must, and can.',
    accept: <String>['should', 'must', 'can', 'may'],
    criteria: <String>['should'],
    minWords: 12,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'modals_1',
    'em',
    'Scenario: Ask permission to retake a quiz.',
    'Write a formal email using could, may, or would politely.',
    criteria: <String>['could', 'would', 'please'],
    minWords: 25,
  ),
];

// --- Small Talk ---
final List<EnglishActivity> _st = <EnglishActivity>[
  ...BankQ.reading(
    'small_talk_1',
    'rd',
    '"How\'s it going?" "Not bad — busy week!" "Yeah, me too. Nice weather today." "Sure is!"',
    'What is the tone of this conversation?',
    <String>['Angry argument', 'Friendly small talk', 'Formal interview'],
    1,
  ),
  BankQ.write(
    'small_talk_1',
    'rds',
    'Write a short small-talk exchange (4 lines) about the weekend.',
    accept: <String>['weekend', 'how', 'fine', 'you'],
    criteria: <String>['weekend'],
    minWords: 12,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'small_talk_1',
    'em',
    'Scenario: Casual email to a classmate after meeting at an event.',
    'Write a friendly follow-up email using small-talk style language.',
    tone: EnglishWritingTone.informal,
    criteria: <String>['hi', 'nice', 'great', 'hope'],
    minWords: 20,
  ),
];

// --- Opinions ---
final List<EnglishActivity> _op = <EnglishActivity>[
  ...BankQ.reading(
    'opinions_1',
    'rd',
    'In my opinion, group projects build teamwork. However, some students prefer working alone because it is faster.',
    'What opinion does the writer express?',
    <String>['Group projects are useless', 'Group projects build teamwork', 'Nobody likes groups'],
    1,
  ),
  BankQ.write(
    'opinions_1',
    'rds',
    'State your opinion on online learning using I think… or In my opinion…',
    accept: <String>['i think', 'opinion', 'believe', 'agree'],
    criteria: <String>['think'],
    minWords: 10,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'opinions_1',
    'em',
    'Scenario: Email a professor sharing your view on a course topic.',
    'Write a formal email stating your opinion with reasons (I think…, because…).',
    criteria: <String>['opinion', 'think', 'believe', 'because'],
    minWords: 28,
  ),
];

// --- Pronunciation TH ---
final List<EnglishActivity> _th = <EnglishActivity>[
  ...BankQ.reading(
    'pronunciation_th_1',
    'rd',
    'Think about the weather. That thunderstorm was loud! My brother thanked the pilot after the flight.',
    'Which word has a voiceless th sound?',
    <String>['That', 'Think', 'Brother'],
    1,
  ),
  BankQ.write(
    'pronunciation_th_1',
    'rds',
    'Write three sentences that each include a word with th.',
    accept: <String>['th', 'think', 'this', 'that', 'the'],
    criteria: <String>['th'],
    minWords: 8,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'pronunciation_th_1',
    'em',
    'Scenario: Email a language partner about pronunciation practice.',
    'Write an email about practicing th sounds. Use words with th in them.',
    tone: EnglishWritingTone.informal,
    criteria: <String>['think', 'thank', 'this', 'that'],
    minWords: 22,
  ),
];

// --- Linking Words ---
final List<EnglishActivity> _link = <EnglishActivity>[
  ...BankQ.reading(
    'linking_words_1',
    'rd',
    'I was tired; however, I finished the essay. Because the deadline was close, I worked late. Therefore, I submitted on time.',
    'Which linker shows contrast?',
    <String>['Because', 'However', 'Therefore'],
    1,
  ),
  BankQ.write(
    'linking_words_1',
    'rds',
    'Write a short paragraph using because, however, and therefore.',
    accept: <String>['because', 'however', 'therefore'],
    criteria: <String>['however'],
    minWords: 15,
    skill: EnglishSkill.reading,
  ),
  BankQ.topicEmail(
    'linking_words_1',
    'em',
    'Scenario: Explain a delay to your professor.',
    'Write a formal email using because and however to link your ideas.',
    criteria: <String>['because', 'however', 'therefore'],
    minWords: 28,
  ),
];
