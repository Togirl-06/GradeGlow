import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mathematics_degree.dart';
import '../../services/mathematics_progress_service.dart';
import '../../theme/mathematics_degree_theme.dart';
import '../../widgets/mathematics/mathematics_degree_widgets.dart';
import 'mathematics_lesson_hub_screen.dart';

class MathematicsModuleScreen extends StatelessWidget {
  const MathematicsModuleScreen({
    super.key,
    required this.year,
    required this.course,
    required this.module,
  });

  final MathematicsDegreeYear year;
  final MathematicsDegreeCourse course;
  final MathematicsDegreeModule module;

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);

    final MathematicsProgressService progress =
        context.watch<MathematicsProgressService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          module.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: module.lessons.length,
        itemBuilder: (BuildContext context, int index) {
          final MathematicsDegreeLesson lesson = module.lessons[index];
          final double mastery = progress.lessonMastery(lesson.id);
          final String readiness = progress.readinessLabel(
            MathematicsLessonPath(
              year: year,
              course: course,
              module: module,
              lesson: lesson,
            ),
          );
          final bool mastered = progress.isLessonMastered(lesson.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MathematicsLessonHubScreen(
                      path: MathematicsLessonPath(
                        year: year,
                        course: course,
                        module: module,
                        lesson: lesson,
                      ),
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: c.cardDecoration(borderColor: mastered
                        ? c.success.withValues(alpha: 0.5)
                        : null,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: mastered
                              ? c.success.withValues(alpha: 0.2)
                              : c.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: mastered
                                ? c.success
                                : c.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          mastered ? '✓' : '${index + 1}',
                          style: TextStyle(
                            color: mastered
                                ? c.success
                                : c.primaryLight,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              lesson.title,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            MathDegreeMasteryBar(mastery: mastery),
                            const SizedBox(height: 4),
                            Text(
                              '${mastery.round()}% · $readiness',
                              style: TextStyle(
                                color: c.textPrimary.withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: c.textPrimary.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
