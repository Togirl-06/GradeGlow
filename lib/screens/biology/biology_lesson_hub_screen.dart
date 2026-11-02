import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/biology_degree.dart';
import '../../models/virtual_university_lesson_contract.dart';
import '../../services/biology_progress_service.dart';
import '../../services/openai_service.dart';
import '../../theme/biology_degree_theme.dart';
import '../../utils/biology_degree_navigation.dart';
import '../../widgets/biology/biology_degree_widgets.dart';
import '../../widgets/virtual_university/vu_accessibility.dart';

/// Active-learning hub — each card opens a full scientific workspace.
class BiologyLessonHubScreen extends StatelessWidget {
  const BiologyLessonHubScreen({super.key, required this.path});

  final BiologyLessonPath path;

  static const List<BioLessonActivityKind> _flow =
      BioLessonActivityKind.activeLessonFlow;

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final BiologyProgressService progress = context
        .watch<BiologyProgressService>();
    final OpenAiService openAi = context.read<OpenAiService>();
    final double mastery = progress.lessonMastery(path.lesson.id);
    final int completed = _flow
        .where(
          (BioLessonActivityKind k) =>
              progress.isActivityComplete(path.lesson.id, k),
        )
        .length;

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
          VuSemanticSectionHeader(
            label: 'Virtual University lesson loop',
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    VirtualUniversityLessonContract.visibleFor(
                          hasInteractive: true,
                          hasDiscussion: false,
                        )
                        .map(
                          (VuActivitySpec s) => Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(s.icon, size: 16),
                            label: Text(
                              s.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: c.cardDecoration(
              borderColor: c.primary.withValues(alpha: 0.45),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      path.course.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
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
                    BioDegreeProgressRing(
                      progress: mastery,
                      label: 'Mastery',
                      size: 64,
                      stroke: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter each workspace like a real lab · $completed/${_flow.length} complete',
                  style: TextStyle(
                    color: c.textPrimary.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                BioDegreeMasteryBar(mastery: mastery),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const BioDegreeSectionHeader(
            title: 'Lesson Workspaces',
            subtitle:
                'Each activity is a full interactive experience — not a button to notes',
          ),
          ..._flow.map((BioLessonActivityKind kind) {
            final bool complete = progress.isActivityComplete(
              path.lesson.id,
              kind,
            );
            const bool locked = false;
            final double cardProgress = complete ? 100 : 45;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorkspaceCard(
                kind: kind,
                topic: path.lesson.title,
                complete: complete,
                locked: locked,
                progress: cardProgress,
                onTap: () => launchBioLessonActivity(
                  context,
                  path,
                  kind,
                  progress,
                  openAi,
                ),
                unlockHint: null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.kind,
    required this.topic,
    required this.complete,
    required this.locked,
    required this.progress,
    required this.onTap,
    this.unlockHint,
  });

  final BioLessonActivityKind kind;
  final String topic;
  final bool complete;
  final bool locked;
  final double progress;
  final VoidCallback? onTap;
  final String? unlockHint;

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final List<String> bullets = kind.workspaceBulletsFor(topic);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: c.cardDecoration(
            borderColor: complete
                ? c.success.withValues(alpha: 0.5)
                : locked
                ? c.border
                : c.primary.withValues(alpha: 0.35),
          ),
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: locked ? 0.72 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(kind.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        kind.shortTitle,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _StatusChip(complete: complete, locked: locked, colors: c),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  bullets.join(' • '),
                  style: TextStyle(
                    color: c.textPrimary.withValues(alpha: 0.72),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (progress / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: c.border.withValues(alpha: 0.45),
                    color: complete
                        ? c.success
                        : locked
                        ? c.textSecondary.withValues(alpha: 0.4)
                        : c.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text(
                      locked
                          ? (unlockHint ?? 'Locked')
                          : '${progress.round()}%',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      complete ? 'Completed' : '+${kind.xpReward} XP',
                      style: TextStyle(
                        color: complete ? c.success : c.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.complete,
    required this.locked,
    required this.colors,
  });

  final bool complete;
  final bool locked;
  final BiologyDegreeColors colors;

  @override
  Widget build(BuildContext context) {
    final String label = complete
        ? '✔ Complete'
        : locked
        ? '🔒 Locked'
        : '▶ Start';
    final Color color = complete
        ? colors.success
        : locked
        ? colors.textSecondary
        : colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}
