import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'mission_briefing_screen.dart';
import 'robotic_arm_mission_screen.dart';

/// Screen 16 — Innovation Garage / longer projects.
class EngineeringProjectLabScreen extends StatelessWidget {
  const EngineeringProjectLabScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final EngineeringMajor major = EngineeringMajors.byId(progress.majorId);
    final bool armDone =
        progress.isMissionComplete(EngMissionCatalog.roboticArm.id);
    final double armPct = armDone
        ? 1.0
        : progress.activeMissionId == EngMissionCatalog.roboticArm.id
            ? 0.35 + progress.activeMissionStep * 0.15
            : 0.0;

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Innovation Garage',
        icon: Icons.science_rounded,
        subtitle: major.title,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EngCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Longer projects · portfolio milestones',
                    style: TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Projects combine Design Studio, Simulation Lab, and sign-off. '
                    'Completed work appears on your in-game résumé.',
                    style: TextStyle(color: EngCosmic.mute, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _ProjectCard(
              title: 'Robotic arm torque package',
              blurb:
                  'Client brief → hand calc → design → simulate → engineering sign-off.',
              progress: armPct.clamp(0.0, 1.0),
              milestones: <String>[
                'Research & brief',
                'Hand calculation',
                'Design & modeling',
                'Simulation & sign-off',
              ],
              doneCount: armDone
                  ? 4
                  : progress.activeMissionId == EngMissionCatalog.roboticArm.id
                      ? (progress.activeMissionStep + 1).clamp(0, 4)
                      : 0,
              onOpen: () {
                if (armDone ||
                    progress.activeMissionId ==
                        EngMissionCatalog.roboticArm.id) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          RoboticArmMissionScreen(progress: progress),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MissionBriefingScreen(
                        progress: progress,
                        mission: EngMissionCatalog.roboticArm,
                      ),
                    ),
                  );
                }
              },
            ),
            ...EngMissionCatalog.forMajor(major.id).map((EngMission m) {
              final bool done = progress.isMissionComplete(m.id);
              return _ProjectCard(
                title: m.title,
                blurb: m.objective,
                progress: done ? 1.0 : 0.25,
                milestones: const <String>[
                  'Brief',
                  'Model',
                  'Check',
                  'Sign-off',
                ],
                doneCount: done ? 4 : 1,
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MissionBriefingScreen(
                        progress: progress,
                        mission: m,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.blurb,
    required this.progress,
    required this.milestones,
    required this.doneCount,
    required this.onOpen,
  });

  final String title;
  final String blurb;
  final double progress;
  final List<String> milestones;
  final int doneCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: 1,
        child: Container(
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
                ),
              ),
              const SizedBox(height: 4),
              Text(blurb, style: const TextStyle(color: EngCosmic.mute, height: 1.35)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: EngCosmic.stroke,
                  color: EngCosmic.electric,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).round()}% · $doneCount/${milestones.length} milestones',
                style: const TextStyle(color: EngCosmic.mute, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...List<Widget>.generate(milestones.length, (int i) {
                final bool done = i < doneCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: done ? EngCosmic.success : EngCosmic.mute,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        milestones[i],
                        style: TextStyle(
                          color: done ? EngCosmic.ink : EngCosmic.mute,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onOpen,
                child: const Text('Open workspace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
