import 'package:ai_study_buddy/vu_v2/data/vu_v2_lesson_flow.dart';
import 'package:ai_study_buddy/vu_v2/labs/vu_v2_lab_catalog.dart';

/// Smoke-check: every faculty shares the same gated hub step list.
void main() {
  const faculties = <String>[
    'nursing',
    'computer_science',
    'business',
    'law',
    'engineering',
    'medicine',
    'psychology',
  ];

  List<String>? canonical;
  for (final String id in faculties) {
    final List<VuV2LessonStep> steps = VuV2LessonFlowPlan.forLesson(
      subjectId: id,
      topicTitle: 'Sample topic',
    );
    final List<String> labels =
        steps.map(VuV2LessonFlowPlan.label).toList(growable: false);
    canonical ??= labels;
    if (labels.join('|') != canonical.join('|')) {
      throw StateError('Step mismatch for $id: $labels vs $canonical');
    }
    final exp = VuV2LabCatalog.resolveForTopic(id, 'Sample topic');
    if (exp == null) {
      throw StateError('No lab for $id');
    }
  }

  // ignore: avoid_print
  print('OK · shared steps: ${canonical!.join(' → ')}');
  // ignore: avoid_print
  print('OK · lab resolve works for ${faculties.length} faculties');
}
