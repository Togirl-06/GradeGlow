import '../career_sim_models.dart';
import 'career_mission_builder.dart';

/// Compact seed for one of seven track missions.
class MissionSeed {
  const MissionSeed({
    required this.title,
    required this.brief,
    required this.objective,
    required this.startLocationId,
    required this.cinematicTitle,
    required this.cinematicBody,
    required this.supervisorLine,
    required this.decisionTitle,
    required this.decisionBody,
    required this.goodLabel,
    required this.goodNarrative,
    required this.okLabel,
    required this.okNarrative,
    required this.badLabel,
    required this.badNarrative,
    required this.endTitle,
    required this.endBody,
    this.decision2Title,
    this.decision2Body,
    this.good2Label,
    this.good2Narrative,
    this.ok2Label,
    this.ok2Narrative,
    this.bad2Label,
    this.bad2Narrative,
    this.freeTextPrompt,
    this.freeTextKeywords = const <String>[],
    this.freeTextHint,
    this.pressureTitle,
    this.pressureBody,
    this.randomEventTitle,
    this.randomEventBody,
    this.badgeOnClear,
    this.primarySkill = CareerSkillId.analysis,
    this.secondarySkill = CareerSkillId.communication,
    this.objectiveLabels = const <String>[
      'Assess the situation',
      'Choose the sound path',
      'Close cleanly',
    ],
  });

  final String title;
  final String brief;
  final String objective;
  final String startLocationId;
  final String cinematicTitle;
  final String cinematicBody;
  final String supervisorLine;
  final String decisionTitle;
  final String decisionBody;
  final String goodLabel;
  final String goodNarrative;
  final String okLabel;
  final String okNarrative;
  final String badLabel;
  final String badNarrative;
  final String? decision2Title;
  final String? decision2Body;
  final String? good2Label;
  final String? good2Narrative;
  final String? ok2Label;
  final String? ok2Narrative;
  final String? bad2Label;
  final String? bad2Narrative;
  final String? freeTextPrompt;
  final List<String> freeTextKeywords;
  final String? freeTextHint;
  final String? pressureTitle;
  final String? pressureBody;
  final String? randomEventTitle;
  final String? randomEventBody;
  final String? badgeOnClear;
  final String primarySkill;
  final String secondarySkill;
  final List<String> objectiveLabels;
  final String endTitle;
  final String endBody;
}

/// Builds a full [CareerWorld] from locations, NPCs, and 7 mission seeds.
abstract final class CareerWorldKit {
  static const List<CareerTrackStage> stages = <CareerTrackStage>[
    CareerTrackStage.training,
    CareerTrackStage.firstMission,
    CareerTrackStage.realScenarios,
    CareerTrackStage.advanced,
    CareerTrackStage.advanced,
    CareerTrackStage.crisis,
    CareerTrackStage.boss,
  ];

  static const List<CareerSimGameMode> modes = <CareerSimGameMode>[
    CareerSimGameMode.training,
    CareerSimGameMode.career,
    CareerSimGameMode.career,
    CareerSimGameMode.career,
    CareerSimGameMode.career,
    CareerSimGameMode.crisis,
    CareerSimGameMode.boss,
  ];

  static const List<int> stars = <int>[1, 2, 3, 4, 4, 5, 5];
  static const List<int> levels = <int>[1, 1, 2, 3, 4, 5, 6];
  static const List<int> xp = <int>[220, 300, 380, 450, 520, 650, 900];

  static CareerWorld build({
    required String id,
    required String name,
    required String workplace,
    required CareerRole role,
    required List<String> skillIds,
    required List<String> careerTitles,
    required List<CareerLocation> locations,
    required List<CareerNpc> npcs,
    required String supervisorNpcId,
    required String missionIdPrefix,
    required List<MissionSeed> seeds,
  }) {
    assert(seeds.length == 7, 'Every career world needs exactly 7 missions');
    final List<CareerMission> missions = <CareerMission>[
      for (int i = 0; i < 7; i++)
        _mission(
          index: i + 1,
          prefix: missionIdPrefix,
          supervisorNpcId: supervisorNpcId,
          seed: seeds[i],
        ),
    ];
    return CareerWorld(
      id: id,
      name: name,
      workplace: workplace,
      role: role,
      skillIds: skillIds,
      careerTitles: careerTitles,
      locations: locations,
      npcs: npcs,
      missions: missions,
    );
  }

