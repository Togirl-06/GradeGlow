import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chemistry_degree.dart';
import '../../services/chemistry_progress_service.dart';
import '../../services/openai_service.dart';
import '../../theme/chemistry_degree_theme.dart';
import '../../utils/chemistry_degree_navigation.dart';
import '../../widgets/chemistry/chemistry_degree_widgets.dart';

/// Lesson activities: lecture → AI tutor → quiz → exam.
class ChemistryLessonHubScreen extends StatelessWidget {
  const ChemistryLessonHubScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  static const List<ChemLessonActivityKind> _flow =
      ChemLessonActivityKind.activeLessonFlow;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    final ChemistryProgressService progress =
        context.watch<ChemistryProgressService>();
    final OpenAiService openAi = context.read<OpenAiService>();
    final double mastery = progress.lessonMastery(path.lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          path.lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.45),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(path.course.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            path.breadcrumb,
                            style: TextStyle(
                              color: c.textPrimary.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            path.lesson.title,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ChemDegreeProgressRing(
                      progress: mastery,
                      label: 'Mastery',
                      size: 64,
                      stroke: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ChemDegreeMasteryBar(mastery: mastery),
                const SizedBox(height: 8),
                Text(
                  progress.readinessLabel(path),
                  style: TextStyle(
                    color: c.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                if (mastery >= 70)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: c.success.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Strong mastery — try the virtual lab or exam →',
                        style: TextStyle(
                          color: c.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ChemDegreeSectionHeader(
            title: 'Lesson Activities',
            subtitle: 'Lecture → textbook → lab → tutor → quiz → exam',
          ),
          ..._flow.map((ChemLessonActivityKind kind) {
            final bool complete = progress.isActivityComplete(path.lesson.id, kind);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(
                kind: kind,
                complete: complete,
                onTap: () => launchChemLessonActivity(
                  context,
                  path,
                  kind,
                  progress,
                  openAi,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.kind,
    required this.complete,
    required this.onTap,
  });

  final ChemLessonActivityKind kind;
  final bool complete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: c.cardDecoration(borderColor: complete
                ? c.success.withValues(alpha: 0.45)
                : c.primary.withValues(alpha: 0.2),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Text(kind.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      kind.label,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      kind.subtitle,
                      style: TextStyle(
                        color: c.textPrimary.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (complete)
                Icon(Icons.check_circle_rounded, color: c.success)
              else
                Text(
                  '+${kind.masteryWeight * 2} XP',
                  style: TextStyle(
                    color: c.primary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: c.textPrimary.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


