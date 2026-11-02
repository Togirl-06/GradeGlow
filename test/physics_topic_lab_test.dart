import 'package:ai_study_buddy/data/physics/physics_catalog.dart';
import 'package:ai_study_buddy/data/physics/physics_topic_lab_engine.dart';
import 'package:ai_study_buddy/models/physics/physics_lab_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('velocity topic gets Motion Tracking Laboratory', () {
    final topic = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_velocity',
    );
    final course = PhysicsCatalog.courseById(trackId: 'undergraduate_core', courseId: 'kinematics');
    expect(topic, isNotNull);
    expect(course, isNotNull);

    final profile = PhysicsTopicLabEngine.profileFor(course: course!, topic: topic!);
    expect(profile.simulationTitle, 'Motion Tracking Laboratory');
    expect(profile.simulationKind, PhysicsSimulationKind.motionTracking);
    expect(profile.virtualLab.experimentTitle, 'Measuring Velocity Using Motion Sensors');
    expect(profile.report.title, 'Determining Velocity of a Moving Object');
  });

  test('acceleration topic gets Vehicle Acceleration Test', () {
    final topic = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_acceleration',
    );
    final course = PhysicsCatalog.courseById(trackId: 'undergraduate_core', courseId: 'kinematics');
    final profile = PhysicsTopicLabEngine.profileFor(course: course!, topic: topic!);
    expect(profile.simulationTitle, 'Vehicle Acceleration Test');
    expect(profile.simulationKind, PhysicsSimulationKind.acceleration);
  });

  test('dynamic topics get unique lab names', () {
    final course = PhysicsCatalog.courseById(trackId: 'undergraduate_core', courseId: 'kinematics');
    final position = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_position',
    );
    final speed = PhysicsCatalog.topicById(
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_speed',
    );
    final posProfile = PhysicsTopicLabEngine.profileFor(course: course!, topic: position!);
    final speedProfile = PhysicsTopicLabEngine.profileFor(course: course, topic: speed!);

    expect(posProfile.simulationTitle, contains('Position'));
    expect(speedProfile.simulationTitle, contains('Speed'));
    expect(posProfile.virtualLab.experimentTitle, isNot(equals(speedProfile.virtualLab.experimentTitle)));
  });
}
