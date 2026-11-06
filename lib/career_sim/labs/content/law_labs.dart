/// School of Law: seven labs at Ashford & Lane Solicitors. Each lab works
/// the firm's fifteen client matters (law_matters.dart) through a different
/// professional task — research, analysis, drafting, client interviews,
/// negotiation, court advocacy and a full case.
library;

import 'dart:math' as math;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../work/work_steps.dart';
import 'law_matters.dart';

const List<String> _strategies = <String>[
  'Proceed towards trial on the merits',
  'Negotiate a settlement',
  'Advise the client not to pursue (or to resolve informally)',
];

const List<String> _strategyPattern = <String>[
  r'trial|issue proceedings|court',
  r'settle|settlement|negotiat|mediat',
  r'not (to )?pursue|no (viable |realistic )?(claim|case)|discontinu|resolve informally|not (be )?(liable|recoverable)',
];

const List<String> lawReference = <String>[
  'Jurisdiction: England and Wales. All cases in your files are real reported decisions — cite only those.',
  'Citations: Name v Name [year] volume report page, e.g. Donoghue v Stevenson [1932] AC 562.',
  'IRAC: Issue → Rule (authority) → Application to the facts → Conclusion.',
  'Never guarantee a client an outcome; give a reasoned view of prospects.',
  'Client confidentiality: never discuss one client’s affairs with another.',
  'Examination-in-chief: open questions only. Leading questions are for cross-examination.',
  'Limitation (Limitation Act 1980): contract and tort generally 6 years; personal injury 3 years.',
];

LabDifficulty _level(int i) => i < 5 ? LabDifficulty.foundation : (i < 10 ? LabDifficulty.intermediate : LabDifficulty.advanced);

bool _defends(LegalMatter m) => m.client.toLowerCase().contains('defendant');

String _clientName(LegalMatter m) => m.client.split(',').first;

String _surname(LegalMatter m) => _clientName(m).split(' ').last;

/// A distinctive word from a citation (first significant word of the claimant).
String citationKey(String citation) {
  final List<String> parts = citation.split(RegExp(r'\s+v\.?\s+'));
  if (parts.first.trim() == 'R' && parts.length > 1) return parts[1].split(' ').first;
  return parts.first.split(' ').firstWhere((String w) => w.length > 2 && w != 'The', orElse: () => parts.first);
}

String _statute(LegalMatter m) => m.legislation.isEmpty ? '' : m.legislation.first.split(',').first;

List<T> _shuffled<T>(List<T> xs, String seed) {
  final List<T> out = List<T>.of(xs);
  out.shuffle(math.Random(seed.codeUnits.fold<int>(11, (int a, int c) => (a * 31 + c) & 0x3fffffff)));
  return out;
}

/// Options with the correct one shuffled in; returns (options, correct index).
(List<String>, int) _mc(String correct, List<String> wrong, String seed) {
  final List<String> opts = _shuffled(<String>[correct, ...wrong], seed);
  return (opts, opts.indexOf(correct));
}

ChoiceQuestion _q(String id, String prompt, String correct, List<String> wrong, String seed, {String explain = ''}) {
  final (List<String> o, int c) = _mc(correct, wrong, seed);
  return ChoiceQuestion(id, prompt, o, c, explain: explain);
}

// ------------------------------------------------------------ rubric pieces

const RubricItem _guarantee = RubricItem('promising the client a guaranteed outcome',
    <String>[r'\bguarantee', r'certain to (win|succeed)', r'will definitely (win|succeed)', r'100\s*% (sure|certain)'],
    advice: 'Solicitors give a reasoned view of prospects; they never guarantee results.');

RubricItem _issueItem(LegalMatter m) => RubricItem('identifies the legal issue', <String>[m.issuePattern], weight: 2, advice: 'State the precise question the law must answer.');

