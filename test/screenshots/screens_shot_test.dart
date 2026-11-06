// Writes PNG screenshots of the main career and hospital screens.
import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/hospital/ui/hospital_painters.dart';
import 'package:ai_study_buddy/career_sim/hospital/ui/hospital_screens.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/ui/lab_screens.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/career_centre.dart';
import 'package:ai_study_buddy/career_sim/ui/career_dashboard.dart';
import 'package:ai_study_buddy/career_sim/ui/job_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/money_find_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/workplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../career_sim/labs_flow_test.dart' show FakeLabRunner;
import 'shot.dart';

Future<CareerSimStore> employedStore() async {
  final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
  await s.ensureLoaded(majorId: 'mobile_app_development', displayName: 'Alex Morgan');
  final JobPosting j = CareerCatalog.posting('mk_flutter_dev')!;
  s.profile.employment.add(Employment(
    id: 'e1', postingId: j.id, deptId: 'cs', workplaceId: j.workplaceId, employer: j.company.name,
    title: 'Junior Flutter Developer', stage: CareerStage.junior, salary: 62000, salaryPeriod: 'year', startDay: 1, payFrequency: 'monthly',
  ));
  s.profile.stage = CareerStage.junior;
  const String note = 'I implemented the change, verified it with tests and checked the results; next the team should review it and monitor the risk.';
  for (int i = 0; i < 4; i++) {
    await s.requestAssignment();
    await s.submitAssignment(const TaskResult(taskId: 't', score: 96, passed: true), note);
  }
  await s.requestAssignment();
  return s;
}

void main() {
  setUp(() => HospitalUi.animate = false);

  testWidgets('screenshots', (WidgetTester t) async {
    final CareerSimStore fresh = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await fresh.ensureLoaded(majorId: 'computer_science', displayName: 'Jordan Smith');
    await pumpShot(t, fresh, const Scaffold(body: CareerSimDashboard(studentName: 'Jordan Smith', majorLabel: 'Computer Science')));
    await save(t, '01_dashboard');
    await pumpShot(t, fresh, const Scaffold(body: CareerSimDashboard(studentName: 'Jordan Smith', majorLabel: 'Computer Science')), size: const Size(390, 844));
    await save(t, '02_dashboard_phone');
    await pumpShot(t, fresh, const CareerCentreScreen());
    await save(t, '03_career_centre');
    await pumpShot(t, fresh, const JobBoardScreen());
    await save(t, '04_job_board');
    await pumpShot(t, fresh, const PracticalLabsScreen());
    await save(t, '05_labs');

    final LabSpec lab = LabCatalog.lab('cs_lab_fundamentals')!;
    await fresh.startLab(lab);
    await fresh.setLabPhase(lab, LabPhase.work);
    await pumpShot(t, fresh, LabSessionScreen(labId: lab.id));
    await save(t, '06_code_lab');

    final CareerSimStore emp = await employedStore();
    await pumpShot(t, emp, const WorkplaceScreen());
    await save(t, '07_workplace');
    await pumpShot(t, emp, const MoneyScreen());
    await save(t, '08_earnings');

    final CareerSimStore nurse = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await nurse.ensureLoaded(majorId: 'nursing', displayName: 'Sarah Lee');
    await pumpShot(t, nurse, const HospitalScreen());
    await save(t, '09_hospital');
    await nurse.startHospitalCase('ed_chest_pain');
    for (final SimAction a in const <SimAction>[SimAction('intervene', 'hand_hygiene'), SimAction('measure', 'monitor'), SimAction('measure', 'ecg'), SimAction('order', 'cultures')]) {
      await nurse.hospitalAct('ed_chest_pain', a);
    }
    await pumpShot(t, nurse, const PatientRoomScreen(caseId: 'ed_chest_pain'));
    await save(t, '10_patient_room');
    t.view.reset();
  });
}
