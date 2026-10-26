import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';

/// Progress dashboard — XP, level, completions, badges, recommended next.
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final double xpFrac =
        (progress.xpIntoLevel / progress.xpToNextLevel).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'My Performance',
        icon: Icons.insights_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: progress,
            builder: (BuildContext context, _) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: MedCosmic.panelBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            MedCosmic.pill(
                              'Level ${progress.level}',
                              bg: MedCosmic.purple.withValues(alpha: 0.25),
                              icon: Icons.star_rounded,
                            ),
                            const Spacer(),
                            Text(
                              '${progress.xp} XP total',
                              style: const TextStyle(
                                color: MedCosmic.mute,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: xpFrac,
                            minHeight: 10,
                            backgroundColor: MedCosmic.stroke,
                            color: MedCosmic.clinical,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${progress.xpIntoLevel} / ${progress.xpToNextLevel} XP to next level',
                          style: const TextStyle(
                            color: MedCosmic.mute,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MedCosmic.clinical.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MedCosmic.clinical.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Recommended next',
                                style: TextStyle(
                                  color: MedCosmic.clinical,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                progress.recommendedNext ??
                                    'Explore the Medical Simulation Hub',
                                style: const TextStyle(
                                  color: MedCosmic.ink,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StatGrid(
                    scenarios: progress.completedScenarios.length,
                    skills: progress.completedSkills.length,
                    structures: progress.identifiedStructures.length,
                    badges: progress.badges.length,
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'Completed scenarios',
                    empty: 'No scenarios completed yet.',
                    children: progress.completedScenarios.isEmpty
                        ? null
                        : progress.completedScenarios.map((String id) {
                            final int? score = progress.scenarioScores[id];
                            return _Line(
                              label: id,
                              trailing: score != null ? 'Score $score' : null,
                              icon: Icons.assignment_turned_in_rounded,
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Completed skills',
                    empty: 'No skills completed yet.',
                    children: progress.completedSkills.isEmpty
                        ? null
                        : progress.completedSkills
                            .map(
                              (String id) => _Line(
                                label: id,
                                icon: Icons.handyman_rounded,
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Identified structures',
                    empty: 'Open Anatomy to identify structures.',
                    children: progress.identifiedStructures.isEmpty
                        ? null
                        : progress.identifiedStructures
                            .map(
                              (String id) => _Line(
                                label: id,
                                icon: Icons.accessibility_new_rounded,
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Badges',
                    empty: 'Earn badges by clearing high-score cases and skills.',
                    children: progress.badges.isEmpty
                        ? null
                        : progress.badges
                            .map(
                              (String id) => _Line(
                                label: id,
                                icon: Icons.military_tech_rounded,
                                accent: MedCosmic.gold,
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                    child: Text(
                      'Course focus: ${progress.program.title} · '
                      '${progress.program.facility}',
                      style: const TextStyle(
                        color: MedCosmic.mute,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.scenarios,
    required this.skills,
    required this.structures,
    required this.badges,
  });

  final int scenarios;
  final int skills;
  final int structures;
  final int badges;

  @override
  Widget build(BuildContext context) {
    final List<({String label, int value, Color color})> items =
        <({String label, int value, Color color})>[
      (label: 'Scenarios', value: scenarios, color: MedCosmic.clinical),
      (label: 'Skills', value: skills, color: MedCosmic.teal),
      (label: 'Structures', value: structures, color: MedCosmic.purple),
      (label: 'Badges', value: badges, color: MedCosmic.gold),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: items.map((({String label, int value, Color color}) e) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: MedCosmic.panelBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${e.value}',
                style: TextStyle(
                  color: e.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              Text(
                e.label,
                style: const TextStyle(
                  color: MedCosmic.mute,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.empty,
    required this.children,
  });

  final String title;
  final String empty;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: MedCosmic.panelBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: MedCosmic.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (children == null || children!.isEmpty)
            Text(
              empty,
              style: const TextStyle(color: MedCosmic.mute, fontSize: 13),
            )
          else
            ...children!,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.icon,
    this.trailing,
    this.accent,
  });

  final String label;
  final IconData icon;
  final String? trailing;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: accent ?? MedCosmic.clinical),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                color: MedCosmic.mute,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
