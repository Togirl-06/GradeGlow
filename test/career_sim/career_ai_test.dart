// Live AI helps the simulator understand unusual wording and makes replies
// sound natural, but it never decides a fact or a score: the case and the
// published rules still do. With no AI (or a failing one) everything falls
// back to the rules.
import 'package:ai_study_buddy/career_sim/ai/career_ai.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show FakeLabRunner;

class FakeAi implements CareerAi {
  FakeAi({this.topic, this.voiced, this.fail = false});
  final String? topic;
  final String? voiced;
  final bool fail;
  final List<String> classified = <String>[];

  @override
  Future<String> ask({required CareerAiRole role, required String context, required String question}) async => 'ok';

  @override
  Future<String?> classify({required String text, required Map<String, String> options, required String context}) async {
    if (fail) throw StateError('offline');
    classified.add(text);
    return topic != null && options.containsKey(topic) ? topic : null;
  }

  @override
  Future<String?> voice({required String character, required String scripted, required String heard}) async {
    if (fail) throw StateError('offline');
    return safeVoice(voiced, scripted);
  }
}

const String odd = 'Is there anything that disagrees with you, say penicillin or plasters?';

Future<CareerSimStore> nurse(MemoryCareerRepository repo, CareerAi? ai) async {
  final CareerSimStore s = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}), ai: ai);
  await s.ensureLoaded(userId: 'n1', majorId: 'nursing');
  return s;
}

void main() {
  test('pickOption reads only a listed id; "none" means none', () {
    const List<String> ids = <String>['allergies', 'meds', 'history'];
    expect(pickOption('allergies', ids), 'allergies');
    expect(pickOption('The answer is: meds.', ids), 'meds');
    expect(pickOption('none', ids), isNull);
    expect(pickOption('diagnosis', ids), isNull);
    expect(pickOption('medsx', ids), isNull);
  });

  test('safeVoice refuses new numbers, empty or rambling lines', () {
    const String script = 'The pain started about 30 minutes ago.';
    expect(safeVoice('It came on maybe 30 minutes back.', script), 'It came on maybe 30 minutes back.');
    expect(safeVoice('It started 2 hours ago.', script), isNull);
    expect(safeVoice('   ', script), isNull);
    expect(safeVoice('x' * 500, script), isNull);
    expect(safeVoice(null, script), isNull);
  });

  test('the rules do not understand the odd wording on their own', () async {
    final CareerSimStore s = await nurse(MemoryCareerRepository(), null);
    await s.startHospitalCase('ward_diabetes');
    final PatientSim p = await s.hospitalAct('ward_diabetes', const SimAction('ask', '', odd));
    expect(p.has('ask:allergies'), isFalse);
    expect(p.patientLine, "I'm sorry, I'm not sure what you mean.");
  });

  test('AI understands the wording; the case supplies the answer and it survives a restart', () async {
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final FakeAi ai = FakeAi(topic: 'allergies');
    final CareerSimStore s = await nurse(repo, ai);
    await s.startHospitalCase('ward_diabetes');
    final PatientSim p = await s.hospitalAct('ward_diabetes', const SimAction('ask', '', odd));
    expect(ai.classified, <String>[odd]);
    expect(p.has('ask:allergies'), isTrue, reason: 'counts as asking about allergies');
    expect(p.patientLine, p.topicAnswer('allergies'), reason: 'the reply is the case\'s own fact');
    // Replayed later without AI: identical result.
    final CareerSimStore again = await nurse(repo, null);
    final PatientSim r = again.hospitalSim('ward_diabetes')!;
    expect(r.has('ask:allergies'), isTrue);
    expect(r.patientLine, p.patientLine);
  });

  test('AI is not asked when the rules already understand', () async {
    final FakeAi ai = FakeAi(topic: 'history');
    final CareerSimStore s = await nurse(MemoryCareerRepository(), ai);
    await s.startHospitalCase('ward_diabetes');
    final PatientSim p = await s.hospitalAct('ward_diabetes', const SimAction('ask', '', 'Do you have any allergies?'));
    expect(ai.classified, isEmpty);
    expect(p.has('ask:allergies'), isTrue);
  });

  test('a failing AI falls back to the rules', () async {
    final CareerSimStore s = await nurse(MemoryCareerRepository(), FakeAi(fail: true));
    await s.startHospitalCase('ward_diabetes');
    await expectLater(s.hospitalAct('ward_diabetes', const SimAction('ask', '', odd)), completes);
    final PatientSim p = s.hospitalSim('ward_diabetes')!;
    expect(p.has('ask:allergies'), isFalse);
    expect(s.patientSays(p.patientLine), p.patientLine);
  });

  test('the patient speaks in AI wording only when it keeps the facts', () async {
    final CareerSimStore good = await nurse(MemoryCareerRepository(), FakeAi(voiced: 'Oh, none that I know of, love.'));
    await good.startHospitalCase('ward_diabetes');
    final PatientSim p = await good.hospitalAct('ward_diabetes', const SimAction('ask', '', 'Do you have any allergies?'));
    await pumpEventQueue();
    expect(good.patientSays(p.patientLine), 'Oh, none that I know of, love.');

    final CareerSimStore bad = await nurse(MemoryCareerRepository(), FakeAi(voiced: 'I am allergic to 3 things.'));
    await bad.startHospitalCase('ward_diabetes');
    final PatientSim q = await bad.hospitalAct('ward_diabetes', const SimAction('ask', '', 'Do you have any allergies?'));
    await pumpEventQueue();
    expect(bad.patientSays(q.patientLine), q.patientLine, reason: 'a number not in the script is refused');
  });
}
