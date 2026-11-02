import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'robotic_arm_mission_screen.dart';

/// Shared Design Studio — routes to major-specific builders.
class DesignStudioScreen extends StatelessWidget {
  const DesignStudioScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final EngineeringMajor major = EngineeringMajors.byId(progress.majorId);

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Design Studio',
        icon: Icons.architecture_rounded,
        subtitle: major.facility,
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
                  Text(
                    'Build & configure · ${major.title}',
                    style: const TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Place parameters, validate constraints, then send designs '
                    'to Simulation Lab. This is a constrained educational builder — '
                    'not professional CAD.',
                    style: TextStyle(color: EngCosmic.mute, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _StudioCard(
              title: 'Robotic arm configurator',
              blurb: 'Length, motor torque, joint strength for MechWorks.',
              icon: Icons.precision_manufacturing_rounded,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        RoboticArmMissionScreen(progress: progress),
                  ),
                );
              },
            ),
            _StudioCard(
              title: 'Bridge concept desk',
              blurb: 'Civil: span, load, capacity, and budget trade-offs.',
              icon: Icons.apartment_rounded,
              locked: progress.majorId != 'civil_engineering',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Open Challenge Arena → Conceptual bridge for the civil check.',
                    ),
                  ),
                );
              },
            ),
            _StudioCard(
              title: 'Circuit board desk',
              blurb: 'Electrical: resistance and current limits.',
              icon: Icons.bolt_rounded,
              locked: progress.majorId != 'electrical_engineering',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Open Challenge Arena → Series circuit for the EE check.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  const _StudioCard({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String blurb;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: EngCosmic.panelBox(radius: 16),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: EngCosmic.purple.withValues(alpha: 0.25),
                    child: Icon(icon, color: EngCosmic.electric),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                        Text(
                          blurb,
                          style: const TextStyle(
                            color: EngCosmic.mute,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    locked ? Icons.lock_outline : Icons.chevron_right,
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
