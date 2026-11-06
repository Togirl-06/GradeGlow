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

const List<String> _suffix = <String>['', ' — with the stakeholder', ' — full assignment'];

List<LabScenario> caseScenarios(String prefix, CaseFile c, {LabPerson? person, List<String> tools = const <String>[]}) => <LabScenario>[
      for (int l = 0; l < 3; l++)
        LabScenario(
          id: '${prefix}_${c.key}_${l + 1}',
          title: '${c.title}${_suffix[l]}',
          level: levels3[l],
          people: <LabPerson>[if (person != null) person],
          briefing: Briefing(
            what: '${c.brief} ${<String>[
              'Work the ${c.queueName.toLowerCase()}.',
              'Work the ${c.queueName.toLowerCase()}, then speak to ${c.person}.',
              'Work the ${c.queueName.toLowerCase()}, speak to ${c.person}${c.procedure.isEmpty ? '' : ', plan the procedure'}${c.docType.isEmpty ? '' : ' and write the ${c.docType.toLowerCase()}'}.',
            ][l]}',
            why: 'This is the work a new professional is trusted with in their first months.',
            information: c.sources,
            tools: tools.isEmpty ? const <String>['Work queue', 'Conversation', 'Document editor', 'Calculator'] : tools,
            expected: <String>[
              'Every item in the queue decided correctly.',
              'Correct queue decisions, and the right questions and conclusions in the conversation.',
              'The whole assignment to the standard your supervisor would sign off.',
            ][l],
          ),
          steps: <LabStep>[
            TriageStep(
              id: '${prefix}_${c.key}_${l + 1}_q',
              title: c.queueName,
              instructions: 'Open each item and make a decision for every field.',
              queueName: c.queueName,
              fields: c.fields,
              items: c.items,
            ),
            if (l >= 1)
              DialogueStep(
                id: '${prefix}_${c.key}_${l + 1}_talk',
                title: 'Speak to ${c.person}',
                instructions: 'Choose what to ask or say. You have a limited number of turns — focus on what matters.',
                person: c.person,
                opening: c.opening,
                options: c.options,
                conclusions: c.conclusions,
                maxTurns: c.options.where((DialogueOption o) => o.value == DialogueValue.essential || o.value == DialogueValue.useful).length + 2,
              ),
            if (l == 2 && c.procedure.isNotEmpty)
              SequenceStep(
                id: '${prefix}_${c.key}_${l + 1}_proc',
                title: 'Plan the procedure',
                instructions: 'Put the steps in the order you would carry them out.',
                correctOrder: c.procedure,
                mustPrecede: c.mustPrecede,
              ),
            if (l == 2 && c.sections.isNotEmpty)
              DocumentStep(
                id: '${prefix}_${c.key}_${l + 1}_doc',
                title: 'Write the ${c.docType.toLowerCase()}',
                instructions: 'Write each section in full sentences. The marking rubric is shown beside each section.',
                docType: c.docType,
                sections: c.sections,
                model: c.model,
                forbidden: c.forbidden,
                sources: c.sources,
              ),
          ],
        ),
    ];

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
