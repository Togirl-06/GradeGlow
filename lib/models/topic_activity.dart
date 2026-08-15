import 'package:flutter/material.dart';

import 'practice_lab.dart';

/// Interactive activity types available per curriculum topic.
enum TopicActivityKind {
  multipleChoice,
  shortAnswer,
  voiceResponse,
  labelDiagram,
  dragDrop,
  matching,
  fillBlank,
  caseStudy,
  aiRoleplay,
  virtualLab,
  liveSimulation,
  scenarioChallenge,
  timedQuiz,
  adaptivePractice,
  reviewMode,
  puzzleChallenge,
  masteryTest,
  punnettSquare,
  codeCompletion,
  aiCodingInterview,
  courtroomSimulation,
  practicalExam,
  imageIdentification,
}

class TopicActivity {
  const TopicActivity({
    required this.kind,
    required this.title,
    required this.description,
    required this.emoji,
    this.isLive = true,
    this.diagramId,
    this.visualActivityId,
    this.simulationStyle,
    this.timed = false,
  });

  final TopicActivityKind kind;
  final String title;
  final String description;
  final String emoji;
  final bool isLive;
  final String? diagramId;
  final String? visualActivityId;
  final SimulationStyle? simulationStyle;
  final bool timed;

  String get categoryLabel => switch (kind) {
        TopicActivityKind.multipleChoice ||
        TopicActivityKind.shortAnswer ||
        TopicActivityKind.fillBlank ||
        TopicActivityKind.timedQuiz ||
        TopicActivityKind.reviewMode ||
        TopicActivityKind.adaptivePractice ||
        TopicActivityKind.masteryTest ||
        TopicActivityKind.puzzleChallenge =>
          'Quiz & Questions',
        TopicActivityKind.labelDiagram ||
        TopicActivityKind.dragDrop ||
        TopicActivityKind.matching ||
        TopicActivityKind.imageIdentification ||
        TopicActivityKind.punnettSquare =>
          'Diagram & Visual',
        TopicActivityKind.caseStudy ||
        TopicActivityKind.aiRoleplay ||
        TopicActivityKind.liveSimulation ||
        TopicActivityKind.scenarioChallenge ||
        TopicActivityKind.courtroomSimulation ||
        TopicActivityKind.practicalExam =>
          'Scenarios & Simulation',
        TopicActivityKind.virtualLab => 'Virtual Lab',
        TopicActivityKind.voiceResponse => 'Voice Practice',
        TopicActivityKind.codeCompletion ||
        TopicActivityKind.aiCodingInterview =>
          'Coding Practice',
      };

  IconData get icon => switch (kind) {
        TopicActivityKind.multipleChoice => Icons.check_circle_outline_rounded,
        TopicActivityKind.shortAnswer => Icons.edit_note_rounded,
        TopicActivityKind.voiceResponse => Icons.mic_rounded,
        TopicActivityKind.labelDiagram => Icons.label_outline_rounded,
        TopicActivityKind.dragDrop => Icons.drag_indicator_rounded,
        TopicActivityKind.matching => Icons.compare_arrows_rounded,
        TopicActivityKind.fillBlank => Icons.space_bar_rounded,
        TopicActivityKind.caseStudy => Icons.medical_information_outlined,
        TopicActivityKind.aiRoleplay => Icons.smart_toy_outlined,
        TopicActivityKind.virtualLab => Icons.science_outlined,
        TopicActivityKind.liveSimulation => Icons.monitor_heart_outlined,
        TopicActivityKind.scenarioChallenge => Icons.emoji_events_outlined,
        TopicActivityKind.timedQuiz => Icons.timer_outlined,
        TopicActivityKind.adaptivePractice => Icons.auto_awesome_rounded,
        TopicActivityKind.reviewMode => Icons.replay_rounded,
        TopicActivityKind.puzzleChallenge => Icons.extension_rounded,
        TopicActivityKind.masteryTest => Icons.military_tech_rounded,
        TopicActivityKind.punnettSquare => Icons.grid_on_rounded,
        TopicActivityKind.codeCompletion => Icons.code_rounded,
        TopicActivityKind.aiCodingInterview => Icons.terminal_rounded,
        TopicActivityKind.courtroomSimulation => Icons.gavel_rounded,
        TopicActivityKind.practicalExam => Icons.fact_check_outlined,
        TopicActivityKind.imageIdentification => Icons.image_search_rounded,
      };
}
