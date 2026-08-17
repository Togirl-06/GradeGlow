import '../../../data/university_learning_engine.dart';
import '../university_lab_result.dart';
import '../workplace_immersion.dart';

enum SimDomain {
  clinical,
  chemistry,
  physics,
  business,
  finance,
  accounting,
  marketing,
  law,
  engineering,
  computing,
  general,
}

enum SimStepKind { locate, measure, applyTool }

class SimMeter {
  const SimMeter({
    required this.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.warnBelow = 25,
    this.warnAbove = 90,
  });

  final String key;
  final String label;
  final double value;
  final String unit;
  final double warnBelow;
  final double warnAbove;

  SimMeter copyWith({double? value}) => SimMeter(
        key: key,
        label: label,
        value: (value ?? this.value).clamp(0, 100),
        unit: unit,
        warnBelow: warnBelow,
        warnAbove: warnAbove,
      );
}

class SimHotspot {
  const SimHotspot({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.correct,
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final bool correct;
}

class SimTool {
  const SimTool({
    required this.id,
    required this.label,
    required this.correct,
  });

  final String id;
  final String label;
  final bool correct;
}

class SimStep {
  const SimStep({
    required this.id,
    required this.phase,
    required this.objective,
    required this.kind,
    this.hotspots = const <SimHotspot>[],
    this.tools = const <SimTool>[],
    this.measureLabel = '',
    this.measureUnit = '',
    this.measureMin = 40,
    this.measureMax = 60,
    this.successMeter = '',
    this.successDelta = 12,
    this.failMeter = '',
    this.failDelta = -18,
    this.successLog = 'Action recorded.',
    this.failAlert = 'The situation deteriorated.',
    this.hint1 = 'Look at the primary finding, not the noise.',
    this.hint2 = 'Match the lecture concept to this station.',
    this.hint3 = 'Apply the procedure you were taught — in order.',
    this.solution = 'Complete the marked objective, then stabilize the board.',
  });

  final String id;
  final String phase;
  final String objective;
  final SimStepKind kind;
  final List<SimHotspot> hotspots;
  final List<SimTool> tools;
  final String measureLabel;
  final String measureUnit;
  final double measureMin;
  final double measureMax;
  final String successMeter;
  final double successDelta;
  final String failMeter;
  final double failDelta;
  final String successLog;
  final String failAlert;
  final String hint1;
  final String hint2;
  final String hint3;
  final String solution;
}

class SimBriefing {
  const SimBriefing({
    required this.labTitle,
    required this.courseLine,
    required this.role,
    required this.mission,
    required this.difficulty,
    required this.minutes,
    required this.equipment,
    required this.skills,
    required this.scenario,
    required this.domain,
    required this.workplace,
    required this.level,
    required this.steps,
    required this.meters,
    required this.boardTitle,
  });

  final String labTitle;
  final String courseLine;
  final String role;
  final String mission;
  final String difficulty;
  final int minutes;
  final List<String> equipment;
  final List<String> skills;
  final String scenario;
  final SimDomain domain;
  final WorkplaceKind workplace;
  final int level;
  final List<SimStep> steps;
  final List<SimMeter> meters;
  final String boardTitle;
}

class SimPlayState {
  SimPlayState({
    required this.briefing,
    required this.startedAt,
  })  : meters = List<SimMeter>.from(briefing.meters),
        log = <String>[briefing.scenario];

  final SimBriefing briefing;
  final DateTime startedAt;
  final List<SimMeter> meters;
  final List<String> log;
  int stepIndex = 0;
  int attemptsOnStep = 0;
  int hintsUsed = 0;
  int hintTier = 0;
  int correctActs = 0;
  int totalActs = 0;
  int mistakes = 0;
  String? alert;
  bool complete = false;

  SimStep get step => briefing.steps[stepIndex];

  double meter(String key) {
    for (final SimMeter m in meters) {
      if (m.key == key) return m.value;
    }
    return 50;
  }

  void bump(String key, double delta) {
    if (key.isEmpty) return;
    for (int i = 0; i < meters.length; i++) {
      if (meters[i].key == key) {
        meters[i] = meters[i].copyWith(value: meters[i].value + delta);
      }
    }
  }

  UniversityLabResult toResult() {
    final int elapsed = DateTime.now().difference(startedAt).inSeconds;
    final double acc =
        totalActs == 0 ? 0 : (correctActs / totalActs).clamp(0.0, 1.0);
    final double vitals = meters.fold<double>(0, (double s, SimMeter m) => s + m.value) /
        (meters.isEmpty ? 1 : meters.length) /
        100;
    final double procedure = (1 - (mistakes / (totalActs + 1))).clamp(0.0, 1.0);
    final double thinking = (acc * 0.55 + vitals * 0.25 + procedure * 0.20)
        .clamp(0.0, 1.0);
    final bool passed = thinking >= 0.62 && mistakes < 5;
    return UniversityLabResult(
      accuracy: acc,
      identifyCorrect: correctActs,
      identifyAttempts: totalActs,
      viewsVisited: briefing.steps.length,
      labelDrillComplete: complete,
      coachingNotes: debriefNotes(thinking),
      xpEarned: passed
          ? 120 + (thinking * 80).round()
          : 40 + (thinking * 40).round(),
      secondsElapsed: elapsed,
      clinicalSolved: passed,
      clinicalReasoningScore: thinking,
      hintsUsed: hintsUsed,
      recommendedReview: briefing.courseLine,
    );
  }

  List<String> debriefNotes(double thinking) {
    final String well = mistakes <= 1
        ? 'You kept the board stable and sequenced the procedure correctly.'
        : correctActs >= (briefing.steps.length / 2)
            ? 'You identified the primary issue even after the situation shifted.'
            : 'You stayed in the scenario; recover by repeating the lecture procedure.';
    final String struggle = mistakes == 0
        ? 'Watch time. Efficient practitioners still re-check the primary signal.'
        : 'You reacted to noise before locking the primary finding.';
    return <String>[
      well,
      struggle,
      'Review: ${briefing.courseLine}.',
      thinking >= 0.8
          ? 'Your sequencing is close to professional standard for this level.'
          : 'Prioritize the life/system-critical meter before secondary tasks.',
    ];
  }
}

class UniversitySimLevels {
  static int fromLessonCount(int completed) =>
      (1 + completed ~/ 2).clamp(1, 5);

  static String label(int level) {
    switch (level) {
      case 1:
        return 'Level 1 · Guided';
      case 2:
        return 'Level 2 · Assisted';
      case 3:
        return 'Level 3 · Independent';
      case 4:
        return 'Level 4 · Realistic scenario';
      default:
        return 'Level 5 · Professional simulation';
    }
  }

  static String difficulty(int level) {
    switch (level) {
      case 1:
        return 'Guided';
      case 2:
        return 'Assisted';
      case 3:
        return 'Independent';
      case 4:
        return 'Realistic';
      default:
        return 'Professional';
    }
  }

  static int minutes(UniversityLabLink link, int level) =>
      (link.estimatedMinutes + (level - 2) * 6).clamp(18, 55);
}
