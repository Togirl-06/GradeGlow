import 'package:flutter/material.dart';

import '../../models/mathematics_degree.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../screens/ai_tutor_screen.dart';
import '../../screens/mathematics/mathematics_practice_screen.dart';
import '../../services/mathematics_progress_service.dart';
import '../../services/openai_service.dart';
import '../../widgets/mathematics/math_activity_scope.dart';

Widget _mathRoute(BuildContext context, Widget child) =>
    MathActivityScope.wrap(context, child);

Future<void> launchMathLessonActivity(
  BuildContext context,
  MathematicsLessonPath path,
  MathLessonActivityKind kind,
  MathematicsProgressService progress,
  OpenAiService openAi,
) async {
  bool? finished;

  try {
    switch (kind) {
      case MathLessonActivityKind.lecture:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => AiProfessorClassroomScreen(
              openAi: openAi,
              lessonId: path.lesson.id,
              lessonTitle: path.lesson.title,
              courseId: path.course.id,
              courseTitle: path.course.title,
              moduleTitle: path.module.title,
              faculty: 'mathematics',
              masteryHint: progress.lessonMastery(path.lesson.id) / 100.0,
              onPractice: () async {
                await Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MathematicsPracticeScreen(
                      path: path,
                      kind: MathLessonActivityKind.quiz,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      case MathLessonActivityKind.aiTutor:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _mathRoute(
              context,
              AiTutorScreen(
                initialPrompt:
                    'Help me understand ${path.lesson.title} from ${path.course.title}. '
                    'Walk through one example step by step.',
                requireEngagedSession: true,
              ),
            ),
          ),
        );
      case MathLessonActivityKind.quiz:
      case MathLessonActivityKind.exam:
        finished = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext ctx) => _mathRoute(
              context,
              MathematicsPracticeScreen(
                path: path,
                kind: kind,
              ),
            ),
          ),
        );
      case MathLessonActivityKind.homework:
      case MathLessonActivityKind.interactiveLesson:
      case MathLessonActivityKind.guidedPractice:
      case MathLessonActivityKind.officeHours:
      case MathLessonActivityKind.virtualLab:
        return;
    }
  } catch (e, stack) {
    debugPrint('Math activity launch failed ($kind): $e\n$stack');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${kind.label}. Please try again.')),
      );
    }
    return;
  }

  if (!context.mounted || finished != true) return;

  try {
    if (kind == MathLessonActivityKind.exam) {
      await progress.markExamPassed(path.lesson.id);
    }
    await progress.completeActivity(path.lesson.id, kind);
  } catch (e) {
    debugPrint('Math activity completion failed: $e');
  }
}

String badgeLabel(String badgeId) {
  return switch (badgeId) {
    'limit_master' => 'Limit Master',
    'catalog_quarter' => '25% Explored',
    'catalog_half' => 'Half the Catalog',
    'math_explorer' => 'Full Catalog Explorer',
    'degree_quarter' => '25% Explored',
    'degree_half' => 'Half the Catalog',
    'math_graduate' => 'Full Catalog Explorer',
    _ when badgeId.endsWith('_master') => 'Lesson Master',
    _ => badgeId.replaceAll('_', ' '),
  };
}
