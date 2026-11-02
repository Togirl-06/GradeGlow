import 'dart:math' as math;

import 'career_sim_models.dart';

/// Runtime for career simulations — worlds plug in content; UI drives actions.
class CareerSimEngine {
  CareerSimEngine(this.world, {this.playerCareerLevel = 1, this.priorSkillAvg = 50});

  final CareerWorld world;
  final int playerCareerLevel;
  final int priorSkillAvg;
  final math.Random _rng = math.Random();

  CareerSimSessionState? _session;
  CareerSimSessionState get session {
    final CareerSimSessionState? s = _session;
    if (s == null) {
      throw StateError('No active career sim session');
    }
    return s;
  }

  bool get hasSession => _session != null;

  /// Adaptive hint strength: 0 = none, 1 = soft, 2 = direct.
  int get adaptiveHintLevel {
    if (priorSkillAvg >= 80) return 0;
    if (priorSkillAvg >= 55) return 1;
    return 2;
  }

  String? hintForCurrentBeat() {
    final int level = adaptiveHintLevel;
    if (level == 0) return null;
    final CareerBeat beat = session.beat;
    if (beat.kind == CareerBeatKind.decision || beat.kind == CareerBeatKind.tool) {
      if (level >= 2) {
        return 'Consider checking the patient\'s vital signs before escalating.';
      }
      return 'The patient\'s condition may require further assessment.';
    }
    if (beat.kind == CareerBeatKind.freeText && level >= 1) {
      return 'Acknowledge feelings, then keep the patient safe.';
    }
    return null;
  }

  CareerSimSessionState startMission(CareerMission mission) {
    _session = CareerSimSessionState(
      world: world,
      mission: mission,
      beatId: mission.startBeatId,
      locationId: mission.startLocationId,
      hintLevel: adaptiveHintLevel,
    );
    final CareerBeat first = mission.beat(mission.startBeatId);
    if (first.timerSeconds != null) {
      _session!.timerRemaining = first.timerSeconds;
    }
    if (first.locationId != null) {
      _session!.locationId = first.locationId!;
    }
    return _session!;
  }

  void tickTimer() {
    final CareerSimSessionState? s = _session;
    if (s == null || s.finished) return;
    final int? t = s.timerRemaining;
    if (t == null || t <= 0) return;
    s.timerRemaining = t - 1;
    if (s.timerRemaining == 0) {
      s.meters['patient'] = (s.meters['patient'] ?? 50) - 12;
      s.meters['stress'] = (s.meters['stress'] ?? 25) + 15;
      s.lastNarrative =
          'Time ran out. The situation worsened while you hesitated.';
      s.skills[CareerSkillId.timeManagement] =
          (s.skills[CareerSkillId.timeManagement] ?? 50) - 8;
    }
  }

  CareerSimSessionState continueCinematic() {
    final CareerSimSessionState s = session;
    final CareerBeat beat = s.beat;
    if (beat.nextBeatId != null) {
      _goToBeat(beat.nextBeatId!);
    }
    return s;
  }

  CareerSimSessionState applyChoice(String choiceId) {
    final CareerSimSessionState s = session;
    final CareerBeat beat = s.beat;
    final CareerChoice choice = beat.choices.firstWhere(
      (CareerChoice c) => c.id == choiceId,
      orElse: () => beat.choices.first,
    );
    return _applyConsequence(choice.consequence, spokenLine: choice.label);
  }

  CareerSimSessionState applyTool(String toolId) {
    final CareerSimSessionState s = session;
    final CareerBeat beat = s.beat;
    for (final CareerChoice c in beat.choices) {
      if (c.id == toolId) {
        return _applyConsequence(c.consequence, spokenLine: c.label);
      }
    }
    // Generic tool fallback
    return _applyConsequence(
      CareerConsequence(
        narrative: 'You use $toolId and gather more information.',
        nextBeatId: beat.nextBeatId ?? beat.choices.firstOrNull?.consequence.nextBeatId,
        meterDeltas: const <String, int>{'trust': 2},
        skillDeltas: const <String, int>{CareerSkillId.clinicalKnowledge: 3},
      ),
    );
  }

  CareerSimSessionState submitFreeText(String text) {
    final CareerSimSessionState s = session;
    final CareerBeat beat = s.beat;
    s.dialogueMemory.add(text.trim());
    final String lower = text.toLowerCase();
    final bool good = beat.freeTextGoodKeywords.any(
      (String k) => lower.contains(k.toLowerCase()),
    );
    final CareerConsequence? result =
        good ? beat.freeTextGood : beat.freeTextWeak;
    return _applyConsequence(
      result ??
          CareerConsequence(
            narrative: good
                ? 'They soften. Your words landed.'
                : 'They pull back. Try acknowledging their feelings and safety.',
            nextBeatId: beat.nextBeatId,
            skillDeltas: good
                ? const <String, int>{
                    CareerSkillId.communication: 10,
                    CareerSkillId.professionalism: 6,
                  }
                : const <String, int>{
                    CareerSkillId.communication: -4,
                    CareerSkillId.professionalism: -2,
                  },
            meterDeltas: good
                ? const <String, int>{'trust': 8, 'patient': 5}
                : const <String, int>{'trust': -5, 'stress': 6},
          ),
      spokenLine: text,
    );
  }

