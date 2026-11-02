import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/education/university.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every career has a degree; degree ids match the career catalog', () {
    for (final CareerDef c in CareerCatalog.all) {
      final Degree? d = UniversityCatalog.degreeForCareer(c.id);
      expect(d, isNotNull, reason: c.id);
      expect(c.degreeId, d!.id);
      expect(d.awardRank >= c.minEducationRank, true, reason: c.id);
    }
  });

  test('exam questions are well-formed', () {
    for (final Degree d in UniversityCatalog.degrees) {
      for (final Course c in d.courses) {
        expect(c.questions.length >= 4, true, reason: c.id);
        for (final ExamQuestion q in c.questions) {
          expect(q.correct >= 0 && q.correct < q.options.length, true, reason: c.id);
          expect(q.options.toSet().length, q.options.length, reason: '${c.id} ${q.prompt}');
        }
      }
    }
  });

  test('full degree flow: enrol, lectures, study, exam, graduate', () {
    final UniversityRecord r = UniversityRecord();
    final Degree d = UniversityCatalog.degreeById('deg_cs')!;
    expect(UniversityEngine.canEnrolDegree(r, d, 0), isNull);
    r.activeDegreeId = d.id;
    Degree? done;
    int day = 1;
    for (final Course c in d.courses) {
      expect(UniversityEngine.enrolInCourse(r, d, c), isNull);
      expect(r.progress(c.id).examReady, false);
      while (r.progress(c.id).lectures < 4) {
        while (!UniversityEngine.lectureOpen(day, 10 * 60)) {
          day++;
        }
        expect(UniversityEngine.attendLecture(r, c, day, 10 * 60), isNull);
        day++;
      }
      for (int i = 0; i < 4; i++) {
        UniversityEngine.study(r, c);
      }
      expect(r.progress(c.id).examReady, true);
      final List<ExamQuestion> q = UniversityEngine.examFor(c, 0);
      final ExamResult res = UniversityEngine.grade(c, q, q.map((ExamQuestion e) => e.correct).toList());
      expect(res.passed, true);
      done = UniversityEngine.recordExam(r, d, c, res).completed;
    }
    expect(done?.id, 'deg_cs');
    expect(r.has('deg_cs'), true);
    expect(r.activeDegreeId, isNull);
    expect(UniversityEngine.educationRankOf(r), 2);
    expect(r.associateEarned.contains('deg_cs'), true);
  });

  test('failing an exam costs study time; weekend lectures rejected; json round trip', () {
    final UniversityRecord r = UniversityRecord(activeDegreeId: 'deg_nursing');
    final Degree d = UniversityCatalog.degreeById('deg_nursing')!;
    final Course c = d.courses.first;
    UniversityEngine.enrolInCourse(r, d, c);
    expect(UniversityEngine.attendLecture(r, c, 6, 600), isNotNull);
    UniversityEngine.study(r, c, minutes: 300);
    final List<ExamQuestion> q = UniversityEngine.examFor(c, 0);
    final ExamResult bad = UniversityEngine.grade(c, q, List<int?>.filled(q.length, null));
    expect(bad.passed, false);
    UniversityEngine.recordExam(r, d, c, bad);
    expect(r.progress(c.id).studyMinutes, 180);
    final UniversityRecord r2 = UniversityRecord.fromJson(r.toJson());
    expect(r2.progress(c.id).attempts, 1);
    expect(r2.activeDegreeId, 'deg_nursing');
  });

  test('law needs a bachelor first', () {
    final Degree law = UniversityCatalog.degreeById('deg_law')!;
    expect(UniversityEngine.canEnrolDegree(UniversityRecord(), law, 0), isNotNull);
    expect(UniversityEngine.canEnrolDegree(UniversityRecord(), law, 2), isNull);
  });
}
