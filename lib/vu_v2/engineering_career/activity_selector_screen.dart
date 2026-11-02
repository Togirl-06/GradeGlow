import 'package:flutter/material.dart';

import 'challenge_arena_screen.dart';
import 'design_studio_screen.dart';
import 'engineering_career_center_screen.dart';
import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_interview_screen.dart';
import 'engineering_project_lab_screen.dart';
import 'mechworks_workplace_screen.dart';
import 'simulation_lab_screen.dart';
import 'work_task_board_screen.dart';

/// Screen 3 — choose activity type within a major.
class ActivitySelectorScreen extends StatelessWidget {
  const ActivitySelectorScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final EngineeringMajor major = EngineeringMajors.byId(progress.majorId);
    final List<_Activity> acts = <_Activity>[
      _Activity(
        title: 'Challenge Arena',
        blurb: 'Short problems, calculations, troubleshooting',
        icon: Icons.emoji_events_rounded,
        color: EngCosmic.electric,
        difficulty: 'Mixed',
        reward: '+40–120 XP',
        progressLabel:
            '${progress.completedMissions.where((String id) => (EngMissionCatalog.byId(id)?.majorId ?? '') == major.id).length} cleared',
        builder: (_) => ChallengeArenaScreen(progress: progress),
      ),
      _Activity(
        title: 'Design Studio',
        blurb: 'Construct and configure systems',
        icon: Icons.architecture_rounded,
        color: EngCosmic.purple,
        difficulty: 'Hands-on',
        reward: 'Design XP',
        progressLabel: 'Interactive editor',
        builder: (_) => DesignStudioScreen(progress: progress),
      ),
      _Activity(
        title: 'Simulation Lab',
        blurb: 'Change inputs · observe model outputs',
        icon: Icons.analytics_rounded,
        color: EngCosmic.teal,
        difficulty: 'Explore',
        reward: 'Skill XP',
        progressLabel: 'Teaching models',
        builder: (_) => SimulationLabScreen(progress: progress),
      ),
      _Activity(
        title: 'Interview & Career',
        blurb: 'Practice interviews · apply · offers',
        icon: Icons.work_rounded,
        color: EngCosmic.orange,
        difficulty: 'Career',
        reward: 'Job unlock',
        progressLabel: progress.hasAnyJob ? 'Employed' : 'Open roles',
        builder: (_) => EngineeringCareerCenterScreen(progress: progress),
        secondary: (_) => EngineeringInterviewScreen(progress: progress),
      ),
      _Activity(
        title: 'Engineering Career World',
        blurb: 'Workplace · manager tasks · deliverables',
        icon: Icons.apartment_rounded,
        color: EngCosmic.success,
        difficulty: 'On the job',
        reward: '\$ pay',
        progressLabel: progress.hasAnyJob ? 'Unlocked' : 'Locked',
        locked: !progress.hasAnyJob,
        builder: (_) => WorkTaskBoardScreen(progress: progress),
        secondary: (_) => MechWorksWorkplaceScreen(progress: progress),
      ),
      _Activity(
        title: 'Innovation Garage',
        blurb: 'Longer projects · portfolio milestones',
        icon: Icons.science_rounded,
        color: EngCosmic.gold,
        difficulty: 'Project',
        reward: 'Portfolio',
        progressLabel: 'Milestones',
        builder: (_) => EngineeringProjectLabScreen(progress: progress),
      ),
    ];

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Activities',
        icon: Icons.grid_view_rounded,
        subtitle: major.title,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Text(
              '${major.facility} · pick how you want to practice',
              style: const TextStyle(color: EngCosmic.mute, height: 1.4),
            ),
            const SizedBox(height: 14),
            ...acts.map((a) => _card(context, a)),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, _Activity a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: a.locked ? 0.55 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (a.locked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Get hired in Career Center to unlock Workplace.'),
                  ),
                );
                return;
              }
              if (a.secondary != null && a.title.startsWith('Interview')) {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: EngCosmic.panel,
                  builder: (BuildContext c) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.chat, color: EngCosmic.electric),
                          title: const Text('Interview Center',
                              style: TextStyle(color: EngCosmic.ink)),
                          onTap: () {
                            Navigator.pop(c);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: a.secondary!),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.work, color: EngCosmic.gold),
                          title: const Text('Career Center',
                              style: TextStyle(color: EngCosmic.ink)),
                          onTap: () {
                            Navigator.pop(c);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: a.builder),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
                return;
              }
              if (a.secondary != null && a.title.startsWith('Engineering Career')) {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: EngCosmic.panel,
                  builder: (BuildContext c) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: const Text('Work Task Board',
                              style: TextStyle(color: EngCosmic.ink)),
                          onTap: () {
                            Navigator.pop(c);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: a.builder),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Enter Workplace Floor',
                              style: TextStyle(color: EngCosmic.ink)),
                          onTap: () {
                            Navigator.pop(c);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: a.secondary!),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: a.builder),
              );
            },
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: EngCosmic.panelBox(radius: 16),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: a.color.withValues(alpha: 0.22),
                    child: Icon(a.icon, color: a.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          a.title,
                          style: const TextStyle(
                            color: EngCosmic.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          a.blurb,
                          style: const TextStyle(
                            color: EngCosmic.mute,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: <Widget>[
                            EngCosmic.pill(a.difficulty),
                            EngCosmic.pill(a.reward),
                            EngCosmic.pill(a.progressLabel),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    a.locked ? Icons.lock_outline : Icons.chevron_right,
                    color: EngCosmic.mute,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Activity {
  const _Activity({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.reward,
    required this.progressLabel,
    required this.builder,
    this.secondary,
    this.locked = false,
  });

  final String title;
  final String blurb;
  final IconData icon;
  final Color color;
  final String difficulty;
  final String reward;
  final String progressLabel;
  final WidgetBuilder builder;
  final WidgetBuilder? secondary;
  final bool locked;
}
