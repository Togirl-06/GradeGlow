import '../career_sim_models.dart';

/// Compact choice for [DecisionBeatSpec].
class ChoiceSpec {
  const ChoiceSpec({
    required this.id,
    required this.label,
    required this.narrative,
    this.skillDeltas = const <String, int>{},
    this.meterDeltas = const <String, int>{},
    this.failMission = false,
    this.unlockObjectives = const <String>[],
  });

  final String id;
  final String label;
  final String narrative;
  final Map<String, int> skillDeltas;
  final Map<String, int> meterDeltas;
  final bool failMission;
  final List<String> unlockObjectives;
}

/// One decision beat with good / ok / bad style choices.
class DecisionBeatSpec {
  const DecisionBeatSpec({
    required this.title,
    required this.body,
    required this.choices,
    this.locationId,
    this.npcId,
  });

  final String title;
  final String body;
  final String? locationId;
  final String? npcId;
  final List<ChoiceSpec> choices;
}

/// Compact mission blueprint → full [CareerMission] with playable beats.
class MissionSpec {
  const MissionSpec({
    required this.id,
    required this.index,
    required this.title,
    required this.brief,
    required this.objective,
    required this.mode,
    required this.trackStage,
    required this.difficultyStars,
    required this.xpReward,
    required this.requiredCareerLevel,
    required this.startLocationId,
    required this.objectiveLabels,
    required this.cinematicTitle,
    required this.cinematicBody,
    required this.supervisorNpcId,
    required this.supervisorLine,
    required this.decisions,
    required this.endTitle,
    required this.endBody,
    this.badgeOnClear,
    this.freeTextPrompt,
    this.freeTextKeywords = const <String>[],
    this.freeTextHint,
    this.pressureTitle,
    this.pressureBody,
    this.pressureSeconds = 90,
    this.randomEventTitle,
    this.randomEventBody,
    this.primarySkill = CareerSkillId.criticalThinking,
    this.secondarySkill = CareerSkillId.communication,
  });

  final String id;
  final int index;
  final String title;
  final String brief;
  final String objective;
  final CareerSimGameMode mode;
  final CareerTrackStage trackStage;
  final int difficultyStars;
  final int xpReward;
  final int requiredCareerLevel;
  final String startLocationId;
  final String? badgeOnClear;
  final List<String> objectiveLabels;
  final String cinematicTitle;
  final String cinematicBody;
  final String supervisorNpcId;
  final String supervisorLine;
  final List<DecisionBeatSpec> decisions;
  final String? freeTextPrompt;
  final List<String> freeTextKeywords;
  final String? freeTextHint;
  final String? pressureTitle;
  final String? pressureBody;
  final int pressureSeconds;
  final String? randomEventTitle;
  final String? randomEventBody;
  final String endTitle;
  final String endBody;
  final String primarySkill;
  final String secondarySkill;
}

