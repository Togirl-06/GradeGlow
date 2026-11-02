import 'package:flutter/material.dart';

import '../data/practice_lab_university_catalog.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_subject.dart';
import '../models/practice_lab_topic.dart';
import '../models/practice_lab_unit.dart';
import '../data/visual_learning_catalog.dart';
import '../screens/science_diagram_lab_screen.dart';
import '../screens/anatomy_game_screen.dart';
import '../screens/er_simulation_screen.dart';
import '../screens/practice_lab_session_screen.dart';

/// Opens the correct practice session for Subject → Course → Unit → Topic.
void startUniversityPracticeLab({
  required BuildContext context,
  required PracticeLabSubject subject,
  required PracticeLabCourse course,
  required PracticeLabUnit unit,
  required PracticeLabTopic topic,
  required PracticeDifficulty difficulty,
}) {
  final PracticeLabCategory category = subject.toCategory();
  final PracticeLabType lab = PracticeLabUniversityCatalog.labFor(
    subject: subject,
    course: course,
    unit: unit,
    topic: topic,
    difficulty: difficulty,
  );

  final Widget screen = switch (lab.style) {
    SimulationStyle.diagramLab => ScienceDiagramLabScreen(
        category: category,
        lab: lab,
        subjectId: subject.id,
        courseId: course.id,
        topic: topic,
        environmentConfig: VisualLearningCatalog.configForSubject(subject.id),
      ),
    SimulationStyle.anatomyGame => AnatomyGameScreen(category: category, lab: lab),
    SimulationStyle.erEmergency => ErSimulationScreen(category: category, lab: lab),
    _ => PracticeLabSessionScreen(
        category: category,
        lab: lab,
        courseName: course.name,
        topicAreaName: unit.name,
        topicName: topic.name,
        subjectId: subject.id,
        courseId: course.id,
        topicId: topic.id,
      ),
  };
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
