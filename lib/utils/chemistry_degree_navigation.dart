import 'package:flutter/material.dart';

import '../../models/chemistry_degree.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../screens/ai_tutor_screen.dart';
import '../../screens/chemistry/chemistry_equation_builder_screen.dart';
import '../../screens/chemistry/chemistry_lab_report_screen.dart';
import '../../screens/chemistry/chemistry_molecule_studio_screen.dart';
import '../../screens/chemistry/chemistry_periodic_table_screen.dart';
import '../../screens/chemistry/chemistry_practice_screen.dart';
import '../../screens/chemistry/chemistry_textbook_screen.dart';
import '../../screens/chemistry/chemistry_virtual_lab_screen.dart';
import '../../services/chemistry_progress_service.dart';
import '../../services/openai_service.dart';
import '../../widgets/chemistry/chem_activity_scope.dart';

Widget _chemRoute(BuildContext context, Widget child) =>
    ChemActivityScope.wrap(context, child);

Future<void> launchChemLessonActivity(
  BuildContext context,
  ChemistryLessonPath path,
  ChemLessonActivityKind kind,
  ChemistryProgressService progress,
  OpenAiService openAi,
) async {
  bool? finished;

  try {
    switch (kind) {
      case ChemLessonActivityKind.lecture:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => AiProfessorClassroomScreen(
              openAi: openAi,
              lessonId: path.lesson.id,
              lessonTitle: path.lesson.title,
              courseId: path.course.id,
              courseTitle: path.course.title,
              moduleTitle: path.module.title,
              faculty: 'chemistry',
              masteryHint: progress.lessonMastery(path.lesson.id) / 100.0,
            ),
          ),
        );
      case ChemLessonActivityKind.textbook:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryTextbookScreen(path: path),
            ),
          ),
        );
      case ChemLessonActivityKind.moleculeStudio:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryMoleculeStudioScreen(path: path),
            ),
          ),
        );
      case ChemLessonActivityKind.periodicTable:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryPeriodicTableScreen(path: path),
            ),
          ),
        );
      case ChemLessonActivityKind.virtualLab:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryVirtualLabScreen(path: path),
            ),
          ),
        );
      case ChemLessonActivityKind.equationBuilder:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryEquationBuilderScreen(path: path),
            ),
          ),
        );
      case ChemLessonActivityKind.labReport:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryLabReportScreen(path: path),
            ),
          ),
        );
      case ChemLessonActivityKind.aiTutor:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              AiTutorScreen(
                initialPrompt:
                    'Help me understand ${path.lesson.title} from ${path.course.title}. '
                    'Explain like a chemistry professor with electron movement and a lab example.',
                requireEngagedSession: true,
              ),
            ),
          ),
        );
      case ChemLessonActivityKind.quiz:
      case ChemLessonActivityKind.exam:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _chemRoute(
              context,
              ChemistryPracticeScreen(path: path, kind: kind),
            ),
          ),
        );
    }
  } catch (e, stack) {
    debugPrint('Chemistry activity launch failed ($kind): $e\n$stack');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${kind.label}. Please try again.')),
      );
    }
    return;
  }

  if (!context.mounted || finished != true) return;

  try {
    if (kind == ChemLessonActivityKind.exam) {
      await progress.markExamPassed(path.lesson.id);
    }
    await progress.completeActivity(path.lesson.id, kind);
  } catch (e) {
    debugPrint('Chemistry activity completion failed: $e');
  }
}

String badgeLabel(String badgeId) {
  return switch (badgeId) {
    'bonding_master' => 'Bonding Master',
    'chem_explorer' => 'Chemistry Explorer',
    'catalog_quarter' => '25% Explored',
    'catalog_half' => 'Half the Catalog',
    'degree_quarter' => '25% Explored',
    'degree_half' => 'Half the Catalog',
    _ when badgeId.endsWith('_master') => 'Lesson Master',
    _ => badgeId.replaceAll('_', ' '),
  };
}
