// Numeric lab reports agree with each case's written result and are shown in
// the patient record with ranges and flags.
import 'package:ai_study_buddy/career_sim/hospital/hospital_cases.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_models.dart';
import 'package:ai_study_buddy/career_sim/hospital/lab_panels.dart';
import 'package:ai_study_buddy/career_sim/hospital/ui/hospital_screens.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'labs_flow_test.dart' show FakeLabRunner, k;

/// Plain numbers in a written result, ignoring units such as ×10⁹/L.
List<double> numbersIn(String text) => RegExp(r'\d+(?:\.\d+)?')
    .allMatches(text.replaceAll(RegExp(r'×\s*10⁹'), ''))
    .map((Match m) => double.parse(m[0]!))
    .toList();

void main() {
  test('every adult blood test has a numeric report', () {
    int panels = 0;
    for (final PatientCase c in hospitalCases) {
      for (final String id in c.tests.keys) {
        final List<LabRow>? rows = labPanel(c, id);
        if (labPanelAnalytes.containsKey(id) && c.age >= 16) {
          expect(rows, isNotNull, reason: '${c.id}/$id');
          panels++;
        } else {
          expect(rows, isNull, reason: '${c.id}/$id');
        }
      }
    }
    expect(panels, greaterThanOrEqualTo(25));
  });

  test('a report is flagged exactly when the case marks the result abnormal', () {
    for (final PatientCase c in hospitalCases) {
      for (final MapEntry<String, TestResult> t in c.tests.entries) {
        final List<LabRow>? rows = labPanel(c, t.key);
        if (rows == null) continue;
        final List<String> flagged = <String>[for (final LabRow r in rows) if (r.abnormal) '${r.name} ${r.shown} ${r.flag}'];
        expect(flagged.isNotEmpty, t.value.abnormal, reason: '${c.id}/${t.key}: "${t.value.result}" vs $flagged');
      }
    }
  });

  test('every number in a written result appears in its report', () {
    for (final PatientCase c in hospitalCases) {
      for (final MapEntry<String, TestResult> t in c.tests.entries) {
        final List<LabRow>? rows = labPanel(c, t.key);
        if (rows == null) continue;
        for (final double n in numbersIn(t.value.result)) {
          expect(rows.any((LabRow r) => (r.value - n).abs() < 0.001), isTrue, reason: '${c.id}/${t.key}: $n from "${t.value.result}"');
        }
      }
    }
  });

  test('named findings move the right analyte in the right direction', () {
    String flag(String caseId, String test, String analyte) =>
        labPanel(hospitalCase(caseId)!, test)!.firstWhere((LabRow r) => r.id == analyte).flag;
    expect(flag('ed_chest_pain', 'troponin', 'tni'), 'H');
    expect(flag('icu_sepsis', 'lactate', 'lac'), 'H');
    expect(flag('icu_sepsis', 'cbc', 'wbc'), 'H');
    expect(flag('icu_sepsis', 'bmp', 'cr'), 'H');
    expect(flag('icu_sepsis', 'abg', 'ph'), 'L');
    expect(flag('icu_sepsis', 'abg', 'pao2'), 'L');
    expect(flag('ed_asthma', 'abg', 'paco2'), 'L');
    expect(flag('ed_asthma', 'abg', 'pao2'), 'L');
    expect(flag('maternity_pph', 'cbc', 'hgb'), 'L');
    expect(flag('medsurg_delirium', 'bmp', 'na'), 'L');
    expect(flag('medsurg_delirium', 'bmp', 'bun'), 'H');
    expect(flag('onc_neutropenic', 'cbc', 'neut'), 'L');
    expect(flag('lab_potassium', 'bmp', 'k'), 'H');
    expect(flag('radiology_contrast', 'bmp', 'egfr'), 'L');
    expect(flag('cardio_af', 'bmp', 'k'), '');
    expect(flag('cardio_af', 'bmp', 'mg'), '');
  });

  test('eGFR follows creatinine, age and sex (CKD-EPI 2021)', () {
    expect(ckdEpi2021(2.47, 66, 'M').round(), 28);
    expect(ckdEpi2021(0.8, 79, 'F').round(), 75);
    expect(ckdEpi2021(0.9, 58, 'M').round(), 99);
    final LabRow egfr = labPanel(hospitalCase('radiology_contrast')!, 'bmp')!.firstWhere((LabRow r) => r.id == 'egfr');
    expect(egfr.shown, '28');
    expect(egfr.range, '≥ 60');
  });

  test('female ranges are used for women', () {
    final LabRow hgb = labPanel(hospitalCase('maternity_pph')!, 'cbc')!.firstWhere((LabRow r) => r.id == 'hgb');
    expect(hgb.range, '12.0–15.5');
    expect(hgb.shown, '8.9');
  });

  testWidgets('the patient record shows the numeric report once results are back', (WidgetTester t) async {
    t.view.physicalSize = const Size(1300, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await s.ensureLoaded(majorId: 'medicine');
    await s.startHospitalCase('icu_sepsis');
    for (final SimAction a in const <SimAction>[SimAction('order', 'cbc'), SimAction('order', 'lactate'), SimAction('wait', '30')]) {
      await s.hospitalAct('icu_sepsis', a);
    }
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: const MaterialApp(home: PatientRecordsScreen(caseId: 'icu_sepsis'))));
    await t.pumpAndSettle();
    expect(k('panel_cbc'), findsOneWidget);
    expect(k('panel_lactate'), findsOneWidget);
    expect(t.widget<Text>(k('rec_cbc_wbc')).data, '18.0');
    expect(t.widget<Text>(k('rec_lactate_lac')).data, '4.2');
    expect(find.text('H ↑'), findsWidgets);
    expect(find.text('4.5–11.0'), findsOneWidget);
  });
}