  static CareerMission _mission({
    required int index,
    required String prefix,
    required String supervisorNpcId,
    required MissionSeed seed,
  }) {
    final List<DecisionBeatSpec> decisions = <DecisionBeatSpec>[
      DecisionBeatSpec(
        title: seed.decisionTitle,
        body: seed.decisionBody,
        locationId: seed.startLocationId,
        choices: CareerMissionBuilder.triad(
          goodLabel: seed.goodLabel,
          goodNarrative: seed.goodNarrative,
          okLabel: seed.okLabel,
          okNarrative: seed.okNarrative,
          badLabel: seed.badLabel,
          badNarrative: seed.badNarrative,
          primarySkill: seed.primarySkill,
          secondarySkill: seed.secondarySkill,
        ),
      ),
    ];
    if (seed.decision2Title != null &&
        seed.decision2Body != null &&
        seed.good2Label != null) {
      decisions.add(
        DecisionBeatSpec(
          title: seed.decision2Title!,
          body: seed.decision2Body!,
          locationId: seed.startLocationId,
          choices: CareerMissionBuilder.triad(
            goodLabel: seed.good2Label!,
            goodNarrative: seed.good2Narrative ?? 'Solid enough.',
            okLabel: seed.ok2Label ?? 'Take a middling compromise',
            okNarrative: seed.ok2Narrative ?? 'Partial progress.',
            badLabel: seed.bad2Label ?? 'Ignore the problem',
            badNarrative: seed.bad2Narrative ?? 'Situation collapses.',
            primarySkill: seed.primarySkill,
            secondarySkill: seed.secondarySkill,
          ),
        ),
      );
    }

    final CareerTrackStage stage = stages[index - 1];
    final bool crisisOrBoss =
        stage == CareerTrackStage.crisis || stage == CareerTrackStage.boss;

    return CareerMissionBuilder.build(
      MissionSpec(
        id: '${prefix}_m$index',
        index: index,
        title: seed.title,
        brief: seed.brief,
        objective: seed.objective,
        mode: modes[index - 1],
        trackStage: stage,
        difficultyStars: stars[index - 1],
        xpReward: xp[index - 1],
        requiredCareerLevel: levels[index - 1],
        startLocationId: seed.startLocationId,
        badgeOnClear: seed.badgeOnClear,
        objectiveLabels: seed.objectiveLabels,
        cinematicTitle: seed.cinematicTitle,
        cinematicBody: seed.cinematicBody,
        supervisorNpcId: supervisorNpcId,
        supervisorLine: seed.supervisorLine,
        decisions: decisions,
        freeTextPrompt: seed.freeTextPrompt,
        freeTextKeywords: seed.freeTextKeywords,
        freeTextHint: seed.freeTextHint,
        pressureTitle: seed.pressureTitle ??
            (crisisOrBoss ? 'TIME PRESSURE' : null),
        pressureBody: seed.pressureBody ??
            (crisisOrBoss
                ? 'The situation is deteriorating. Choose under pressure.'
                : null),
        randomEventTitle: seed.randomEventTitle ??
            (crisisOrBoss ? 'UNEXPECTED DEVELOPMENT' : null),
        randomEventBody: seed.randomEventBody ??
            (crisisOrBoss
                ? 'A new complication appears. Adapt carefully.'
                : null),
        endTitle: seed.endTitle,
        endBody: seed.endBody,
        primarySkill: seed.primarySkill,
        secondarySkill: seed.secondarySkill,
      ),
    );
  }
}
