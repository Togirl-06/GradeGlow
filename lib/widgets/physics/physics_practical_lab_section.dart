import 'package:flutter/material.dart';

import '../../data/physics/physics_practical_lab_catalog.dart';
import '../../models/physics/physics_program.dart';
import '../../screens/physics/physics_routes.dart';
import '../../theme/physics_theme.dart';

/// Practical Lab block for Physics Faculty home — PhysicLab grid + Physics Lab course benefits.
class PhysicsPracticalLabSection extends StatelessWidget {
  const PhysicsPracticalLabSection({
    super.key,
    this.previewCount = 6,
    this.compact = false,
  });

  final int previewCount;
  final bool compact;

  void _openPractical(BuildContext context, PhysicsPracticalLab practical) {
    final PhysicsTrack? track = practical.track;
    final PhysicsCourse? course = practical.course;
    final PhysicsTopic? topic = practical.topic;
    if (track == null || course == null || topic == null) return;
    PhysicsRoutes.openSimulation(context, track: track, course: course, topic: topic);
  }

  void _openHub(BuildContext context) {
    PhysicsRoutes.openPracticalHub(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<PhysicsPracticalLab> preview = PhysicsPracticalLabCatalog.all.take(previewCount).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[PhysicsTheme.consoleBg, PhysicsTheme.consolePanel, Color(0xFF1E1B4B)],
        ),
        border: Border.all(color: PhysicsTheme.consoleAccent.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PhysicsTheme.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: PhysicsTheme.consoleAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PhysicsTheme.consoleAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        '🎓 PRACTICAL LAB',
                        style: TextStyle(
                          color: PhysicsTheme.consoleAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.science_rounded, color: PhysicsTheme.nebula.withValues(alpha: 0.9), size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose a Practical',
                  style: TextStyle(
                    color: PhysicsTheme.consoleText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  PhysicsPracticalLabCatalog.tagline,
                  style: TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PhysicsPracticalLabCatalog.benefits
                      .map(
                        (String b) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.check_circle_rounded, size: 14, color: PhysicsTheme.consoleGood),
                              const SizedBox(width: 6),
                              Text(
                                b,
                                style: const TextStyle(
                                  color: PhysicsTheme.consoleText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              PhysicsPracticalLabCatalog.intro,
              style: TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 12, height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: compact ? 2 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: compact ? 1.05 : 0.92,
              ),
              itemCount: preview.length,
              itemBuilder: (BuildContext context, int i) {
                return _PracticalTile(
                  practical: preview[i],
                  onTap: () => _openPractical(context, preview[i]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Material(
              color: PhysicsTheme.consoleAccent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _openHub(context),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.grid_view_rounded, color: Color(0xFF0F172A), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Explore all ${PhysicsPracticalLabCatalog.all.length} practicals',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F172A), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticalTile extends StatelessWidget {
  const _PracticalTile({required this.practical, required this.onTap});

  final PhysicsPracticalLab practical;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PhysicsTheme.consolePanel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PhysicsTheme.consoleBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                PhysicsTheme.consolePanel,
                PhysicsTheme.primary.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(practical.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Text(
                  practical.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PhysicsTheme.consoleText,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  practical.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 10, height: 1.3),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: PhysicsTheme.consoleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    practical.category,
                    style: const TextStyle(
                      color: PhysicsTheme.consoleAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
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
