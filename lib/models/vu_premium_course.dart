import 'package:flutter/material.dart';

/// Unified Virtual University course experience models (premium classroom).

enum VuLessonItemKind {
  lesson,
  interactive,
  simulation,
  quiz,
  assignment,
  discussion,
  project,
}

class VuPremiumLessonItem {
  const VuPremiumLessonItem({
    required this.id,
    required this.title,
    required this.kind,
    this.subtitle = '',
    this.estimatedMinutes = 25,
    this.xpReward = 40,
  });

  final String id;
  final String title;
  final VuLessonItemKind kind;
  final String subtitle;
  final int estimatedMinutes;
  final int xpReward;

  IconData get icon => switch (kind) {
    VuLessonItemKind.lesson => Icons.play_circle_outline_rounded,
    VuLessonItemKind.interactive => Icons.touch_app_outlined,
    VuLessonItemKind.simulation => Icons.science_outlined,
    VuLessonItemKind.quiz => Icons.quiz_outlined,
    VuLessonItemKind.assignment => Icons.assignment_outlined,
    VuLessonItemKind.discussion => Icons.forum_outlined,
    VuLessonItemKind.project => Icons.architecture_outlined,
  };

  String get kindLabel => switch (kind) {
    VuLessonItemKind.lesson => 'Lesson',
    VuLessonItemKind.interactive => 'Interactive',
    VuLessonItemKind.simulation => 'Simulation',
    VuLessonItemKind.quiz => 'Quiz',
    VuLessonItemKind.assignment => 'Assignment',
    VuLessonItemKind.discussion => 'AI Discussion',
    VuLessonItemKind.project => 'Project',
  };
}

class VuPremiumModule {
  const VuPremiumModule({
    required this.id,
    required this.title,
    required this.items,
    this.subtitle = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final List<VuPremiumLessonItem> items;

  int get itemCount => items.length;
}

class VuCourseAnnouncement {
  const VuCourseAnnouncement({
    required this.title,
    required this.body,
    required this.postedAt,
  });

  final String title;
  final String body;
  final DateTime postedAt;
}

class VuCourseResource {
  const VuCourseResource({
    required this.title,
    required this.subtitle,
    this.icon = Icons.menu_book_outlined,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class VuCourseUpcoming {
  const VuCourseUpcoming({
    required this.title,
    required this.whenLabel,
    required this.kind,
  });

  final String title;
  final String whenLabel;
  final VuLessonItemKind kind;
}

/// Callbacks so the premium shell can open faculty-native experiences.
class VuPremiumCourseActions {
  const VuPremiumCourseActions({
    this.onOpenAiProfessor,
    this.onOpenInteractive,
    this.onOpenSimulation,
    this.onOpenPractice,
    this.onOpenQuiz,
    this.onOpenDiscussion,
  });

  final Future<void> Function(VuPremiumLessonItem item)? onOpenAiProfessor;
  final Future<void> Function(VuPremiumLessonItem item)? onOpenInteractive;
  final Future<void> Function(VuPremiumLessonItem item)? onOpenSimulation;
  final Future<void> Function(VuPremiumLessonItem item)? onOpenPractice;
  final Future<void> Function(VuPremiumLessonItem item)? onOpenQuiz;
  final Future<void> Function(VuPremiumLessonItem item)? onOpenDiscussion;
}

class VuPremiumCourse {
  const VuPremiumCourse({
    required this.id,
    required this.title,
    required this.facultyLabel,
    required this.description,
    required this.emoji,
    required this.professorName,
    required this.professorTitle,
    required this.modules,
    this.tagline = '',
    this.announcements = const <VuCourseAnnouncement>[],
    this.resources = const <VuCourseResource>[],
    this.upcoming = const <VuCourseUpcoming>[],
    this.accent,
    this.actions = const VuPremiumCourseActions(),
  });

  final String id;
  final String title;
  final String facultyLabel;
  final String description;
  final String tagline;
  final String emoji;
  final String professorName;
  final String professorTitle;
  final List<VuPremiumModule> modules;
  final List<VuCourseAnnouncement> announcements;
  final List<VuCourseResource> resources;
  final List<VuCourseUpcoming> upcoming;
  final Color? accent;
  final VuPremiumCourseActions actions;

  List<VuPremiumLessonItem> get allItems =>
      modules.expand((VuPremiumModule m) => m.items).toList();

  int get totalLessons => allItems.length;

  int get totalEstimatedMinutes =>
      allItems.fold<int>(0, (int a, VuPremiumLessonItem i) => a + i.estimatedMinutes);

  VuPremiumLessonItem? itemById(String id) {
    for (final VuPremiumLessonItem item in allItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  VuPremiumModule? moduleForItem(String itemId) {
    for (final VuPremiumModule m in modules) {
      if (m.items.any((VuPremiumLessonItem i) => i.id == itemId)) return m;
    }
    return null;
  }
}
