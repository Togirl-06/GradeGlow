import 'package:flutter/material.dart';

import '../../data/biology_notebook_content.dart';
import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

class BiologyNotebookScreen extends StatelessWidget {
  const BiologyNotebookScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final List<BiologyNotebookSection> sections = BiologyNotebookContent.build(
      topic: path.lesson.title,
      course: path.course.title,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${path.lesson.title} · Notebook',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: sections.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'University Biology Notebook',
                      style: TextStyle(color: c.primaryLight, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      path.lesson.title,
                      style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Textbook-quality notes — not summaries. Diagrams · tables · mnemonics · cases.',
                      style: TextStyle(color: c.textPrimary.withValues(alpha: 0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }
          final BiologyNotebookSection section = sections[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: c.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(section.title, style: TextStyle(color: c.primary, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(section.body, style: TextStyle(color: c.textPrimary.withValues(alpha: 0.9), fontSize: 14, height: 1.5)),
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
            style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Mark notebook complete', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}
