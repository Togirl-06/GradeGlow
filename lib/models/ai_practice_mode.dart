import 'package:flutter/material.dart';

import 'practice_lab.dart';

/// Scenario difficulty — affects AI complexity and grading strictness.
enum PracticeDifficulty {
  beginner('Beginner', 'Foundational scenarios with guided expectations'),
  intermediate('Intermediate', 'Realistic scenarios with moderate complexity'),
  advanced('Advanced', 'High-stakes scenarios with nuanced decisions');

  const PracticeDifficulty(this.label, this.description);

  final String label;
  final String description;
}

/// Visual avatar archetype for the AI role.
enum AvatarRole {
  patient('Patient', Icons.sick_outlined, Color(0xFF5C9CE6)),
  teacher('Teacher', Icons.school_outlined, Color(0xFF9B6DD7)),
  ceo('CEO', Icons.business_center_outlined, Color(0xFFE6A23C)),
  customer('Customer', Icons.shopping_bag_outlined, Color(0xFFE85D75)),
  lawyer('Lawyer', Icons.gavel_outlined, Color(0xFF4A6FA5)),
  interviewer('Interviewer', Icons.record_voice_over_outlined, Color(0xFF2E9B8F)),
  manager('Manager', Icons.supervisor_account_outlined, Color(0xFF6B7B8C)),
  client('Client', Icons.person_outline, Color(0xFF7B9E6B)),
  witness('Witness', Icons.visibility_outlined, Color(0xFF8B7355));

  const AvatarRole(this.label, this.icon, this.accentColor);

  final String label;
  final IconData icon;
  final Color accentColor;
}

/// Avatar emotional state during conversation.
enum AvatarEmotion { neutral, happy, concerned, thinking, surprised }

/// Student interaction mode during a live simulation.
enum PracticeInteractionMode {
  askQuestion('Ask Question', Icons.chat_bubble_outline_rounded, 'Ask a question'),
  giveInstructions('Give Instructions', Icons.assignment_outlined, 'Give instructions'),
  makeDecision('Make Decision', Icons.touch_app_outlined, 'Make a decision');

  const PracticeInteractionMode(this.label, this.icon, this.hint);

  final String label;
  final IconData icon;
  final String hint;
}

/// A selectable scenario template within a major.
class PracticeScenarioTemplate {
  const PracticeScenarioTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.avatarRole,
    required this.aiRoleLabel,
    required this.studentTasks,
    required this.evaluationCriteria,
    required this.roleplayGuide,
    this.defaultDifficulty = PracticeDifficulty.intermediate,
    this.isAiGenerated = false,
  });

  final String id;
  final String title;
  final String description;
  final AvatarRole avatarRole;
  final String aiRoleLabel;
  final List<String> studentTasks;
  final List<String> evaluationCriteria;
  final String roleplayGuide;
  final PracticeDifficulty defaultDifficulty;
  final bool isAiGenerated;
}

/// Extended grade with criteria breakdown and study topics.
class PracticeModeGrade {
  const PracticeModeGrade({
    required this.score,
    required this.summary,
    required this.improvementPlan,
    this.strengths = const <String>[],
    this.improvements = const <String>[],
    this.studyTopics = const <String>[],
    this.criteriaScores = const <String, int>{},
  });

  factory PracticeModeGrade.fromJson(Map<String, dynamic> json) {
    final Map<String, int> criteria = <String, int>{};
    final dynamic rawCriteria = json['criteriaScores'] ?? json['criteria'];
    if (rawCriteria is Map) {
      rawCriteria.forEach((dynamic key, dynamic value) {
        criteria[key.toString()] = ((value as num?) ?? 0).toInt().clamp(0, 100);
      });
    }

    return PracticeModeGrade(
      score: ((json['score'] as num?) ?? 0).toInt().clamp(0, 100),
      summary: (json['summary'] as String? ?? json['feedback'] as String? ?? '').trim(),
      improvementPlan: (json['improvementPlan'] as String? ?? json['plan'] as String? ?? '').trim(),
      strengths: _stringList(json['strengths']),
      improvements: _stringList(json['improvements'] ?? json['weaknesses']),
      studyTopics: _stringList(json['studyTopics'] ?? json['recommendedStudyTopics']),
      criteriaScores: criteria,
    );
  }

  factory PracticeModeGrade.fromSimulationGrade(SimulationGrade grade) {
    return PracticeModeGrade(
      score: grade.score,
      summary: grade.summary,
      improvementPlan: grade.improvementPlan,
      strengths: grade.strengths,
      improvements: grade.improvements,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const <String>[];
    return raw.map((dynamic e) => e.toString()).where((String s) => s.isNotEmpty).toList();
  }

  final int score;
  final String summary;
  final String improvementPlan;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> studyTopics;
  final Map<String, int> criteriaScores;
}

/// Saved AI Practice Mode session.
class AiPracticeRecord {
  const AiPracticeRecord({
    required this.id,
    required this.majorId,
    required this.majorName,
    required this.scenarioTitle,
    required this.difficulty,
    required this.score,
    required this.summary,
    required this.completedAt,
    this.avatarRole,
  });

  factory AiPracticeRecord.fromMap(String id, Map<String, dynamic> data) {
    return AiPracticeRecord(
      id: id,
      majorId: data['majorId'] as String? ?? '',
      majorName: data['majorName'] as String? ?? '',
      scenarioTitle: data['scenarioTitle'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? 'intermediate',
      score: (data['score'] as num?)?.toInt() ?? 0,
      summary: data['summary'] as String? ?? '',
      completedAt: DateTime.tryParse(data['completedAt'] as String? ?? '') ?? DateTime.now(),
      avatarRole: data['avatarRole'] as String?,
    );
  }

  final String id;
  final String majorId;
  final String majorName;
  final String scenarioTitle;
  final String difficulty;
  final int score;
  final String summary;
  final DateTime completedAt;
  final String? avatarRole;
}

/// Leaderboard entry for monthly rankings.
class AiPracticeLeaderboardEntry {
  const AiPracticeLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalScore,
    required this.sessionCount,
    required this.averageScore,
  });

  factory AiPracticeLeaderboardEntry.fromMap(String id, Map<String, dynamic> data) {
    final int count = (data['sessionCount'] as num?)?.toInt() ?? 1;
    final int total = (data['totalScore'] as num?)?.toInt() ?? 0;
    return AiPracticeLeaderboardEntry(
      userId: id,
      displayName: data['displayName'] as String? ?? 'Student',
      totalScore: total,
      sessionCount: count,
      averageScore: count > 0 ? (total / count).round() : 0,
    );
  }

  final String userId;
  final String displayName;
  final int totalScore;
  final int sessionCount;
  final int averageScore;
}
