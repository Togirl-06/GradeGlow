/// Shared Career Simulation models — every profession world plugs into these.
library;

enum CareerSimGameMode { training, career, crisis, boss }

/// Universal Career Lab progression (every major).
enum CareerTrackStage {
  hub,
  training,
  firstMission,
  realScenarios,
  advanced,
  crisis,
  boss,
  mastery,
}

extension CareerTrackStageX on CareerTrackStage {
  String get label {
    switch (this) {
      case CareerTrackStage.hub:
        return 'Career Hub';
      case CareerTrackStage.training:
        return 'Training';
      case CareerTrackStage.firstMission:
        return 'First Mission';
      case CareerTrackStage.realScenarios:
        return 'Real Scenarios';
      case CareerTrackStage.advanced:
        return 'Advanced Missions';
      case CareerTrackStage.crisis:
        return 'Crisis Missions';
      case CareerTrackStage.boss:
        return 'Boss Mission';
      case CareerTrackStage.mastery:
        return 'Career Mastery';
    }
  }
}

enum CareerBeatKind {
  cinematic,
  dialogue,
  decision,
  freeText,
  tool,
  timerPressure,
  randomEvent,
  erChallenge,
  missionEnd,
}

/// Skill axes scored across Career Labs (nursing + universal fields).
abstract final class CareerSkillId {
  static const String criticalThinking = 'critical_thinking';
  static const String communication = 'communication';
  static const String patientCare = 'patient_care';
  static const String clinicalKnowledge = 'clinical_knowledge';
  static const String timeManagement = 'time_management';
  static const String professionalism = 'professionalism';

  // Cross-world skills
  static const String analysis = 'analysis';
  static const String investigation = 'investigation';
  static const String advocacy = 'advocacy';
  static const String diagnosis = 'diagnosis';
  static const String strategy = 'strategy';
  static const String risk = 'risk';
  static const String accuracy = 'accuracy';
  static const String creativity = 'creativity';
  static const String research = 'research';
  static const String experimentation = 'experimentation';
  static const String design = 'design';
  static const String modeling = 'modeling';
  static const String security = 'security';
  static const String ethics = 'ethics';

  static const List<String> nursingDefaults = <String>[
    criticalThinking,
    communication,
    patientCare,
    clinicalKnowledge,
    timeManagement,
    professionalism,
  ];

  /// Sensible defaults for non-nursing Career Worlds.
  static const List<String> universalDefaults = <String>[
    criticalThinking,
    communication,
    analysis,
    timeManagement,
    professionalism,
    ethics,
  ];

  static String label(String id) {
    switch (id) {
      case criticalThinking:
        return 'Critical Thinking';
      case communication:
        return 'Communication';
      case patientCare:
        return 'Patient Care';
      case clinicalKnowledge:
        return 'Clinical Knowledge';
      case timeManagement:
        return 'Time Management';
      case professionalism:
        return 'Professionalism';
      case analysis:
        return 'Analysis';
      case investigation:
        return 'Investigation';
      case advocacy:
        return 'Advocacy';
      case diagnosis:
        return 'Diagnosis';
      case strategy:
        return 'Strategy';
      case risk:
        return 'Risk Judgment';
      case accuracy:
        return 'Accuracy';
      case creativity:
        return 'Creativity';
      case research:
        return 'Research';
      case experimentation:
        return 'Experimentation';
      case design:
        return 'Design';
      case modeling:
        return 'Modeling';
      case security:
        return 'Security';
      case ethics:
        return 'Ethics';
      default:
        return id;
    }
  }
}

class CareerConsequence {
  const CareerConsequence({
    this.narrative = '',
    this.nextBeatId,
    this.meterDeltas = const <String, int>{},
    this.skillDeltas = const <String, int>{},
    this.failMission = false,
    this.completeMission = false,
    this.unlockObjectives = const <String>[],
    this.setFlags = const <String, String>{},
    this.injectRandomEvent = false,
  });

  final String narrative;
  final String? nextBeatId;
  final Map<String, int> meterDeltas;
  final Map<String, int> skillDeltas;
  final bool failMission;
  final bool completeMission;
  final List<String> unlockObjectives;
  final Map<String, String> setFlags;
  final bool injectRandomEvent;
}

class CareerChoice {
  const CareerChoice({
    required this.id,
    required this.label,
    required this.consequence,
  });

  final String id;
  final String label;
  final CareerConsequence consequence;
}

class CareerBeat {
  const CareerBeat({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.locationId,
    this.npcId,
    this.choices = const <CareerChoice>[],
    this.toolIds = const <String>[],
    this.timerSeconds,
    this.randomEventBeatIds = const <String>[],
    this.erCategory,
    this.freeTextHint,
    this.freeTextGoodKeywords = const <String>[],
    this.freeTextGood,
    this.freeTextWeak,
    this.nextBeatId,
    this.continueLabel = 'Continue',
  });

  final String id;
  final CareerBeatKind kind;
  final String title;
  final String body;
  final String? locationId;
  final String? npcId;
  final List<CareerChoice> choices;
  final List<String> toolIds;
  final int? timerSeconds;
  final List<String> randomEventBeatIds;
  final String? erCategory;
  final String? freeTextHint;
  final List<String> freeTextGoodKeywords;
  final CareerConsequence? freeTextGood;
  final CareerConsequence? freeTextWeak;
  final String? nextBeatId;
  final String continueLabel;
}

class CareerObjective {
  const CareerObjective({
    required this.id,
    required this.label,
    this.done = false,
  });