List<RubricItem> _authorityItems(LegalMatter m) => <RubricItem>[
      for (final Authority a in m.relevant) RubricItem('cites ${citationKey(a.citation)} (${a.citation})', <String>[RegExp.escape(citationKey(a.citation))], weight: 2, advice: a.proposition),
      if (m.legislation.isNotEmpty) RubricItem('refers to the ${_statute(m)}', <String>[RegExp.escape(_statute(m).split(' ').first)], advice: m.legislation.join(' ')),
    ];

RubricItem _conclusionItem(LegalMatter m) => RubricItem('reaches the correct conclusion', <String>[m.conclusionPattern], weight: 2, advice: m.conclusion);

const RubricItem _applies = RubricItem('applies the law to these facts', <String>[r'\bbecause\b', r'\btherefore\b', r'on (these|the) facts', r'\bapplies\b', r'\bhere\b'],
    advice: 'Connect each rule to a specific fact.');

/// A paragraph that satisfies every rubric item for [m] (model answer).
String modelParagraph(LegalMatter m, {int minWords = 0}) {
  final StringBuffer b = StringBuffer()
    ..write('Dear ${_clientName(m)}, the issue is ${m.issue.toLowerCase()}. ')
    ..write('The relevant law is: ${m.relevant.map((Authority a) => '${a.citation}, where ${a.proposition[0].toLowerCase()}${a.proposition.substring(1)}').join(' ')} ')
    ..write(m.legislation.isEmpty ? '' : '${m.legislation.join(' ')} ')
    ..write('On these facts the rule applies because ${m.facts.where(((String, bool) f) => f.$2).map(((String, bool) f) => f.$1.toLowerCase().replaceAll('.', '')).join('; ')}. ')
    ..write('Therefore our conclusion is: ${m.conclusion}. ')
    ..write('Recommended approach: ${_strategies[m.strategy].toLowerCase()} — we recommend that you ${<String>['proceed to trial', 'negotiate a settlement', 'do not pursue the claim'][m.strategy]}. ')
    ..write('Please provide ${m.evidence.toLowerCase()}. We ask for a response within 14 days. The sum claimed is £${m.claimValue.round()}. ')
    ..write('This attendance note records the advice given at our meeting with the client. ');
  String t = b.toString();
  while (RegExp(r"[A-Za-z0-9'’]+").allMatches(t).length < minWords) {
    t += 'This view is based on the documents in the file and the instructions received, and will be reviewed if further evidence emerges. ';
  }
  return t;
}

DocumentStep _doc(String id, LegalMatter m, String type, List<DocSection> sections, {String title = ''}) {
  final int maxWords = sections.fold<int>(0, (int a, DocSection s) => math.max(a, s.minWords));
  return DocumentStep(
    id: id,
    title: title.isEmpty ? 'Draft the $type' : title,
    instructions: 'Write each section in your own words. Cite only authorities in the file. The rubric is shown below the editor.',
    docType: type,
    sections: sections,
    sources: <String>[
      'Matter: ${m.title} (${m.area}). Client: ${m.client}. Other side: ${m.opponent}.',
      m.summary,
      for (final Authority a in m.authorities) '${a.citation} — ${a.proposition}',
      ...m.legislation,
    ],
    allowedCitations: <String>[for (final Authority a in m.authorities) a.citation],
    forbidden: const <RubricItem>[_guarantee],
    model: <String, String>{for (final DocSection s in sections) s.id: modelParagraph(m, minWords: math.max(maxWords, s.minWords))},
  );
}

