import 'package:flutter/material.dart';

import 'science_lab_theme.dart';

/// AI Lab Instructor briefing before ENTER LAB.
Future<bool> showScienceMissionBriefing({
  required BuildContext context,
  required ScienceLabTheme theme,
  required String missionTitle,
  required String missionNumber,
  required String instructorLine,
  String instructorName = 'Lab Instructor',
  String cta = 'ENTER LAB',
}) async {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              missionNumber.toUpperCase(),
              style: TextStyle(
                color: theme.accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              missionTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.accent.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.accent.withValues(alpha: 0.2),
                        child: Text(theme.emoji, style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        instructorName,
                        style: TextStyle(
                          color: theme.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    instructorLine,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Loop: Investigate → Interact → Record → Solve → Feedback',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('NOT NOW'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      cta,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return go == true;
}
