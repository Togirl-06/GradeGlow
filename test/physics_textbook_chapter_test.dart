import 'package:ai_study_buddy/data/physics/physics_catalog.dart';
import 'package:ai_study_buddy/data/physics/physics_textbook_chapter_engine.dart';
import 'package:ai_study_buddy/data/physics/physics_topic_knowledge_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('textbook chapter includes reading path and diagrams', () {
    final course = PhysicsCatalog.courseById(trackId: 'undergraduate_core', courseId: 'kinematics');
    final topic = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_speed',
    );
    expect(course, isNotNull);
    expect(topic, isNotNull);

    final String chapter = PhysicsTextbookChapterEngine.build(
      course: course!,
      topic: topic!,
      levelLabel: 'Undergraduate',
    );

    expect(chapter, contains('Reading Path'));
    expect(chapter, contains('Diagram Gallery'));
    expect(chapter, contains('Learning Objectives'));
    expect(chapter, contains('Continue Your Study'));
    expect(chapter, contains('Previous chapter'));
    expect(chapter.length, greaterThan(8000));
  });

  test('velocity chapter is wrapped with navigation', () {
    final course = PhysicsCatalog.courseById(trackId: 'undergraduate_core', courseId: 'kinematics');
    final topic = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_velocity',
    );
    final String chapter = PhysicsTopicKnowledgeEngine.completeGuide(
      course: course!,
      topic: topic!,
      levelLabel: 'Undergraduate',
    );
    expect(chapter, contains('Reading Path'));
    expect(chapter, contains('Continue Your Study'));
    expect(chapter, contains('Chapter 5: Velocity'));
  });

  test('acceleration chapter includes deep dive and full examples', () {
    final course = PhysicsCatalog.courseById(trackId: 'undergraduate_core', courseId: 'kinematics');
    final topic = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_acceleration',
    );
    final String chapter = PhysicsTextbookChapterEngine.build(
      course: course!,
      topic: topic!,
      levelLabel: 'Undergraduate',
    );
    expect(chapter, contains('Deep Dive'));
    expect(chapter, contains('Average acceleration'));
    expect(chapter, contains('Acceleration–time graph'));
    expect(chapter.length, greaterThan(10000));
  });
}