List<DocSection> _draftSections(LegalMatter m, String type) => switch (type) {
      'Legal memorandum' => <DocSection>[
          DocSection('question', 'Question presented', minWords: 20, rubric: <RubricItem>[_issueItem(m)]),
          DocSection('answer', 'Brief answer', minWords: 25, rubric: <RubricItem>[_conclusionItem(m)]),
          DocSection('discussion', 'Discussion', minWords: 80, rubric: <RubricItem>[..._authorityItems(m), _applies]),
          DocSection('recommendation', 'Recommendation', minWords: 20, rubric: <RubricItem>[RubricItem('recommends a course of action', <String>[_strategyPattern[m.strategy]], advice: _strategies[m.strategy])]),
        ],
      'Letter before claim' => <DocSection>[
          DocSection('details', 'Details of the claim', minWords: 40, rubric: <RubricItem>[RubricItem('names our client', <String>[RegExp.escape(_surname(m))])]),
          DocSection('basis', 'Legal basis', minWords: 60, rubric: <RubricItem>[_issueItem(m), ..._authorityItems(m), _applies]),
          DocSection('remedy', 'What our client seeks', minWords: 20, rubric: <RubricItem>[RubricItem('states the sum or remedy sought', <String>[r'£\s?\d', r'refund', r'compensation', r'damages'])]),
          DocSection('deadline', 'Response required', minWords: 15, rubric: <RubricItem>[RubricItem('sets a reasonable deadline (e.g. 14 days)', <String>[r'within \d+ days', r'\d+ days', r'by \d'])]),
        ],
      'Case brief' => <DocSection>[
          DocSection('facts', 'Material facts', minWords: 40, rubric: const <RubricItem>[]),
          DocSection('issue', 'Issue', minWords: 15, rubric: <RubricItem>[_issueItem(m)]),
          DocSection('rule', 'Rule', minWords: 40, rubric: _authorityItems(m)),
          DocSection('application', 'Application', minWords: 50, rubric: const <RubricItem>[_applies]),
          DocSection('conclusion', 'Conclusion', minWords: 20, rubric: <RubricItem>[_conclusionItem(m)]),
        ],
      'Attendance note' => <DocSection>[
          DocSection('attendance', 'Attendance', minWords: 15, rubric: <RubricItem>[RubricItem('records who attended', <String>[RegExp.escape(_surname(m)), r'client', r'attend'])]),
          DocSection('instructions', 'Client’s instructions', minWords: 40, rubric: const <RubricItem>[]),
          DocSection('advice', 'Advice given', minWords: 60, rubric: <RubricItem>[_issueItem(m), ..._authorityItems(m), _conclusionItem(m)]),
          DocSection('actions', 'Action points', minWords: 20, rubric: <RubricItem>[RubricItem('lists the evidence to obtain', <String>[RegExp.escape(m.evidence.split(' ').where((String w) => w.length > 5).first.toLowerCase())], advice: m.evidence)]),
        ],
      _ => <DocSection>[
          DocSection('intro', 'Introduction', minWords: 20, rubric: <RubricItem>[RubricItem('addresses the client', <String>[RegExp.escape(_surname(m)), RegExp.escape(_clientName(m).split(' ').first)])]),
          DocSection('facts', 'Our understanding of the facts', minWords: 40, rubric: const <RubricItem>[]),
          DocSection('advice', 'Our advice', minWords: 80, rubric: <RubricItem>[_issueItem(m), ..._authorityItems(m), _applies, _conclusionItem(m)]),
          DocSection('next', 'Next steps', minWords: 20, rubric: <RubricItem>[RubricItem('recommends a course of action', <String>[_strategyPattern[m.strategy]], advice: _strategies[m.strategy])]),
        ],
    };

String _draftType(int i, LegalMatter m) {
  if (m.area.startsWith('Criminal')) return 'Case brief';
  if (_defends(m)) return 'Legal memorandum';
  if (m.strategy == 2) return i.isEven ? 'Client advice letter' : 'Legal memorandum';
  return const <String>['Client advice letter', 'Legal memorandum', 'Letter before claim', 'Case brief', 'Attendance note'][i % 5];
}

// ------------------------------------------------------------ step builders

