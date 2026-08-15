import 'package:flutter/material.dart';

import '../../data/physics/physics_formula_engine.dart';
import '../../data/physics/physics_catalog.dart';
import '../../data/physics/physics_topic_lab_engine.dart';
import '../../models/physics/physics_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'physics_routes.dart';

/// Topic hub — physics learning modes for one topic.
class PhysicsTopicScreen extends StatelessWidget {
  const PhysicsTopicScreen({
    super.key,
    required this.trackId,
    required this.courseId,
    required this.topicId,
  });

  final String trackId;
  final String courseId;
  final String topicId;

  static final FacultyPalette _p = FacultyPalette.physics();

  @override
  Widget build(BuildContext context) {
    final PhysicsTrack? track = PhysicsCatalog.trackById(trackId);
    final PhysicsCourse? course = PhysicsCatalog.courseById(trackId: trackId, courseId: courseId);
    final PhysicsTopic? topic = PhysicsCatalog.topicById(trackId: trackId, courseId: courseId, topicId: topicId);
    if (track == null || course == null || topic == null) {
      return FacultyScaffold(
        palette: _p,
        title: 'Topic',
        body: const Center(child: Text('Topic not found.')),
      );
    }

    return FacultyScaffold(
      palette: _p,
      title: topic.title,
      subtitle: course.title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyTopicIntro(
            palette: _p,
            hook: topic.hook,
            summary: topic.summary,
            concepts: topic.keyConcepts,
          ),
          const SizedBox(height: 22),
          FacultySectionHeader(palette: _p, label: 'Learning modes', icon: Icons.grid_view_rounded),
          ...PhysicsLearningMode.values.asMap().entries.map(
            (MapEntry<int, PhysicsLearningMode> e) {
              final PhysicsLearningMode mode = e.value;
              final PhysicsTopicLabProfile? labProfile =
                  mode == PhysicsLearningMode.experimentReport
                      ? PhysicsTopicLabEngine.profileFor(course: course, topic: topic)
                      : null;
              return FacultyModeCard(
                palette: _p,
                index: e.key + 1,
                icon: mode.icon,
                title: mode.label,
                subtitle: _modeSubtitle(mode, labProfile) ?? mode.subtitle,
                detail: _modeDetail(mode, course, topic, labProfile),
                onTap: () => _openMode(context, track: track, course: course, topic: topic, mode: mode),
              );
            },
          ),
        ],
      ),
    );
  }

  String? _modeSubtitle(PhysicsLearningMode mode, PhysicsTopicLabProfile? profile) {
    return switch (mode) {
      PhysicsLearningMode.experimentReport => profile?.report.title,
      _ => null,
    };
  }

  String _modeDetail(PhysicsLearningMode mode, PhysicsCourse course, PhysicsTopic topic, PhysicsTopicLabProfile? profile) {
    return switch (mode) {
      PhysicsLearningMode.lecture => 'Textbook chapter · voice · practice · mastery checklist',
      PhysicsLearningMode.virtualLab => 'Topic-specific 3D simulation',
      PhysicsLearningMode.quiz => '${course.quizTitle} · ${topic.title}',
      PhysicsLearningMode.experimentReport => profile == null
          ? 'Formal lab write-up with AI grading'
          : '${profile.report.title} · AI professor grading',
      PhysicsLearningMode.formulaNotebook => () {
          final int n = PhysicsFormulaEngine.formulasFor(courseId: course.id, topic: topic).length;
          final String preview = PhysicsFormulaEngine.formulaLines(courseId: course.id, topic: topic).take(2).join(' · ');
          return '$n formulas · $preview';
        }(),
    };
  }

  void _openMode(
    BuildContext context, {
    required PhysicsTrack track,
    required PhysicsCourse course,
    required PhysicsTopic topic,
    required PhysicsLearningMode mode,
  }) {
    PhysicsRoutes.openMode(
      context,
      track: track,
      course: course,
      topic: topic,
      mode: mode,
    );
  }
}
