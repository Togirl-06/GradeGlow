import 'package:flutter/material.dart';

import '../../data/engineering/engineering_catalog.dart';
import '../../models/engineering/engineering_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'engineering_capstone_screen.dart';
import 'engineering_design_review_screen.dart';
import 'engineering_lecture_screen.dart';
import 'engineering_workspace_screen.dart';

/// Course hub — the six engineering learning modes.
class EngineeringCourseScreen extends StatelessWidget {
  const EngineeringCourseScreen({
    super.key,
    required this.majorId,
    required this.courseId,
  });

  final String majorId;
  final String courseId;

    @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.engineering(context);
    final EngineeringMajor? major = EngineeringCatalog.majorById(majorId);
    final EngineeringCourse? course = EngineeringCatalog.courseById(majorId: majorId, courseId: courseId);
    if (major == null || course == null) {
      return FacultyScaffold(
        palette: palette,
        title: 'Course',
        body: const Center(child: Text('Course not found.')),
      );
    }

    return FacultyScaffold(
      palette: palette,
      title: course.title,
      subtitle: major.name,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyTopicIntro(
            palette: palette,
            hook: EngineeringCatalog.philosophy,
            summary: course.blurb,
            concepts: course.topics,
          ),
          const SizedBox(height: 14),
          FacultyInfoPanel(
            palette: palette,
            icon: Icons.lightbulb_outline,
            text:
                'Beginner path: open AI Professor first, then Interactive Concepts. '
                'In the lab/simulator, change one slider at a time and try to reach GOOD status — then break it on purpose and recover.',
          ),
          const SizedBox(height: 22),
          FacultySectionHeader(palette: palette, label: 'Learning modes', icon: Icons.grid_view_rounded),
          ...EngineeringLearningMode.values.asMap().entries.map(
            (MapEntry<int, EngineeringLearningMode> e) {
              final EngineeringLearningMode mode = e.value;
              return FacultyModeCard(
                palette: palette,
                index: e.key + 1,
                icon: mode.icon,
                title: mode.label,
                subtitle: mode.subtitle,
                detail: '${mode.philosophyStep} · ${switch (mode) {
                  EngineeringLearningMode.lecture => 'Start with ${course.topics.first}',
                  EngineeringLearningMode.concepts => '${course.conceptControls.length} live controls',
                  EngineeringLearningMode.virtualLab => course.labTitle,
                  EngineeringLearningMode.simulator => course.simulatorTitle,
                  EngineeringLearningMode.designReview => 'Submit notes for senior review',
                  EngineeringLearningMode.capstone => course.capstoneTitle,
                }}',
                onTap: () => _openMode(context, major: major, course: course, mode: mode),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openMode(
    BuildContext context, {
    required EngineeringMajor major,
    required EngineeringCourse course,
    required EngineeringLearningMode mode,
  }) {
    final Widget screen = switch (mode) {
      EngineeringLearningMode.lecture => EngineeringLectureScreen(
          major: major,
          course: course,
          topicTitle: course.topics.first,
        ),
      EngineeringLearningMode.concepts => EngineeringWorkspaceScreen(
          major: major,
          course: course,
          mode: EngineeringLearningMode.concepts,
        ),
      EngineeringLearningMode.virtualLab => EngineeringWorkspaceScreen(
          major: major,
          course: course,
          mode: EngineeringLearningMode.virtualLab,
        ),
      EngineeringLearningMode.simulator => EngineeringWorkspaceScreen(
          major: major,
          course: course,
          mode: EngineeringLearningMode.simulator,
        ),
      EngineeringLearningMode.designReview => EngineeringDesignReviewScreen(major: major, course: course),
      EngineeringLearningMode.capstone => EngineeringCapstoneScreen(major: major, course: course),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
