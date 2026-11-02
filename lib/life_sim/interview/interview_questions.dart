/// Interview question bank: classic behavioural questions + role-specific ones.
library;

enum QuestionKind {
  opening,
  motivation,
  strengths,
  challenge,
  conflict,
  technical,
  closing,
}

class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.kind,
    required this.text,
    this.keywords = const <String>[],
    this.tips = const <String>[],
    this.followUp = 'Can you give me a specific example of that?',
  });

  final String id;
  final QuestionKind kind;

  /// May contain `{employer}` and `{role}` placeholders.
  final String text;

  /// Concepts a strong answer touches (matched by substring, lowercase).
  final List<String> keywords;

  /// Coaching tips shown in interview prep.
  final List<String> tips;
  final String followUp;

  String render({required String employer, required String role}) =>
      text.replaceAll('{employer}', employer).replaceAll('{role}', role);
}

class InterviewQuestionBank {
  const InterviewQuestionBank._();

  static const InterviewQuestion about = InterviewQuestion(
    id: 'about',
    kind: QuestionKind.opening,
    text: 'Thanks for coming in. To start, tell me about yourself.',
    keywords: <String>['stud', 'degree', 'experienc', 'skill', 'project', 'passion', 'interest', 'goal', 'learn'],
    tips: <String>[
      'Give a 45–60 second story: where you are now, what you have done, where you want to go.',
      'Link your background to THIS role — do not recite your whole life.',
    ],
  );

  static const InterviewQuestion why = InterviewQuestion(
    id: 'why_here',
    kind: QuestionKind.motivation,
    text: 'Why do you want to work at {employer} as a {role}?',
    keywords: <String>['compan', 'team', 'mission', 'value', 'role', 'grow', 'learn', 'contribut', 'communit', 'customer'],
    tips: <String>[
      'Show you researched the company — mention what it values.',
      'Say what you will contribute, not only what you will gain.',
    ],
  );

  static const InterviewQuestion strengths = InterviewQuestion(
    id: 'strengths',
    kind: QuestionKind.strengths,
    text: 'What would you say are your greatest strengths?',
    keywords: <String>['strength', 'good at', 'reliab', 'learn', 'detail', 'team', 'communicat', 'solv', 'organi', 'problem', 'adapt'],
    tips: <String>[
      'Pick two strengths that matter for the job and prove each with a quick example.',
    ],
  );

  static const InterviewQuestion challenge = InterviewQuestion(
    id: 'challenge',
    kind: QuestionKind.challenge,
    text: 'Tell me about a challenge you faced and how you dealt with it.',
    keywords: <String>['challeng', 'problem', 'situation', 'solv', 'learn', 'result', 'deadline', 'plan', 'ask', 'fix'],
    tips: <String>[
      'Use STAR: Situation, Task, Action, Result.',
      'End with what you learned.',
    ],
    followUp: 'What was the outcome, and what would you do differently?',
  );

  static const InterviewQuestion conflict = InterviewQuestion(
    id: 'conflict',
    kind: QuestionKind.conflict,
    text: 'How do you handle conflict with a teammate or a difficult customer?',
    keywords: <String>['listen', 'understand', 'calm', 'respect', 'discuss', 'agree', 'resolv', 'perspective', 'feedback', 'compromis'],
    tips: <String>[
      'Show empathy first, then a practical resolution.',
      'Never blame or criticise the other person.',
    ],
    followUp: 'Tell me about a time that actually happened.',
  );

  static const InterviewQuestion whyHire = InterviewQuestion(
    id: 'why_hire',
    kind: QuestionKind.closing,
    text: 'Last question: why should we hire you?',
    keywords: <String>['skill', 'experienc', 'value', 'contribut', 'team', 'result', 'learn', 'reliab', 'passion', 'fit'],
    tips: <String>[
      'Summarise your 2–3 strongest points that match what they need.',
      'Finish confidently and thank them.',
    ],
  );

