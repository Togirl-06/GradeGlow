import '../../models/law/law_program.dart';

/// Shared factory for compact, practice-ready Law School topics.
class LawTopicFactory {
  LawTopicFactory._();

  static LawLesson intro({
    required String id,
    required String title,
    required String field,
    required String hook,
    required String question,
    required String doctrine,
    required List<String> elements,
    String writingType = 'Client memo',
    String? simulationCaseId,
    int objectionIndex = 0,
  }) {
    return LawLesson(
      id: id,
      title: title,
      hook: hook,
      question: question,
      doctrine: doctrine,
      elements: elements,
      briefCaseName: 'Teaching brief: $title ($field)',
      briefFacts: hook,
      briefIssue: question,
      briefRule: doctrine,
      briefHolding:
          'Apply the elements to the hook facts; identify the strongest and weakest element for each side.',
      writingPrompt:
          'Write a short $writingType on this $field dispute. Address each element and one counterargument.',
      writingType: writingType,
      objectionStem:
          'Opposing counsel asks a witness a compound, suggestive question about the key $field fact: '
          '"You agree the other side is clearly wrong here, right?"',
      objectionOptions: const <String>['Leading', 'Hearsay', 'Relevance', 'Asked and answered'],
      correctObjectionIndex: objectionIndex,
      objectionExplain:
          'Leading questions suggest the answer and are generally improper on direct of a friendly witness. '
          'In $field practice, control the record with precise objections.',
      clientOpening: 'I need a $field lawyer. Here is what happened: $hook',
      clientFacts: const <String>[
        'Client has documents and a timeline.',
        'Opposing party already made a low settlement offer.',
        'Key witness may be biased.',
        'Deadline or statute of limitations may be approaching.',
      ],
      negotiationOffer:
          'Other side offers a modest settlement and a broad release. Advise accept, counter, or litigate for this $field matter.',
      examHypo: '$hook Discuss the governing $field issues using IRAC. Cover: ${elements.join('; ')}.',
      simulationCaseId: simulationCaseId,
    );
  }
}