TriageStep _authorityTriage(String id, LegalMatter m) => TriageStep(
      id: id,
      title: 'Assess the research file',
      instructions: 'For each source, decide whether it is relevant to the issue in this matter.',
      queueName: 'Research file',
      fields: const <TriageField>[TriageField('rel', 'Relevant to this issue?', <String>['Relevant', 'Not relevant'])],
      items: <TriageItem>[
        for (int k = 0; k < m.authorities.length; k++)
          TriageItem(
            id: 'a$k',
            title: m.authorities[k].citation,
            body: m.authorities[k].proposition,
            answers: <String, String>{'rel': m.authorities[k].relevant ? 'Relevant' : 'Not relevant'},
            why: m.authorities[k].relevant ? 'It decides the same legal question.' : 'It concerns a different legal question.',
          ),
        for (int k = 0; k < m.legislation.length; k++)
          TriageItem(id: 'l$k', title: m.legislation[k].split(' — ').first, body: m.legislation[k], answers: const <String, String>{'rel': 'Relevant'}, why: 'The statute governs this matter.'),
      ],
    );

TriageStep _factTriage(String id, LegalMatter m) => TriageStep(
      id: id,
      title: 'Separate material from immaterial facts',
      instructions: 'A material fact affects the legal outcome. Mark each fact.',
      queueName: 'Case file facts',
      fields: const <TriageField>[TriageField('mat', 'Legally material?', <String>['Material', 'Not material'])],
      items: <TriageItem>[
        for (int k = 0; k < m.facts.length; k++)
          TriageItem(id: 'f$k', title: 'Fact ${k + 1}', body: m.facts[k].$1, answers: <String, String>{'mat': m.facts[k].$2 ? 'Material' : 'Not material'}),
      ],
    );

const DialogueOption _promise = DialogueOption('promise', 'Tell them we will definitely win', 'Client: That’s a relief — so it’s guaranteed?',
    value: DialogueValue.unsafe, note: 'Never guarantee an outcome (professional conduct).');
const DialogueOption _confidential = DialogueOption('other', 'Mention another client’s similar case by name', 'Client: Oh — is that someone I might know?',
    value: DialogueValue.unsafe, note: 'Breach of client confidentiality.');
const DialogueOption _fees = DialogueOption('fees', 'Explain our fees and how the matter could be funded', 'Client: Thanks, that is clear.', value: DialogueValue.useful);

DialogueStep _consultation(String id, LegalMatter m) {
  final List<DialogueOption> opts = <DialogueOption>[
    for (int k = 0; k < m.interview.length; k++)
      DialogueOption('q$k', m.interview[k].question, '${_clientName(m)}: ${m.interview[k].answer}', value: m.interview[k].essential ? DialogueValue.essential : DialogueValue.neutral),
    DialogueOption('docs', 'Ask what documents or evidence they have', '${_clientName(m)}: I can get you ${m.evidence.toLowerCase()}.', value: DialogueValue.useful),
    _fees,
    _promise,
    _confidential,
  ];
  return DialogueStep(
    id: id,
    title: 'Interview the client',
    instructions: 'Find out what you need to advise. You have limited time: choose questions carefully. Then record your conclusions.',
    person: _clientName(m),
    opening: 'Thanks for seeing me. ${m.summary}',
    options: _shuffled(opts, id),
    maxTurns: m.interview.length + 3,
    conclusions: <MathQuestion>[
      _q('issue', 'The key legal issue is', m.issue, m.wrongIssues, '${id}i'),
      _q('evidence', 'The most important evidence to obtain now is', m.evidence, m.wrongEvidence, '${id}e'),
    ],
  );
}

