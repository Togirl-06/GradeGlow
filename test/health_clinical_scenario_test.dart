import 'package:ai_study_buddy/vu_v2/health_career/health_career_content.dart';
import 'package:ai_study_buddy/vu_v2/health_career/models/clinical_scenario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('eight health programs are registered', () {
    expect(HealthPrograms.all.length, 8);
    expect(HealthPrograms.isHealthId('nursing'), isTrue);
    expect(HealthPrograms.normalizeId('pharmacy'), 'pharmacy_fundamentals');
  });

  test('safe dyspnea case scores pass without critical errors', () {
    final ClinicalScenario s = ClinicalScenarioCatalog.dyspneaWard;
    final ClinicalEvaluation e = ClinicalScenarioEngine.evaluate(
      scenario: s,
      measured: ClinicalInstrument.values.toSet(),
      flaggedAbnormal: s.expectedAbnormals.toSet(),
      chosenActionIds: s.correctActionIds.toSet(),
      askedKeys: s.interviewKeys.toSet(),
    );
    expect(e.criticalFail, isFalse);
    expect(e.passed, isTrue);
    expect(e.score, greaterThanOrEqualTo(60));
  });

  test('penicillin action is a critical fail', () {
    final ClinicalScenario s = ClinicalScenarioCatalog.dyspneaWard;
    final ClinicalEvaluation e = ClinicalScenarioEngine.evaluate(
      scenario: s,
      measured: ClinicalInstrument.values.toSet(),
      flaggedAbnormal: s.expectedAbnormals.toSet(),
      chosenActionIds: <String>{'give_penicillin'},
      askedKeys: s.interviewKeys.toSet(),
    );
    expect(e.criticalFail, isTrue);
    expect(e.passed, isFalse);
  });
}
