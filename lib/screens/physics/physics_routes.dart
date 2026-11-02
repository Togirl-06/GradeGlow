import 'package:flutter/material.dart';

import '../../models/physics/physics_program.dart';
import 'physics_course_screen.dart' deferred as course;
import 'physics_experiment_report_screen.dart' deferred as report;
import 'physics_formula_notebook_screen.dart' deferred as formula;
import 'physics_lecture_screen.dart' deferred as lecture;
import 'physics_level_screen.dart' deferred as level;
import 'physics_practical_lab_hub_screen.dart' deferred as hub;
import 'physics_quiz_screen.dart' deferred as quiz;
import 'physics_simulation_lab_screen.dart' deferred as sim;
import 'physics_topic_screen.dart' deferred as topic;

/// Lazy navigation for Physics Faculty — avoids loading every screen at once.
class PhysicsRoutes {
  PhysicsRoutes._();

  static Future<void> _loadWithSpinner(BuildContext context, Future<void> Function() load) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await load();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  static Future<void> openLevel(BuildContext context, PhysicsLevel physicsLevel) async {
    await _loadWithSpinner(context, level.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => level.PhysicsLevelScreen(level: physicsLevel),
      ),
    );
  }

  static Future<void> openCourse(
    BuildContext context, {
    required String trackId,
    required String courseId,
  }) async {
    await _loadWithSpinner(context, course.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => course.PhysicsCourseScreen(trackId: trackId, courseId: courseId),
      ),
    );
  }

  static Future<void> openTopic(
    BuildContext context, {
    required String trackId,
    required String courseId,
    required String topicId,
  }) async {
    await _loadWithSpinner(context, topic.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => topic.PhysicsTopicScreen(
          trackId: trackId,
          courseId: courseId,
          topicId: topicId,
        ),
      ),
    );
  }

  static Future<void> openSimulation(
    BuildContext context, {
    required PhysicsTrack track,
    required PhysicsCourse course,
    required PhysicsTopic topic,
  }) async {
    await _loadWithSpinner(context, sim.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => sim.PhysicsSimulationLabScreen(track: track, course: course, topic: topic),
      ),
    );
  }

  static Future<void> openPracticalHub(BuildContext context) async {
    await _loadWithSpinner(context, hub.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => hub.PhysicsPracticalLabHubScreen()),
    );
  }

  static Future<void> openMode(
    BuildContext context, {
    required PhysicsTrack track,
    required PhysicsCourse course,
    required PhysicsTopic topic,
    required PhysicsLearningMode mode,
  }) async {
    if (!context.mounted) return;
    switch (mode) {
      case PhysicsLearningMode.lecture:
        await _loadWithSpinner(context, lecture.loadLibrary);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => lecture.PhysicsLectureScreen(track: track, course: course, topic: topic),
          ),
        );
      case PhysicsLearningMode.virtualLab:
        await _loadWithSpinner(context, sim.loadLibrary);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => sim.PhysicsSimulationLabScreen(track: track, course: course, topic: topic),
          ),
        );
      case PhysicsLearningMode.quiz:
        await _loadWithSpinner(context, quiz.loadLibrary);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => quiz.PhysicsQuizScreen(track: track, course: course, topic: topic),
          ),
        );
      case PhysicsLearningMode.experimentReport:
        await _loadWithSpinner(context, report.loadLibrary);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => report.PhysicsExperimentReportScreen(track: track, course: course, topic: topic),
          ),
        );
      case PhysicsLearningMode.formulaNotebook:
        await _loadWithSpinner(context, formula.loadLibrary);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => formula.PhysicsFormulaNotebookScreen(track: track, course: course, topic: topic),
          ),
        );
    }
  }
}