DialogueStep _courtroom(String id, LegalMatter m) {
  final String witness = _clientName(m);
  final List<DialogueOption> opts = <DialogueOption>[
    for (int k = 0; k < m.interview.length; k++) ...<DialogueOption>[
      DialogueOption('open$k', m.interview[k].question, '$witness: ${m.interview[k].answer}',
          value: m.interview[k].essential ? DialogueValue.essential : DialogueValue.neutral),
      if (m.interview[k].leading.isNotEmpty)
        DialogueOption('lead$k', m.interview[k].leading, 'Opposing counsel: Objection — counsel is leading the witness. Judge: Sustained. Please rephrase.',
            value: DialogueValue.poor, note: 'Leading questions are not allowed when examining your own witness.'),
    ],
    DialogueOption('spec', 'Ask the witness what the other party was thinking', 'Opposing counsel: Objection — speculation. Judge: Sustained.',
        value: DialogueValue.poor, note: 'A witness can only give evidence of what they perceived.'),
    DialogueOption('attack', 'Tell the judge the other side is lying', 'Judge: Counsel, that is a matter for submissions, not an accusation from the bar. I will note that.',
        value: DialogueValue.unsafe, note: 'Advocates must not make unsupported allegations or give evidence themselves.'),
  ];
  return DialogueStep(
    id: id,
    title: 'Examination-in-chief and the judge’s questions',
    instructions: 'Call $witness and bring out the facts with open questions. Then answer the judge.',
    person: 'Court',
    opening: 'Judge: Counsel, you may call your witness. ($witness takes the oath.)',
    options: _shuffled(opts, id),
    maxTurns: m.interview.length + 4,
    conclusions: <MathQuestion>[
      _q('auth', 'Judge: “Counsel, what is your principal authority?”', m.relevant.isNotEmpty ? m.relevant.first.citation : m.legislation.first,
          <String>[for (final Authority a in m.authorities.where((Authority a) => !a.relevant).take(3)) a.citation], '${id}a'),
      _q('order', 'Judge: “What do you invite the court to find?”', m.conclusion, m.wrongConclusions, '${id}o'),
    ],
  );
}

double _step(LegalMatter m) => m.claimValue <= 2000 ? 10 : (m.claimValue <= 20000 ? 100 : 500);

LabStep _negotiation(String id, LegalMatter m) {
  if (m.claimValue == 0) {
    return TriageStep(
      id: id,
      title: 'Prepare representations to the prosecution',
      instructions: 'Before asking the CPS to review the charge, decide how each fact bears on the case.',
      queueName: 'Evidence review',
      fields: const <TriageField>[TriageField('eff', 'Effect on the case', <String>['Supports the defence', 'Irrelevant'])],
      items: <TriageItem>[
        for (int k = 0; k < m.facts.length; k++)
          TriageItem(id: 'e$k', title: 'Item ${k + 1}', body: m.facts[k].$1, answers: <String, String>{'eff': m.facts[k].$2 ? 'Supports the defence' : 'Irrelevant'}),
      ],
    );
  }
  final bool def = _defends(m);
  final double x = m.opponentMaximum;
  final String net = def ? 'a + ${m.monthlyCost}m' : 'a - ${m.monthlyCost}m';
  return SimulationStep(
    id: id,
    title: 'Mediation: reach a settlement within your authority',
    instructions: def
        ? 'You act for the paying party. In a private session the mediator says the claimant will not accept less than £${x.round()}. '
            'Your client has authorised total spending (settlement plus legal costs of £${m.monthlyCost.round()} a month) of up to £${(x * 1.5).round()}, and wants it resolved within 3 months.'
        : 'In a private session the mediator says ${m.opponent} cannot go above £${x.round()}. Your client’s bottom line is £${m.clientMinimum.round()} after legal costs '
            '(£${m.monthlyCost.round()} a month until settled), and they want it resolved within 3 months.',
    inputs: <SimInput>[
      SimInput('a', 'Settlement figure', 0, m.claimValue, step: _step(m), initial: m.claimValue, unit: '£'),
      const SimInput('m', 'Months until settlement', 0, 12, step: 1, initial: 6),
    ],
    outputs: <SimOutput>[
      const SimOutput('s', 'Settlement figure', 'a', unit: '£', decimals: 0),
      SimOutput('n', def ? 'Total cost to your client' : 'Your client’s net recovery', net, unit: '£', decimals: 0),
      const SimOutput('t', 'Months to resolve', 'm', decimals: 0),
    ],
    constraints: <SimConstraint>[
      if (def) SimConstraint('s', '>=', x, 'At least the claimant’s walk-away figure (£${x.round()})') else SimConstraint('s', '<=', x, 'Within what the other side can pay (£${x.round()})'),
      if (def) SimConstraint('n', '<=', x * 1.5, 'Within your client’s authority (£${(x * 1.5).round()})') else SimConstraint('n', '>=', m.clientMinimum, 'At or above your client’s bottom line (£${m.clientMinimum.round()})'),
      const SimConstraint('t', '<=', 3, 'Resolved within 3 months'),
    ],
    questions: <MathQuestion>[
      NumberQuestion('net2', def ? 'Total cost to your client if settled at £${x.round()} after 2 months' : 'Your client’s net recovery if settled at £${x.round()} after 2 months',
          def ? x + 2 * m.monthlyCost : x - 2 * m.monthlyCost, tolerance: 1, unit: '£'),
      _q('batna', 'Your client’s best alternative to a negotiated agreement is to', _strategies[m.strategy == 1 ? 0 : m.strategy], <String>[
        for (int k = 0; k < 3; k++)
          if (k != (m.strategy == 1 ? 0 : m.strategy)) _strategies[k],
        'Accept whatever is offered first',
      ], '${id}b'),
    ],
    model: <String, double>{'a': x, 'm': 0},
  );
}

