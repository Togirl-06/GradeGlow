import 'package:flutter/material.dart';

import '../../data/university_learning_engine.dart';
import '../labs/simulation/university_sim_flow.dart';
import '../labs/simulation/university_sim_models.dart';
import '../labs/university_lab_result.dart';

/// Lecture → laboratory simulation (not a multiple-choice quiz).
abstract final class VuV2LessonActivityRouter {
  static UniversityLabLink? linkedLab({
    required String subjectId,
    required String lessonTitle,
    String? moduleTitle,
  }) {
    return UniversityLearningEngine.labForLesson(
      subjectId: subjectId,
      lessonTitle: lessonTitle,
      moduleTitle: moduleTitle,
    );
  }

  static Future<UniversityLabResult?> openLinkedLab({
    required BuildContext context,
    required UniversityLabLink link,
    required String subjectId,
    String? courseTitle,
    String? topicTitle,
    int labLevel = 2,
  }) {
    return UniversitySimulationFlow.open(
      context: context,
      link: link,
      subjectId: subjectId,
      courseTitle: courseTitle ?? '',
      topicTitle: topicTitle ?? link.title,
      level: labLevel,
    );
  }

  static int levelFor(int completedLessons) =>
      UniversitySimLevels.fromLessonCount(completedLessons);
}
