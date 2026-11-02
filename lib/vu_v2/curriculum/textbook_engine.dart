import '../data/vu_v2_topic_content_models.dart';
import 'academic_quality_contract.dart';
import 'textbook_architecture.dart';
import 'textbook_fields.dart';
import 'textbook_packs.dart';

/// Builds a publishable textbook chapter. Thin summaries never leave this engine.
abstract final class UniversityTextbookEngine {
  static List<VuV2TextbookSection> build({
    required String subjectId,
    required String facultyTitle,
    required String trackTitle,
    required String courseTitle,
    required String topic,
    String? subtitle,
  }) {
    final CourseOutline outline = TextbookArchitecture.outlineFor(
      subjectId: subjectId,
      courseTitle: courseTitle,
      topicTitle: topic,
    );
    final TextbookField field = TextbookField.forTopic(subjectId, topic);
    List<VuV2TextbookSection> sections = field.compose(
      topic: topic.trim(),
      courseTitle: courseTitle,
      facultyTitle: facultyTitle,
      outline: outline,
      subtitle: subtitle,
    );
    TextbookQualityReport report = TextbookQualityContract.inspect(sections);
    int enrich = 0;
    while (!report.publishable && enrich < 4) {
      enrich++;
      sections = <VuV2TextbookSection>[
        ...sections,
        VuV2TextbookSection(
          title: 'Further development $enrich',
          body:
              '${field.expansion(topic, courseTitle, outline)}\n\n'
              '${TextbookPacks.essay(field.kind, topic, courseTitle)}',
        ),
      ];
      report = TextbookQualityContract.inspect(sections);
    }
    if (!report.publishable) {
      throw StateError(
        'Textbook chapter for "$topic" failed the quality contract: ${report.defects.join('; ')}',
      );
    }
    return sections;
  }
}
