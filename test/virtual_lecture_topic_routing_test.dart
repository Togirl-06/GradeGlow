import 'package:ai_study_buddy/data/virtual_lecture_fallback.dart';
import 'package:ai_study_buddy/data/virtual_lecture_topic_profile.dart';
import 'package:ai_study_buddy/models/virtual_lecture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VirtualLectureTopicProfile', () {
    test('unit circle routes to trigonometry', () {
      final VirtualLectureTopicProfile profile = VirtualLectureTopicProfile.resolve(
        topic: 'Unit Circle',
        course: 'Trigonometry',
        courseId: 'trigonometry',
        module: 'Unit Circle',
        lessonId: 'unit_circle',
      );

      expect(profile.category, LectureTopicCategory.trigonometry);
      expect(profile.mainEquation, contains('cos'));
      expect(profile.introSpeech.toLowerCase(), contains('unit circle'));
    });

    test('trigonometric equations do not route to algebra', () {
      expect(
        VirtualLectureTopicProfile.isAlgebraEquationTopic(
          topic: 'Trigonometric Equations',
          courseId: 'trigonometry',
        ),
        isFalse,
      );
    });
  });

  group('VirtualLectureFallback', () {
    test('unit circle lecture teaches unit circle not linear functions', () {
      final VirtualLectureScript script = VirtualLectureFallback.build(
        topic: 'Unit Circle',
        course: 'Trigonometry',
        module: 'Unit Circle',
        courseId: 'trigonometry',
        lessonId: 'unit_circle',
        mode: LectureMode.comprehensive,
      );

      expect(script.topic, 'Unit Circle');
      expect(script.segments, isNotEmpty);

      final String allSpeech = script.segments
          .map((LectureSegment s) => s.professorSpeech)
          .join(' ')
          .toLowerCase();

      expect(allSpeech, contains('unit circle'));
      expect(allSpeech, isNot(contains('g(x) = 2x')));

      final bool hasUnitCircleEquation = script.segments.any(
        (LectureSegment s) =>
            (s.whiteboard.equation ?? '').contains('cos') ||
            (s.whiteboard.title ?? '').toLowerCase().contains('unit circle'),
      );
      expect(hasUnitCircleEquation, isTrue);
    });
  });
}