/// Builds solid multi-beat missions from compact specs.
abstract final class CareerMissionBuilder {
  static CareerMission build(MissionSpec spec) {
    assert(spec.decisions.isNotEmpty, 'Mission needs at least one decision');
    final String prefix = 'b${spec.index}';
    final List<CareerObjective> objectives = <CareerObjective>[
      for (int i = 0; i < spec.objectiveLabels.length; i++)
        CareerObjective(id: 'obj_$i', label: spec.objectiveLabels[i]),
    ];

    final bool wantsPressure = spec.pressureTitle != null ||
        spec.trackStage == CareerTrackStage.crisis ||
        spec.trackStage == CareerTrackStage.boss;
    final bool wantsRandom = spec.randomEventTitle != null ||
        spec.trackStage == CareerTrackStage.crisis ||
        spec.trackStage == CareerTrackStage.boss;
    final bool wantsFreeText =
        spec.freeTextPrompt != null && spec.freeTextPrompt!.isNotEmpty;

    final String cinematicId = '${prefix}_cine';
    final String dialogueId = '${prefix}_dlg';
    final String endId = '${prefix}_end';
    final String freeId = '${prefix}_ft';
    final String pressureId = '${prefix}_timer';
    final String randomId = '${prefix}_rand';

    final List<String> decisionIds = <String>[
      for (int i = 0; i < spec.decisions.length; i++) '${prefix}_d$i',
    ];

    String nextAfterDecisions() {
      if (wantsFreeText) return freeId;
      if (wantsPressure) return pressureId;
      return endId;
    }

    final List<CareerBeat> beats = <CareerBeat>[
      CareerBeat(
        id: cinematicId,
        kind: CareerBeatKind.cinematic,
        locationId: spec.startLocationId,
        title: spec.cinematicTitle,
        body: spec.cinematicBody,
        nextBeatId: dialogueId,
        continueLabel: 'Begin',
      ),
      CareerBeat(
        id: dialogueId,
        kind: CareerBeatKind.dialogue,
        locationId: spec.startLocationId,
        npcId: spec.supervisorNpcId,
        title: 'Briefing',
        body: spec.supervisorLine,
        choices: <CareerChoice>[
          CareerChoice(
            id: 'ack',
            label: 'Understood — I\'m on it.',
            consequence: CareerConsequence(
              narrative: 'They nod. The clock is already moving.',
              nextBeatId: decisionIds.first,
              unlockObjectives: objectives.isNotEmpty
                  ? <String>[objectives.first.id]
                  : const <String>[],
              skillDeltas: <String, int>{
                CareerSkillId.professionalism: 4,
                spec.secondarySkill: 3,
              },
              meterDeltas: const <String, int>{'trust': 6},
            ),
          ),
          CareerChoice(
            id: 'hesitate',
            label: 'Ask for more time before starting.',
            consequence: CareerConsequence(
              narrative: 'They sigh. "Move. You\'ll learn by doing."',
              nextBeatId: decisionIds.first,
              skillDeltas: const <String, int>{
                CareerSkillId.professionalism: -2,
                CareerSkillId.timeManagement: -3,
              },
              meterDeltas: const <String, int>{'trust': -4, 'stress': 6},
            ),
          ),
        ],
      ),
    ];

    for (int i = 0; i < spec.decisions.length; i++) {
      final DecisionBeatSpec d = spec.decisions[i];
      final bool last = i == spec.decisions.length - 1;
      final String fallbackNext =
          last ? nextAfterDecisions() : decisionIds[i + 1];
      final List<String> unlock = objectives.length > i + 1
          ? <String>[objectives[i + 1 > objectives.length - 1
              ? objectives.length - 1
              : i + 1].id]
          : (objectives.isNotEmpty
              ? <String>[objectives.last.id]
              : const <String>[]);

      beats.add(
        CareerBeat(
          id: decisionIds[i],
          kind: CareerBeatKind.decision,
          locationId: d.locationId ?? spec.startLocationId,
          npcId: d.npcId,
          title: d.title,
          body: d.body,
          choices: <CareerChoice>[
            for (final ChoiceSpec c in d.choices)
              CareerChoice(
                id: c.id,
                label: c.label,
                consequence: CareerConsequence(
                  narrative: c.narrative,
                  nextBeatId: c.failMission ? null : fallbackNext,
                  failMission: c.failMission,
                  completeMission: false,
                  unlockObjectives: c.unlockObjectives.isNotEmpty
                      ? c.unlockObjectives
                      : (c.failMission ? const <String>[] : unlock),
                  skillDeltas: c.skillDeltas.isNotEmpty
                      ? c.skillDeltas
                      : <String, int>{
                          spec.primarySkill: c.failMission ? -10 : 8,
                          spec.secondarySkill: c.failMission ? -4 : 4,
                        },
                  meterDeltas: c.meterDeltas.isNotEmpty
                      ? c.meterDeltas
                      : (c.failMission
                          ? const <String, int>{
                              'trust': -18,
                              'patient': -20,
                              'stress': 15,
                            }
                          : const <String, int>{
                              'trust': 6,
                              'patient': 8,
                              'stress': -4,
                            }),
                ),
              ),
          ],
        ),
      );
    }

    if (wantsFreeText) {
      final String afterFree = wantsPressure ? pressureId : endId;
      beats.add(
        CareerBeat(
          id: freeId,
          kind: CareerBeatKind.freeText,
          locationId: spec.startLocationId,
          title: 'Your response',
          body: spec.freeTextPrompt!,
          freeTextHint: spec.freeTextHint ?? 'Be clear, specific, and professional.',
          freeTextGoodKeywords: spec.freeTextKeywords.isNotEmpty
              ? spec.freeTextKeywords
              : const <String>['because', 'evidence', 'safe', 'plan', 'next'],
          freeTextGood: CareerConsequence(
            narrative: 'Your words land. Credibility rises.',
            nextBeatId: afterFree,
            skillDeltas: <String, int>{
              CareerSkillId.communication: 12,
              spec.primarySkill: 6,
            },
            meterDeltas: const <String, int>{'trust': 10, 'patient': 6},
            unlockObjectives: objectives.isNotEmpty
                ? <String>[objectives.last.id]
                : const <String>[],
          ),
          freeTextWeak: CareerConsequence(
            narrative: 'Vague. They ask you to be more precise.',
            nextBeatId: afterFree,
            skillDeltas: const <String, int>{
              CareerSkillId.communication: -4,
            },
            meterDeltas: const <String, int>{'trust': -4, 'stress': 6},
          ),
        ),
      );
    }

    if (wantsPressure) {
      final String afterPressure = wantsRandom ? randomId : endId;
      beats.add(
        CareerBeat(
          id: pressureId,
          kind: CareerBeatKind.timerPressure,
          locationId: spec.startLocationId,
          title: spec.pressureTitle ?? 'TIME PRESSURE',
          body: spec.pressureBody ??
              'The situation is deteriorating. Choose under pressure.',
          timerSeconds: spec.pressureSeconds,
          randomEventBeatIds:
              wantsRandom ? <String>[randomId] : const <String>[],
          choices: <CareerChoice>[
            CareerChoice(
              id: 'prioritize',
              label: 'Prioritize the highest-stakes issue first',
              consequence: CareerConsequence(
                narrative: 'Calm priority call. The team follows your lead.',
                nextBeatId: afterPressure,
                injectRandomEvent: wantsRandom,
                completeMission: !wantsRandom,
                skillDeltas: <String, int>{
                  CareerSkillId.criticalThinking: 12,
                  CareerSkillId.timeManagement: 10,
                  spec.primarySkill: 6,
                },
                meterDeltas: const <String, int>{
                  'patient': 10,
                  'trust': 8,
                  'stress': -6,
                  'time': -15,
                },
              ),
            ),
            CareerChoice(
              id: 'scatter',
              label: 'Try to fix everything at once',
              consequence: CareerConsequence(
                narrative: 'You scatter. Errors multiply. Stress spikes.',
                nextBeatId: afterPressure,
                injectRandomEvent: wantsRandom,
                completeMission: !wantsRandom,
                skillDeltas: <String, int>{
                  CareerSkillId.timeManagement: -8,
                  spec.primarySkill: -4,
                },
                meterDeltas: const <String, int>{
                  'patient': -8,
                  'trust': -6,
                  'stress': 14,
                  'time': -25,
                },
              ),
            ),
            CareerChoice(
              id: 'freeze',
              label: 'Freeze and wait for someone else',
              consequence: CareerConsequence(
                narrative: 'Hesitation costs outcomes. Leadership notices.',
                failMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: -12,
                  CareerSkillId.timeManagement: -10,
                },
                meterDeltas: const <String, int>{
                  'trust': -20,
                  'patient': -18,
                  'stress': 18,
                },
              ),
            ),
          ],
        ),
      );
    }