// ------------------------------------------------------------ scenarios

LabScenario _sc(String prefix, int i, String what, String why, List<LabStep> steps, {List<String> info = const <String>[], List<String> reqs = const <String>[]}) {
  final LegalMatter m = lawMatters[i];
  return LabScenario(
    id: '${prefix}_${m.id}',
    title: m.title,
    level: _level(i),
    people: <LabPerson>[LabPerson(_clientName(m), m.client.split(', ').skip(1).join(', '), m.summary.split('. ').first)],
    briefing: Briefing(
      what: what,
      why: why,
      information: <String>['${m.area} · ${m.client} v ${m.opponent}', m.summary, ...info],
      tools: const <String>['Matter file and research bundle', 'Document editor with rubric', 'Calculator and scratch pad', 'Firm reference notes'],
      expected: 'Work that a supervising partner could sign off: accurate law, only verified authorities, and clear reasoning.',
      requirements: reqs,
    ),
    steps: steps,
  );
}

LabSpec _lab(String id, int number, String title, String summary, List<String> objectives, List<String> skills, int minutes, List<LabScenario> scenarios, {bool portfolio = false}) =>
    LabSpec(
      id: id,
      deptId: 'law',
      majorId: 'introduction_to_law',
      number: number,
      title: title,
      environment: LabEnvironment.lawFirm,
      summary: summary,
      objectives: objectives,
      skills: skills,
      difficulty: LabDifficulty.intermediate,
      minutes: minutes,
      scenarios: scenarios,
      reference: lawReference,
      addsToPortfolio: portfolio,
    );

const List<String> _conduct = <String>['Cite only authorities in the file; never invent a citation.', 'Do not guarantee outcomes.', 'Keep client information confidential.'];

