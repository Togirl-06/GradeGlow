import 'package:flutter/material.dart';

/// One graded decision inside a university practical (not a flashcard dump).
class PracticalStep {
  const PracticalStep({
    required this.phaseLabel,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.coachCorrect,
    required this.coachWrong,
  });

  final String phaseLabel;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String coachCorrect;
  final String coachWrong;
}

/// Case-driven practical: briefing → investigate → diagnose → professional WHY → score.
class UniversityPracticalMission {
  const UniversityPracticalMission({
    required this.id,
    required this.courseId,
    required this.emoji,
    required this.title,
    required this.role,
    required this.briefingTitle,
    required this.briefingBody,
    required this.uniqueHook,
    required this.steps,
    required this.vivaPrompt,
    required this.vivaOptions,
    required this.vivaCorrectIndex,
    required this.badgeId,
    required this.accent,
  });

  final String id;
  final String courseId;
  final String emoji;
  final String title;
  final String role;
  final String briefingTitle;
  final String briefingBody;
  final String uniqueHook;
  final List<PracticalStep> steps;
  final String vivaPrompt;
  final List<String> vivaOptions;
  final int vivaCorrectIndex;
  final String badgeId;
  final Color accent;
}
