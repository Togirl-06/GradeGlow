import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryCareerRepository repo;
  int clock = 1000;
  CareerSimStore newStore() => CareerSimStore(repository: repo, clock: () => clock += 10);

  setUp(() => repo = MemoryCareerRepository());

  test('state is saved on every change and restored by a new session', () async {
    final CareerSimStore a = newStore();
    await a.ensureLoaded(userId: 'u1', majorId: 'nursing');
    expect(a.profile.deptId, 'nursing');
    final TrainingModule m = CareerCatalog.module('nu_m2')!;
    await a.markLessonStudied(m);
    final NumericTaskSpec dosage = m.practice.whereType<NumericTaskSpec>().first;
    await a.recordTask(CareerSimStore.moduleTaskKey(m, dosage), dosage,
        TaskGrader.grade(dosage, const NumericAnswer(<double?>[3, 330, 125])));
    expect(a.profile.skillPoints['nu_meds'], 1);

    final CareerSimStore b = newStore();
    await b.ensureLoaded(userId: 'u1');
    expect(b.profile.toJson(), a.profile.toJson());
    expect(repo.remote.containsKey('u1'), isTrue);
  });

  test('the newer of device and cloud copies wins', () async {
    final CareerSimStore a = newStore();
    await a.ensureLoaded(userId: 'u2', majorId: 'law');
    await a.chooseDepartment('law');
    final CareerProfile newer = CareerProfile.fromJson(a.profile.toJson())
      ..day = 42
      ..updatedAtMs = clock + 100000;
    await repo.saveRemote('u2', newer.toJson());
    final CareerSimStore b = newStore();
    await b.ensureLoaded(userId: 'u2');
    expect(b.profile.day, 42);
  });

  test('a cloud failure keeps the device copy and reports it', () async {
    final CareerSimStore a = newStore();
    await a.ensureLoaded(userId: 'u3', majorId: 'law');
    repo.failRemote = true;
    await a.chooseDepartment('cs');
    expect(a.syncWarning, isNotNull);
    final CareerSimStore b = newStore();
    await b.ensureLoaded(userId: 'u3');
    expect(b.profile.deptId, 'cs');
  });

  test('skill points are awarded once per task, best score kept', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'computer_science');
    final TrainingModule m = CareerCatalog.module('cs_m1')!;
    final ClassifyTaskSpec c = m.practice.whereType<ClassifyTaskSpec>().first;
    final String key = CareerSimStore.moduleTaskKey(m, c);
    final TaskResult right = TaskGrader.grade(c, ClassifyAnswer(c.items.map((ClassifyItem i) => i.category).toList()));
    await s.recordTask(key, c, right);
    await s.recordTask(key, c, right);
    expect(s.profile.skillPoints['cs_algo'], 1);
    final TaskResult worse = TaskGrader.grade(c, ClassifyAnswer(c.items.map((ClassifyItem i) => c.categories.first).toList()));
    await s.recordTask(key, c, worse);
    expect(s.profile.taskResults[key]!.score, 100);
  });

  test('rule violations are refused with a message and change nothing', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'computer_science');
    final Department cs = s.department!;
    final ProjectSpec p = cs.projects.first;
    await expectLater(s.publishProject(cs, p), throwsA(isA<CareerActionException>()));
    await expectLater(s.requestTraineeStatus(), completion(isNotEmpty));
    expect(s.profile.stage, CareerStage.student);
    final JobApplication a = await s.startApplication('cs_intern_northwind');
    await expectLater(s.startApplication('cs_intern_northwind'), throwsA(isA<CareerActionException>()));
    await expectLater(s.submitApplication(a.id), throwsA(isA<CareerActionException>()));
    expect(s.profile.application(a.id)!.status, ApplicationStatus.draft);
    await expectLater(s.acceptOffer(a.id), throwsA(isA<CareerActionException>()));
    await expectLater(s.requestAssignment(), throwsA(isA<CareerActionException>()));
    await expectLater(s.saveResume(const Resume(fullName: 'A', email: 'not-an-email')), throwsA(isA<CareerActionException>()));
  });

  test('an under-qualified applicant is rejected at screening with reasons, not hired', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'computer_science');
    await s.saveResume(const Resume(fullName: 'Sam Lee', email: 'sam@example.com'));
    final JobApplication a = await s.startApplication('cs_intern_northwind');
    await s.saveDraft(a.id, coverLetter: List<String>.filled(90, 'word').join(' '), portfolioIds: const <String>[]);
    await s.submitApplication(a.id);
    await s.advanceDay();
    expect(s.profile.application(a.id)!.status, ApplicationStatus.underReview);
    await s.advanceDay();
    final JobApplication after = s.profile.application(a.id)!;
    expect(after.status, ApplicationStatus.rejected);
    expect(after.screening!.gaps, isNotEmpty);
    expect(s.profile.currentJob, isNull);
  });

  test('internship completion with good performance yields a return offer the student must accept', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'computer_science');
    final JobPosting j = CareerCatalog.posting('cs_intern_northwind')!;
    s.profile.employment.add(Employment(
      id: 'e1', postingId: j.id, deptId: 'cs', workplaceId: 'cs_northwind', employer: j.company.name,
      title: 'Software Engineering Intern', stage: CareerStage.intern, salary: 4000, salaryPeriod: 'month', startDay: 1,
    ));
    s.profile.stage = CareerStage.intern;
    const TaskResult pass = TaskResult(taskId: 't', score: 100, passed: true);
    for (int i = 0; i < 3; i++) {
      await s.requestAssignment();
      await s.submitAssignment(pass, 'I implemented the change, verified it with tests, and the next step is to monitor it in production.');
    }
    await expectLater(s.requestAssignment(), throwsA(isA<CareerActionException>()));
    await s.completeInternship();
    expect(s.profile.currentJob, isNull);
    final JobApplication offer = s.profile.applications.last;
    expect(offer.status, ApplicationStatus.offerReceived);
    expect(s.profile.stage, CareerStage.intern);
    await s.acceptOffer(offer.id);
    expect(s.profile.stage, CareerStage.entryLevel);
    expect(s.profile.currentJob!.title, 'Associate Software Engineer');
  });
}
