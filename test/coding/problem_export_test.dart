// Keeps the server judge's copy of the problem bank identical to the app's.
//
// The Cloud Function grades submissions against
// functions/code_judge/problems.json. This test regenerates that JSON from the
// Dart bank into build/coding_problems.json and fails if the committed copy is
// out of date. To refresh it, copy build/coding_problems.json over the
// committed file.
import 'dart:convert';
import 'dart:io';

import 'package:ai_study_buddy/data/leetcode_problem_bank.dart';
import 'package:ai_study_buddy/models/leetcode_problem.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _json(LeetcodeProblem p) => <String, Object?>{
      'id': p.id,
      'title': p.title,
      'difficulty': p.difficulty,
      'kind': p.isDebug ? 'debug' : 'implement',
      'functionName': p.functionName,
      'tags': p.tags,
      'description': p.description,
      'examples': <Map<String, String>>[
        for (final LeetcodeExample e in p.examples) <String, String>{'input': e.input, 'output': e.output},
      ],
      'hiddenTests': <Map<String, String>>[
        for (final LeetcodeHiddenTest t in p.hiddenTests) <String, String>{'input': t.input, 'output': t.output},
      ],
    };

void main() {
  test('server judge problem bank matches the app', () {
    final Map<String, Map<String, Object?>> byId = <String, Map<String, Object?>>{};
    for (final LeetcodeProblem p in <LeetcodeProblem>[
      ...LeetcodeProblemBank.allCuratedProblems,
      ...LeetcodeProblemBank.allDebugProblems,
    ]) {
      byId['${p.isDebug ? 'debug' : 'impl'}:${p.id}'] = _json(p);
    }
    final List<String> keys = byId.keys.toList()..sort();
    final String generated = const JsonEncoder.withIndent(' ').convert(<String, Object?>{
      for (final String k in keys) k: byId[k],
    });
    Directory('build').createSync(recursive: true);
    File('build/coding_problems.json').writeAsStringSync('$generated\n');

    expect(keys, isNotEmpty);
    final File committed = File('functions/code_judge/problems.json');
    if (committed.existsSync()) {
      expect(committed.readAsStringSync(), '$generated\n',
          reason: 'functions/code_judge/problems.json is stale; copy build/coding_problems.json over it.');
    }
  });
}
