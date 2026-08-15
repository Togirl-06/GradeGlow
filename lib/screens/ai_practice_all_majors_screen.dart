import 'package:flutter/material.dart';

import '../data/ai_practice_catalog.dart';
import '../models/practice_lab.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';

/// Full list of majors grouped by field.
class AiPracticeAllMajorsScreen extends StatelessWidget {
  const AiPracticeAllMajorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('All Majors')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text(
            'Browse every major and program supported in AI Practice Mode.',
            style: TextStyle(color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ...AiPracticeCatalog.subjectGroups.map(
            (PracticeLabSubjectGroup group) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 2),
                    child: Text('${group.emoji} ${group.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  ...group.subjects.map(
                    (PracticeLabCategory major) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StudySurfaceCard(
                        onTap: () => Navigator.of(context).pop(major),
                        child: Row(
                          children: <Widget>[
                            Icon(major.icon, color: StudyColors.primary),
                            const SizedBox(width: 12),
                            Expanded(child: Text('${major.emoji} ${major.name}'.trim(), style: const TextStyle(fontWeight: FontWeight.w600))),
                            Icon(Icons.chevron_right_rounded, color: textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
