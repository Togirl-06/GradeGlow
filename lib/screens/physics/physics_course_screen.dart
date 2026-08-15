import 'package:flutter/material.dart';

import '../../data/physics/physics_catalog.dart';
import '../../models/physics/physics_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'physics_routes.dart';

/// Course browser — every topic in the course, unlocked.
class PhysicsCourseScreen extends StatelessWidget {
  const PhysicsCourseScreen({
    super.key,
    required this.trackId,
    required this.courseId,
  });

  final String trackId;
  final String courseId;

  static final FacultyPalette _p = FacultyPalette.physics();

  @override
  Widget build(BuildContext context) {
    final PhysicsTrack? track = PhysicsCatalog.trackById(trackId);
    final PhysicsCourse? course = PhysicsCatalog.courseById(trackId: trackId, courseId: courseId);
    if (track == null || course == null) {
      return FacultyScaffold(
        palette: _p,
        title: 'Course',
        body: const Center(child: Text('Course not found.')),
      );
    }

    return FacultyScaffold(
      palette: _p,
      title: course.title,
      subtitle: track.level.label,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyHeroCard(
            palette: _p,
            title: course.title,
            tagline: track.level.label,
            body: course.blurb,
            stats: <String>['${course.topics.length} chapters', 'Read in order'],
          ),
          const SizedBox(height: 22),
          FacultySectionHeader(
            palette: _p,
            label: 'Topics · ${course.topics.length}',
            icon: Icons.playlist_play_rounded,
          ),
          ...course.topics.asMap().entries.map(
            (MapEntry<int, PhysicsTopic> e) => FacultyNavCard(
              palette: _p,
              icon: Icons.science_outlined,
              title: 'Chapter ${e.key + 1}: ${e.value.title}',
              subtitle: e.value.hook,
              badge: e.key == 0 ? 'Start' : null,
              onTap: () => PhysicsRoutes.openTopic(
                context,
                trackId: trackId,
                courseId: courseId,
                topicId: e.value.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
