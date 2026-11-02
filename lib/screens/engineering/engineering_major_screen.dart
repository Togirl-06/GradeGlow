import 'package:flutter/material.dart';

import '../../data/engineering/engineering_catalog.dart';
import '../../models/engineering/engineering_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'engineering_course_screen.dart';

/// One engineering major — courses and signature gameplay.
class EngineeringMajorScreen extends StatelessWidget {
  const EngineeringMajorScreen({super.key, required this.majorId});

  final String majorId;

    @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.engineering(context);
    final EngineeringMajor? major = EngineeringCatalog.majorById(majorId);
    if (major == null) {
      return FacultyScaffold(
        palette: palette,
        title: 'Major',
        body: const Center(child: Text('Major not found.')),
      );
    }

    return FacultyScaffold(
      palette: palette,
      title: major.name,
      subtitle: 'Engineering Faculty',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyHeroCard(
            palette: palette,
            title: major.name,
            body: major.tagline,
            stats: <String>['${major.courses.length} courses', ...major.gameplay.take(2)],
          ),
          const SizedBox(height: 18),
          FacultySectionHeader(palette: palette, label: 'Signature gameplay', icon: Icons.videogame_asset_outlined),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: major.gameplay.map((String g) => FacultyConceptChip(label: g, palette: palette)).toList(),
          ),
          const SizedBox(height: 22),
          FacultySectionHeader(palette: palette, label: 'Courses', icon: Icons.menu_book_outlined),
          ...major.courses.map(
            (EngineeringCourse course) => FacultyNavCard(
              palette: palette,
              icon: Icons.architecture_outlined,
              title: course.title,
              subtitle: course.blurb,
              detail: '${course.topics.length} topics · 6 learning modes',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EngineeringCourseScreen(majorId: major.id, courseId: course.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
