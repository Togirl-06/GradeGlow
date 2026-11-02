import 'package:flutter/material.dart';

import '../../models/law_simulation.dart';
import '../../models/practice_lab.dart';
import '../../theme/law_theme.dart';
import '../law_simulation_screen.dart';

/// Side selection — plaintiff/prosecution vs defense before the case begins.
class LawCaseSideSelectScreen extends StatelessWidget {
  const LawCaseSideSelectScreen({
    super.key,
    required this.caseFile,
    required this.category,
    required this.lab,
    this.isDailyCase = true,
  });

  final LawCaseFile caseFile;
  final PracticeLabCategory category;
  final PracticeLabType lab;
  final bool isDailyCase;

  void _start(BuildContext context, LawPartySide side) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LawSimulationScreen(
          category: category,
          lab: lab,
          caseId: caseFile.id,
          side: side,
          isDailyCase: isDailyCase,
          startWithBriefing: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawTheme.background,
      appBar: AppBar(
        backgroundColor: LawTheme.bench,
        foregroundColor: Colors.white,
        title: const Text('New Case Assigned'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: <Widget>[
          Text(
            'NEW CASE ASSIGNED',
            style: TextStyle(
              color: LawTheme.textSecondary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caseFile.title,
            style: TextStyle(
              color: LawTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${caseFile.displayCaseNumber} · ${caseFile.displayTrack}',
            style: TextStyle(color: LawTheme.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Text(
            caseFile.summary,
            style: TextStyle(color: LawTheme.textSecondary, height: 1.45, fontSize: 15),
          ),
          const SizedBox(height: 28),
          Text(
            'You represent:',
            style: TextStyle(color: LawTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _SideCard(
            title: 'Plaintiff / Prosecution',
            subtitle: caseFile.prosecutionTheory,
            icon: Icons.gavel_rounded,
            color: LawTheme.primary,
            onTap: () => _start(context, LawPartySide.prosecution),
          ),
          const SizedBox(height: 12),
          _SideCard(
            title: 'Defense / Respondent',
            subtitle: caseFile.defenseTheory,
            icon: Icons.shield_outlined,
            color: LawTheme.benchLight,
            onTap: () => _start(context, LawPartySide.defense),
          ),
          const SizedBox(height: 20),
          Text(
            'Choosing a side changes your theory, interviews, and how the AI judge scores your advocacy.',
            style: TextStyle(color: LawTheme.textSecondary, fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LawTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: LawTheme.textPrimary, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(color: LawTheme.textSecondary, height: 1.4, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: LawTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