final LabSpec lawResearchLab = _lab(
  'law_lab_research',
  1,
  'Legal Research',
  'Take a client’s question, identify the issue, sort a research bundle of real cases and statutes into relevant and irrelevant, and write a research summary citing only what you have verified.',
  const <String>['Frame the legal issue precisely', 'Assess the relevance of authorities', 'Write a research summary with accurate citations'],
  const <String>['law_research', 'law_reasoning'],
  30,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('lr', i, 'Research the law for ${lawMatters[i].title}.', 'Every piece of advice the firm gives rests on research like this.', <LabStep>[
        NumericStep(id: 'lr_${lawMatters[i].id}_1', title: 'Frame the issue', instructions: 'Read the file and choose the precise legal question.', questions: <MathQuestion>[
          _q('issue', 'The legal issue is', lawMatters[i].issue, lawMatters[i].wrongIssues, 'lr$i'),
        ]),
        _authorityTriage('lr_${lawMatters[i].id}_2', lawMatters[i]),
        _doc('lr_${lawMatters[i].id}_3', lawMatters[i], 'Research summary', <DocSection>[
          DocSection('issue', 'Issue', minWords: 15, rubric: <RubricItem>[_issueItem(lawMatters[i])]),
          DocSection('law', 'Relevant law', minWords: 40, rubric: _authorityItems(lawMatters[i])),
          DocSection('conclusion', 'Conclusion', minWords: 20, rubric: <RubricItem>[_conclusionItem(lawMatters[i])]),
        ]),
      ], reqs: _conduct),
  ],
);

final LabSpec lawCaseAnalysisLab = _lab(
  'law_lab_analysis',
  2,
  'Case Analysis',
  'Work through a case file: pick out the material facts, decide the outcome, and write a structured IRAC analysis.',
  const <String>['Distinguish material from immaterial facts', 'Apply rules to facts', 'Write IRAC analyses'],
  const <String>['law_reasoning', 'law_writing'],
  30,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('la', i, 'Analyse the case file for ${lawMatters[i].title}.', 'Partners rely on trainees to see which facts actually matter.', <LabStep>[
        _factTriage('la_${lawMatters[i].id}_1', lawMatters[i]),
        NumericStep(id: 'la_${lawMatters[i].id}_2', title: 'Decide the likely outcome', instructions: 'Apply the law in the file to the material facts.', questions: <MathQuestion>[
          _q('outcome', 'The most likely outcome is', lawMatters[i].conclusion, lawMatters[i].wrongConclusions, 'la$i'),
        ]),
        _doc('la_${lawMatters[i].id}_3', lawMatters[i], 'IRAC analysis', <DocSection>[
          DocSection('issue', 'Issue', minWords: 15, rubric: <RubricItem>[_issueItem(lawMatters[i])]),
          DocSection('rule', 'Rule', minWords: 30, rubric: _authorityItems(lawMatters[i])),
          DocSection('application', 'Application', minWords: 50, rubric: const <RubricItem>[_applies]),
          DocSection('conclusion', 'Conclusion', minWords: 15, rubric: <RubricItem>[_conclusionItem(lawMatters[i])]),
        ]),
      ], reqs: _conduct),
  ],
);

final LabSpec lawDraftingLab = _lab(
  'law_lab_drafting',
  3,
  'Legal Drafting',
  'Draft the document each matter needs — client advice letters, memoranda, letters before claim, case briefs and attendance notes — against the firm’s rubric.',
  const <String>['Choose the right structure for the document', 'Write clearly for the reader', 'Cite accurately and never overpromise'],
  const <String>['law_writing'],
  35,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('ld', i, 'Draft a ${_draftType(i, lawMatters[i]).toLowerCase()} for ${lawMatters[i].title}.', 'Written work leaves the firm under the partner’s name: it must be accurate and professional.', <LabStep>[
        _doc('ld_${lawMatters[i].id}_1', lawMatters[i], _draftType(i, lawMatters[i]), _draftSections(lawMatters[i], _draftType(i, lawMatters[i]))),
      ], reqs: _conduct),
  ],
  portfolio: true,
);

final LabSpec lawConsultationLab = _lab(
  'law_lab_consultation',
  4,
  'Client Consultation',
  'Interview the client. Ask the right questions in the time available, avoid professional-conduct breaches, then identify the issue and the evidence needed.',
  const <String>['Elicit the legally relevant facts', 'Communicate professionally and ethically', 'Identify missing evidence'],
  const <String>['law_client', 'law_reasoning'],
  25,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('lc', i, 'First meeting with ${_clientName(lawMatters[i])} about ${lawMatters[i].title}.', 'Advice is only as good as the facts you gather.', <LabStep>[
        _consultation('lc_${lawMatters[i].id}_1', lawMatters[i]),
      ], reqs: _conduct),
  ],
);

