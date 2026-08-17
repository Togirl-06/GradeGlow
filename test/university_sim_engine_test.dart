import 'package:ai_study_buddy/data/university_learning_engine.dart';
import 'package:ai_study_buddy/data/virtual_lecture_curriculum_script.dart';
import 'package:ai_study_buddy/models/virtual_lecture.dart';
import 'package:ai_study_buddy/vu_v2/curriculum/academic_quality_contract.dart';
import 'package:ai_study_buddy/vu_v2/data/vu_v2_topic_content.dart';
import 'package:ai_study_buddy/vu_v2/labs/engine/lab_blueprint.dart';
import 'package:ai_study_buddy/vu_v2/labs/investigation/investigation_models.dart';
import 'package:ai_study_buddy/vu_v2/labs/simulation/university_sim_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('membrane transport is a publishable textbook chapter, not a summary', () {
    final pack = VuV2TopicContent.forLesson(
      subjectId: 'biology',
      facultyTitle: 'Biology',
      facultyEmoji: '🧬',
      trackTitle: 'Cell Biology',
      courseTitle: 'Cell Biology',
      topicTitle: 'Membrane Transport',
    );
    final TextbookQualityReport report =
        TextbookQualityContract.inspect(pack.sections);
    expect(report.publishable, isTrue, reason: report.defects.join('; '));
    expect(report.wordCount, greaterThan(2800));
    expect(pack.sections.map((s) => s.title), containsAll(<String>[
      'Learning Objectives',
      '1.1 Introduction',
      'Worked Example',
      'Clinical Connection',
      'Chapter Summary',
      'Case Study',
      'Lecture — full treatment',
      'Precise definitions',
      'Worked example 1 — guided',
      'Practice problems',
    ]));
    final String blob =
        pack.sections.map((s) => s.body).join('\n').toLowerCase();
    expect(blob, contains('sglt'));
    expect(blob, isNot(contains('names the core idea this chapter teaches')));
    expect(blob, isNot(contains('consists of bones. bones provide support')));
  });

  test('skeletal chapter teaches axial vs appendicular instead of a caption', () {
    final pack = VuV2TopicContent.forLesson(
      subjectId: 'biology',
      facultyTitle: 'Biology',
      facultyEmoji: '🧬',
      trackTitle: 'Anatomy',
      courseTitle: 'Anatomy',
      topicTitle: 'The Skeletal System',
    );
    final TextbookQualityReport report =
        TextbookQualityContract.inspect(pack.sections);
    expect(report.publishable, isTrue, reason: report.defects.join('; '));
    final String blob = pack.sections.map((s) => s.body).join('\n');
    expect(blob, contains('appendicular'));
    expect(blob, contains('diaphysis'));
    expect(blob.toLowerCase(), contains('x-ray'));
  });

  test('professor lecture is conversational, not a textbook clip', () {
    final script = VirtualLectureCurriculumScript.build(
      lessonTitle: 'Membrane Transport',
      courseTitle: 'Cell Biology',
      moduleTitle: 'Cell Biology',
      courseId: 'general_biology',
      lessonId: 'membrane',
      mode: LectureMode.concept,
      faculty: 'biology',
    );
    expect(script.segments.first.professorSpeech.toLowerCase(), contains('slow down'));
    expect(
      script.segments.any((s) => s.knowledgeCheck != null || s.beats.any((b) => b.studentChoice != null)),
      isTrue,
    );
    expect(
      script.segments.first.professorSpeech,
      isNot(contains('names the core idea this chapter teaches')),
    );
  });

  test('biology lab is an unknown-cell investigation, not a quiz', () {
    const UniversityLabLink link = UniversityLabLink(
      labId: 'biology',
      stationId: 'practical',
      title: 'Unknown cell investigation',
      purpose: 'Identify the specimen.',
      objectives: <String>['Observe', 'Hypothesize'],
    );
    final InvestigationSpec spec = InvestigationCatalog.forLesson(
      subjectId: 'biology',
      courseTitle: 'General Biology',
      topicTitle: 'Cell Structure',
      link: link,
      level: 2,
    );
    expect(spec.kind, InvestigationKind.biologyCell);
    expect(spec.quality.publishable, isTrue, reason: spec.quality.defects.join('; '));
    expect(spec.equipment, contains('Compound microscope'));
    expect(spec.procedure.join(' ').toLowerCase(), contains('4×'));
    expect(LabQualityContract.allowsQuizLab('click A correctIndex'), isFalse);
  });

  test('domain labs map to investigations with a quality contract', () {
    const UniversityLabLink link = UniversityLabLink(
      labId: 'x',
      stationId: 'bench',
      title: 'Lab',
      purpose: 'Investigate',
      objectives: <String>['Work'],
    );
    expect(
      InvestigationCatalog.kindFor(subjectId: 'chemistry', topicTitle: 'Titration'),
      InvestigationKind.chemistryTitration,
    );
    expect(
      InvestigationCatalog.kindFor(subjectId: 'physics', topicTitle: 'Gravity'),
      InvestigationKind.physicsGravity,
    );
    expect(
      InvestigationCatalog.kindFor(subjectId: 'nursing', topicTitle: 'Chest Pain'),
      InvestigationKind.clinicalEd,
    );
    expect(
      InvestigationCatalog.kindFor(subjectId: 'law', topicTitle: 'Contracts'),
      InvestigationKind.lawTrial,
    );
    expect(
      InvestigationCatalog.kindFor(subjectId: 'business', topicTitle: 'Revenue'),
      InvestigationKind.businessHq,
    );
    for (final InvestigationKind kind in InvestigationKind.values) {
      final InvestigationSpec spec = InvestigationCatalog.spec(
        kind,
        'Course',
        'Topic',
        'Lab',
        2,
      );
      expect(spec.quality.publishable, isTrue, reason: spec.quality.defects.join('; '));
    }
    expect(UniversitySimLevels.fromLessonCount(0), 1);
    expect(UniversitySimLevels.fromLessonCount(8), 4);
    expect(link.title, isNotEmpty);
  });

  test('career programs open a workplace lab, never a biology microscope', () {
    expect(
      LabCatalog.fromSubject('resume_writing'),
      LabDiscipline.careerPractice,
    );
    expect(
      LabCatalog.fromSubject('physics'),
      LabDiscipline.physics,
    );
    expect(
      UniversityLearningEngine.labForLesson(
        subjectId: 'resume_writing',
        lessonTitle: 'Achievement Writing',
      ),
      isNotNull,
    );
    expect(
      UniversityLearningEngine.labForLesson(
        subjectId: 'public_speaking',
        lessonTitle: 'Speech Structure',
      )!
          .labId,
      'career_practice',
    );
  });

  test('lab engine maps every major to a workspace blueprint', () {
    const UniversityLabLink link = UniversityLabLink(
      labId: 'lab',
      stationId: 'bench',
      title: 'Laboratory',
      purpose: 'Perform the work',
      objectives: <String>['Manipulate the academic object'],
    );
    expect(
      LabCatalog.disciplineFor(subjectId: 'biology', topicTitle: 'The Skeletal System'),
      LabDiscipline.anatomy,
    );
    expect(
      LabCatalog.disciplineFor(subjectId: 'biology', topicTitle: 'Cell Structure'),
      LabDiscipline.biology,
    );
    expect(
      LabCatalog.disciplineFor(subjectId: 'mathematics', topicTitle: 'The Derivative'),
      LabDiscipline.mathematics,
    );
    expect(
      LabCatalog.disciplineFor(subjectId: 'physics', topicTitle: 'Projectile Motion'),
      LabDiscipline.physics,
    );
    expect(
      LabCatalog.fromSubject('physics'),
      LabDiscipline.physics,
    );
    expect(
      LabCatalog.fromSubject('computerScience'),
      LabDiscipline.computerScience,
    );
    for (final LabDiscipline d in LabDiscipline.values) {
      final LabBlueprint bp = LabCatalog.forLesson(
        subjectId: d.name,
        courseTitle: 'Course',
        topicTitle: d.name,
        link: link,
        level: 2,
      );
      expect(bp.quality.publishable, isTrue, reason: bp.quality.defects.join('; '));
      expect(bp.tools, isNotEmpty);
      expect(bp.layers, isNotEmpty);
    }
  });
}
