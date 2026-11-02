import 'package:flutter/material.dart';

import '../../../data/university_learning_engine.dart';
import '../university_lab_result.dart';
import '../engine/laboratory_engine.dart';

/// Course labs open the interactive laboratory engine.
abstract final class InvestigationLabFlow {
  static Future<UniversityLabResult?> open({
    required BuildContext context,
    required UniversityLabLink link,
    required String subjectId,
    String courseTitle = '',
    String topicTitle = '',
    int level = 2,
  }) {
    return LaboratoryEngine.open(
      context: context,
      link: link,
      subjectId: subjectId,
      courseTitle: courseTitle,
      topicTitle: topicTitle,
      level: level,
    );
  }
}
