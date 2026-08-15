import 'package:flutter/material.dart';

import '../../models/chemistry_degree.dart';
import '../../theme/chemistry_degree_theme.dart';

class ChemistryLabReportScreen extends StatefulWidget {
  const ChemistryLabReportScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  @override
  State<ChemistryLabReportScreen> createState() => _ChemistryLabReportScreenState();
}

class _ChemistryLabReportScreenState extends State<ChemistryLabReportScreen> {
  final Map<String, TextEditingController> _fields = <String, TextEditingController>{
    'Aim': TextEditingController(),
    'Theory': TextEditingController(),
    'Apparatus': TextEditingController(),
    'Procedure': TextEditingController(),
    'Observations': TextEditingController(),
    'Calculations': TextEditingController(),
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
          ? 'Excellent — complete and precise'
          : len >= 15
              ? 'Good — add more detail'
              : 'Incomplete — expand this section';
    }
    setState(() => _grades = grades);
  }

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

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
            'Complete each section. AI grades every part of your report.',
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
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: c.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
                      child: Text(
                        grade,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
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
                  style: FilledButton.styleFrom(
                    backgroundColor: c.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save lab report', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            )
          : null,
    );
  }
}
