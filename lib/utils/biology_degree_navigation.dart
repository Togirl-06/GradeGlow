import 'package:flutter/material.dart';

import '../../models/biology_degree.dart';
import '../../screens/ai_tutor_screen.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../screens/biology/biology_animation_screen.dart';
import '../../screens/biology/biology_case_studies_screen.dart';
import '../../screens/biology/biology_dissection_screen.dart';
import '../../screens/biology/biology_interactive_activity_screen.dart';
import '../../screens/biology/biology_lab_report_screen.dart';
import '../../screens/biology/biology_microscope_screen.dart';
import '../../screens/biology/biology_model_studio_screen.dart';
import '../../screens/biology/biology_notebook_screen.dart';
import '../../screens/biology/biology_practice_screen.dart';
import '../../screens/biology/biology_reflection_screen.dart';
import '../../screens/biology/biology_virtual_lab_screen.dart';
import '../../services/biology_progress_service.dart';
import '../../services/openai_service.dart';
import '../../widgets/biology/bio_activity_scope.dart';

Widget _bioRoute(BuildContext context, Widget child) =>
    BioActivityScope.wrap(context, child);

Future<void> launchBioLessonActivity(
  BuildContext context,
  BiologyLessonPath path,
  BioLessonActivityKind kind,
  BiologyProgressService progress,
  OpenAiService openAi,
) async {
  bool? finished;

  try {
    switch (kind) {
      case BioLessonActivityKind.lecture:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => AiProfessorClassroomScreen(
              openAi: openAi,
              lessonId: path.lesson.id,
              lessonTitle: path.lesson.title,
              courseId: path.course.id,
              courseTitle: path.course.title,
              moduleTitle: path.module.title,
              faculty: 'biology',
              masteryHint: progress.lessonMastery(path.lesson.id) / 100.0,
            ),
          ),
        );
      case BioLessonActivityKind.interactive:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyInteractiveActivityScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.model3d:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyModelStudioScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.virtualLab:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyVirtualLabScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.practice:
      case BioLessonActivityKind.exam:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(
              context,
              BiologyPracticeScreen(path: path, kind: kind),
            ),
          ),
        );
      case BioLessonActivityKind.caseStudies:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyCaseStudiesScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.aiTutor:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(
              context,
              AiTutorScreen(
                initialPrompt:
                    'Discuss ${path.lesson.title} from ${path.course.title} with me. '
                    'Answer naturally with explanations, ask follow-ups, and connect to lab or clinical examples.',
                requireEngagedSession: true,
              ),
            ),
          ),
        );
      case BioLessonActivityKind.reflection:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyReflectionScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.microscope:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyMicroscopeScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.dissection:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyDissectionScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.animation:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyAnimationScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.notebook:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyNotebookScreen(path: path)),
          ),
        );
      case BioLessonActivityKind.labReport:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _bioRoute(context, BiologyLabReportScreen(path: path)),
          ),
        );
    }
  } catch (e, stack) {
    debugPrint('Biology activity launch failed ($kind): $e\n$stack');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${kind.label}. Please try again.')),
      );
    }
    return;
  }

  if (!context.mounted || finished != true) return;

  try {
    if (kind == BioLessonActivityKind.exam) {
      await progress.markExamPassed(path.lesson.id);
    }
    await progress.completeActivity(path.lesson.id, kind);
  } catch (e) {
    debugPrint('Biology activity completion failed: $e');
  }
}

String biologyBadgeLabel(String badgeId) {
  return switch (badgeId) {
    'membrane_master' => 'Membrane Master',
    'bio_explorer' => 'Biology Explorer',
    'bio_catalog_quarter' => '25% Explored',
    'bio_catalog_half' => 'Half the Catalog',
    _ when badgeId.endsWith('_master') => 'Lesson Master',
    _ => badgeId.replaceAll('_', ' '),
  };
}
