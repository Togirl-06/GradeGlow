// The app's side of the career server: reports wait in an outbox while
// offline, are sent in order exactly once, survive a restart, and the
// server's verified balance and refusals are shown to the student.
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/server/career_server.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show FakeLabRunner;
import 'market_journey_test.dart' show passLab;

class FlakyServer implements CareerServer {
  bool online = false;
  String? refuse;
  final List<String> ops = <String>[];
  int balance = 0;

  @override
  Future<CareerServerReply> send(String opId, String action, Map<String, dynamic> payload) async {
    if (!online) throw const CareerServerOffline('offline');
    if (action != 'state') ops.add(opId);
    if (refuse != null && action == 'lab') {
      return CareerServerReply(rejected: true, message: refuse!, state: const <String, dynamic>{}, reply: const <String, dynamic>{});
    }
    if (action == 'lab') balance += 1234;
    return CareerServerReply(rejected: false, message: '', state: <String, dynamic>{'balanceCents': balance}, reply: const <String, dynamic>{'ok': true});
  }
}

void main() {
  test('offline reports wait, survive a restart, then send once in order', () async {
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final FlakyServer server = FlakyServer();
    final CareerSimStore s = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}), server: server);
    await s.ensureLoaded(userId: 'u1', majorId: 'mobile_app_development');
    final LabSpec lab = LabCatalog.forDept('cs').first;
    await passLab(s, lab, lab.scenarios.first);
    await pumpEventQueue();
    expect(s.profile.serverOutbox.length, 1, reason: 'kept while offline');
    expect(s.verifiedBalanceCents, isNull);

    // Restart: the queued report is still there.
    final CareerSimStore again = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}), server: server);
    server.online = true;
    await again.ensureLoaded(userId: 'u1', majorId: 'mobile_app_development');
    await pumpEventQueue();
    await again.flushServer();
    expect(again.profile.serverOutbox, isEmpty);
    expect(server.ops.length, 1);
    expect(again.verifiedBalanceCents, 1234);
    await again.flushServer();
    expect(server.ops.length, 1, reason: 'nothing is sent twice');
  });

  test('a refused report is recorded and shown, and not retried', () async {
    final FlakyServer server = FlakyServer()
      ..online = true
      ..refuse = 'Unknown lab scenario.';
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}), server: server);
    await s.ensureLoaded(userId: 'u2', majorId: 'mobile_app_development');
    final LabSpec lab = LabCatalog.forDept('cs').first;
    await passLab(s, lab, lab.scenarios.first);
    await pumpEventQueue();
    await s.flushServer();
    expect(s.profile.serverOutbox, isEmpty);
    expect(s.serverRejections.single['message'], 'Unknown lab scenario.');
  });

  test('signed-out students keep working locally with nothing sent', () async {
    final FlakyServer server = FlakyServer()..online = true;
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}), server: server);
    await s.ensureLoaded(majorId: 'mobile_app_development');
    final LabSpec lab = LabCatalog.forDept('cs').first;
    await passLab(s, lab, lab.scenarios.first);
    await pumpEventQueue();
    expect(server.ops, isEmpty);
    expect(s.profile.balanceCents, greaterThan(0));
  });
}
