import 'package:flutter/material.dart';

import '../../models/law_simulation.dart';
import '../../theme/practice_lab_game_theme.dart';

class LawProgressHud extends StatelessWidget {
  const LawProgressHud({super.key, required this.progress, this.phase});

  final LawPlayerProgress progress;
  final LawSimulationPhase? phase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PracticeLabGameTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(progress.rankTitle, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w900)),
              const Spacer(),
              if (phase != null)
                Text(
                  _phaseLabel(phase!),
                  style: TextStyle(color: PracticeLabGameTheme.primary(context), fontWeight: FontWeight.w800, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (progress.xp / (progress.level * 120)).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: PracticeLabGameTheme.border(context),
              color: PracticeLabGameTheme.primary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Level ${progress.level} · ${progress.xp} XP · ${progress.casesWon} wins',
            style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(LawSimulationPhase phase) => switch (phase) {
        LawSimulationPhase.briefing => 'Briefing',
        LawSimulationPhase.investigation => 'Investigation',
        LawSimulationPhase.argument => 'Build Argument',
        LawSimulationPhase.courtroom => 'Courtroom',
        LawSimulationPhase.verdict => 'Verdict',
      };
}

class LawCaseCard extends StatelessWidget {
  const LawCaseCard({super.key, required this.caseFile, required this.onTap});

  final LawCaseFile caseFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PracticeLabGameTheme.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Text(_categoryEmoji(caseFile.category), style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(caseFile.title, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      '${caseFile.displayTrack} · ~${caseFile.estimatedMinutes} min',
                      style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Text('⭐' * caseFile.difficulty, style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right_rounded, color: PracticeLabGameTheme.textSecondary(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryEmoji(LawCaseCategory c) => switch (c) {
        LawCaseCategory.criminal => '🚨',
        LawCaseCategory.civil => '📜',
        LawCaseCategory.school => '🎓',
        LawCaseCategory.workplace => '🏢',
      };
}

class LawPhaseStepper extends StatelessWidget {
  const LawPhaseStepper({super.key, required this.current});

  final LawSimulationPhase current;

  @override
  Widget build(BuildContext context) {
    const List<LawSimulationPhase> phases = <LawSimulationPhase>[
      LawSimulationPhase.briefing,
      LawSimulationPhase.investigation,
      LawSimulationPhase.argument,
      LawSimulationPhase.courtroom,
      LawSimulationPhase.verdict,
    ];
    final int raw = phases.indexOf(current);
    final int index = raw < 0 ? 0 : raw;
    return Row(
      children: List<Widget>.generate(phases.length * 2 - 1, (int i) {
        if (i.isOdd) {
          return Expanded(child: Container(height: 2, color: PracticeLabGameTheme.border(context)));
        }
        final int step = i ~/ 2;
        final bool active = step <= index;
        return CircleAvatar(
          radius: 14,
          backgroundColor: active ? PracticeLabGameTheme.primary(context) : PracticeLabGameTheme.border(context),
          child: Text('${step + 1}', style: TextStyle(color: active ? Colors.white : PracticeLabGameTheme.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w900)),
        );
      }),
    );
  }
}

class LawCourtroomBanner extends StatelessWidget {
  const LawCourtroomBanner({super.key, required this.judgeLine, this.loading = false});

  final String judgeLine;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[Color(0xFF3E2723), Color(0xFF5D4037)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.gavel_rounded, color: Color(0xFFD4A574), size: 28),
          const SizedBox(height: 6),
          Text('THE COURT', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          if (loading)
            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4A574)))
          else
            Text(judgeLine, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, height: 1.4, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class LawEvidenceChip extends StatelessWidget {
  const LawEvidenceChip({super.key, required this.evidence, this.selected = false, this.onTap});

  final LawEvidence evidence;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      label: Text(evidence.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      avatar: Icon(
        evidence.isFakeLead ? Icons.warning_amber_rounded : Icons.description_outlined,
        size: 16,
        color: evidence.isFakeLead ? Colors.orange : null,
      ),
    );
  }
}
