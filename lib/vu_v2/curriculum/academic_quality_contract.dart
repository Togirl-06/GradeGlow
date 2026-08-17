import '../data/vu_v2_topic_content_models.dart';

/// Content that fails this contract is never shown as lecture notes.
abstract final class TextbookQualityContract {
  static const int minimumWords = 2800;
  static const int minimumSections = 14;

  static const List<String> requiredTitles = <String>[
    'Learning Objectives',
    '1.1 Introduction',
    'Worked Example',
    'Clinical Connection',
    'Common Misconceptions',
    'Check Your Understanding',
    'Chapter Summary',
    'Key Terms',
    'Review Questions',
    'Application Questions',
    'Case Study',
  ];

  static const List<String> bannedFragments = <String>[
    'names the core idea this chapter teaches',
    'Invent a realistic prompt',
    'fill-in',
    'Write the central relation',
    'A learner faces a standard problem involving',
  ];

  static TextbookQualityReport inspect(List<VuV2TextbookSection> sections) {
    final List<String> defects = <String>[];
    if (sections.length < minimumSections) {
      defects.add('Fewer than $minimumSections sections.');
    }
    final Set<String> titles = sections.map((VuV2TextbookSection s) => s.title).toSet();
    for (final String required in requiredTitles) {
      if (!titles.contains(required)) {
        defects.add('Missing section: $required');
      }
    }
    final int words = sections.fold<int>(
      0,
      (int n, VuV2TextbookSection s) =>
          n + s.body.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length,
    );
    if (words < minimumWords) {
      defects.add('Only $words words; need $minimumWords+ of instructional prose.');
    }
    final String blob = sections.map((VuV2TextbookSection s) => s.body).join('\n');
    for (final String banned in bannedFragments) {
      if (blob.contains(banned)) {
        defects.add('Template leftover: "$banned"');
      }
    }
    final bool summaryLike = (blob.contains('consists of bones. Bones provide support') &&
            !blob.toLowerCase().contains('almost useless') &&
            !blob.toLowerCase().contains('it is a summary')) ||
        (words < 900 && blob.split('.').length < 12);
    if (summaryLike) {
      defects.add('Reads as a summary, not a teaching chapter.');
    }
    return TextbookQualityReport(wordCount: words, defects: defects);
  }
}

class TextbookQualityReport {
  const TextbookQualityReport({required this.wordCount, required this.defects});

  final int wordCount;
  final List<String> defects;

  bool get publishable => defects.isEmpty;
}

/// Labs that fail this contract are not opened as a university laboratory.
abstract final class LabQualityContract {
  static const List<String> requiredBeats = <String>[
    'scenario',
    'objectives',
    'equipment',
    'procedure',
    'data',
    'analysis',
    'report',
  ];

  static bool allowsQuizLab(String description) {
    final String d = description.toLowerCase();
    if (d.contains('click a') && d.contains('correctindex')) return false;
    if (d.contains('multiple-choice') && !d.contains('hypothesis')) return false;
    return true;
  }

  static LabQualityReport inspectSpec(InvestigationSpecLike spec) {
    final List<String> defects = <String>[];
    if (spec.scenario.trim().isEmpty) defects.add('Missing scenario');
    if (spec.objectives.isEmpty) defects.add('Missing objectives');
    if (spec.equipment.isEmpty) defects.add('Missing equipment');
    if (spec.procedure.isEmpty) defects.add('Missing procedure');
    for (final String beat in requiredBeats) {
      if (!spec.beats.contains(beat)) {
        defects.add('Missing lab beat: $beat');
      }
    }
    if (spec.scenario.toLowerCase().contains('click the nucleus') &&
        spec.scenario.toLowerCase().contains('identify the cell')) {
      defects.add('Quiz wearing a lab coat');
    }
    return LabQualityReport(defects: defects);
  }
}

/// Minimal surface so the contract does not import the investigation package.
class InvestigationSpecLike {
  const InvestigationSpecLike({
    required this.scenario,
    required this.objectives,
    required this.equipment,
    required this.procedure,
    required this.beats,
  });

  final String scenario;
  final List<String> objectives;
  final List<String> equipment;
  final List<String> procedure;
  final List<String> beats;
}

class LabQualityReport {
  const LabQualityReport({required this.defects});
  final List<String> defects;
  bool get publishable => defects.isEmpty;
}
