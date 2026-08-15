import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/law/law_catalog.dart';
import '../../models/law/law_program.dart';
import '../../models/law_simulation.dart';
import '../../services/law_daily_case_scheduler.dart';
import '../../services/law_daily_progress_service.dart';
import '../../theme/faculty_palette.dart';
import '../../theme/law_theme.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'law_lesson_screen.dart';

class LawSpecializationScreen extends StatefulWidget {
  const LawSpecializationScreen({super.key, required this.specializationId});

  final String specializationId;

  @override
  State<LawSpecializationScreen> createState() => _LawSpecializationScreenState();
}

class _LawSpecializationScreenState extends State<LawSpecializationScreen> {
    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LawDailyProgressService.instance.ensureLoaded();
    });
  }

  Future<void> _openLesson(LawSpecialization spec, LawCourse course, LawLesson lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawLessonScreen(
          specializationId: spec.id,
          courseId: course.id,
          lessonId: lesson.id,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.law(context);
    final LawSpecialization? spec = LawCatalog.byId(widget.specializationId);
    if (spec == null) {
      return FacultyScaffold(palette: palette, title: 'Track', body: const Center(child: Text('Not found')));
    }

    final LawCaseFile? dailyCase = LawDailyCaseScheduler.caseForSpecialization(spec.id);
    final List<({LawCourse course, LawLesson lesson})> topics = <({LawCourse course, LawLesson lesson})>[
      for (final LawCourse c in spec.courses)
        for (final LawLesson l in c.lessons) (course: c, lesson: l),
    ];

    return Consumer<LawDailyProgressService>(
      builder: (BuildContext context, LawDailyProgressService progress, Widget? _) {
        final bool dailyDone = progress.isDailyCompleted(spec.id);

        return FacultyScaffold(
          palette: palette,
          title: spec.name,
          subtitle: 'Law School',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              FacultyTopicIntro(
                palette: palette,
                hook: spec.tagline,
                summary:
                    'Every topic starts with a dispute, then teaches through briefing, writing, and courtroom practice.',
              ),
              const SizedBox(height: 22),
              FacultySectionHeader(palette: palette, label: 'Topics · ${topics.length}', icon: Icons.list_alt_rounded),
              ...topics.map(
                (({LawCourse course, LawLesson lesson}) item) {
                  final bool isToday =
                      dailyCase != null && item.lesson.simulationCaseId == dailyCase.id;
                  return FacultyNavCard(
                    palette: palette,
                    icon: Icons.menu_book_outlined,
                    title: item.lesson.title,
                    subtitle: item.lesson.hook,
                    detail: item.course.title,
                    badge: isToday ? (dailyDone ? 'Done' : 'Daily') : null,
                    trailing: isToday && dailyDone
                        ? Icon(Icons.check_circle_rounded, color: LawTheme.success, size: 22)
                        : null,
                    onTap: () => _openLesson(spec, item.course, item.lesson),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
