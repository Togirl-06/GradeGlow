import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';

/// Screen 14–15 — profile, résumé snapshot, career ladder.
class EngineeringProfileScreen extends StatelessWidget {
  const EngineeringProfileScreen({
    super.key,
    required this.progress,
    this.playerName,
  });

  final EngineeringCareerProgress progress;
  final String? playerName;

  @override
  Widget build(BuildContext context) {
    final EngineeringMajor major = EngineeringMajors.byId(progress.majorId);
    final String name = (playerName ?? 'Student').trim();
    final List<String> stages = <String>[
      'Engineering Student',
      'Intern',
      'Junior Engineer',
      'Mid-Level Engineer',
      'Senior Engineer',
      'Engineering Lead',
      'Specialist / Founder',
    ];

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Engineer profile',
        icon: Icons.badge_rounded,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EngCosmic.panelBox(radius: 18),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: EngCosmic.purple,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name.isEmpty ? 'Student Engineer' : name,
                          style: const TextStyle(
                            color: EngCosmic.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${major.title} · ${progress.stageLabel}',
                          style: const TextStyle(color: EngCosmic.mute),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Lv ${progress.level} · ${progress.xpIntoLevel}/${progress.xpToNextLevel} XP · Bank ${progress.balanceLabel}',
                          style: const TextStyle(
                            color: EngCosmic.electric,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _section(
              'Skills',
              progress.skills
                  .map(
                    (String s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(s,
                                style: const TextStyle(color: EngCosmic.ink)),
                          ),
                          EngCosmic.pill('Lv ${progress.skillLevels[s] ?? 1}'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            _section(
              'Career ladder',
              List<Widget>.generate(stages.length, (int i) {
                final int stageNum = i + 1;
                final bool current = progress.careerStage == stageNum ||
                    (progress.careerStage > 6 && i == stages.length - 1);
                final bool done = progress.careerStage > stageNum ||
                    (i < 6 && progress.careerStage > i + 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        done || current
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: current
                            ? EngCosmic.electric
                            : done
                                ? EngCosmic.success
                                : EngCosmic.mute,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stages[i],
                        style: TextStyle(
                          color: current ? EngCosmic.ink : EngCosmic.mute,
                          fontWeight:
                              current ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      if (current) ...<Widget>[
                        const SizedBox(width: 8),
                        EngCosmic.pill('Current'),
                      ],
                    ],
                  ),
                );
              }),
            ),
            _section(
              'In-game résumé',
              <Widget>[
                Text(
                  'Missions: ${progress.completedMissions.length} · '
                  'Interviews: ${progress.interviewHistory.length} · '
                  'Jobs held: ${progress.employedJobIds.length}',
                  style: const TextStyle(color: EngCosmic.mute, height: 1.4),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rewards unlock through verified activity — opening screens alone does not raise skills.',
                  style: TextStyle(color: EngCosmic.mute, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: progress.badges
                      .take(12)
                      .map((String b) => EngCosmic.pill(b.replaceAll('_', ' ')))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: EngCosmic.panelBox(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: EngCosmic.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
