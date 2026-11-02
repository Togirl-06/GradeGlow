import 'package:flutter/material.dart';

import '../../data/law/law_catalog.dart';
import '../../models/law/law_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'law_lesson_screen.dart';

class LawCourseScreen extends StatelessWidget {
  const LawCourseScreen({
    super.key,
    required this.specializationId,
    required this.courseId,
  });

  final String specializationId;
  final String courseId;

    @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.law(context);
    final LawSpecialization? spec = LawCatalog.byId(specializationId);
    final LawCourse? course = LawCatalog.courseById(specId: specializationId, courseId: courseId);
    if (spec == null || course == null) {
      return FacultyScaffold(palette: palette, title: 'Course', body: const Center(child: Text('Not found')));
    }

    return FacultyScaffold(
      palette: palette,
      title: course.title,
      subtitle: spec.name,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyHeroCard(
            palette: palette,
            title: course.title,
            tagline: LawCatalog.philosophy,
            body: course.blurb,
            stats: <String>['${course.lessons.length} lessons', 'Dispute-driven'],
          ),
          const SizedBox(height: 22),
          FacultySectionHeader(palette: palette, label: 'Lessons', icon: Icons.gavel_rounded),
          ...course.lessons.asMap().entries.map(
            (MapEntry<int, LawLesson> e) => FacultyNavCard(
              palette: palette,
              icon: Icons.balance_outlined,
              title: 'Chapter ${e.key + 1}: ${e.value.title}',
              subtitle: e.value.hook,
              detail: 'Q: ${e.value.question}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LawLessonScreen(
                    specializationId: specializationId,
                    courseId: courseId,
                    lessonId: e.value.id,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
