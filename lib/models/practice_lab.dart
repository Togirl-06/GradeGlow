import 'package:flutter/material.dart';

/// How the AI should behave in a simulation lab.
enum SimulationStyle {
  aiPatient,
  erEmergency,
  codingInterview,
  debugging,
  systemDesign,
  customerScenario,
  courtroom,
  counseling,
  classroom,
  diagnosis,
  anatomyGame,
  diagramLab,
}

/// A discipline track inside Practice Labs.
class PracticeLabCategory {
  const PracticeLabCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.labs,
    this.groupId,
  });

  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final List<PracticeLabType> labs;
  final String? groupId;
}

/// Top-level subject area grouping majors/disciplines.
class PracticeLabSubjectGroup {
  const PracticeLabSubjectGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.subjects,
  });

  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final List<PracticeLabCategory> subjects;
}

/// A single simulation lab within a track.
class PracticeLabType {
  const PracticeLabType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.style,
    this.codeLab = false,
    this.timed = false,
    this.aiRole,
    this.studentTasks = const <String>[],
    this.evaluationCriteria = const <String>[],
    this.difficulty = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final SimulationStyle style;
  final bool codeLab;
  final bool timed;

  /// Who the AI plays in this scenario (e.g. "Patient", "Interviewer", "CEO").
  final String? aiRole;

  /// What the student must accomplish during the simulation.
  final List<String> studentTasks;

  /// Dimensions the student is graded on at the end.
  final List<String> evaluationCriteria;

  /// "Beginner", "Intermediate", or "Advanced" (empty when unspecified).
  final String difficulty;
}

/// One message in a live simulation transcript.
class SimulationMessage {
  const SimulationMessage({
    required this.isStudent,
    required this.text,
    required this.at,
  });

  factory SimulationMessage.student(String text) =>
      SimulationMessage(isStudent: true, text: text, at: DateTime.now());

  factory SimulationMessage.ai(String text) =>
      SimulationMessage(isStudent: false, text: text, at: DateTime.now());

  factory SimulationMessage.fromMap(Map<String, dynamic> map) {
    return SimulationMessage(
      isStudent: map['isStudent'] == true,
      text: map['text'] as String? ?? '',
      at: DateTime.tryParse(map['at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final bool isStudent;
  final String text;
  final DateTime at;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isStudent': isStudent,
        'text': text,
        'at': at.toIso8601String(),
      };
}

/// Opening state when a simulation starts.
class SimulationStart {
  const SimulationStart({
    required this.scenarioTitle,
    required this.briefing,
    required this.aiRole,
    required this.openingMessage,
    this.contextFields = const <String, String>{},
    this.vitals = const <String, String>{},
  });

  factory SimulationStart.fromJson(Map<String, dynamic> json) {
    return SimulationStart(
      scenarioTitle: (json['scenarioTitle'] as String? ?? json['title'] as String? ?? 'Simulation').trim(),
      briefing: (json['briefing'] as String? ?? json['prompt'] as String? ?? '').trim(),
      aiRole: (json['aiRole'] as String? ?? 'AI').trim(),
      openingMessage: (json['openingMessage'] as String? ?? json['aiMessage'] as String? ?? '').trim(),
      contextFields: _stringMap(json['contextFields'] ?? json['context']),
      vitals: _stringMap(json['vitals']),
    );
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is! Map) return const <String, String>{};
    return Map<String, String>.fromEntries(
      raw.entries
          .where((MapEntry<dynamic, dynamic> e) => e.key is String && e.value != null)
          .map((MapEntry<dynamic, dynamic> e) => MapEntry<String, String>(e.key as String, e.value.toString().trim())),
    );
  }

  final String scenarioTitle;
  final String briefing;
  final String aiRole;
  final String openingMessage;
  final Map<String, String> contextFields;
  final Map<String, String> vitals;
}

/// Final grade after ending a simulation.
class SimulationGrade {
  const SimulationGrade({
    required this.score,
    required this.summary,
    required this.improvementPlan,
    this.strengths = const <String>[],
    this.improvements = const <String>[],
    this.studyTopics = const <String>[],
    this.criteriaScores = const <String, int>{},
    this.hintsUsed = 0,
  });

  factory SimulationGrade.fromJson(Map<String, dynamic> json) {
    final Map<String, int> criteria = <String, int>{};
    final dynamic rawCriteria = json['criteriaScores'] ?? json['criteria'];
    if (rawCriteria is Map) {
      rawCriteria.forEach((dynamic key, dynamic value) {
        if (key is String && value is num) {
          criteria[key] = value.toInt().clamp(0, 100);
        }
      });
    }
    return SimulationGrade(
      score: ((json['score'] as num?) ?? 0).toInt().clamp(0, 100),
      summary: (json['summary'] as String? ?? json['feedback'] as String? ?? '').trim(),
      improvementPlan: (json['improvementPlan'] as String? ?? json['plan'] as String? ?? '').trim(),
      strengths: (json['strengths'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .where((String s) => s.isNotEmpty)
          .toList(),
      improvements: (json['improvements'] as List<dynamic>? ?? json['weaknesses'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .where((String s) => s.isNotEmpty)
          .toList(),
      studyTopics: (json['studyTopics'] as List<dynamic>? ?? json['recommendedStudyTopics'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .where((String s) => s.isNotEmpty)
          .toList(),
      criteriaScores: criteria,
      hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
    );
  }

  final int score;
  final String summary;
  final String improvementPlan;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> studyTopics;
  final Map<String, int> criteriaScores;
  final int hintsUsed;
}

/// Incremental score pulse during a live simulation.
class PracticeLabLiveScore {
  const PracticeLabLiveScore({
    required this.overall,
    this.criteriaScores = const <String, int>{},
    this.feedback = '',
  });

  factory PracticeLabLiveScore.fromJson(Map<String, dynamic> json) {
    final Map<String, int> criteria = <String, int>{};
    final dynamic raw = json['criteriaScores'] ?? json['criteria'];
    if (raw is Map) {
      raw.forEach((dynamic key, dynamic value) {
        if (key is String && value is num) criteria[key] = value.toInt().clamp(0, 100);
      });
    }
    return PracticeLabLiveScore(
      overall: ((json['overall'] as num?) ?? json['score'] as num?)?.toInt().clamp(0, 100) ?? 0,
      criteriaScores: criteria,
      feedback: (json['feedback'] as String? ?? '').trim(),
    );
  }

  final int overall;
  final Map<String, int> criteriaScores;
  final String feedback;
}
class PracticeLabRecord {
  const PracticeLabRecord({
    required this.id,
    required this.categoryId,
    required this.labId,
    required this.categoryName,
    required this.labTitle,
    required this.scenarioTitle,
    required this.score,
    required this.summary,
    required this.completedAt,
  });

  factory PracticeLabRecord.fromMap(String id, Map<String, dynamic> data) {
    return PracticeLabRecord(
      id: id,
      categoryId: data['categoryId'] as String? ?? '',
      labId: data['labId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      labTitle: data['labTitle'] as String? ?? '',
      scenarioTitle: data['scenarioTitle'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      summary: data['summary'] as String? ?? '',
      completedAt: DateTime.tryParse(data['completedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String categoryId;
  final String labId;
  final String categoryName;
  final String labTitle;
  final String scenarioTitle;
  final int score;
  final String summary;
  final DateTime completedAt;
}
