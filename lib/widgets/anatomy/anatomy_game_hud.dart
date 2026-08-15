import 'package:flutter/material.dart';

import '../../models/anatomy_game.dart';
import '../../theme/study_theme.dart';

/// Game-style HUD: level, XP bar, streak, hearts, round progress.
class AnatomyGameHud extends StatelessWidget {
  const AnatomyGameHud({super.key, required this.progress});

  final AnatomyGameProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _Badge(label: 'LV ${progress.level}', icon: Icons.military_tech_rounded),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (progress.xp % 120) / 120,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    color: StudyColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${progress.xp} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              ...List<Widget>.generate(3, (int i) {
                final bool alive = i < progress.lives;
                return Icon(
                  alive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: alive ? StudyColors.danger : Colors.white24,
                  size: 20,
                );
              }),
              const Spacer(),
              Row(
                children: <Widget>[
                  const Icon(Icons.local_fire_department_rounded, color: StudyColors.accent, size: 18),
                  const SizedBox(width: 4),
                  Text('${progress.streak}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(width: 16),
              Text(
                'Round ${progress.round}/${progress.totalRounds}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StudyColors.primary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
        ],
      ),
    );
  }
}
