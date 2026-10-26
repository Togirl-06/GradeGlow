import 'package:flutter/material.dart';

import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'mechworks_workplace_screen.dart';
import 'robotic_arm_mission_screen.dart';
import 'simulation_lab_screen.dart';

/// Screen 12 — manager assignments after hire.
class WorkTaskBoardScreen extends StatelessWidget {
  const WorkTaskBoardScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final List<_Task> tasks = <_Task>[
      _Task(
        id: 'apex_vibration_v1',
        title: 'Investigate pick-and-place vibration',
        manager:
            'Check unbalance vs RPM, write a recommendation, submit before standup.',
        priority: 'High',
        difficulty: 'Junior',
        reward: '+110 XP · +\$12.00',
        tool: 'Workplace workstation',
        status: progress.workplaceTasksDone.contains('apex_vibration_v1')
            ? 'Passed'
            : progress.clockedIn
                ? 'In progress'
                : 'Available',
        open: (BuildContext c) {
          Navigator.of(c).push(
            MaterialPageRoute<void>(
              builder: (_) => MechWorksWorkplaceScreen(progress: progress),
            ),
          );
        },
      ),
      _Task(
        id: 'apex_arm_recheck',
        title: 'Re-validate robotic arm torque after rebuild',
        manager:
            'Run the teaching model again with the night-shift reach setting and sign off.',
        priority: 'Medium',
        difficulty: 'Junior',
        reward: '+80 XP',
        tool: 'Design Studio / Simulation',
        status: progress.isMissionComplete('mech_robotic_arm_v1')
            ? 'Passed'
            : 'Available',
        open: (BuildContext c) {
          Navigator.of(c).push(
            MaterialPageRoute<void>(
              builder: (_) => RoboticArmMissionScreen(progress: progress),
            ),
          );
        },
      ),
      _Task(
        id: 'apex_sim_sweep',
        title: 'Motor torque sensitivity sweep',
        manager:
            'In Simulation Lab, vary motor torque and document when the arm fails SF.',
        priority: 'Low',
        difficulty: 'Explore',
        reward: 'Skill XP',
        tool: 'Simulation Lab',
        status: 'Available',
        open: (BuildContext c) {
          Navigator.of(c).push(
            MaterialPageRoute<void>(
              builder: (_) => SimulationLabScreen(progress: progress),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Work Task Board',
        icon: Icons.view_kanban_rounded,
        subtitle: progress.hasAnyJob ? 'Employed' : 'Preview',
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            if (!progress.hasAnyJob)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EngCosmic.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Preview mode — accept a job offer to unlock paid workplace tasks.',
                  style: TextStyle(color: EngCosmic.orange),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: EngCosmic.panelBox(radius: 14),
              child: const Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: EngCosmic.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Samira Okonkwo · Today\'s assignments are on the board. '
                      'Open a task, do the work, then submit for feedback.',
                      style: TextStyle(color: EngCosmic.ink, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...tasks.map((t) => _taskCard(context, t)),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(BuildContext context, _Task t) {
    final Color statusColor = switch (t.status) {
      'Passed' => EngCosmic.success,
      'In progress' => EngCosmic.electric,
      _ => EngCosmic.mute,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: EngCosmic.panelBox(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    t.title,
                    style: const TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                EngCosmic.pill(
                  t.status,
                  bg: statusColor.withValues(alpha: 0.16),
                  fg: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.manager,
              style: const TextStyle(color: EngCosmic.mute, height: 1.35),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                EngCosmic.pill(t.priority),
                EngCosmic.pill(t.difficulty),
                EngCosmic.pill(t.tool),
                EngCosmic.pill(
                  t.reward,
                  bg: EngCosmic.gold.withValues(alpha: 0.14),
                  fg: EngCosmic.gold,
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => t.open(context),
              child: const Text('Open Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Task {
  const _Task({
    required this.id,
    required this.title,
    required this.manager,
    required this.priority,
    required this.difficulty,
    required this.reward,
    required this.tool,
    required this.status,
    required this.open,
  });

  final String id;
  final String title;
  final String manager;
  final String priority;
  final String difficulty;
  final String reward;
  final String tool;
  final String status;
  final void Function(BuildContext) open;
}
