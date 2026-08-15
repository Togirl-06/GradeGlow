import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/law_simulation_data.dart';
import '../models/law_simulation.dart';
import '../models/practice_lab.dart';
import '../services/law_daily_progress_service.dart';
import '../theme/practice_lab_game_theme.dart';
import '../widgets/law/law_simulation_widgets.dart';
import 'law/law_case_side_select_screen.dart';
import 'law_simulation_screen.dart';

/// Law simulation home — case library for every specialization, daily challenge, progress.
class LawSimulationHubScreen extends StatelessWidget {
  const LawSimulationHubScreen({
    super.key,
    required this.category,
    required this.lab,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;

  @override
  Widget build(BuildContext context) {
    final LawPlayerProgress progress = LawSimulationData.playerProgress;
    final LawCaseFile daily = LawSimulationData.dailyCase();
    final Map<String, List<LawCaseFile>> grouped = LawSimulationData.casesBySpecialization;

    return Consumer<LawDailyProgressService>(
      builder: (BuildContext context, LawDailyProgressService dailyProgress, Widget? _) {
        final bool dailyDone = daily.specializationId != null &&
            dailyProgress.isDailyCompleted(daily.specializationId!);

        return Scaffold(
          backgroundColor: PracticeLabGameTheme.background(context),
          appBar: AppBar(
            title: const Text('Law Simulation', style: TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: PracticeLabGameTheme.background(context),
            foregroundColor: PracticeLabGameTheme.textPrimary(context),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: <Color>[Color(0xFF3E2723), Color(0xFF5D4037)]),
                ),
                child: Text(
                  'Investigate cases, build arguments, and argue before an AI judge. One court case per specialization each day — finish it to mark complete.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LawProgressHud(progress: progress),
              const SizedBox(height: 14),
              if (progress.continueCaseId != null)
                FilledButton.icon(
                  onPressed: () =>
                      _startCase(context, progress.continueCaseId!, LawPartySide.prosecution, resume: true),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue Case'),
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
              if (progress.continueCaseId != null) const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _pickSideAndStart(context, daily),
                icon: Icon(dailyDone ? Icons.check_circle_rounded : Icons.today_rounded),
                label: Text(
                  dailyDone
                      ? 'Daily Challenge · Done — ${daily.title}'
                      : 'Daily Challenge — ${daily.title}',
                ),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              ),
              const SizedBox(height: 22),
              Text(
                'CASE LIBRARY · ${LawSimulationData.allCases.length} CASES',
                style: TextStyle(
                  color: PracticeLabGameTheme.textSecondary(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'One courtroom case for every Law School specialization.',
                style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12),
              ),
              const SizedBox(height: 12),
              ...grouped.entries.expand((MapEntry<String, List<LawCaseFile>> entry) {
                return <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        color: PracticeLabGameTheme.primary(context),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  ...entry.value.map((LawCaseFile file) {
                    final bool done = file.specializationId != null &&
                        dailyProgress.isDailyCompleted(file.specializationId!);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CaseRow(
                        caseFile: file,
                        completedToday: done,
                        onTap: () => _pickSideAndStart(context, file),
                      ),
                    );
                  }),
                ];
              }),
            ],
          ),
        );
      },
    );
  }

  void _pickSideAndStart(BuildContext context, LawCaseFile file) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawCaseSideSelectScreen(
          caseFile: file,
          category: category,
          lab: lab,
          isDailyCase: true,
        ),
      ),
    );
  }

  void _startCase(BuildContext context, String caseId, LawPartySide side, {bool resume = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawSimulationScreen(
          category: category,
          lab: lab,
          caseId: caseId,
          side: side,
          resume: resume,
          startWithBriefing: !resume,
        ),
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({
    required this.caseFile,
    required this.completedToday,
    required this.onTap,
  });

  final LawCaseFile caseFile;
  final bool completedToday;
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
              Text(_emoji(caseFile.category), style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      caseFile.title,
                      style: TextStyle(
                        color: PracticeLabGameTheme.textPrimary(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      completedToday
                          ? '${caseFile.displayTrack} · Completed today'
                          : '${caseFile.displayTrack} · ~${caseFile.estimatedMinutes} min · Today\'s case',
                      style: TextStyle(
                        color: completedToday
                            ? const Color(0xFF2E7D32)
                            : PracticeLabGameTheme.textSecondary(context),
                        fontSize: 12,
                        fontWeight: completedToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  if (completedToday)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 22)
                  else
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

  String _emoji(LawCaseCategory c) => switch (c) {
        LawCaseCategory.criminal => '🚨',
        LawCaseCategory.civil => '📜',
        LawCaseCategory.school => '🎓',
        LawCaseCategory.workplace => '🏢',
      };
}
