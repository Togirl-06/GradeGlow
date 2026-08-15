// LeetCode-style algorithm problem with examples, constraints, and test cases.

enum LeetcodeProblemKind {
  /// Student implements from an empty template.
  implement,

  /// Student fixes buggy code pre-loaded in the editor.
  debug,
}

class LeetcodeExample {  const LeetcodeExample({
    required this.input,
    required this.output,
    this.explanation,
  });

  factory LeetcodeExample.fromJson(Map<String, dynamic> json) {
    return LeetcodeExample(
      input: json['input'] as String? ?? '',
      output: json['output'] as String? ?? '',
      explanation: json['explanation'] as String?,
    );
  }

  final String input;
  final String output;
  final String? explanation;
}

class LeetcodeHiddenTest {
  const LeetcodeHiddenTest({required this.input, required this.output});

  factory LeetcodeHiddenTest.fromJson(Map<String, dynamic> json) {
    return LeetcodeHiddenTest(
      input: json['input'] as String? ?? '',
      output: json['output'] as String? ?? '',
    );
  }

  final String input;
  final String output;
}

class LeetcodeProblem {
  const LeetcodeProblem({
    required this.id,
    required this.title,
    required this.slug,
    required this.difficulty,
    required this.description,
    required this.examples,
    required this.constraints,
    required this.tags,
    required this.functionName,
    this.kind = LeetcodeProblemKind.implement,
    this.starterCode = const <String, String>{},
    this.hiddenTests = const <LeetcodeHiddenTest>[],
  });

  factory LeetcodeProblem.fromJson(Map<String, dynamic> json) {
    return LeetcodeProblem(
      id: json['id'] as String? ?? 'problem',
      title: json['title'] as String? ?? 'Untitled',
      slug: json['slug'] as String? ?? 'untitled',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      description: json['description'] as String? ?? '',
      examples: ((json['examples'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => LeetcodeExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      constraints: ((json['constraints'] as List<dynamic>?) ?? <dynamic>[]).map((dynamic e) => '$e').toList(),
      tags: ((json['tags'] as List<dynamic>?) ?? <dynamic>[]).map((dynamic e) => '$e').toList(),
      functionName: json['functionName'] as String? ?? 'solve',
      kind: json['kind'] == 'debug' ? LeetcodeProblemKind.debug : LeetcodeProblemKind.implement,
      starterCode: Map<String, String>.from(
        ((json['starterCode'] as Map<String, dynamic>?) ?? const <String, dynamic>{}).map(
          (String k, dynamic v) => MapEntry<String, String>(k, '$v'),
        ),
      ),
      hiddenTests: ((json['hiddenTests'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => LeetcodeHiddenTest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String title;
  final String slug;
  final String difficulty;
  final String description;
  final List<LeetcodeExample> examples;
  final List<String> constraints;
  final List<String> tags;
  final String functionName;
  final LeetcodeProblemKind kind;
  /// Per-language buggy or scaffold code (`python3`, `java`, …).
  final Map<String, String> starterCode;
  final List<LeetcodeHiddenTest> hiddenTests;

  bool get isDebug => kind == LeetcodeProblemKind.debug;

  String get promptFallback {
    final String action = isDebug
        ? 'Fix the bug in the existing implementation of $title.'
        : 'Implement $title.';
    final StringBuffer buf = StringBuffer('$action\n\n$description');
    if (isDebug) {
      buf.writeln('\nThe editor contains broken code — correct it so every test case passes.');
    }
    for (int i = 0; i < examples.length; i++) {
      final LeetcodeExample ex = examples[i];
      buf.writeln('\nExample ${i + 1}:\nInput: ${ex.input}\nOutput: ${ex.output}');
      if (ex.explanation != null) buf.writeln('Explanation: ${ex.explanation}');
    }
    if (constraints.isNotEmpty) {
      buf.writeln('\nConstraints:\n${constraints.map((String c) => '• $c').join('\n')}');
    }
    return buf.toString();
  }
}

class LeetcodeTestCaseResult {
  const LeetcodeTestCaseResult({
    required this.index,
    required this.passed,
    required this.input,
    required this.expected,
    required this.actual,
    this.hidden = false,
  });

  factory LeetcodeTestCaseResult.fromJson(Map<String, dynamic> json) {
    return LeetcodeTestCaseResult(
      index: (json['index'] as num?)?.toInt() ?? 1,
      passed: json['passed'] == true,
      input: json['input'] as String? ?? '',
      expected: json['expected'] as String? ?? '',
      actual: json['actual'] as String? ?? '',
      hidden: json['hidden'] == true,
    );
  }

  final int index;
  final bool passed;
  final String input;
  final String expected;
  final String actual;
  final bool hidden;
}

class LeetcodeRunResult {
  const LeetcodeRunResult({
    required this.accepted,
    required this.results,
    required this.feedback,
    required this.runtimeNote,
    this.timeComplexity,
    this.spaceComplexity,
    this.readabilityNotes,
    this.optimizationTips,
    this.edgeCaseNotes,
  });

  factory LeetcodeRunResult.fromJson(Map<String, dynamic> json) {
    return LeetcodeRunResult(
      accepted: json['accepted'] == true,
      results: ((json['results'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => LeetcodeTestCaseResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedback: json['feedback'] as String? ?? '',
      runtimeNote: json['runtimeNote'] as String? ?? '',
      timeComplexity: json['timeComplexity'] as String?,
      spaceComplexity: json['spaceComplexity'] as String?,
      readabilityNotes: json['readabilityNotes'] as String?,
      optimizationTips: json['optimizationTips'] as String?,
      edgeCaseNotes: json['edgeCaseNotes'] as String?,
    );
  }

  final bool accepted;
  final List<LeetcodeTestCaseResult> results;
  final String feedback;
  final String runtimeNote;
  final String? timeComplexity;
  final String? spaceComplexity;
  final String? readabilityNotes;
  final String? optimizationTips;
  final String? edgeCaseNotes;

  String get codeReviewSummary {
    final List<String> parts = <String>[];
    if (timeComplexity != null && timeComplexity!.isNotEmpty) {
      parts.add('Time: $timeComplexity');
    }
    if (spaceComplexity != null && spaceComplexity!.isNotEmpty) {
      parts.add('Space: $spaceComplexity');
    }
    if (readabilityNotes != null && readabilityNotes!.isNotEmpty) {
      parts.add(readabilityNotes!);
    }
    if (optimizationTips != null && optimizationTips!.isNotEmpty) {
      parts.add('Optimize: $optimizationTips');
    }
    if (edgeCaseNotes != null && edgeCaseNotes!.isNotEmpty) {
      parts.add('Edge cases: $edgeCaseNotes');
    }
    return parts.join('\n');
  }
}
