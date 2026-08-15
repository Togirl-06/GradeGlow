import 'package:flutter/material.dart';

import '../../data/university_learning_engine.dart';
import '../career_labs/playable/science/shared/science_lab_theme.dart';
import 'university_lab_result.dart';

/// University-style lab introduction before ENTER LAB.
Future<bool> showUniversityLabBriefing({
  required BuildContext context,
  required UniversityLabLink link,
  String subjectId = 'biology',
}) async {
  final ScienceLabTheme theme = ScienceLabTheme.forSubject(subjectId);
  final UniversityProfessorStyle professor =
      UniversityProfessorStyle.forSubject(subjectId);
  final bool? go = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'LAB BRIEFING · ${professor.title.toUpperCase()}',
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MISSION',
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                link.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '"${professor.openerTone}"',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Objective',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                link.purpose,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 1.45),
              ),
              const SizedBox(height: 14),
              const Text(
                'Procedure',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              ..._procedureFor(link).asMap().entries.map(
                    (MapEntry<int, String> e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${e.key + 1}.',
                            style: TextStyle(
                              color: theme.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.value,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 14),
              const Text(
                'Grading rubric',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Accuracy · Spatial rotation · Procedure completion',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  _chip('~${link.estimatedMinutes} min', theme.accent),
                  const SizedBox(width: 8),
                  _chip(link.difficulty, theme.accent),
                ],
              ),
              if (link.safetyNotes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                ...link.safetyNotes.map(
                  (String s) => Text(
                    '⚠ $s',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(backgroundColor: theme.accent),
                      child: const Text('ENTER LAB'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return go == true;
}

List<String> _procedureFor(UniversityLabLink link) {
  if (link.stationId == 'anatomy_3d' ||
      link.title.toLowerCase().contains('skeleton') ||
      link.title.toLowerCase().contains('3d')) {
    return const <String>[
      'Accept the ED patient chart',
      'Orbit until the required clinical view is locked',
      'Diagnose the implicated structure on the 3D model',
      'Answer the clinical viva (WHY) for a reasoning score',
      'Complete labels and submit for board scoring',
    ];
  }
  return link.objectives;
}

Future<void> showUniversityLabDebrief({
  required BuildContext context,
  required UniversityLabLink link,
  required String subjectId,
  UniversityLabResult? result,
}) async {
  final UniversityProfessorStyle style =
      UniversityProfessorStyle.forSubject(subjectId);
  final ScienceLabTheme theme = ScienceLabTheme.forSubject(subjectId);
  final UniversityLabResult report = result ??
      const UniversityLabResult(
        accuracy: 0.5,
        identifyCorrect: 0,
        identifyAttempts: 1,
        viewsVisited: 1,
        labelDrillComplete: false,
        coachingNotes: <String>[
          'Complete the mission so we can score accuracy, reasoning, and decisions.',
        ],
        xpEarned: 0,
      );
  final String review =
      report.recommendedReview ?? link.prerequisite ?? link.title;

  await showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      backgroundColor: theme.surface,
      title: Text(
        'LAB REPORT',
        style: TextStyle(color: theme.accent, fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                style.title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _reportRow('Mission', link.title),
              _reportRow('Result', report.resultStatus),
              _reportRow('Accuracy', report.scoreLabel),
              _reportRow('Reasoning', report.reasoningGrade),
              _reportRow('Decision quality', report.decisionQuality),
              _reportRow('Efficiency', report.efficiencyLabel),
              _reportRow('Concept mastery', '${report.conceptMasteryPercent}%'),
              _reportRow('Hints used', '${report.hintsUsed}'),
              _reportRow('Recommended review', review),
              if (report.coachingNotes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'Professor debrief',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'What you did well · What you missed · Why the decision mattered.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                ...report.coachingNotes.take(4).map(
                      (String note) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $note',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
              ],
              const SizedBox(height: 8),
              Text(
                report.passed
                    ? 'You practiced this as a professional would. Try the harder scenario next.'
                    : 'The simulation responded to your choices. Retry the mission after you review $review.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          style: FilledButton.styleFrom(backgroundColor: theme.accent),
          child: Text(report.passed ? 'Continue' : 'Retry later'),
        ),
      ],
    ),
  );
}

Widget _reportRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _chip(String label, Color accent) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: accent.withValues(alpha: 0.4)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: accent,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    ),
  );
}
