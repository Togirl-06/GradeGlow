import 'package:flutter/material.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

class BiologyLabReportScreen extends StatefulWidget {
  const BiologyLabReportScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyLabReportScreen> createState() => _BiologyLabReportScreenState();
}

class _BiologyLabReportScreenState extends State<BiologyLabReportScreen> {
  final Map<String, TextEditingController> _fields = <String, TextEditingController>{
    'Objective': TextEditingController(),
    'Hypothesis': TextEditingController(),
    'Materials': TextEditingController(),
    'Procedure': TextEditingController(),
    'Observations': TextEditingController(),
    'Results': TextEditingController(),
    'Discussion': TextEditingController(),
    'Conclusion': TextEditingController(),
  };

  Map<String, String>? _grades;

  @override
  void dispose() {
    for (final TextEditingController c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final Map<String, String> grades = <String, String>{};
    for (final MapEntry<String, TextEditingController> entry in _fields.entries) {
      final int len = entry.value.text.trim().length;
      grades[entry.key] = len >= 40
          ? 'Excellent — scientific and complete'
          : len >= 15
              ? 'Good — add evidence and interpretation'
              : 'Incomplete — expand with data and reasoning';
    }
    setState(() => _grades = grades);
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.path.lesson.title} · Lab Report',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Write a university lab report. AI grades scientific accuracy, clarity, and critical thinking.',
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ..._fields.entries.map((MapEntry<String, TextEditingController> entry) {
            final String? grade = _grades?[entry.key];
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
                  if (grade != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(grade, style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            );
          }),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Submit for grading', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      bottomNavigationBar: _grades != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: c.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save lab report', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            )
          : null,
    );
  }
}
