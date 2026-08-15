import 'package:flutter/material.dart';

import '../../data/chemistry_textbook_content.dart';
import '../../models/chemistry_degree.dart';
import '../../theme/chemistry_degree_theme.dart';

class ChemistryTextbookScreen extends StatelessWidget {
  const ChemistryTextbookScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);
    final List<ChemistryTextbookSection> sections = ChemistryTextbookContent.build(
      topic: path.lesson.title,
      course: path.course.title,
      module: path.module.title,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${path.lesson.title} · Textbook',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: sections.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'AI Textbook Chapter',
                      style: TextStyle(
                        color: c.primaryLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      path.lesson.title,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${path.course.title} · Complete chapter — not summaries',
                      style: TextStyle(
                        color: c.textPrimary.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final ChemistryTextbookSection section = sections[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: c.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    section.title,
                    style: TextStyle(
                      color: c.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section.body,
                    style: TextStyle(
                      color: c.textPrimary.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Mark chapter read',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
