import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/physics_degree.dart';
import '../../services/physics_progress_service.dart';
import '../../theme/physics_degree_theme.dart';
import '../../utils/physics_degree_navigation.dart';
import '../../widgets/physics/physics_degree_widgets.dart';

/// Topic hub — lecture → simulation → quiz → report → formulas.
class PhysicsDegreeLessonHubScreen extends StatelessWidget {
  const PhysicsDegreeLessonHubScreen({super.key, required this.path});

  final PhysicsLessonPath path;

  static const List<PhysLessonActivityKind> _flow =
      PhysLessonActivityKind.activeLessonFlow;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);
    final PhysicsProgressService progress = context.watch<PhysicsProgressService>();
    final double mastery = progress.lessonMastery(path.topic.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          path.topic.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.45)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      path.track.emoji.isEmpty ? '⚛️' : path.track.emoji,
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
                            path.topic.title,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PhysDegreeProgressRing(
                      progress: mastery,
                      label: 'Mastery',
                      size: 64,
                      stroke: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  path.topic.summary,
                  style: TextStyle(
                    color: c.textPrimary.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                PhysDegreeMasteryBar(mastery: mastery),
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
                        border: Border.all(color: c.success.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Strong mastery — run the simulation or quiz →',
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
          const PhysDegreeSectionHeader(
            title: 'Lesson Activities',
            subtitle: 'Professor → 3D lab → quiz → report → formulas',
          ),
          ..._flow.map((PhysLessonActivityKind kind) {
            final bool complete = progress.isActivityComplete(path.topic.id, kind);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(
                kind: kind,
                complete: complete,
                onTap: () => launchPhysLessonActivity(context, path, kind, progress),
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

  final PhysLessonActivityKind kind;
  final bool complete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: c.cardDecoration(
            borderColor: complete
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
