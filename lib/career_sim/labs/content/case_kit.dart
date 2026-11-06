/// Builders for casework labs (business, HR, IT, security, health, English,
/// software teams …). A [CaseFile] is one realistic piece of work: a queue
/// of items to decide, a person to talk to, a procedure and a written
/// deliverable. It is run at three levels, each adding the next part of the
/// job, so five case files make a fifteen-scenario lab.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../work/work_steps.dart';
import 'design_kit.dart' show levels3;

class CaseFile {
  const CaseFile({
    required this.key,
    required this.title,
    required this.brief,
    required this.queueName,
    required this.fields,
    required this.items,
    required this.person,
    required this.opening,
    required this.options,
    this.conclusions = const <MathQuestion>[],
    this.procedure = const <String>[],
    this.mustPrecede = const <(int, int)>[],
    this.docType = '',
    this.sections = const <DocSection>[],
    this.model = const <String, String>{},
    this.forbidden = const <RubricItem>[],
    this.sources = const <String>[],
  });

  final String key;
  final String title;
  final String brief;
  final String queueName;
  final List<TriageField> fields;
  final List<TriageItem> items;

  /// Who the student talks to, e.g. "Priya Shah, store manager".
  final String person;
  final String opening;
  final List<DialogueOption> options;
  final List<MathQuestion> conclusions;

  /// A procedure in the correct order (optional).
  final List<String> procedure;
  final List<(int, int)> mustPrecede;

  /// The written deliverable (optional).
  final String docType;
  final List<DocSection> sections;
  final Map<String, String> model;
  final List<RubricItem> forbidden;
  final List<String> sources;
}

const List<String> _suffix = <String>['', ' — follow-up', ' — closing the case'];

/// The three scenarios of one case file. Each level is a different stage of
/// the same job rather than a repeat: (1) work the queue; (2) follow it up in
/// conversation; (3) plan the procedure and write the document. When a case
/// has no procedure or document, level 3 is the whole assignment end to end.
List<LabScenario> caseScenarios(String prefix, CaseFile c, {LabPerson? person, List<String> tools = const <String>[]}) {
  LabStep queue(int l) => TriageStep(
        id: '${prefix}_${c.key}_${l + 1}_q',
        title: c.queueName,
        instructions: 'Open each item and make a decision for every field.',
        queueName: c.queueName,
        fields: c.fields,
        items: c.items,
      );
  LabStep talk(int l) => DialogueStep(
        id: '${prefix}_${c.key}_${l + 1}_talk',
        title: 'Speak to ${c.person}',
        instructions: 'Choose what to ask or say. You have a limited number of turns — focus on what matters.',
        person: c.person,
        opening: c.opening,
        options: c.options,
        conclusions: c.conclusions,
        maxTurns: c.options.where((DialogueOption o) => o.value == DialogueValue.essential || o.value == DialogueValue.useful).length + 2,
      );
  final bool hasProc = c.procedure.isNotEmpty, hasDoc = c.sections.isNotEmpty;
  final List<String> caseNotes = <String>[for (final TriageItem i in c.items) '${i.title}: ${i.body}'];
  final List<List<LabStep>> steps = <List<LabStep>>[
    <LabStep>[queue(0)],
    <LabStep>[talk(1)],
    <LabStep>[
      if (!(hasProc && hasDoc)) queue(2),
      if (!hasProc && !hasDoc) talk(2),
      if (hasProc)
        SequenceStep(
          id: '${prefix}_${c.key}_3_proc',
          title: 'Plan the procedure',
          instructions: 'Put the steps in the order you would carry them out.',
          correctOrder: c.procedure,
          mustPrecede: c.mustPrecede,
        ),
      if (hasDoc)
        DocumentStep(
          id: '${prefix}_${c.key}_3_doc',
          title: 'Write the ${c.docType.toLowerCase()}',
          instructions: 'Write each section in full sentences. The marking rubric is shown beside each section.',
          docType: c.docType,
          sections: c.sections,
          model: c.model,
          forbidden: c.forbidden,
          sources: c.sources,
        ),
    ],
  ];
  final List<String> doing = <String>[
    'Work the ${c.queueName.toLowerCase()}.',
    'Follow up with ${c.person}: ask the right questions and reach the right conclusions.',
    hasProc || hasDoc
        ? 'Close the case: ${<String>[if (hasProc) 'plan the procedure', if (hasDoc) 'write the ${c.docType.toLowerCase()}'].join(' and ')}.'
        : 'Handle the whole case end to end: the ${c.queueName.toLowerCase()} and the conversation with ${c.person}.',
  ];
  return <LabScenario>[
    for (int l = 0; l < 3; l++)
      LabScenario(
        id: '${prefix}_${c.key}_${l + 1}',
        title: '${c.title}${_suffix[l]}',
        level: levels3[l],
        people: <LabPerson>[if (person != null) person],
        briefing: Briefing(
          what: '${c.brief} ${doing[l]}',
          why: 'This is the work a new professional is trusted with in their first months.',
          information: <String>[...c.sources, if (l > 0) ...<String>['Case file — ${c.queueName}:', ...caseNotes]],
          tools: tools.isEmpty ? const <String>['Work queue', 'Conversation', 'Document editor', 'Calculator'] : tools,
          expected: <String>[
            'Every item in the queue decided correctly.',
            'The right questions asked, nothing unsafe said, and the right conclusions.',
            'The case closed to the standard your supervisor would sign off.',
          ][l],
        ),
        steps: steps[l],
      ),
  ];
}

