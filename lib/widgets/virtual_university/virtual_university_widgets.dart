import 'package:flutter/material.dart';

import '../../config/virtual_university.dart';
import '../../models/practice_lab_subject.dart';
import '../../theme/study_theme.dart';
import '../../widgets/study_surface.dart';

/// Dashboard hero — primary entry to the Virtual University.
class VirtualUniversityHeroCard extends StatelessWidget {
  const VirtualUniversityHeroCard({super.key, required this.onEnter});

  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEnter,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: <Color>[StudyColors.primaryDark, StudyColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: StudyColors.primary.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '🌍 VIRTUAL UNIVERSITY',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  VirtualUniversity.heroHeadline,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  VirtualUniversity.heroSubhead,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 16),
                const LearningLoopStrip(light: true, compact: true),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onEnter,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Enter Virtual University', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Learn → Practice → Feedback → Master → Apply
class LearningLoopStrip extends StatelessWidget {
  const LearningLoopStrip({super.key, this.light = false, this.compact = false});

  final bool light;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color text = light ? Colors.white.withValues(alpha: 0.92) : StudyColors.textSecondary(Theme.of(context).brightness);
    final Color active = light ? Colors.white : StudyColors.primary;
    final double fontSize = compact ? 10 : 11;

    return Wrap(
      spacing: compact ? 4 : 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (int i = 0; i < VirtualUniversity.learningLoop.length; i++) ...<Widget>[
          Text(
            VirtualUniversity.learningLoop[i],
            style: TextStyle(color: active, fontWeight: FontWeight.w800, fontSize: fontSize),
          ),
          if (i < VirtualUniversity.learningLoop.length - 1)
            Icon(Icons.chevron_right_rounded, size: compact ? 14 : 16, color: text),
        ],
      ],
    );
  }
}

/// Old vs new education pattern.
class LearningPhilosophyCard extends StatelessWidget {
  const LearningPhilosophyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color muted = StudyColors.textSecondary(Theme.of(context).brightness);
    return StudySurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Not another flashcard app',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _PatternRow(label: 'Traditional', steps: VirtualUniversity.oldLearningPattern, muted: true),
          const SizedBox(height: 10),
          _PatternRow(label: 'GradeGlow', steps: VirtualUniversity.learningLoop, muted: false),
          const SizedBox(height: 10),
          Text(
            VirtualUniversity.mission,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.label, required this.steps, required this.muted});

  final String label;
  final List<String> steps;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Color color = muted ? StudyColors.textSecondary(Theme.of(context).brightness) : StudyColors.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: color)),
        ),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: <Widget>[
              for (int i = 0; i < steps.length; i++) ...<Widget>[
                Text(steps[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                if (i < steps.length - 1) Icon(Icons.arrow_forward_rounded, size: 12, color: color.withValues(alpha: 0.6)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal carousel of subject "worlds".
class SubjectWorldsCarousel extends StatelessWidget {
  const SubjectWorldsCarousel({super.key, required this.subjects, required this.onSubjectTap});

  final List<PracticeLabSubject> subjects;
  final ValueChanged<PracticeLabSubject> onSubjectTap;

  @override
  Widget build(BuildContext context) {
    final List<PracticeLabSubject> featured = <PracticeLabSubject>[];
    for (final String id in VirtualUniversity.featuredSubjectIds) {
      for (final PracticeLabSubject s in subjects) {
        if (s.id == id) {
          featured.add(s);
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'EXPLORE INTERACTIVE WORLDS',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.6),
        ),
        const SizedBox(height: 4),
        Text(
          'Every subject becomes a place to practice—not just read about.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final PracticeLabSubject subject = featured[index];
              final SubjectWorld world = VirtualUniversity.worldFor(subjectId: subject.id, groupId: subject.groupId);
              return _SubjectWorldTile(subject: subject, world: world, onTap: () => onSubjectTap(subject));
            },
          ),
        ),
      ],
    );
  }
}

class _SubjectWorldTile extends StatelessWidget {
  const _SubjectWorldTile({required this.subject, required this.world, required this.onTap});

  final PracticeLabSubject subject;
  final SubjectWorld world;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${world.emoji} ${subject.name}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact mission line for activity hubs.
class VirtualUniversityMissionBanner extends StatelessWidget {
  const VirtualUniversityMissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyColors.primaryTint(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            VirtualUniversity.tagline,
            style: TextStyle(color: StudyColors.primary, fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const LearningLoopStrip(compact: true),
        ],
      ),
    );
  }
}
