import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/vu_v2/data/vu_v2_lesson_flow.dart';

void main() {
  test('mastery requires professor, lab, and knowledge check', () {
    expect(
      VuV2LessonFlowPlan.masterySteps(requiresLab: true),
      <VuV2LessonStep>[
        VuV2LessonStep.aiProfessor,
        VuV2LessonStep.realWorldLab,
        VuV2LessonStep.knowledgeCheck,
      ],
    );
    expect(
      VuV2LessonFlowPlan.masterySteps(requiresLab: false),
      <VuV2LessonStep>[
        VuV2LessonStep.aiProfessor,
        VuV2LessonStep.knowledgeCheck,
      ],
    );
    expect(
      VuV2LessonFlowPlan.label(VuV2LessonStep.aiProfessor),
      'AI Professor',
    );
    expect(
      VuV2LessonFlowPlan.label(VuV2LessonStep.realWorldLab),
      'Professional lab',
    );
  });
}
