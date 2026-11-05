import 'dart:convert';
import 'dart:io';

import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes the simulator's bug-fix starters to build/career_debug_starters.json.
/// functions/test/career_debug_starters.test.js runs each one through the real
/// judge harness to prove the starter is broken and the problem is fixable.
void main() {
  test('export bug-fix starters for the judge check', () {
    final List<Map<String, String>> out = <Map<String, String>>[];
    final Set<String> seen = <String>{};
    for (final CodeTaskSpec t in CareerCatalog.allCodeTasks()) {
      if (t.buggyStarter.isEmpty) continue;
      for (final MapEntry<String, String> e in t.buggyStarter.entries) {
        if (!seen.add('${t.problemKey}|${e.key}|${e.value}')) continue;
        out.add(<String, String>{'key': t.problemKey, 'task': t.id, 'language': e.key, 'code': e.value});
      }
      expect(t.buggyStarter.keys, containsAll(<String>['python3', 'javascript']), reason: t.id);
      expect(CareerCatalog.problem(t.problemKey), isNotNull, reason: t.problemKey);
    }
    expect(out, isNotEmpty);
    Directory('build').createSync(recursive: true);
    File('build/career_debug_starters.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));
  });
}
