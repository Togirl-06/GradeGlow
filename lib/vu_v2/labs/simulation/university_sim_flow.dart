import 'package:flutter/material.dart';

import '../../../data/university_learning_engine.dart';
import '../investigation/investigation_flow.dart';
import '../university_lab_result.dart';

/// Course labs open an investigation (not a multiple-choice quiz).
abstract final class UniversitySimulationFlow {
  static Future<UniversityLabResult?> open({
    required BuildContext context,
    required UniversityLabLink link,
    required String subjectId,
    String courseTitle = '',
    String topicTitle = '',
    int level = 2,
  }) {
    return InvestigationLabFlow.open(
      context: context,
      link: link,
      subjectId: subjectId,
      courseTitle: courseTitle,
      topicTitle: topicTitle,
      level: level,
    );
  }
}
