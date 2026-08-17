import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/config/vu_schools_catalog.dart';
import 'package:ai_study_buddy/data/university_learning_engine.dart';
import 'package:ai_study_buddy/vu_v2/data/vu_v2_lesson_flow.dart';
import 'package:ai_study_buddy/vu_v2/labs/career_practice_labs.dart';
import 'package:ai_study_buddy/vu_v2/labs/course_labs_catalog.dart';
import 'package:ai_study_buddy/vu_v2/labs/engine/lab_blueprint.dart';
import 'package:ai_study_buddy/vu_v2/labs/investigation/investigation_models.dart';

void main() {
  const List<String> programs = <String>[
    'resume_writing',
    'interview_preparation',
    'public_speaking',
    'personal_finance',
    'leadership',
    'communication_skills',
    'freelancing',
    'project_management',
    'time_management',
    'remote_work_skills',
  ];

  test('School of Career and Life Skills is practice-only', () {
    final VuSchool? school = VuSchoolsCatalog.schoolForProgramId('resume_writing');
    expect(school?.id, 'career_life_skills');
    expect(school?.practiceOnly, isTrue);
    expect(VuSchoolsCatalog.isPracticeOnly('resume_writing'), isTrue);
    expect(VuSchoolsCatalog.isPracticeOnly('biology'), isFalse);
    for (final String id in programs) {
      expect(VuSchoolsCatalog.isPracticeOnly(id), isTrue, reason: id);
    }
  });

  test('practice-only mastery is lab + workplace, never lecture', () {
    expect(
      VuV2LessonFlowPlan.masterySteps(
        requiresLab: true,
        subjectId: 'resume_writing',
      ),
      <VuV2LessonStep>[
        VuV2LessonStep.realWorldLab,
        VuV2LessonStep.interactivePractice,
      ],
    );
    expect(
      VuV2LessonFlowPlan.forLesson(
        subjectId: 'interview_preparation',
        topicTitle: 'STAR Stories',
      ),
      isNot(contains(VuV2LessonStep.aiProfessor)),
    );
    expect(
      VuV2LessonFlowPlan.forLesson(
        subjectId: 'public_speaking',
        topicTitle: 'Opening',
      ),
      isNot(contains(VuV2LessonStep.coreNotes)),
    );
    expect(
      VuV2LessonFlowPlan.forLesson(
        subjectId: 'biology',
        topicTitle: 'Cells',
      ),
      contains(VuV2LessonStep.aiProfessor),
    );
  });

  test('each career program has a workplace lab, not a biology fallback', () {
    for (final String id in programs) {
      final UniversityLabLink? link = UniversityLearningEngine.labForLesson(
        subjectId: id,
        lessonTitle: 'Live mission',
      );
      expect(link, isNotNull, reason: id);
      expect(link!.title.toLowerCase(), isNot(contains('cell')));
      expect(link.prerequisite, isNull);
      expect(CourseLabsCatalog.forMajor(id), isNotEmpty, reason: id);

      final LabBlueprint bp = LabCatalog.forLesson(
        subjectId: id,
        courseTitle: 'Course',
        topicTitle: 'Live mission',
        link: link,
        level: 2,
      );
      expect(bp.discipline, LabDiscipline.careerPractice, reason: id);
      expect(bp.quality.publishable, isTrue, reason: bp.quality.defects.join('; '));

      expect(
        InvestigationCatalog.kindFor(subjectId: id, topicTitle: 'Live mission'),
        isNot(InvestigationKind.biologyCell),
        reason: id,
      );
      expect(CareerPracticeLabs.workplaceWorldId(id), isNotEmpty);
    }
  });
}
