import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/vu_v2/data/vu_v2_lesson_flow.dart';
import 'package:ai_study_buddy/vu_v2/labs/university_lab_result.dart';

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

  test('lab report grades reasoning from the simulation result', () {
    const UniversityLabResult result = UniversityLabResult(
      accuracy: 0.87,
      identifyCorrect: 4,
      identifyAttempts: 5,
      viewsVisited: 3,
      labelDrillComplete: true,
      coachingNotes: <String>['You used the lecture concept under pressure.'],
      xpEarned: 120,
      clinicalSolved: true,
      clinicalReasoningScore: 0.91,
      hintsUsed: 1,
      recommendedReview: 'Price elasticity',
    );
    expect(result.resultStatus, 'Successful');
    expect(result.reasoningGrade, 'Excellent');
    expect(result.decisionQuality, 'Excellent');
    expect(result.conceptMasteryPercent, 87);
    expect(result.hintsUsed, 1);
    expect(result.recommendedReview, 'Price elasticity');
  });
}
