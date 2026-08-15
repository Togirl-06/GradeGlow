import '../../data/coding_languages.dart';
import '../../data/cs_curriculum/cs_curriculum_workspace_builder.dart';
import '../../data/cs_w3s_catalog.dart';
import '../../models/cs_w3s_topic.dart';

/// Resolved Try It Yourself exercise for a V2 Computer Science lesson.
class VuV2CsTryItSpec {
  const VuV2CsTryItSpec({
    required this.topicId,
    required this.topicTitle,
    required this.task,
    required this.starterCode,
    required this.runContext,
    required this.languageId,
    required this.languageLabel,
    required this.exampleInput,
    required this.exampleOutput,
    required this.exampleSteps,
    required this.syntaxBullets,
  });

  final String topicId;
  final String topicTitle;
  final String task;
  final String starterCode;
  final String runContext;
  final String languageId;
  final String languageLabel;
  final String exampleInput;
  final String exampleOutput;
  final String exampleSteps;
  final List<String> syntaxBullets;
}

/// Builds W3Schools-style coding exercises for CS roadmap topics.
abstract final class VuV2CsTryItResolver {
  static VuV2CsTryItSpec resolve({
    required String topicTitle,
    String? topicId,
    String trackTitle = 'Computer Science',
    String courseTitle = 'Computer Science',
  }) {
    final String id = (topicId ?? '').trim();
    CsW3sTopic? topic;
    if (id.isNotEmpty) {
      topic = CsCurriculumWorkspaceBuilder.resolveTopic(id) ??
          CsW3sCatalog.byId(id);
    }
    topic ??= _matchByTitle(topicTitle);
    if (topic != null) {
      final String langId = _languageFromTrack(trackTitle, topic);
      return VuV2CsTryItSpec(
        topicId: topic.id,
        topicTitle: topic.title,
        task: topic.tryIt.task,
        starterCode: topic.tryItStarterFor(langId),
        runContext: topic.tryIt.runContext.isEmpty
            ? 'Your code should demonstrate ${topic.title}.'
            : topic.tryIt.runContext,
        languageId: langId,
        languageLabel: _labelFor(langId),
        exampleInput: topic.example.input,
        exampleOutput: topic.example.output,
        exampleSteps: topic.example.steps,
        syntaxBullets: topic.syntaxFor(langId),
      );
    }
    return _generated(
      topicTitle: topicTitle,
      topicId: id.isEmpty ? _slug(topicTitle) : id,
      trackTitle: trackTitle,
      courseTitle: courseTitle,
    );
  }

  static CsW3sTopic? _matchByTitle(String title) {
    final String needle = title.toLowerCase().trim();
    if (needle.isEmpty) return null;
    for (final CsW3sTopic t in CsW3sCatalog.topics) {
      if (t.title.toLowerCase() == needle) return t;
    }
    for (final CsW3sTopic t in CsW3sCatalog.topics) {
      if (needle.contains(t.title.toLowerCase()) ||
          t.title.toLowerCase().contains(needle)) {
        return t;
      }
    }
    // Keyword fallbacks for common roadmap titles.
    const Map<String, String> keys = <String, String>{
      'array': 'arrays',
      'loop': 'loops',
      'for ': 'loops',
      'while': 'loops',
      'function': 'functions',
      'method': 'functions',
      'hash': 'hash_maps',
      'map': 'hash_maps',
      'dict': 'hash_maps',
      'linked': 'linked_lists',
      'stack': 'stacks',
      'binary': 'binary_search',
      'search': 'binary_search',
      'recur': 'recursion',
      'sort': 'sorting',
    };
    for (final MapEntry<String, String> e in keys.entries) {
      if (needle.contains(e.key)) {
        final CsW3sTopic? hit = CsW3sCatalog.byId(e.value);
        if (hit != null) return hit;
      }
    }
    return null;
  }

  static String _languageFromTrack(String trackTitle, CsW3sTopic topic) {
    final String t = trackTitle.toLowerCase();
    if (t.contains('html')) return 'html';
    if (t.contains('css')) return 'css';
    if (t.contains('javascript') || t.contains('js')) return 'javascript';
    if (t.contains('typescript') || t.contains('ts')) return 'typescript';
    if (t.contains('java') && !t.contains('javascript')) return 'java';
    if (t.contains('c++') || t.contains('cpp')) return 'cpp';
    if (t.contains('c#')) return 'csharp';
    if (t.contains('python')) return 'python3';
    if (topic.tryIt.startersByLanguage.containsKey('python3')) return 'python3';
    if (topic.tryIt.starterCode.isNotEmpty) return 'python3';
    return CodingLanguage.defaultLanguage.id;
  }

  static String _labelFor(String id) {
    final CodingLanguage? lang = CodingLanguage.byId(id);
    if (lang != null) return lang.label;
    return switch (id) {
      'html' => 'HTML',
      'css' => 'CSS',
      'javascript' => 'JavaScript',
      _ => id,
    };
  }

  static VuV2CsTryItSpec _generated({
    required String topicTitle,
    required String topicId,
    required String trackTitle,
    required String courseTitle,
  }) {
    final String langId = _languageFromTrack(
      trackTitle,
      CsW3sCatalog.defaultTopic,
    );
    final String starter = _starterFor(langId, topicTitle);
    return VuV2CsTryItSpec(
      topicId: topicId,
      topicTitle: topicTitle,
      task:
          'Try it yourself: write a small program that demonstrates "$topicTitle" '
          'from $courseTitle. Edit the starter, then Run.',
      starterCode: starter,
      runContext:
          'Print or return something that clearly shows you used $topicTitle correctly.',
      languageId: langId,
      languageLabel: _labelFor(langId),
      exampleInput: 'Concept: $topicTitle',
      exampleOutput: 'A working mini demo',
      exampleSteps:
          '1) Read the task\n2) Edit the starter code\n3) Press Run\n4) Fix until output matches the goal',
      syntaxBullets: <String>[
        'Keep the example tiny — one clear idea.',
        'Use print / console output so you can see results.',
        'Change one thing at a time, then Run again.',
        'When it works, open the full coding lab for harder problems.',
      ],
    );
  }

  static String _starterFor(String langId, String topic) {
    final String safe = topic.replaceAll('"', "'");
    return switch (langId) {
      'html' =>
        '<!DOCTYPE html>\n<html>\n<head>\n  <title>$safe</title>\n</head>\n<body>\n  <h1>$safe</h1>\n  <!-- Try it yourself: edit this page -->\n  <p>Practice $safe here.</p>\n</body>\n</html>\n',
      'css' =>
        '/* Try it yourself: $safe */\nbody {\n  font-family: system-ui, sans-serif;\n  background: #0f172a;\n  color: #e2e8f0;\n}\n\nh1 {\n  color: #fb923c;\n}\n',
      'javascript' || 'typescript' =>
        '// Try it yourself: $safe\nfunction demo() {\n  const message = "Learning: $safe";\n  console.log(message);\n  return message;\n}\n\ndemo();\n',
      'java' =>
        '// Try it yourself: $safe\npublic class Main {\n  public static void main(String[] args) {\n    System.out.println("Learning: $safe");\n  }\n}\n',
      'cpp' =>
        '// Try it yourself: $safe\n#include <iostream>\nint main() {\n  std::cout << "Learning: $safe" << std::endl;\n  return 0;\n}\n',
      _ =>
        '# Try it yourself: $safe\n# Edit this code, then press Run.\n\nprint("Learning:", "$safe")\n\n# TODO: add 3–6 lines that show the idea in action\n',
    };
  }

  static String _slug(String title) => title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
