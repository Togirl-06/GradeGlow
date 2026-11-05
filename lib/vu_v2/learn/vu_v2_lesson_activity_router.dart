import 'package:flutter/material.dart';

import '../../career_sim/career_sim.dart';
import '../../career_sim/model/content_models.dart';

/// Lecture → professional practice in the matching career-simulator
/// department (graded tasks, projects and roles for this subject).
abstract final class VuV2LessonActivityRouter {
  static Department? linkedDepartment(String subjectId) => CareerSim.departmentForSubject(subjectId);

  static Future<void> openPractice(BuildContext context, String subjectId) =>
      CareerSim.openForSubject(context, subjectId);
}
