import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/vu_premium_course_adapters.dart';
import '../../models/world_curriculum_program.dart';
import '../../screens/membership_screen.dart';
import '../../services/subscription_service.dart';
import '../../utils/virtual_university_premium.dart';
import '../../widgets/virtual_university/vu_subject_layout.dart';
import '../virtual_university/course/vu_premium_course_screen.dart';

class WorldCurriculumCourseScreen extends StatelessWidget {
  const WorldCurriculumCourseScreen({
    super.key,
    required this.meta,
    required this.course,
    this.courseIndex = 0,
  });

  final WorldSubjectMeta meta;
  final WorldCourse course;
  final int courseIndex;

  Future<void> _openClassroom(BuildContext context) async {
    bool isPremium = false;
    try {
      isPremium = context.read<SubscriptionService>().isPremium;
    } catch (_) {}
    if (!VirtualUniversityPremium.canAccessCourse(
      isPremium: isPremium,
      courseTitle: course.title,
      courseIndex: courseIndex,
    )) {
      final bool? upgrade = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: const Text('Premium course'),
          content: Text(
            '${course.title} is part of the full ${meta.title} program. '
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
      return;
    }
    if (!context.mounted) return;
    final courseData = VuPremiumCourseAdapters.fromWorld(
      meta: meta,
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return VuSubjectPage(
      title: course.title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          VuSubjectHero(
            emoji: meta.emoji,
            title: course.title,
            subtitle: meta.title,
            footer: '${course.topics.length} topics · digital classroom',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openClassroom(context),
            icon: const Icon(Icons.school_rounded),
            label: const Text('Enter digital classroom'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Modules, AI Professor, practice, community, and achievements for ${meta.title}.',
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}
