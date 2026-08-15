import 'package:flutter/material.dart';

import '../../models/virtual_university_lesson_contract.dart';

/// Reusable lesson hub — title, progress header, and canonical activity tiles.
class VuLessonHubShell extends StatelessWidget {
  const VuLessonHubShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onOpen,
    this.activities = VirtualUniversityLessonContract.standard,
    this.completedActivityNames = const <String>{},
    this.certificateBadge,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<VuActivitySpec> activities;
  final Set<String> completedActivityNames;
  final void Function(VuCanonicalActivity activity) onOpen;

  /// Shown in the header when all required activities in [activities] are done.
  final Widget? certificateBadge;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<VuActivitySpec> required =
        activities.where((VuActivitySpec s) => s.isRequired).toList();
    final int doneCount = required
        .where(
          (VuActivitySpec s) =>
              completedActivityNames.contains(s.activity.name),
        )
        .length;
    final bool masteryReady =
        VirtualUniversityLessonContract.allRequiredComplete(
          activities: activities,
          completedActivityNames: completedActivityNames,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: scheme.surface,
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Required · $doneCount/${required.length} complete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              if (masteryReady && certificateBadge != null) ...<Widget>[
                const SizedBox(width: 12),
                certificateBadge!,
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Learning Workspaces',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Required activities unlock mastery. Supplemental tiles are optional study.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...activities.map((VuActivitySpec spec) {
          final bool done =
              completedActivityNames.contains(spec.activity.name);
          return _VuActivityTile(
            spec: spec,
            accent: accent,
            done: done,
            onTap: () => onOpen(spec.activity),
          );
        }),
      ],
    );
  }
}

class _VuActivityTile extends StatelessWidget {
  const _VuActivityTile({
    required this.spec,
    required this.accent,
    required this.done,
    required this.onTap,
  });

  final VuActivitySpec spec;
  final Color accent;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color borderColor = done
        ? Colors.green.withValues(alpha: 0.55)
        : accent.withValues(alpha: 0.35);
    final Color statusColor = done ? Colors.green : accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: scheme.surface,
              border: Border.all(color: borderColor),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: statusColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    spec.icon ?? Icons.circle_outlined,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        spec.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec.subtitle,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  spec.isSupplemental
                      ? 'Study'
                      : done
                      ? '✓ Done'
                      : 'Required',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