  CareerSimSessionState completeErChallenge({required bool success}) {
    return _applyConsequence(
      CareerConsequence(
        narrative: success
            ? 'Clinical challenge cleared. The bay stabilizes enough to continue.'
            : 'The challenge strained the team — you regroup with what you learned.',
        nextBeatId: session.beat.nextBeatId,
        completeMission: session.beat.nextBeatId == null,
        skillDeltas: success
            ? const <String, int>{
                CareerSkillId.clinicalKnowledge: 12,
                CareerSkillId.criticalThinking: 8,
              }
            : const <String, int>{
                CareerSkillId.clinicalKnowledge: 3,
                CareerSkillId.criticalThinking: 2,
              },
        meterDeltas: success
            ? const <String, int>{'patient': 15, 'trust': 8}
            : const <String, int>{'patient': -5, 'stress': 10},
      ),
    );
  }

  CareerSimSessionState _applyConsequence(
    CareerConsequence c, {
    String? spokenLine,
  }) {
    final CareerSimSessionState s = session;
    if (spokenLine != null && spokenLine.trim().isNotEmpty) {
      s.dialogueMemory.add(spokenLine.trim());
    }
    s.lastNarrative = c.narrative;
    c.meterDeltas.forEach((String k, int v) {
      s.meters[k] = ((s.meters[k] ?? 50) + v).clamp(0, 100);
    });
    c.skillDeltas.forEach((String k, int v) {
      s.skills[k] = ((s.skills[k] ?? 50) + v).clamp(0, 100);
    });
    c.setFlags.forEach((String k, String v) {
      s.flags[k] = v;
    });
    for (final String oid in c.unlockObjectives) {
      s.objectives = s.objectives
          .map(
            (CareerObjective o) =>
                o.id == oid ? o.copyWith(done: true) : o,
          )
          .toList();
    }

    if (c.failMission) {
      s.finished = true;
      s.won = false;
      return s;
    }
    if (c.completeMission) {
      s.finished = true;
      s.won = true;
      // Mark remaining objectives done on win.
      s.objectives =
          s.objectives.map((CareerObjective o) => o.copyWith(done: true)).toList();
      return s;
    }

    String? next = c.nextBeatId;
    if (c.injectRandomEvent ||
        (s.beat.kind == CareerBeatKind.timerPressure &&
            s.beat.randomEventBeatIds.isNotEmpty &&
            _rng.nextBool())) {
      final List<String> pool = s.beat.randomEventBeatIds.isNotEmpty
          ? s.beat.randomEventBeatIds
          : (c.setFlags['random_pool']?.split(',') ?? const <String>[]);
      if (pool.isNotEmpty) {
        next = pool[_rng.nextInt(pool.length)];
      }
    }

    if (next != null) {
      _goToBeat(next);
    } else if (s.beat.kind == CareerBeatKind.missionEnd) {
      s.finished = true;
      s.won = (s.meters['patient'] ?? 0) >= 40 && (s.meters['trust'] ?? 0) >= 35;
    }
    return s;
  }

  void _goToBeat(String beatId) {
    final CareerSimSessionState s = session;
    s.beatId = beatId;
    final CareerBeat beat = s.mission.beat(beatId);
    if (beat.locationId != null) {
      s.locationId = beat.locationId!;
    }
    if (beat.timerSeconds != null) {
      s.timerRemaining = beat.timerSeconds;
    }
    if (beat.kind == CareerBeatKind.missionEnd) {
      s.finished = true;
      s.won = (s.meters['patient'] ?? 0) >= 40 && (s.meters['trust'] ?? 0) >= 35;
      if (s.won) {
        s.objectives = s.objectives
            .map((CareerObjective o) => o.copyWith(done: true))
            .toList();
      }
    }
  }

  CareerPerformanceReport buildReport({List<String> badgesEarned = const <String>[]}) {
    final CareerSimSessionState s = session;
    final Map<String, int> scores = Map<String, int>.from(s.skills);
    final double avg = scores.values.isEmpty
        ? 50
        : scores.values.reduce((int a, int b) => a + b) / scores.values.length;
    final double stars = s.won
        ? (avg / 20).clamp(2.5, 5.0)
        : (avg / 25).clamp(1.0, 3.0);

    final String feedback = _supervisorFeedback(s, avg);
    final String next = s.won
        ? 'Improve response time under pressure — try the next mission.'
        : 'Replay this shift. Focus on assessment before action.';

    final int xp = s.won
        ? s.mission.xpReward
        : (s.mission.xpReward * 0.35).round().clamp(40, 200);

    return CareerPerformanceReport(
      missionId: s.mission.id,
      missionTitle: s.mission.title,
      won: s.won,
      overallStars: double.parse(stars.toStringAsFixed(1)),
      skillScores: scores,
      supervisorFeedback: feedback,
      nextChallenge: next,
      xpEarned: xp,
      badgesEarned: badgesEarned,
      metersEnd: Map<String, int>.from(s.meters),
    );
  }

  String _supervisorFeedback(CareerSimSessionState s, double avg) {
    final int patient = s.meters['patient'] ?? 50;
    final int trust = s.meters['trust'] ?? 50;
    final int timeSkill = s.skills[CareerSkillId.timeManagement] ?? 50;
    final String boss = s.world.role.supervisorName;
    if (!s.won) {
      return '$boss: "We need to talk about what happened. '
          'Patient safety comes first — go review your assessment sequence and try again."';
    }
    if (patient >= 80 && trust >= 70) {
      return '$boss: "Strong shift. You read the room, acted, and kept the patient safe. '
          'That\'s how Student Nurses become Charge Nurses."';
    }
    if (timeSkill < 55) {
      return '$boss: "You correctly identified the problem, but you spent too long '
          'gathering information before escalating. Speed matters in the ED."';
    }
    if (avg >= 75) {
      return '$boss: "Solid work. Communication and clinical judgment both showed up. '
          'Keep sharpening prioritization."';
    }
    return '$boss: "You finished the mission. Next time, tighten your handoffs '
        'and double-check allergies before meds."';
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