  final String id;
  final String label;
  final bool done;

  CareerObjective copyWith({bool? done}) =>
      CareerObjective(id: id, label: label, done: done ?? this.done);
}

class CareerMission {
  const CareerMission({
    required this.id,
    required this.index,
    required this.title,
    required this.brief,
    required this.objective,
    required this.mode,
    required this.difficultyStars,
    required this.xpReward,
    required this.requiredCareerLevel,
    required this.startBeatId,
    required this.startLocationId,
    required this.beats,
    this.trackStage = CareerTrackStage.realScenarios,
    this.objectives = const <CareerObjective>[],
    this.badgeOnClear,
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
  final String startBeatId;
  final String startLocationId;
  final List<CareerBeat> beats;
  final List<CareerObjective> objectives;
  final String? badgeOnClear;

  CareerBeat beat(String id) => beats.firstWhere(
        (CareerBeat b) => b.id == id,
        orElse: () => beats.first,
      );
}

class CareerLocation {
  const CareerLocation({
    required this.id,
    required this.name,
    required this.blurb,
    required this.icon,
    this.unlockCareerLevel = 1,
    this.lockedHint,
  });

  final String id;
  final String name;
  final String blurb;
  final String icon; // emoji / short glyph
  final int unlockCareerLevel;
  final String? lockedHint;
}

class CareerNpc {
  const CareerNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.personality,
    this.avatarGlyph = '👤',
  });

  final String id;
  final String name;
  final String role;
  final String personality;
  final String avatarGlyph;
}

class CareerRole {
  const CareerRole({
    required this.title,
    required this.shift,
    required this.supervisorName,
    required this.tagline,
  });

  final String title;
  final String shift;
  final String supervisorName;
  final String tagline;
}

class CareerWorld {
  const CareerWorld({
    required this.id,
    required this.name,
    required this.workplace,
    required this.role,
    required this.locations,
    required this.npcs,
    required this.missions,
    required this.skillIds,
    this.careerTitles = const <String>[],
  });

  final String id;
  final String name;
  final String workplace;
  final CareerRole role;
  final List<CareerLocation> locations;
  final List<CareerNpc> npcs;
  final List<CareerMission> missions;
  final List<String> skillIds;
  final List<String> careerTitles;

  CareerMission? missionById(String id) {
    for (final CareerMission m in missions) {
      if (m.id == id) return m;
    }
    return null;
  }

  CareerNpc? npcById(String? id) {
    if (id == null) return null;
    for (final CareerNpc n in npcs) {
      if (n.id == id) return n;
    }
    return null;
  }

  CareerLocation? locationById(String? id) {
    if (id == null) return null;
    for (final CareerLocation l in locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  String titleForLevel(int level) {
    if (careerTitles.isEmpty) return 'Level $level';
    final int i = (level - 1).clamp(0, careerTitles.length - 1);
    return careerTitles[i];
  }
}

class CareerPerformanceReport {
  const CareerPerformanceReport({
    required this.missionId,
    required this.missionTitle,
    required this.won,
    required this.overallStars,
    required this.skillScores,
    required this.supervisorFeedback,
    required this.nextChallenge,
    required this.xpEarned,
    required this.badgesEarned,
    required this.metersEnd,
  });

  final String missionId;
  final String missionTitle;
  final bool won;
  final double overallStars;
  final Map<String, int> skillScores;
  final String supervisorFeedback;
  final String nextChallenge;
  final int xpEarned;
  final List<String> badgesEarned;
  final Map<String, int> metersEnd;
}

/// Live session snapshot owned by [CareerSimEngine].
class CareerSimSessionState {
  CareerSimSessionState({
    required this.world,
    required this.mission,
    required this.beatId,
    required this.locationId,
    Map<String, int>? meters,
    Map<String, int>? skills,
    Map<String, String>? flags,
    List<CareerObjective>? objectives,
    List<String>? dialogueMemory,
    this.hintLevel = 1,
    this.timerRemaining,
    this.lastNarrative = '',
    this.finished = false,
    this.won = false,
  })  : meters = meters ??
            <String, int>{
              'patient': 70,
              'trust': 55,
              'stress': 25,
              'time': 100,
            },
        skills = skills ??
            <String, int>{
              for (final String s in world.skillIds) s: 50,
            },
        flags = flags ?? <String, String>{},
        objectives = objectives ??
            List<CareerObjective>.from(mission.objectives),
        dialogueMemory = dialogueMemory ?? <String>[];

  final CareerWorld world;
  final CareerMission mission;
  String beatId;
  String locationId;
  final Map<String, int> meters;
  final Map<String, int> skills;
  final Map<String, String> flags;
  List<CareerObjective> objectives;
  final List<String> dialogueMemory;
  int hintLevel;
  int? timerRemaining;
  String lastNarrative;
  bool finished;
  bool won;

  CareerBeat get beat => mission.beat(beatId);

  CareerSimSessionState copy() => CareerSimSessionState(
        world: world,
        mission: mission,
        beatId: beatId,
        locationId: locationId,
        meters: Map<String, int>.from(meters),
        skills: Map<String, int>.from(skills),
        flags: Map<String, String>.from(flags),
        objectives: List<CareerObjective>.from(objectives),
        dialogueMemory: List<String>.from(dialogueMemory),
        hintLevel: hintLevel,
        timerRemaining: timerRemaining,
        lastNarrative: lastNarrative,
        finished: finished,
        won: won,
      );
}
