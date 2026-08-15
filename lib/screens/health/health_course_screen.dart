import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/health_faculty_catalog.dart';
import '../../data/vu_premium_course_adapters.dart';
import '../../models/health_faculty_program.dart';
import '../../screens/membership_screen.dart';
import '../../services/health_faculty_progress_service.dart';
import '../../services/subscription_service.dart';
import '../../services/virtual_university_dashboard_service.dart';
import '../../utils/virtual_university_premium.dart';
import '../../widgets/virtual_university/vu_subject_layout.dart';
import '../virtual_university/course/vu_premium_course_screen.dart';
import 'health_lesson_hub_screen.dart';

class HealthCourseScreen extends StatelessWidget {
  const HealthCourseScreen({
    super.key,
    required this.faculty,
    required this.course,
    this.courseIndex = 0,
  });

  final HealthFaculty faculty;
  final HealthCourse course;
  final int courseIndex;

  Future<bool> _ensureAccess(BuildContext context) async {
    bool isPremium = false;
    try {
      isPremium = context.read<SubscriptionService>().isPremium;
    } catch (_) {
      isPremium = false;
    }
    if (VirtualUniversityPremium.canAccessCourse(
      isPremium: isPremium,
      courseTitle: course.title,
      courseIndex: courseIndex,
    )) {
      return true;
    }
    final bool? upgrade = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Premium course'),
        content: Text(
          '${course.title} is part of the full ${faculty.title} program. '
          'Free access includes your first course plus intro tracks. '
          'Upgrade for the full catalog.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('View plans'),
          ),
        ],
      ),
    );
    if (upgrade == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
      );
    }
    return false;
  }

  Future<void> _openPremiumClassroom(BuildContext context) async {
    if (!await _ensureAccess(context)) return;
    if (!context.mounted) return;
    VirtualUniversityDashboardService? dash;
    try {
      dash = context.read<VirtualUniversityDashboardService>();
    } catch (_) {}
    try {
      await dash?.recordContinue(
        subjectId: faculty.name,
        subjectName: faculty.title,
        courseTitle: course.title,
        lessonTitle: course.title,
        routeHint: 'health:${faculty.name}:${course.id}',
        progress: 0.1,
      );
    } catch (_) {}

    if (!context.mounted) return;
    final courseData = VuPremiumCourseAdapters.fromHealth(
      faculty: faculty,
      course: course,
      context: context,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuPremiumCourseScreen(course: courseData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    HealthFacultyProgressService? progress;
    try {
      progress = context.watch<HealthFacultyProgressService>();
    } catch (_) {
      progress = null;
    }

    final double courseMastery = progress == null || course.topics.isEmpty
        ? 0
        : course.topics
                  .map((HealthTopic t) => progress!.lessonProgress(t.id))
                  .reduce((double a, double b) => a + b) /
              course.topics.length;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return VuSubjectPage(
      title: course.title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          VuSubjectHero(
            emoji: faculty.emoji,
            title: course.title,
            subtitle: faculty.title,
            footer:
                '${(courseMastery * 100).round()}% mastery · ${course.topics.length} topics',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openPremiumClassroom(context),
            icon: const Icon(Icons.school_rounded),
            label: const Text('Enter digital classroom'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Modules, AI Professor, practice, quizzes, community, and achievements — built like a real university class.',
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Opens a health topic / course from a campus continue/search route hint.
Future<void> openHealthRouteHint(
  BuildContext context,
  String routeHint,
) async {
  final List<String> parts = routeHint.split(':');
  if (parts.length < 3 || parts.first != 'health') return;
  final HealthFaculty? faculty = HealthFaculty.fromId(parts[1]);
  if (faculty == null) return;
  final List<HealthCourse> courses = HealthFacultyCatalog.coursesFor(faculty);
  final int courseIndex = courses.indexWhere(
    (HealthCourse c) => c.id == parts[2],
  );
  if (courseIndex < 0) return;
  final HealthCourse course = courses[courseIndex];

  final HealthFacultyProgressService health = context
      .read<HealthFacultyProgressService>();

  if (parts.length >= 4) {
    HealthTopic? topic;
    for (final HealthTopic t in course.topics) {
      if (t.id == parts[3]) {
        topic = t;
        break;
      }
    }
    if (topic != null) {
      final HealthTopic opened = topic;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ChangeNotifierProvider<HealthFacultyProgressService>.value(
                value: health,
                child: HealthLessonHubScreen(
                  path: HealthLessonPath(
                    faculty: faculty,
                    course: course,
                    topic: opened,
                  ),
                ),
              ),
        ),
      );
      return;
    }
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ChangeNotifierProvider<HealthFacultyProgressService>.value(
            value: health,
            child: HealthCourseScreen(
              faculty: faculty,
              course: course,
              courseIndex: courseIndex,
            ),
          ),
    ),
  );
}
