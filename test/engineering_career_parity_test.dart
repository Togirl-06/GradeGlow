import 'package:ai_study_buddy/vu_v2/engineering_career/engineering_career_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each engineering major has at least two missions and three jobs', () {
    for (final EngineeringMajor m in EngineeringMajors.all) {
      expect(
        EngMissionCatalog.forMajor(m.id).length,
        greaterThanOrEqualTo(2),
        reason: 'missions for ${m.id}',
      );
      expect(
        EngJobs.forMajor(m.id).length,
        greaterThanOrEqualTo(3),
        reason: 'jobs for ${m.id}',
      );
    }
  });

  test('flagship Apex mech job exists', () {
    final EngJob? job = EngJobs.byId('apex_mech_junior');
    expect(job, isNotNull);
    expect(job!.company, 'Apex Dynamics');
  });
}
