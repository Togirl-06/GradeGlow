import '../../config/vu_schools_catalog.dart';

/// Shared Virtual University lesson journey.
enum VuV2LessonStep {
  moduleIntro,
  coreNotes,
  aiProfessor,
  interactivePractice,
  realWorldLab,
  knowledgeCheck,
  challengeMode,
  summarySheet,
}

/// Professor teaches → student uses it in lab → student proves it.
/// Practice-only schools skip the lecture and textbook.
abstract final class VuV2LessonFlowPlan {
  /// Steps shown inside the lesson hub (module intro opens from course home).
  static const List<VuV2LessonStep> hubSteps = <VuV2LessonStep>[
    VuV2LessonStep.coreNotes,
    VuV2LessonStep.aiProfessor,
    VuV2LessonStep.interactivePractice,
    VuV2LessonStep.realWorldLab,
    VuV2LessonStep.knowledgeCheck,
    VuV2LessonStep.challengeMode,
    VuV2LessonStep.summarySheet,
  ];

  /// Career & Life Skills: lab + workplace practice only.
  static const List<VuV2LessonStep> practiceOnlyHubSteps = <VuV2LessonStep>[
    VuV2LessonStep.realWorldLab,
    VuV2LessonStep.interactivePractice,
  ];

  /// A lecture is not mastery. Required: professor + knowledge check
  /// (+ professional lab when one exists for the topic).
  static const List<VuV2LessonStep> masteryCore = <VuV2LessonStep>[
    VuV2LessonStep.aiProfessor,
    VuV2LessonStep.knowledgeCheck,
  ];

  static bool isPracticeOnly(String? subjectId) =>
      subjectId != null && VuSchoolsCatalog.isPracticeOnly(subjectId);

  static List<VuV2LessonStep> hubStepsFor(String subjectId) {
    if (isPracticeOnly(subjectId)) {
      return List<VuV2LessonStep>.from(practiceOnlyHubSteps);
    }
    return List<VuV2LessonStep>.from(hubSteps);
  }

  static List<VuV2LessonStep> masterySteps({
    required bool requiresLab,
    String? subjectId,
  }) {
    if (isPracticeOnly(subjectId)) {
      return List<VuV2LessonStep>.from(practiceOnlyHubSteps);
    }
    if (!requiresLab) return List<VuV2LessonStep>.from(masteryCore);
    return <VuV2LessonStep>[
      VuV2LessonStep.aiProfessor,
      VuV2LessonStep.realWorldLab,
      VuV2LessonStep.knowledgeCheck,
    ];
  }

  /// Faculty flavor lives in note bodies + lab resolver.
  static List<VuV2LessonStep> forLesson({
    required String subjectId,
    required String topicTitle,
  }) {
    return hubStepsFor(subjectId);
  }

  static String label(VuV2LessonStep step, {String? subjectId}) {
    if (isPracticeOnly(subjectId)) {
      switch (step) {
        case VuV2LessonStep.realWorldLab:
          return 'Workplace lab';
        case VuV2LessonStep.interactivePractice:
          return 'Real-world practice';
        default:
          break;
      }
    }
    switch (step) {
      case VuV2LessonStep.moduleIntro:
        return 'Module intro';
      case VuV2LessonStep.coreNotes:
        return 'Lecture notes';
      case VuV2LessonStep.aiProfessor:
        return 'AI Professor';
      case VuV2LessonStep.interactivePractice:
        return 'Practice';
      case VuV2LessonStep.realWorldLab:
        return 'Professional lab';
      case VuV2LessonStep.knowledgeCheck:
        return 'Knowledge check';
      case VuV2LessonStep.challengeMode:
        return 'Harder scenario';
      case VuV2LessonStep.summarySheet:
        return 'Summary';
    }
  }

  static String subtitle(VuV2LessonStep step, {String? subjectId}) {
    if (isPracticeOnly(subjectId)) {
      switch (step) {
        case VuV2LessonStep.realWorldLab:
          return 'Mission · inspect the artifacts · decide · defend why';
        case VuV2LessonStep.interactivePractice:
          return 'The same skill on a live workplace floor';
        default:
          break;
      }
    }
    switch (step) {
      case VuV2LessonStep.moduleIntro:
        return 'Why this module matters';
      case VuV2LessonStep.coreNotes:
        return 'University notes generated from the lecture';
      case VuV2LessonStep.aiProfessor:
        return 'Professor teaches · visuals follow the speech';
      case VuV2LessonStep.interactivePractice:
        return 'Interactive drills and try-it practice';
      case VuV2LessonStep.realWorldLab:
        return 'Mission · investigate · decide · consequences';
      case VuV2LessonStep.knowledgeCheck:
        return 'Prove you can use it · pass ≥70%';
      case VuV2LessonStep.challengeMode:
        return 'Harder check · pass ≥85%';
      case VuV2LessonStep.summarySheet:
        return 'Cheat sheet, formulas, and final tips';
    }
  }

  static String emoji(VuV2LessonStep step) {
    switch (step) {
      case VuV2LessonStep.moduleIntro:
        return '🗺️';
      case VuV2LessonStep.coreNotes:
        return '📘';
      case VuV2LessonStep.aiProfessor:
        return '🎓';
      case VuV2LessonStep.interactivePractice:
        return '⚡';
      case VuV2LessonStep.realWorldLab:
        return '🔬';
      case VuV2LessonStep.knowledgeCheck:
        return '✅';
      case VuV2LessonStep.challengeMode:
        return '🏆';
      case VuV2LessonStep.summarySheet:
        return '📋';
    }
  }

  static int xpFor(VuV2LessonStep step) {
    switch (step) {
      case VuV2LessonStep.moduleIntro:
        return 5;
      case VuV2LessonStep.coreNotes:
        return 15;
      case VuV2LessonStep.aiProfessor:
        return 25;
      case VuV2LessonStep.interactivePractice:
        return 15;
      case VuV2LessonStep.realWorldLab:
        return 30;
      case VuV2LessonStep.knowledgeCheck:
        return 20;
      case VuV2LessonStep.challengeMode:
        return 35;
      case VuV2LessonStep.summarySheet:
        return 10;
    }
  }

  static String stepKey(VuV2LessonStep step) => step.name;

  static VuV2LessonStep? parseStep(String key) {
    for (final VuV2LessonStep s in VuV2LessonStep.values) {
      if (s.name == key) return s;
    }
    return null;
  }
}
