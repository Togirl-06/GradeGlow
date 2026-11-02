import 'package:flutter/material.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

/// End-of-lesson reflection & digital lab notebook.
class BiologyReflectionScreen extends StatefulWidget {
  const BiologyReflectionScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyReflectionScreen> createState() => _BiologyReflectionScreenState();
}

class _BiologyReflectionScreenState extends State<BiologyReflectionScreen> {
  final Map<String, TextEditingController> _fields = <String, TextEditingController>{
    'Key concepts learned': TextEditingController(),
    'Vocabulary': TextEditingController(),
    'Summary in my words': TextEditingController(),
    'Questions I still have': TextEditingController(),
    'Lab observations': TextEditingController(),
    'Data / graphs notes': TextEditingController(),
    'Conclusions': TextEditingController(),
  };

  String? _aiFeedback;

  @override
  void dispose() {
    for (final TextEditingController c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _generateFeedback() {
    final int filled = _fields.values.where((TextEditingController c) => c.text.trim().length >= 12).length;
    setState(() {
      _aiFeedback = filled >= 4
          ? 'Strong reflection on ${widget.path.lesson.title}. '
              'You connected concepts to evidence. Before the assessment, sketch one diagram from memory '
              'and answer one “what if this process fails?” question.'
          : filled >= 2
              ? 'Good start. Expand vocabulary and write the summary in your own words — '
                  'AI feedback improves when each box has concrete detail.'
              : 'Incomplete notebook. Add key concepts, a personal summary, and at least one observation '
                  'or remaining question so feedback can target your gaps.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.path.lesson.title} · Reflection',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Digital lab notebook — saved for review before quizzes and exams. '
            'Observe, write, and reflect so learning sticks.',
            style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 16),
          ..._fields.entries.map((MapEntry<String, TextEditingController> entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(entry.key, style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: entry.value,
                    decoration: InputDecoration(hintText: 'Write ${entry.key.toLowerCase()}…'),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),
            );
          }),
          FilledButton(
            onPressed: _generateFeedback,
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Get AI feedback', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_aiFeedback != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
              child: Text(_aiFeedback!, style: TextStyle(height: 1.45, color: c.textPrimary.withValues(alpha: 0.9))),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _aiFeedback != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save notebook', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            )
          : null,
    );
  }
}
