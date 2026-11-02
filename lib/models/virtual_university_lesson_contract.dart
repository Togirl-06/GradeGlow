import 'package:flutter/material.dart';

/// Whether an activity counts toward mastery / certificate.
enum VuActivityRole { required, supplemental }

/// Canonical Virtual University lesson activities shared across faculties.
enum VuCanonicalActivity {
  /// Lecture + voice (AI Professor).
  aiProfessor,
  textbookNotes,
  interactiveOrVideo,
  practiceOrHomework,
  quizOrExam,
  discussionOrSummary,
}

/// Display + role metadata for one canonical activity tile.
class VuActivitySpec {
  const VuActivitySpec({
    required this.activity,
    required this.role,
    required this.label,
    required this.subtitle,
    this.icon,
  });

  final VuCanonicalActivity activity;
  final VuActivityRole role;
  final String label;
  final String subtitle;
  final IconData? icon;

  bool get isRequired => role == VuActivityRole.required;
  bool get isSupplemental => role == VuActivityRole.supplemental;
}

/// Shared lesson loop contract for every Virtual University faculty.
class VirtualUniversityLessonContract {
  VirtualUniversityLessonContract._();

  /// Full standard set — all six activities with plan roles.
  static const List<VuActivitySpec> standard = <VuActivitySpec>[
    VuActivitySpec(
      activity: VuCanonicalActivity.aiProfessor,
      role: VuActivityRole.required,
      label: 'AI Professor',
      subtitle: 'Lecture + voice · full explanation · Q&A',
      icon: Icons.school_outlined,
    ),
    VuActivitySpec(
      activity: VuCanonicalActivity.textbookNotes,
      role: VuActivityRole.supplemental,
      label: 'Textbook Notes',
      subtitle: 'Full chapter · study anytime · no mastery credit',
      icon: Icons.menu_book_outlined,
    ),
    VuActivitySpec(
      activity: VuCanonicalActivity.interactiveOrVideo,
      role: VuActivityRole.required,
      label: 'Interactive / Video',
      subtitle: 'Slides, video, or interactive workspace',
      icon: Icons.smart_display_outlined,
    ),
    VuActivitySpec(
      activity: VuCanonicalActivity.practiceOrHomework,
      role: VuActivityRole.required,
      label: 'Practice / Homework',
      subtitle: 'Progressive problems · detailed feedback',
      icon: Icons.edit_note_outlined,
    ),
    VuActivitySpec(
      activity: VuCanonicalActivity.quizOrExam,
      role: VuActivityRole.required,
      label: 'Quiz / Exam',
      subtitle: 'University-standard assessment',
      icon: Icons.quiz_outlined,
    ),
    VuActivitySpec(
      activity: VuCanonicalActivity.discussionOrSummary,
      role: VuActivityRole.supplemental,
      label: 'Discussion / Summary',
      subtitle: 'Recap · discussion · optional coaching',
      icon: Icons.forum_outlined,
    ),
  ];

  /// Activities that count toward mastery and certificate unlock.
  static List<VuActivitySpec> get required =>
      standard.where((VuActivitySpec s) => s.isRequired).toList(growable: false);

  /// Filter the standard set for faculties that lack interactive or discussion content.
  static List<VuActivitySpec> visibleFor({
    bool hasInteractive = true,
    bool hasDiscussion = false,
  }) {
    return standard.where((VuActivitySpec spec) {
      switch (spec.activity) {
        case VuCanonicalActivity.interactiveOrVideo:
          return hasInteractive;
        case VuCanonicalActivity.discussionOrSummary:
          return hasDiscussion;
        case VuCanonicalActivity.aiProfessor:
        case VuCanonicalActivity.textbookNotes:
        case VuCanonicalActivity.practiceOrHomework:
        case VuCanonicalActivity.quizOrExam:
          return true;
      }
    }).toList(growable: false);
  }

  /// True when every required activity in [activities] is in [completedActivityNames].
  static bool allRequiredComplete({
    required Iterable<VuActivitySpec> activities,
    required Set<String> completedActivityNames,
  }) {
    for (final VuActivitySpec spec in activities) {
      if (spec.isRequired &&
          !completedActivityNames.contains(spec.activity.name)) {
        return false;
      }
    }
    return true;
  }
}
