import 'dart:convert';
import 'dart:io';

import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exports SQL and program steps to build/career_lab_steps.json so
/// functions/test/lab_keys.test.js can check every answer key against a
/// reference solution run in real SQLite and Python.
void main() {
  test('export lab answer keys', () {
    final List<Map<String, Object?>> sql = <Map<String, Object?>>[];
    final List<Map<String, Object?>> programs = <Map<String, Object?>>[];
    for (final LabSpec lab in LabCatalog.all) {
      for (final LabScenario sc in lab.scenarios) {
        for (final LabStep s in sc.steps) {
          if (s is SqlStep) {
            sql.add(<String, Object?>{
              'id': s.id,
              'setup': lab.database,
              'check': s.check,
              'ordered': s.ordered,
              'starter': s.starter,
              'expected': SqlStep.rowKeys(s.expected),
            });
          } else if (s is ProgramStep) {
            programs.add(<String, Object?>{
              'id': s.id,
              'cases': <Map<String, String>>[for (final ProgramCase c in s.cases) <String, String>{'stdin': c.stdin, 'expected': c.expected}],
            });
          }
        }
      }
    }
    expect(sql, isNotEmpty);
    Directory('build').createSync(recursive: true);
    File('build/career_lab_steps.json').writeAsStringSync(jsonEncode(<String, Object?>{'sql': sql, 'programs': programs}));
  });
}