    if (wantsRandom) {
      beats.add(
        CareerBeat(
          id: randomId,
          kind: CareerBeatKind.randomEvent,
          locationId: spec.startLocationId,
          title: spec.randomEventTitle ?? 'UNEXPECTED DEVELOPMENT',
          body: spec.randomEventBody ??
              'A new complication appears. How do you respond?',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'adapt',
              label: 'Adapt the plan and communicate clearly',
              consequence: CareerConsequence(
                narrative: 'You adapt without losing the thread. Strong work.',
                nextBeatId: endId,
                completeMission: true,
                skillDeltas: <String, int>{
                  CareerSkillId.criticalThinking: 10,
                  CareerSkillId.communication: 8,
                  spec.primarySkill: 8,
                },
                meterDeltas: const <String, int>{
                  'patient': 12,
                  'trust': 10,
                  'stress': -8,
                },
              ),
            ),
            CareerChoice(
              id: 'ignore',
              label: 'Ignore it and stick rigidly to the old plan',
              consequence: CareerConsequence(
                narrative: 'The complication bites. Damage control begins.',
                nextBeatId: endId,
                completeMission: true,
                skillDeltas: <String, int>{
                  CareerSkillId.criticalThinking: -6,
                  spec.primarySkill: -4,
                },
                meterDeltas: const <String, int>{
                  'patient': -10,
                  'trust': -8,
                  'stress': 12,
                },
              ),
            ),
          ],
        ),
      );
    }

    // Winning path without pressure/random: last non-fail choice → free/end
    // Ensure missionEnd is reachable with completeMission on final approach.
    if (!wantsPressure && !wantsRandom) {
      // Patch: mark arriving at end via freeText or last decision with complete.
      // Add a final confirm beat that completes.
      final String confirmId = '${prefix}_confirm';
      final CareerBeat lastDecision = beats.firstWhere(
        (CareerBeat b) => b.id == decisionIds.last,
      );
      final int lastIdx = beats.indexOf(lastDecision);
      final List<CareerChoice> patched = <CareerChoice>[
        for (final CareerChoice c in lastDecision.choices)
          CareerChoice(
            id: c.id,
            label: c.label,
            consequence: CareerConsequence(
              narrative: c.consequence.narrative,
              nextBeatId: c.consequence.failMission
                  ? null
                  : (wantsFreeText ? freeId : confirmId),
              failMission: c.consequence.failMission,
              unlockObjectives: c.consequence.unlockObjectives,
              skillDeltas: c.consequence.skillDeltas,
              meterDeltas: c.consequence.meterDeltas,
            ),
          ),
      ];
      beats[lastIdx] = CareerBeat(
        id: lastDecision.id,
        kind: lastDecision.kind,
        title: lastDecision.title,
        body: lastDecision.body,
        locationId: lastDecision.locationId,
        npcId: lastDecision.npcId,
        choices: patched,
      );

      if (wantsFreeText) {
        final int ftIdx = beats.indexWhere((CareerBeat b) => b.id == freeId);
        if (ftIdx >= 0) {
          final CareerBeat ft = beats[ftIdx];
          beats[ftIdx] = CareerBeat(
            id: ft.id,
            kind: ft.kind,
            title: ft.title,
            body: ft.body,
            locationId: ft.locationId,
            freeTextHint: ft.freeTextHint,
            freeTextGoodKeywords: ft.freeTextGoodKeywords,
            freeTextGood: CareerConsequence(
              narrative: ft.freeTextGood?.narrative ?? 'Strong response.',
              nextBeatId: confirmId,
              skillDeltas: ft.freeTextGood?.skillDeltas ?? const <String, int>{},
              meterDeltas: ft.freeTextGood?.meterDeltas ?? const <String, int>{},
              unlockObjectives: ft.freeTextGood?.unlockObjectives ?? const <String>[],
            ),
            freeTextWeak: CareerConsequence(
              narrative: ft.freeTextWeak?.narrative ?? 'Weak response.',
              nextBeatId: confirmId,
              skillDeltas: ft.freeTextWeak?.skillDeltas ?? const <String, int>{},
              meterDeltas: ft.freeTextWeak?.meterDeltas ?? const <String, int>{},
            ),
          );
        }
      }

      beats.add(
        CareerBeat(
          id: confirmId,
          kind: CareerBeatKind.decision,
          locationId: spec.startLocationId,
          title: 'Close the loop',
          body: 'Document outcomes and confirm next steps with your lead.',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'close_well',
              label: 'Document clearly and hand off cleanly',
              consequence: CareerConsequence(
                narrative: 'Clean close. Mission objectives met.',
                nextBeatId: endId,
                completeMission: true,
                skillDeltas: <String, int>{
                  CareerSkillId.professionalism: 8,
                  spec.primarySkill: 6,
                },
                meterDeltas: const <String, int>{'trust': 8, 'patient': 6},
              ),
            ),
            CareerChoice(
              id: 'close_sloppy',
              label: 'Rush off without documenting',
              consequence: CareerConsequence(
                narrative: 'Sloppy handoff. Trust dips — but you scrape by.',
                nextBeatId: endId,
                completeMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: -6,
                },
                meterDeltas: const <String, int>{'trust': -8, 'stress': 6},
              ),
            ),
          ],
        ),
      );
    }

    beats.add(
      CareerBeat(
        id: endId,
        kind: CareerBeatKind.missionEnd,
        title: spec.endTitle,
        body: spec.endBody,
      ),
    );

    // For pressure/random path: ensure last decision doesn't orphan end.
    // Pressure/random already completeMission on winning choices.

    // If no freeText was requested but we want at least one freeText somewhere
    // for quality bar — missions without freeTextPrompt still ok if another
    // mission in the world has it. Specs should set freeText on ≥1 mission.

    return CareerMission(
      id: spec.id,
      index: spec.index,
      title: spec.title,
      brief: spec.brief,
      objective: spec.objective,
      mode: spec.mode,
      trackStage: spec.trackStage,
      difficultyStars: spec.difficultyStars,
      xpReward: spec.xpReward,
      requiredCareerLevel: spec.requiredCareerLevel,
      startBeatId: cinematicId,
      startLocationId: spec.startLocationId,
      badgeOnClear: spec.badgeOnClear,
      objectives: objectives,
      beats: beats,
    );
  }

  /// Quick good / ok / fail triad used by most worlds.
  static List<ChoiceSpec> triad({
    required String goodLabel,
    required String goodNarrative,
    required String okLabel,
    required String okNarrative,
    required String badLabel,
    required String badNarrative,
    String primarySkill = CareerSkillId.criticalThinking,
    String secondarySkill = CareerSkillId.communication,
    bool badFails = true,
  }) {
    return <ChoiceSpec>[
      ChoiceSpec(
        id: 'good',
        label: goodLabel,
        narrative: goodNarrative,
        skillDeltas: <String, int>{primarySkill: 10, secondarySkill: 6},
        meterDeltas: const <String, int>{
          'patient': 10,
          'trust': 8,
          'stress': -5,
        },
      ),
      ChoiceSpec(
        id: 'ok',
        label: okLabel,
        narrative: okNarrative,
        skillDeltas: <String, int>{primarySkill: 3, secondarySkill: 2},
        meterDeltas: const <String, int>{
          'patient': 2,
          'trust': 2,
          'stress': 4,
        },
      ),
      ChoiceSpec(
        id: 'bad',
        label: badLabel,
        narrative: badNarrative,
        failMission: badFails,
        skillDeltas: <String, int>{primarySkill: -12, secondarySkill: -6},
        meterDeltas: const <String, int>{
          'patient': -18,
          'trust': -16,
          'stress': 14,
        },
      ),
    ];
  }
}