/// Five case files → fifteen scenarios ordered beginner → advanced.
List<LabScenario> fromCases(String prefix, List<CaseFile> cs, {LabPerson? person, List<String> tools = const <String>[]}) {
  final List<LabScenario> all = <LabScenario>[for (final CaseFile c in cs) ...caseScenarios(prefix, c, person: person, tools: tools)];
  all.sort((LabScenario a, LabScenario b) => a.level.index.compareTo(b.level.index));
  return all;
}

/// Orders a mixed list of scenarios beginner → advanced (stable).
List<LabScenario> byLevel(List<LabScenario> all) {
  final List<LabScenario> out = <LabScenario>[];
  for (final LabDifficulty l in levels3) {
    out.addAll(all.where((LabScenario s) => s.level == l));
  }
  return out;
}

// ------------------------------------------------------------ coding problems

const String pyStdinStarter = 'import sys\n\nlines = sys.stdin.read().split("\\n")\n# Write your solution here\n';
const String jsStdinStarter = 'const lines = require("fs").readFileSync(0, "utf8").split("\\n");\n// Write your solution here\n';

class CodeVariant {
  const CodeVariant(this.instructions, this.cases, {this.starterPy, this.starterJs});
  final String instructions;
  final List<ProgramCase> cases;

  /// Starting code (e.g. a deliberately faulty program to repair).
  final String? starterPy;
  final String? starterJs;
}

/// One programming problem set at three levels (each a variant with its own tests).
class CodeProblem {
  const CodeProblem({required this.key, required this.title, required this.brief, required this.variants, this.skills = const <String>[]});
  final String key;
  final String title;
  final String brief;
  final List<CodeVariant> variants;
  final List<String> skills;
}

List<LabScenario> codeScenarios(String prefix, CodeProblem p, {LabPerson? person}) => <LabScenario>[
      for (int l = 0; l < 3; l++)
        LabScenario(
          id: '${prefix}_${p.key}_${l + 1}',
          title: '${p.title}${<String>['', ' — extended', ' — production-ready'][l]}',
          level: levels3[l],
          people: <LabPerson>[if (person != null) person],
          briefing: Briefing(
            what: '${p.brief} ${p.variants[l].instructions}',
            why: 'Working code that handles real inputs is what the team ships.',
            information: const <String>['Programs read from standard input and print to standard output.', 'Hidden edge cases are part of the tests — do not hard-code answers.'],
            tools: const <String>['Code editor (Python 3 or JavaScript)', 'Console to run with your own input', 'Automated tests'],
            expected: 'A program that passes every test case.',
          ),
          steps: <LabStep>[
            ProgramStep(
              id: '${prefix}_${p.key}_${l + 1}_code',
              title: p.title,
              instructions: p.variants[l].instructions,
              cases: p.variants[l].cases,
              skills: p.skills,
              starter: <String, String>{
                'python3': p.variants[l].starterPy ?? pyStdinStarter,
                'javascript': p.variants[l].starterJs ?? jsStdinStarter,
              },
            ),
          ],
        ),
    ];

List<LabScenario> fromCode(String prefix, List<CodeProblem> ps, {LabPerson? person}) =>
    <LabScenario>[for (final CodeProblem p in ps) ...codeScenarios(prefix, p, person: person)];

// ------------------------------------------------------------ SQL problems

/// One level of a SQL problem: the task and the rows a correct answer gives.
class SqlVariant {
  const SqlVariant(this.instructions, this.expected, {this.check, this.ordered = false, this.starter = ''});
  final String instructions;
  final List<List<Object?>> expected;

  /// Query run after the student's statements (for INSERT/UPDATE/CREATE tasks).
  final String? check;
  final bool ordered;

  /// Starting SQL (e.g. a broken query to repair).
  final String starter;
}

/// A database task at three levels, run against the lab's SQLite database.
class SqlProblem {
  const SqlProblem({required this.key, required this.title, required this.brief, required this.variants, this.skills = const <String>[]});
  final String key;
  final String title;
  final String brief;
  final List<SqlVariant> variants;
  final List<String> skills;
}

List<LabScenario> sqlScenarios(String prefix, SqlProblem p, {LabPerson? person}) => <LabScenario>[
      for (int l = 0; l < 3; l++)
        LabScenario(
          id: '${prefix}_${p.key}_${l + 1}',
          title: '${p.title}${<String>['', ' — extended', ' — production-ready'][l]}',
          level: levels3[l],
          people: <LabPerson>[if (person != null) person],
          briefing: Briefing(
            what: '${p.brief} ${p.variants[l].instructions}',
            why: 'Correct, efficient queries are what the business relies on for its decisions.',
            information: const <String>['Run queries against the lab database as often as you like.', 'Results are compared row by row with the correct answer.'],
            tools: const <String>['SQL editor', 'Database schema browser', 'Query results grid'],
            expected: 'A query (or change) that produces exactly the required rows.',
          ),
          steps: <LabStep>[
            SqlStep(
              id: '${prefix}_${p.key}_${l + 1}_sql',
              title: p.title,
              instructions: p.variants[l].instructions,
              expected: p.variants[l].expected,
              check: p.variants[l].check,
              ordered: p.variants[l].ordered,
              starter: p.variants[l].starter,
              skills: p.skills,
            ),
          ],
        ),
    ];

List<LabScenario> fromSql(String prefix, List<SqlProblem> ps, {LabPerson? person}) =>
    <LabScenario>[for (final SqlProblem p in ps) ...sqlScenarios(prefix, p, person: person)];
