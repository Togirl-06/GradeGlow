import 'package:flutter/material.dart';

import 'challenge_arena_screen.dart';
import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'robotic_arm_mission_screen.dart';

/// Screen 4 — Mission briefing before interactive work.
class MissionBriefingScreen extends StatelessWidget {
  const MissionBriefingScreen({
    super.key,
    required this.progress,
    required this.mission,
  });

  final EngineeringCareerProgress progress;
  final EngMission mission;

  Future<void> _start(BuildContext context) async {
    await progress.startMission(mission.id);
    if (!context.mounted) return;
    if (mission.id == EngMissionCatalog.roboticArm.id) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => RoboticArmMissionScreen(progress: progress),
        ),
      );
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => EngGenericMissionScreen(
          progress: progress,
          mission: mission,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EngineeringMajor major = EngineeringMajors.byId(mission.majorId);

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Mission briefing',
        icon: Icons.assignment_rounded,
        subtitle: mission.difficulty,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              height: 160,
              decoration: EngCosmic.panelBox(radius: 18),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WorkshopPainter(major.accent),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 14,
                    right: 16,
                    child: Row(
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: EngCosmic.teal,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: EngCosmic.bg.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: EngCosmic.electric.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'Mentor Priya · ${major.facility}\n'
                              '"Read the constraints carefully — then prove it with numbers."',
                              style: const TextStyle(
                                color: EngCosmic.ink,
                                height: 1.35,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EngCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  EngCosmic.pill('YOUR MISSION', bg: EngCosmic.purple.withValues(alpha: 0.25)),
                  const SizedBox(height: 10),
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.objective,
                    style: const TextStyle(color: EngCosmic.mute, height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Objectives',
                    style: TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _bullet('Investigate the failed configuration'),
                  _bullet('Hand-calculate required torque with SI units'),
                  _bullet('Design, simulate, and pass the constraint checks'),
                  _bullet('Complete engineering sign-off before submitting'),
                  const SizedBox(height: 12),
                  const Text(
                    'Constraints',
                    style: TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      EngCosmic.pill('Payload 5.0 kg'),
                      EngCosmic.pill('SF 1.25'),
                      EngCosmic.pill('τ = F·L'),
                      EngCosmic.pill('SI units'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      EngCosmic.pill(mission.difficulty),
                      const SizedBox(width: 8),
                      EngCosmic.pill(
                        '+${mission.xpReward} XP',
                        bg: EngCosmic.gold.withValues(alpha: 0.16),
                        fg: EngCosmic.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hint available in-mission: ${mission.hint}',
                    style: const TextStyle(
                      color: EngCosmic.electric,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _start(context),
              style: FilledButton.styleFrom(
                backgroundColor: EngCosmic.electric,
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text(
                'Start Mission',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bullet(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('•  ', style: TextStyle(color: EngCosmic.electric)),
            Expanded(
              child: Text(t, style: const TextStyle(color: EngCosmic.mute)),
            ),
          ],
        ),
      );
}

class _WorkshopPainter extends CustomPainter {
  _WorkshopPainter(this.accent);
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF12182B),
    );
    final Paint beam = Paint()..color = accent.withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.2, size.width, 8), beam);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.35, 70, 50),
        const Radius.circular(8),
      ),
      Paint()..color = EngCosmic.panelAlt,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.45),
      18,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
