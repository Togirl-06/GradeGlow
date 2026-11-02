import 'package:ai_study_buddy/data/lecture_visual_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skull lights at the spoken word and holds until the next structure', () {
    const String speech =
        'Let us start at the top of the body. This is the skull. The skull protects the brain.';

    expect(
      LectureVisualSync.resolve(
        diagramId: 'skeleton',
        speech: speech,
        progress: 0.02,
      ).isActive,
      isFalse,
    );

    final skull = LectureVisualSync.resolve(
      diagramId: 'skeleton',
      speech: speech,
      progress: 0.62,
    );
    expect(skull.regionIds, contains('skull'));
    expect(skull.label, anyOf('SKULL', 'BRAIN'));

    const String next =
        'This is the skull. Now follow the skeleton downward. Directly beneath the skull is the vertebral column.';
    final spine = LectureVisualSync.resolve(
      diagramId: 'skeleton',
      speech: next,
      progress: 0.92,
    );
    expect(spine.regionIds, contains('spine'));
    expect(spine.regionIds.contains('skull'), isFalse);
  });

  test('axial skeleton lights the axis as a group', () {
    final cue = LectureVisualSync.resolve(
      diagramId: 'skeleton',
      speech:
          'The human skeleton is divided into two major divisions: the axial skeleton and the appendicular skeleton.',
      progress: 0.62,
    );
    expect(cue.regionIds, containsAll(<String>['skull', 'spine', 'ribs']));
  });

  test('mitochondria illuminate in the animal cell', () {
    final cue = LectureVisualSync.resolve(
      diagramId: 'animal_cell',
      speech:
          'The mitochondria are responsible for producing most of the cell ATP.',
      progress: 0.35,
    );
    expect(cue.regionIds, contains('mitochondria'));
  });

  test('gravity lights the weight arrow on a force diagram', () {
    final cue = LectureVisualSync.resolve(
      diagramId: 'force',
      speech: 'The force of gravity pulls the ball toward the Earth.',
      progress: 0.4,
    );
    expect(cue.regionIds, contains('weight'));
  });

  test('identify tap does not leak the answer from speech', () {
    final cue = LectureVisualSync.resolve(
      diagramId: 'skeleton',
      speech: 'Now locate the scapula yourself. Tap the shoulder blade.',
      progress: 0.7,
      teachingMode: 'identifyTap',
    );
    expect(cue.isActive, isFalse);
  });

  test('right ventricle then pulmonary artery for heart flow', () {
    const String speech =
        'The blood leaves the right ventricle through the pulmonary artery.';
    final early = LectureVisualSync.resolve(
      diagramId: 'heart_detail',
      speech: speech,
      progress: 0.45,
    );
    expect(early.regionIds, contains('right_ventricle'));

    final later = LectureVisualSync.resolve(
      diagramId: 'heart_detail',
      speech: speech,
      progress: 0.95,
    );
    expect(later.regionIds, contains('pulmonary_artery'));
  });
}
