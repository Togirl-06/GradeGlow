import 'package:flutter/material.dart';

import '../../data/physics/physics_catalog.dart';
import '../../models/physics/physics_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'physics_routes.dart';

/// One academic level — lists all courses in that level's track(s).
class PhysicsLevelScreen extends StatelessWidget {
  const PhysicsLevelScreen({super.key, required this.level});

  final PhysicsLevel level;

  static final FacultyPalette _p = FacultyPalette.physics();

  @override
  Widget build(BuildContext context) {
    final List<PhysicsTrack> tracks = PhysicsCatalog.tracksForLevel(level);
    if (tracks.isEmpty) {
      return FacultyScaffold(
        palette: _p,
        title: level.label,
        body: const Center(child: Text('No courses yet.')),
      );
    }

    return FacultyScaffold(
      palette: _p,
      title: level.label,
      subtitle: 'Physics · ${level.subtitle.split(',').first}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyInfoPanel(palette: _p, icon: Icons.auto_stories_outlined, text: level.subtitle),
          const SizedBox(height: 20),
          for (final PhysicsTrack track in tracks) ...<Widget>[
            if (tracks.length > 1) ...<Widget>[
              FacultySectionHeader(palette: _p, label: track.name, icon: Icons.hub_outlined),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(track.tagline, style: TextStyle(color: _p.textSecondary, fontSize: 13, height: 1.35)),
              ),
            ],
            ...track.courses.map(
              (PhysicsCourse course) => FacultyNavCard(
                palette: _p,
                icon: Icons.menu_book_rounded,
                title: course.title,
                subtitle: course.blurb,
                detail: '${course.topics.length} topics · full textbook depth',
                badge: 'Course',
                onTap: () => PhysicsRoutes.openCourse(
                  context,
                  trackId: track.id,
                  courseId: course.id,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
