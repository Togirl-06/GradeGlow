import '../models/topic_profile.dart';

/// Filters questions and builds AI scope instructions from a [TopicProfile].
class TopicScopeValidator {
  TopicScopeValidator._();

  static List<String> filterQuestions(List<String> questions, TopicProfile profile) {
    return questions.where((String q) => isOnTopic(q, profile)).toList();
  }

  static bool isOnTopic(String question, TopicProfile profile) {
    final String lower = question.toLowerCase().trim();
    if (lower.isEmpty) return false;

    for (final String term in profile.forbiddenTerms) {
      if (term.isEmpty) continue;
      if (_containsTerm(lower, term)) return false;
    }

    if (!profile.strictScoping) return true;

    final List<String> anchors = _anchorTerms(profile);
    if (anchors.isEmpty) return true;

    for (final String anchor in anchors) {
      if (_containsTerm(lower, anchor)) return true;
    }
    return false;
  }

  static String buildAiScopeBlock(TopicProfile profile) {
    final StringBuffer buf = StringBuffer()
      ..writeln('STRICT TOPIC SCOPE — generate content ONLY for this exact topic.')
      ..writeln('Subject course topic path: ${profile.subjectId ?? "?"} → ${profile.courseId ?? "?"} → ${profile.topicName}')
      ..writeln('Domain: ${profile.domain}')
      ..writeln()
      ..writeln('LEARNING OBJECTIVES (every question must test one of these):');
    for (final String obj in profile.learningObjectives) {
      buf.writeln('- $obj');
    }
    buf
      ..writeln()
      ..writeln('SKILLS TO TEST: ${profile.skillsToTest.join(", ")}');
    if (profile.allowedDiagramIds.isNotEmpty) {
      buf.writeln('ALLOWED DIAGRAMS ONLY: ${profile.allowedDiagramIds.join(", ")}');
    }
    buf
      ..writeln()
      ..writeln('FORBIDDEN — never ask about these (wrong topic or course):');
    final List<String> forbidden = profile.forbiddenTerms.take(24).toList();
    for (final String term in forbidden) {
      buf.writeln('- $term');
    }
    if (profile.forbiddenTerms.length > 24) {
      buf.writeln('- (and ${profile.forbiddenTerms.length - 24} other off-topic areas)');
    }
    buf.writeln();
    buf.writeln('If a question could belong to another course unit or body system, discard it.');
    buf.writeln('Topic accuracy is more important than question count.');
    return buf.toString();
  }

  /// Topic-scoped stems derived from learning objectives (replaces generic fillers).
  static List<String> objectiveStems(TopicProfile profile, String difficulty) {
    final String d = difficulty.toLowerCase();
    final String level = d.contains('adv')
        ? 'Critically evaluate'
        : d.contains('inter')
            ? 'Apply'
            : 'Explain';
    final List<String> stems = <String>[];
    for (int i = 0; i < profile.learningObjectives.length; i++) {
      final String obj = profile.learningObjectives[i];
      stems.addAll(<String>[
        '$level: $obj',
        'Practice ${i + 1}: How does $obj relate to ${profile.topicName}?',
        'Exam-style: Test your understanding of $obj in ${profile.topicName}.',
      ]);
    }
    return stems;
  }

  static List<String> _anchorTerms(TopicProfile profile) {
    final Set<String> anchors = <String>{};

    void addWords(String text) {
      for (final String word in text.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
        if (word.length >= 4) anchors.add(word);
      }
    }

    addWords(profile.topicName);
    addWords(profile.topicId.replaceAll('_', ' '));
    for (final String obj in profile.learningObjectives) {
      addWords(obj);
    }
    for (final String key in profile.questionBankKeys) {
      if (key.length >= 4) anchors.add(key.toLowerCase());
    }

    for (final String forbidden in profile.forbiddenTerms) {
      anchors.remove(forbidden.toLowerCase());
    }

    return anchors.toList();
  }

  static bool _containsTerm(String haystack, String term) {
    final String t = term.toLowerCase().trim();
    if (t.isEmpty) return false;
    if (t.contains(' ')) return haystack.contains(t);
    final RegExp boundary = RegExp(r'\b' + RegExp.escape(t) + r'\b');
    return boundary.hasMatch(haystack);
  }
}
