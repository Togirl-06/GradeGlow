// The virtual hospital: patients change with time and with the student's
// decisions, unsafe actions are stopped and explained, and scoring follows
// each case's clinical rubric.
import 'package:ai_study_buddy/career_sim/hospital/hospital_cases.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_models.dart';
import 'package:ai_study_buddy/career_sim/hospital/ui/hospital_painters.dart';
import 'package:ai_study_buddy/career_sim/hospital/ui/hospital_screens.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'hospital_solver.dart';
import 'labs_flow_test.dart' show FakeLabRunner, k;

PatientCase cs(String id) => hospitalCase(id)!;

void main() {
  test('every department has patients and every case is internally consistent', () {
    for (final HospitalDept d in HospitalDept.values) {
      if (d == HospitalDept.triage) continue;
      expect(hospitalCases.any((PatientCase c) => c.dept == d), isTrue, reason: d.label);
    }
    for (final PatientCase c in hospitalCases) {
      expect(c.diagnosis.where((ChoiceOption o) => o.correct).length, 1, reason: c.id);
      expect(c.nursingPriority.where((ChoiceOption o) => o.correct).length, 1, reason: c.id);
      expect(c.requirements.any((Requirement r) => r.critical), isTrue, reason: '${c.id} should have a safety-critical step');
      for (final Requirement r in c.requirements) {
        if (r.flag.startsWith('do:')) {
          final String id = r.flag.substring(3);
          expect(<String>{...generalActions.map((ActionDef a) => a.id), ...c.actions.map((ActionDef a) => a.id)}, contains(id), reason: '${c.id}: ${r.flag}');
        }
      }
    }
  });

  for (final PatientCase c in hospitalCases) {
    for (final ClinicalRole role in c.roles) {
      test('${c.id} (${role.name}): a careful clinician passes; doing nothing fails', () async {
        final PatientSim good = await solvedLocally(c, role);
        final CaseScore sc = good.score();
        expect(sc.critical, isFalse, reason: '${sc.missed} ${sc.late} ${sc.safety.map((SafetyEvent e) => e.explanation)}');
        expect(sc.passed, isTrue, reason: '${sc.overall} ${sc.categories}');
        expect(sc.outcome, c.goodOutcome);

        final PatientSim idle = PatientSim(c, role)
          ..apply(const SimAction('wait', '60'))
          ..apply(const SimAction('document', '', 'Saw the patient.'));
        final CaseScore bad = idle.score();
        expect(bad.passed, isFalse);
        expect(bad.critical, isTrue, reason: 'missing a safety-critical step is never hidden by the total');
        expect(bad.outcome, c.badOutcome);
      });
    }
  }

  test('a patient deteriorates by rule when the key action is late, and the monitor shows it', () {
    final PatientSim s = PatientSim(cs('ed_chest_pain'), ClinicalRole.medicine)
      ..apply(const SimAction('measure', 'monitor'))
      ..apply(const SimAction('wait', '35'));
    expect(s.fired, containsAll(<String>['worse', 'shock']));
    expect(s.v.sbp, lessThan(cs('ed_chest_pain').vitals.sbp - 30));
    expect(s.v.avpu, 'V');
    expect(s.log.where((LogLine l) => l.warning).map((LogLine l) => l.text).join(' '), contains('cardiogenic shock'));
    expect(s.news(), greaterThanOrEqualTo(5));
    // With the ECG and escalation in time, the same rules never fire.
    final PatientSim ok = PatientSim(cs('ed_chest_pain'), ClinicalRole.medicine)
      ..apply(const SimAction('measure', 'ecg'))
      ..apply(const SimAction('escalate', 'Attending physician', goodSbar))
      ..apply(const SimAction('wait', '35'));
    expect(ok.fired, isEmpty);
  });

  test('unsafe actions are stopped and explained; medicines need allergy and ID checks', () {
    final PatientSim s = PatientSim(cs('ed_chest_pain'), ClinicalRole.nursing)..apply(const SimAction('intervene', 'walk'));
    expect(s.safety.single.critical, isTrue);
    expect(s.has('do:walk'), isFalse);
    s.apply(const SimAction('intervene', 'aspirin'));
    expect(s.has('do:aspirin'), isFalse, reason: 'refused until allergies and identity are checked');
    expect(s.safety.last.explanation, contains('check allergies'));
    s
      ..apply(const SimAction('chart', 'allergies'))
      ..apply(const SimAction('exam', 'wristband'))
      ..apply(const SimAction('intervene', 'aspirin'));
    expect(s.has('do:aspirin'), isTrue);
    // A nurse cannot order troponin or activate the cath lab: scope, not given.
    s
      ..apply(const SimAction('order', 'troponin'))
      ..apply(const SimAction('intervene', 'cath'));
    expect(s.orders.containsKey('troponin'), isFalse);
    expect(s.has('do:cath'), isFalse);
    expect(s.safety.where((SafetyEvent e) => !e.critical).length, 2);

    final PatientSim sepsis = PatientSim(cs('icu_sepsis'), ClinicalRole.nursing)..apply(const SimAction('intervene', 'pip_taz'));
    expect(sepsis.safety.single.explanation, contains('penicillin allergy'));
  });

  test('the patient answers from the case history only when asked, and consistently', () {
    final PatientSim s = PatientSim(cs('ed_chest_pain'), ClinicalRole.medicine);
    expect(s.patientLine, contains('30 minutes'));
    expect(s.patientLine.toLowerCase(), isNot(contains('arm')), reason: 'radiation is not volunteered');
    s.apply(const SimAction('ask', '', 'Does the pain spread anywhere?'));
    expect(s.patientLine, contains('left arm'));
    s.apply(const SimAction('ask', '', 'Does it go anywhere else, like your jaw?'));
    expect(s.patientLine, contains('left arm and my jaw'));
    s.apply(const SimAction('ask', '', 'What colour is your car?'));
    expect(s.patientLine, contains('not sure what you mean'));
    s.apply(const SimAction('ask', '', 'Hi, my name is Sam — can you confirm your full name and date of birth?'));
    expect(s.has('ask:intro'), isTrue);
    expect(s.has('identity'), isTrue);
  });

  test('a saved action log replays to exactly the same patient', () async {
    final PatientSim s = await solvedLocally(cs('icu_sepsis'), ClinicalRole.medicine);
    final PatientSim r = PatientSim.replay(cs('icu_sepsis'), ClinicalRole.medicine, s.actions);
    expect(r.minute, s.minute);
    expect(r.v.toJson(), s.v.toJson());
    expect(r.flags, s.flags);
    expect(r.score().overall, s.score().overall);
  });

  test('ward shift: time with one patient passes for all; a neglected patient deteriorates; a prioritised shift passes', () async {
    final Map<String, PatientCase> cases = <String, PatientCase>{for (final String id in wardShift.caseIds) id: cs(id)};
    final ShiftSim neglect = ShiftSim(wardShift, cases, ClinicalRole.nursing)
      ..apply('ward_postop', const SimAction('wait', '20'));
    expect(neglect.sims['ward_diabetes']!.minute, 20);
    expect(neglect.sims['ward_diabetes']!.fired, contains('neuro'), reason: 'her glucose kept falling while you were elsewhere');

    final ShiftSim s = ShiftSim(wardShift, cases, ClinicalRole.nursing);
    await solveShift(() => s, (String id, SimAction a) async => s.apply(id, a));
    s.apply('ward_postop', const SimAction('handover', '', goodHandover));
    final (int overall, bool passed, Map<String, CaseScore> each, int hand) = s.score();
    expect(each.values.every((CaseScore x) => !x.critical), isTrue, reason: each.map((String k, CaseScore v) => MapEntry<String, String>(k, '${v.missed} ${v.late}')).toString());
    expect(hand, greaterThanOrEqualTo(80));
    expect(passed, isTrue, reason: '$overall');
  });

  test('triage: exact levels score full marks; under-triaging the unresponsive patient is critical', () {
    final (int full, bool c1, _) = scoreTriage(<String, int>{for (final TriageArrival a in triageArrivals) a.id: a.priority});
    expect(full, 100);
    expect(c1, isFalse);
    final (int _, bool c2, List<String> notes) = scoreTriage(<String, int>{for (final TriageArrival a in triageArrivals) a.id: a.id == 't_od' ? 3 : a.priority});
    expect(c2, isTrue);
    expect(notes.single, contains('under-triaged'));
  });

  test('hospital progress is saved after every action and survives a restart', () async {
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final CareerSimStore s = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await s.ensureLoaded(userId: 'n1', majorId: 'nursing');
    await s.startHospitalCase('ward_diabetes');
    await s.hospitalAct('ward_diabetes', const SimAction('measure', 'glucose'));
    final CareerSimStore again = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await again.ensureLoaded(userId: 'n1', majorId: 'nursing');
    final PatientSim r = again.hospitalSim('ward_diabetes')!;
    expect(r.has('measure:glucose'), isTrue);
    expect(r.minute, s.hospitalSim('ward_diabetes')!.minute);
    await solveCase(() => again.hospitalSim('ward_diabetes')!, (SimAction a) => again.hospitalAct('ward_diabetes', a));
    final HospitalResult res = await again.finishHospitalCase('ward_diabetes');
    expect(res.passed, isTrue, reason: '${res.score} ${res.notes}');
    expect(again.profile.hospitalPassed('ward_diabetes'), isTrue);
  });

  testWidgets('walk into a room, use equipment, get stopped for an unsafe action, document and debrief', (WidgetTester t) async {
    HospitalUi.animate = false;
    addTearDown(() => HospitalUi.animate = true);
    t.view.physicalSize = const Size(1200, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await s.ensureLoaded(majorId: 'nursing');
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: const MaterialApp(home: HospitalScreen())));
    await t.pumpAndSettle();
    expect(k('hospital_disclaimer'), findsOneWidget);
    await t.tap(k('dept_emergency'));
    await t.pumpAndSettle();
    await t.tap(k('patient_ed_chest_pain'));
    await t.pumpAndSettle();
    expect(k('bedside_monitor'), findsOneWidget);
    expect(find.textContaining('Monitor not attached'), findsNothing, reason: 'painted text is not a widget');
    expect(find.textContaining('30 minutes'), findsOneWidget);
    await t.tap(k('topic_radiation'));
    await t.pumpAndSettle();
    expect(find.textContaining('left arm'), findsWidgets);
    await t.tap(k('tab_equip'));
    await t.pumpAndSettle();
    await t.tap(k('equip_monitor'));
    await t.pumpAndSettle();
    await t.tap(k('equip_ecg'));
    await t.pumpAndSettle();
    expect(s.hospitalSim('ed_chest_pain')!.has('measure:ecg'), isTrue);
    await t.tap(k('tab_treat'));
    await t.pumpAndSettle();
    await t.tap(k('do_walk'));
    await t.pumpAndSettle();
    expect(k('safety_dialog'), findsOneWidget);
    expect(find.textContaining('bed rest'), findsWidgets);
    await t.tap(k('safety_ok'));
    await t.pumpAndSettle();
    await t.tap(k('tab_document'));
    await t.pumpAndSettle();
    await t.tap(k('dx_perfusion'));
    await t.pumpAndSettle();
    await t.enterText(k('notes_field'), goodNote);
    await t.tap(k('notes_save'));
    await t.pumpAndSettle();
    await t.tap(k('case_finish'));
    await t.pumpAndSettle();
    expect(k('critical_banner'), findsOneWidget);
    expect(k('debrief_outcome'), findsOneWidget);
    expect(s.profile.hospitalResults.single.critical, isTrue);
    expect(t.takeException(), isNull);
  });
}
