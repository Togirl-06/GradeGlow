import 'vu_v2_topic_content_models.dart';

/// Adds T/F + short-answer variants alongside MC for demo coverage.
abstract final class VuV2MixedQuiz {
  static List<VuV2Mcq> enrich(List<VuV2Mcq> base) {
    if (base.isEmpty) {
      return const <VuV2Mcq>[
        VuV2Mcq(
          id: 'tf1',
          prompt: 'Practice improves retention. True or False?',
          choices: <String>['True', 'False'],
          correctIndex: 0,
          explanation: 'Spaced practice strengthens memory.',
          kind: VuV2QuestionKind.trueFalse,
        ),
        VuV2Mcq(
          id: 'sa1',
          prompt: 'Name one study habit that helps long-term memory.',
          choices: <String>[],
          correctIndex: 0,
          explanation: 'Spaced repetition, retrieval practice, or teaching others.',
          kind: VuV2QuestionKind.shortAnswer,
          shortAnswerKey: <String>['spaced', 'retrieval', 'practice', 'teach'],
        ),
      ];
    }
    final List<VuV2Mcq> out = List<VuV2Mcq>.from(base);
    final VuV2Mcq first = base.first;
    out.add(
      VuV2Mcq(
        id: '${first.id}_tf',
        prompt: 'True or False: ${first.prompt}',
        choices: const <String>['True', 'False'],
        correctIndex: 0,
        explanation: first.explanation,
        kind: VuV2QuestionKind.trueFalse,
      ),
    );
    out.add(
      VuV2Mcq(
        id: '${first.id}_sa',
        prompt: 'In one phrase, what is the main idea of: ${first.prompt}',
        choices: const <String>[],
        correctIndex: 0,
        explanation: first.explanation,
        kind: VuV2QuestionKind.shortAnswer,
        shortAnswerKey: first.prompt
            .toLowerCase()
            .split(RegExp(r'[^a-z0-9]+'))
            .where((String w) => w.length > 4)
            .take(3)
            .toList(),
      ),
    );
    return out;
  }
}
