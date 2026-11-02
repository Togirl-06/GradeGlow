import 'package:flutter/material.dart';

import '../../labs/centers/vu_v2_lab_game.dart';

class GameMissionResultsScreen extends StatelessWidget {
  const GameMissionResultsScreen({
    super.key,
    required this.missionTitle,
    required this.scores,
    required this.overall,
    required this.xpEarned,
    required this.totalXp,
    this.achievement,
    this.completeLabel = 'MISSION COMPLETE',
    required this.onDone,
  });

  final String missionTitle;
  final Map<String, int> scores;
  final int overall;
  final int xpEarned;
  final int totalXp;
  final String? achievement;
  final String completeLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06101C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                completeLabel,
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                missionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              ...scores.entries.where((MapEntry<String, int> e) => e.key != 'overall').map(
                (MapEntry<String, int> e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(e.key, style: const TextStyle(color: Colors.white70)),
                      ),
                      Text(
                        '${e.value}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white12),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Overall Score',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '$overall/100',
                    style: const TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '+$xpEarned XP',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              if (achievement != null) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Text('🏅', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Achievement',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              achievement!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'Level title: ${VuV2LabGame.titleForLevel(VuV2LabGame.levelForXp(totalXp))}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('RETURN TO HOSPITAL', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
