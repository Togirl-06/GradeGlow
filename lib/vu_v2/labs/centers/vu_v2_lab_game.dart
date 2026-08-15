import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../vu_v2_lab_models.dart';

/// Game layer for Virtual Labs — missions, stars, combos, badges.
abstract final class VuV2LabGame {
  static int levelForXp(int xp) => 1 + (xp ~/ 120);

  static int xpIntoLevel(int xp) => xp % 120;

  static double levelProgress(int xp) => xpIntoLevel(xp) / 120;

  static String titleForLevel(int level) {
    if (level >= 12) return 'Lab Legend';
    if (level >= 8) return 'Senior Technician';
    if (level >= 5) return 'Floor Regular';
    if (level >= 3) return 'Junior Tech';
    return 'Day-1 Intern';
  }

  static int starsForRubric(int total16) {
    if (total16 >= 13) return 3;
    if (total16 >= 9) return 2;
    if (total16 >= 6) return 1;
    return 0;
  }

  static String missionFor(VuV2LabExperiment exp) {
    switch (exp.simulationKind) {
      case VuV2LabSimulationKind.physicsGravity:
        return 'QUEST: Drop at two different g values. Beat the trial log.';
      case VuV2LabSimulationKind.physicsCircuit:
        return 'QUEST: Light the bulb, then break the loop on purpose.';
      case VuV2LabSimulationKind.physicsProjectile:
        return 'QUEST: Launch twice — find which angle goes farther.';
      case VuV2LabSimulationKind.physicsWaves:
        return 'QUEST: Max amplitude, then max frequency. Note both.';
      case VuV2LabSimulationKind.chemistryReaction:
        return 'QUEST: Mix reagents and describe the product cue.';
      case VuV2LabSimulationKind.chemistryPh:
        return 'QUEST: Hit acid, then base, then near-neutral.';
      case VuV2LabSimulationKind.chemistryMolecule:
        return 'QUEST: Build the target formula without guessing forever.';
      case VuV2LabSimulationKind.chemistryTitration:
        return 'QUEST: Land within ~1.5 mL of the endpoint.';
      case VuV2LabSimulationKind.biologyAnatomy:
        return 'QUEST: Tap 3 organs and name one function each.';
      case VuV2LabSimulationKind.biologyCell:
        return 'QUEST: Find nucleus vs mitochondria roles.';
      case VuV2LabSimulationKind.biologyDna:
        return 'QUEST: Complete a clean complementary strand.';
      case VuV2LabSimulationKind.biologyEcology:
        return 'QUEST: Advance 3 seasons and explain the swing.';
      case VuV2LabSimulationKind.nursingPatient:
        return 'QUEST: Survive the 3-step clinical loop with rising SpO₂.';
      case VuV2LabSimulationKind.nursingScenario:
        return 'QUEST: Finish the branch with judgment ≥70.';
      case VuV2LabSimulationKind.nursingEquipment:
        return 'QUEST: Inspect every device — know the job.';
      case VuV2LabSimulationKind.psychologyMemory:
        return 'QUEST: Perfect recall OR explain your chunking miss.';
      case VuV2LabSimulationKind.psychologyAttention:
        return 'QUEST: Score 3 hits with ≤1 false alarm.';
      case VuV2LabSimulationKind.psychologyBias:
        return 'QUEST: Pick the base-rate-aware move.';
      case VuV2LabSimulationKind.mathGraph:
        return 'QUEST: Make the line steep, then shift it up.';
      case VuV2LabSimulationKind.mathQuadratic:
        return 'QUEST: Cross Δ from positive to negative (or reverse).';
      case VuV2LabSimulationKind.mathProbability:
        return 'QUEST: Flip ×50 and watch p drift toward 0.5.';
      default:
        return 'QUEST: Run the apparatus, log evidence, clear the station.';
    }
  }

  static List<String> badgeCatalog = <String>[
    'first_clear',
    'triple_star',
    'streak_3',
    'streak_5',
    'combo_4',
    'facility_sweep',
    'high_roller',
  ];

  static String badgeLabel(String id) {
    switch (id) {
      case 'first_clear':
        return 'First Clear';
      case 'triple_star':
        return '★★★ Perfect Bench';
      case 'streak_3':
        return '3-Streak';
      case 'streak_5':
        return '5-Streak Fire';
      case 'combo_4':
        return 'Combo x4';
      case 'facility_sweep':
        return 'Facility Sweep';
      case 'high_roller':
        return 'High Roller (500 XP)';
      default:
        return id;
    }
  }
}

class VuV2LabGameHud extends StatelessWidget {
  const VuV2LabGameHud({
    super.key,
    required this.xp,
    required this.streak,
    required this.bestStreak,
    required this.accent,
    this.compact = false,
  });

  final int xp;
  final int streak;
  final int bestStreak;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final int level = VuV2LabGame.levelForXp(xp);
    final String title = VuV2LabGame.titleForLevel(level);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _pill('LV $level', accent),
            const SizedBox(width: 8),
            _pill(title, VuV2Colors.mute),
            const Spacer(),
            _pill('🔥 $streak', streak > 0 ? accent : VuV2Colors.mute),
            const SizedBox(width: 8),
            _pill('XP $xp', accent),
          ],
        ),
        if (!compact) ...<Widget>[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: VuV2LabGame.levelProgress(xp),
              minHeight: 8,
              color: accent,
              backgroundColor: VuV2Colors.stroke,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${VuV2LabGame.xpIntoLevel(xp)} / 120 to next level · best streak $bestStreak',
            style: const TextStyle(color: VuV2Colors.mute, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.7)),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class VuV2LabStars extends StatelessWidget {
  const VuV2LabStars({super.key, required this.count, this.size = 18});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < 3; i++)
          Icon(
            i < count ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < count ? const Color(0xFFFBBF24) : VuV2Colors.mute,
            size: size,
          ),
      ],
    );
  }
}
