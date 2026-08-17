import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../career_sim_models.dart';

/// Career Performance Report — not a quiz score stamp.
class CareerSimReportScreen extends StatelessWidget {
  const CareerSimReportScreen({
    super.key,
    required this.world,
    required this.report,
  });

  final CareerWorld world;
  final CareerPerformanceReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: <Widget>[
            Text(
              report.won ? 'MISSION COMPLETE' : 'MISSION FAILED',
              style: TextStyle(
                color: report.won ? const Color(0xFF34D399) : const Color(0xFFF87171),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.missionTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '⭐ ${report.overallStars}/5',
              style: TextStyle(
                color: VuV2Colors.orange,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            ...report.skillScores.entries.map(
              (MapEntry<String, int> e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        CareerSkillId.label(e.key),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text(
                      '${e.value}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121A2B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF243049)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AI Supervisor · ${world.role.supervisorName}',
                    style: TextStyle(
                      color: VuV2Colors.orange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.supervisorFeedback,
                    style: TextStyle(color: Colors.white, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'YOUR NEXT CHALLENGE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              report.nextChallenge,
              style: TextStyle(color: Colors.white, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              'XP +${report.xpEarned}',
              style: TextStyle(
                color: Color(0xFF34D399),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (report.badgesEarned.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: report.badgesEarned
                    .map(
                      (String b) => Chip(
                        label: Text(b),
                        backgroundColor: VuV2Colors.orange.withValues(alpha: 0.2),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: VuV2Colors.orange,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Return to career world',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
