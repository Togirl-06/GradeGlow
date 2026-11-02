import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_lesson_learn_hub_screen.dart';

/// Module intro — why the topic matters before entering lessons.
class VuV2ModuleIntroScreen extends StatelessWidget {
  const VuV2ModuleIntroScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
    required this.module,
    required this.courseLessonIds,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;
  final VuV2RoadmapModule module;
  final List<String> courseLessonIds;

  @override
  Widget build(BuildContext context) {
    final String why = module.whyItMatters ??
        'This module builds a university-level foundation for **${module.title}** '
            'inside ${course.title}. Mastery here unlocks later lessons and real '
            'workplace scenarios in $facultyTitle.';
    final String apps = module.realWorldApplications ??
        'Graduates use these ideas in clinics, courtrooms, labs, startups, and '
            'engineering floors — anywhere $facultyTitle professionals make decisions '
            'under pressure.';
    final List<String> industries = module.industries.isNotEmpty
        ? module.industries
        : <String>[
            facultyTitle,
            'Internships & residencies',
            'Research & graduate study',
          ];

    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            '$facultyEmoji  $facultyTitle · $trackTitle',
            style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
          ),
          const SizedBox(height: 12),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'MODULE INTRO',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  module.title,
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${module.lessonCount} lessons · ${course.title}',
                  style: TextStyle(color: VuV2Colors.mute),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const VuV2SectionTitle('Why this topic matters'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Text(
              why.replaceAll('**', ''),
              style: TextStyle(color: VuV2Colors.ink, height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          const VuV2SectionTitle('Real-world applications'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Text(
              apps,
              style: TextStyle(color: VuV2Colors.ink, height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          const VuV2SectionTitle('Industries'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: industries
                .map(
                  (String i) => Chip(
                    label: Text(i),
                    backgroundColor: VuV2Colors.navyElevated,
                    side: BorderSide(color: VuV2Colors.stroke),
                    labelStyle: TextStyle(color: VuV2Colors.ink),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          VuV2PrimaryButton(
            label: module.lessons.isEmpty
                ? 'No lessons yet'
                : 'Start first lesson',
            icon: Icons.play_arrow_rounded,
            onPressed: module.lessons.isEmpty
                ? null
                : () {
                    final VuV2RoadmapLesson first = module.lessons.first;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2LessonLearnHubScreen(
                          session: session,
                          progress: progress,
                          subjectId: subjectId,
                          facultyTitle: facultyTitle,
                          facultyEmoji: facultyEmoji,
                          trackTitle: trackTitle,
                          courseTitle: course.title,
                          lesson: first,
                          courseLessonIds: courseLessonIds,
                        ),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to course'),
          ),
        ],
      ),
    );
  }
}