final LabSpec lawNegotiationLab = _lab(
  'law_lab_negotiation',
  5,
  'Negotiation and Mediation',
  'Settle disputes within your client’s instructions. Model the settlement range, the cost of delay and your client’s alternatives.',
  const <String>['Work within client authority', 'Calculate the effect of costs and delay', 'Identify the best alternative to agreement'],
  const <String>['law_client', 'law_reasoning'],
  25,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('ln', i, lawMatters[i].claimValue == 0 ? 'Prepare representations to the prosecution in ${lawMatters[i].title}.' : 'Mediation day in ${lawMatters[i].title}.',
          'Most disputes end in negotiated outcomes, not trials.', <LabStep>[_negotiation('ln_${lawMatters[i].id}_1', lawMatters[i])], reqs: _conduct),
  ],
);

final LabSpec lawCourtroomLab = _lab(
  'law_lab_courtroom',
  6,
  'Courtroom Practice',
  'Examine your witness in a mock trial. Open questions bring out evidence; leading or speculative questions draw objections the judge will sustain. Then answer the judge.',
  const <String>['Conduct an examination-in-chief', 'Respond to objections and the bench', 'Make submissions grounded in authority'],
  const <String>['law_advocacy'],
  25,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('lt', i, 'Trial day in ${lawMatters[i].title}.', 'Advocacy turns preparation into an outcome.', <LabStep>[_courtroom('lt_${lawMatters[i].id}_1', lawMatters[i])],
          reqs: const <String>['Use open questions with your own witness.', 'Never mislead the court.']),
  ],
);

final LabSpec lawFullCaseLab = _lab(
  'law_lab_fullcase',
  7,
  'Full Case Assignment',
  'Run a matter from start to finish: research file, skeleton argument, settlement position and final strategy.',
  const <String>['Integrate research, drafting and strategy', 'Advise on the best route for the client'],
  const <String>['law_research', 'law_writing', 'law_advocacy', 'law_client'],
  50,
  <LabScenario>[
    for (int i = 0; i < lawMatters.length; i++)
      _sc('lf', i, 'Take ${lawMatters[i].title} from file opening to strategy.', 'This is what a trainee’s seat in litigation looks like.', <LabStep>[
        _authorityTriage('lf_${lawMatters[i].id}_1', lawMatters[i]),
        _doc('lf_${lawMatters[i].id}_2', lawMatters[i], 'Skeleton argument', <DocSection>[
          DocSection('issue', 'Issue', minWords: 15, rubric: <RubricItem>[_issueItem(lawMatters[i])]),
          DocSection('law', 'Law', minWords: 40, rubric: _authorityItems(lawMatters[i])),
          DocSection('application', 'Application', minWords: 50, rubric: const <RubricItem>[_applies]),
          DocSection('order', 'Outcome sought', minWords: 15, rubric: <RubricItem>[_conclusionItem(lawMatters[i])]),
        ]),
        _negotiation('lf_${lawMatters[i].id}_3', lawMatters[i]),
        NumericStep(id: 'lf_${lawMatters[i].id}_4', title: 'Recommend a strategy', instructions: 'Weigh the merits, costs and the client’s goals.', questions: <MathQuestion>[
          ChoiceQuestion('strategy', 'Your recommendation to the client', _strategies, lawMatters[i].strategy, explain: lawMatters[i].conclusion),
        ]),
      ], reqs: _conduct),
  ],
  portfolio: true,
);

final List<LabSpec> lawLabs = <LabSpec>[lawResearchLab, lawCaseAnalysisLab, lawDraftingLab, lawConsultationLab, lawNegotiationLab, lawCourtroomLab, lawFullCaseLab];