  /// Role-specific questions.
  static const Map<String, List<InterviewQuestion>> byCareer = <String, List<InterviewQuestion>>{
    'software_engineer': <InterviewQuestion>[
      InterviewQuestion(
        id: 'se_debug',
        kind: QuestionKind.technical,
        text: 'A function works for most inputs but crashes for one customer. Walk me through how you would debug it.',
        keywords: <String>['reproduce', 'log', 'test', 'isolate', 'edge', 'breakpoint', 'stack', 'input', 'null', 'fix', 'regression'],
        tips: <String>['Reproduce → isolate → fix → add a test so it never returns.'],
        followUp: 'Walk me through that step by step.',
      ),
      InterviewQuestion(
        id: 'se_structures',
        kind: QuestionKind.technical,
        text: 'Explain the difference between an array and a linked list, and when you would choose each.',
        keywords: <String>['index', 'constant', 'insert', 'memory', 'traverse', 'pointer', 'node', 'contiguous', 'random access', 'delete'],
        tips: <String>['Compare access, insertion and memory — then give a concrete use case.'],
      ),
      InterviewQuestion(
        id: 'se_quality',
        kind: QuestionKind.technical,
        text: 'How do you make sure your code is easy for teammates to maintain?',
        keywords: <String>['readable', 'test', 'review', 'naming', 'document', 'small', 'refactor', 'comment', 'simple', 'pull request'],
        tips: <String>['Mention tests, clear names, small changes and code review.'],
      ),
    ],
    'pharmacist': <InterviewQuestion>[
      InterviewQuestion(
        id: 'ph_error',
        kind: QuestionKind.technical,
        text: 'You notice a prescription dose looks ten times too high. What do you do?',
        keywords: <String>['stop', 'check', 'calculate', 'prescriber', 'contact', 'not dispense', 'safety', 'patient', 'document', 'verify'],
        tips: <String>['Do not dispense; verify the calculation and contact the prescriber.'],
        followUp: 'And how do you record what happened?',
      ),
      InterviewQuestion(
        id: 'ph_counsel',
        kind: QuestionKind.technical,
        text: 'How would you explain a new medicine to an anxious older patient?',
        keywords: <String>['plain', 'listen', 'explain', 'side effect', 'question', 'understand', 'repeat', 'written', 'calm', 'check'],
        tips: <String>['Plain language, small chunks, and check understanding (teach-back).'],
      ),
      InterviewQuestion(
        id: 'ph_stock',
        kind: QuestionKind.technical,
        text: 'How do you keep important medicines in stock without waste?',
        keywords: <String>['stock', 'reorder', 'usage', 'lead time', 'expiry', 'rotate', 'safety stock', 'supplier', 'count', 'review'],
        tips: <String>['Mention usage, lead time, safety stock and expiry rotation.'],
      ),
    ],
    'nurse': <InterviewQuestion>[
      InterviewQuestion(
        id: 'nu_dizzy',
        kind: QuestionKind.technical,
        text: 'A patient says they feel dizzy and their blood pressure is low. What do you do first?',
        keywords: <String>['sit', 'lie', 'safety', 'fall', 'vital', 'assess', 'notify', 'doctor', 'monitor', 'reassure', 'airway'],
        tips: <String>['Safety first (sit or lie them down), then reassess vitals, then escalate.'],
        followUp: 'And who do you tell, and how?',
      ),
      InterviewQuestion(
        id: 'nu_meds',
        kind: QuestionKind.technical,
        text: 'How do you make sure you give the right medication to the right patient?',
        keywords: <String>['patient', 'drug', 'dose', 'route', 'time', 'allerg', 'check', 'identify', 'wristband', 'document', 'rights'],
        tips: <String>['The five rights: patient, drug, dose, route, time — plus allergies and documentation.'],
      ),
      InterviewQuestion(
        id: 'nu_family',
        kind: QuestionKind.technical,
        text: 'A patient\'s family is anxious and keeps asking for updates. How do you handle it?',
        keywords: <String>['listen', 'explain', 'empath', 'update', 'calm', 'plain', 'privacy', 'consent', 'reassure', 'doctor'],
        tips: <String>['Acknowledge feelings, explain in plain language, respect privacy and consent.'],
      ),
    ],
    'doctor': <InterviewQuestion>[
      InterviewQuestion(
        id: 'dr_chest',
        kind: QuestionKind.technical,
        text: 'A 55-year-old arrives with chest pain. How do you approach them?',
        keywords: <String>['history', 'vital', 'ecg', 'risk', 'troponin', 'differential', 'urgent', 'examine', 'aspirin', 'monitor', 'cardiac'],
        tips: <String>['ABCs and vitals, focused history, ECG and bloods, think of dangerous causes first.'],
        followUp: 'Which diagnoses must you not miss?',
      ),
      InterviewQuestion(
        id: 'dr_news',
        kind: QuestionKind.technical,
        text: 'How would you break bad news to a patient?',
        keywords: <String>['private', 'honest', 'empath', 'pause', 'plan', 'questions', 'understand', 'support', 'clear', 'setting'],
        tips: <String>['Private setting, find out what they know, be honest and kind, leave space, agree a plan.'],
      ),
      InterviewQuestion(
        id: 'dr_tests',
        kind: QuestionKind.technical,
        text: 'How do you decide when to order a test — and when not to?',
        keywords: <String>['indicat', 'probability', 'harm', 'cost', 'guideline', 'result', 'change', 'management', 'history', 'evidence'],
        tips: <String>['Order a test only if the result would change what you do.'],
      ),
    ],
    'lawyer': <InterviewQuestion>[
      InterviewQuestion(
        id: 'lw_bad_fact',
        kind: QuestionKind.technical,
        text: 'A client tells you something that damages their own case. What do you do?',
        keywords: <String>['confidential', 'ethic', 'advise', 'duty', 'court', 'honest', 'privilege', 'options', 'candid', 'mislead'],
        tips: <String>['Confidentiality applies, but you can never mislead the court; advise the client candidly.'],
        followUp: 'Where is the line you will not cross?',
      ),
      InterviewQuestion(
        id: 'lw_prep',
        kind: QuestionKind.technical,
        text: 'How do you prepare for a hearing?',
        keywords: <String>['fact', 'law', 'witness', 'timeline', 'argument', 'rebut', 'bundle', 'authorit', 'precedent', 'anticipate'],
        tips: <String>['Facts, law, witnesses, then anticipate the other side.'],
      ),
      InterviewQuestion(
        id: 'lw_explain',
        kind: QuestionKind.technical,
        text: 'How do you explain a complicated legal issue to a client with no legal background?',
        keywords: <String>['plain', 'simple', 'example', 'option', 'risk', 'analogy', 'summar', 'check', 'understand', 'jargon'],
        tips: <String>['Plain words, options with risks, and check understanding.'],
      ),
    ],
    'accountant': <InterviewQuestion>[
      InterviewQuestion(
        id: 'ac_diff',
        kind: QuestionKind.technical,
        text: 'At month end your bank balance differs from the ledger by \$500. What do you do?',
        keywords: <String>['reconcil', 'trace', 'transaction', 'bank', 'error', 'document', 'timing', 'duplicate', 'statement', 'adjust', 'investigat'],
        tips: <String>['Reconcile line by line, look for timing differences and duplicates, document the fix.'],
        followUp: 'What would you check first?',
      ),
      InterviewQuestion(
        id: 'ac_double',
        kind: QuestionKind.technical,
        text: 'Explain debits and credits, and why the books must always balance.',
        keywords: <String>['asset', 'expense', 'double', 'equation', 'liabilit', 'equity', 'revenue', 'balance', 'ledger', 'entry'],
        tips: <String>['Assets = Liabilities + Equity; every entry has equal debits and credits.'],
      ),
      InterviewQuestion(
        id: 'ac_ethics',
        kind: QuestionKind.technical,
        text: 'A manager asks you to record an expense in next month\'s books so this month looks better. How do you respond?',
        keywords: <String>['integrity', 'policy', 'decline', 'escalate', 'document', 'period', 'standard', 'ethic', 'refuse', 'compliance'],
        tips: <String>['Politely decline, explain the accounting rule, escalate if pressured.'],
      ),
    ],
    'business_manager': <InterviewQuestion>[
      InterviewQuestion(
        id: 'bm_underperf',
        kind: QuestionKind.technical,
        text: 'A team member is consistently missing targets. What do you do?',
        keywords: <String>['listen', 'expect', 'support', 'goal', 'feedback', 'document', 'coach', 'cause', 'plan', 'follow'],
        tips: <String>['Understand the cause, set clear expectations, support, then follow up.'],
        followUp: 'And if nothing improves?',
      ),
      InterviewQuestion(
        id: 'bm_sales',
        kind: QuestionKind.technical,
        text: 'Sales dropped 15% this quarter. How do you respond?',
        keywords: <String>['data', 'customer', 'segment', 'cause', 'hypothes', 'test', 'compare', 'competitor', 'pricing', 'plan', 'kpi'],
        tips: <String>['Diagnose with data before acting; test fixes.'],
      ),
      InterviewQuestion(
        id: 'bm_priorit',
        kind: QuestionKind.technical,
        text: 'Everything is urgent and you have limited people. How do you prioritise?',
        keywords: <String>['impact', 'deadline', 'stakeholder', 'trade', 'delegate', 'priorit', 'communicat', 'criteria', 'value', 'urgent'],
        tips: <String>['Rank by impact and deadline, delegate, and communicate trade-offs.'],
      ),
    ],
  };

  /// Questions for a role at [rank], in the order asked.
  static List<InterviewQuestion> forRole(String careerId, int rank) {
    final List<InterviewQuestion> tech = byCareer[careerId] ?? const <InterviewQuestion>[];
    if (rank <= 0) {
      return <InterviewQuestion>[about, why, strengths, if (tech.isNotEmpty) tech[0], whyHire];
    }
    if (rank == 1) {
      return <InterviewQuestion>[
        about, why, strengths, challenge, if (tech.isNotEmpty) tech[0], whyHire,
      ];
    }
    if (rank <= 3) {
      return <InterviewQuestion>[
        about, why, strengths, challenge, conflict,
        ...tech.take(2),
        whyHire,
      ];
    }
    return <InterviewQuestion>[
      about, why, challenge, conflict,
      ...tech,
      whyHire,
    ];
  }
}
