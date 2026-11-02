import 'package:flutter/material.dart';

class ErVitals {
  const ErVitals({
    required this.heartRate,
    required this.bloodPressure,
    required this.respiratoryRate,
    required this.spo2,
    required this.temperature,
  });

  final int heartRate;
  final String bloodPressure;
  final int respiratoryRate;
  final int spo2;
  final double temperature;

  ErVitals copyWith({
    int? heartRate,
    String? bloodPressure,
    int? respiratoryRate,
    int? spo2,
    double? temperature,
  }) {
    return ErVitals(
      heartRate: heartRate ?? this.heartRate,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      spo2: spo2 ?? this.spo2,
      temperature: temperature ?? this.temperature,
    );
  }
}

class ErQuestion {
  const ErQuestion({required this.prompt, required this.response, this.xp = 5});

  final String prompt;
  final String response;
  final int xp;
}

class ErObjective {
  const ErObjective({required this.label, required this.target, this.progress = 0});

  final String label;
  final int target;
  final int progress;

  bool get complete => progress >= target;
  ErObjective advance() => ErObjective(label: label, target: target, progress: (progress + 1).clamp(0, target));
}

class ErSimulationAction {
  const ErSimulationAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

class ErSimulationCase {
  const ErSimulationCase({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.patientName,
    required this.patientAge,
    required this.openingLine,
    required this.vitals,
    required this.questions,
    required this.statusLines,
    required this.objectives,
    required this.tip,
    required this.starsRequired,
  });

  final String id;
  final int caseNumber;
  final String title;
  final String patientName;
  final int patientAge;
  final String openingLine;
  final ErVitals vitals;
  final List<ErQuestion> questions;
  final List<String> statusLines;
  final List<ErObjective> objectives;
  final String tip;
  final int starsRequired;
}

class ErSimulationRun {
  ErSimulationRun({required this.caseData})
      : vitals = caseData.vitals,
        objectives = List<ErObjective>.from(caseData.objectives),
        patientLine = caseData.openingLine;

  final ErSimulationCase caseData;
  ErVitals vitals;
  List<ErObjective> objectives;
  String patientLine;
  int xp = 0;
  int coins = 250;
  int level = 2;
  int levelXp = 320;
  int levelXpMax = 500;
  int secondsRemaining = 10 * 60 + 48;
  final Set<String> askedQuestions = <String>{};
  final List<String> achievements = <String>[];
  bool aspirinGiven = false;
  bool oxygenApplied = false;
  bool ecgOrdered = false;

  int get completedObjectives => objectives.where((ErObjective o) => o.complete).length;
  bool get isCritical => vitals.spo2 < 92 || vitals.heartRate > 110;

  void addXp(int amount) {
    xp += amount;
    levelXp += amount;
    while (levelXp >= levelXpMax) {
      levelXp -= levelXpMax;
      level += 1;
      levelXpMax += 100;
    }
  }

  void tickSecond() {
    if (secondsRemaining > 0) secondsRemaining -= 1;
  }

  bool get allObjectivesComplete => objectives.every((ErObjective o) => o.complete);

  int computeStars() {
    int stars = 1;
    if (completedObjectives >= 2) stars = 2;
    if (allObjectivesComplete && secondsRemaining > 120) stars = 3;
    return stars;
  }

  int computeScorePercent() => ((completedObjectives / objectives.length) * 100).round().clamp(0, 100);
}
