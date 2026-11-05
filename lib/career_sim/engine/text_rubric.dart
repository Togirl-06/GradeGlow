/// Deterministic scoring of written answers (cover letters, write-ups,
/// interview answers, handoff notes).
///
/// A concept only counts when it appears inside a real sentence (five or more
/// words), so a list of keywords does not score. Length, sentence structure
/// and repetition also count. This is a published rule, not AI judgement.
library;

class Concept {
  const Concept(this.id, this.label, this.anyOf, {this.weight = 1});

  final String id;

  /// What the employer/lecturer is looking for, shown to the student.
  final String label;

  /// Accepted phrasings. `*` at the end of a word matches any ending
  /// (`prioriti*` matches prioritise, prioritize, prioritised …).
  final List<String> anyOf;
  final double weight;
}

class TextAssessment {
  const TextAssessment({
    required this.score,
    required this.coverage,
    required this.structure,
    required this.words,
    required this.sentences,
    required this.hits,
    required this.misses,
    required this.notes,
  });

  final int score;
  final double coverage;
  final double structure;
  final int words;
  final int sentences;
  final List<Concept> hits;
  final List<Concept> misses;
  final List<String> notes;
}

abstract final class TextRubric {
  static final RegExp _wordRe = RegExp(r"[a-z0-9']+");
  static final Map<String, RegExp> _cache = <String, RegExp>{};

  static List<String> words(String text) =>
      _wordRe.allMatches(text.toLowerCase()).map((Match m) => m.group(0)!).toList();

  static List<String> sentences(String text) => text
      .split(RegExp(r'[.!?;\n]+'))
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();

  static RegExp _phrase(String phrase) {
    return _cache.putIfAbsent(phrase, () {
      final List<String> parts = phrase.toLowerCase().trim().split(RegExp(r'\s+'));
      final String body = parts.map((String p) {
        final bool stem = p.endsWith('*');
        final String core = RegExp.escape(stem ? p.substring(0, p.length - 1) : p);
        return stem ? '$core[a-z0-9]*' : core;
      }).join(r'\s+');
      return RegExp('(?<![a-z0-9])$body(?![a-z0-9])');
    });
  }

  static bool mentions(String text, Concept c) {
    final String lower = text.toLowerCase();
    return c.anyOf.any((String p) => _phrase(p).hasMatch(lower));
  }

  /// Scores [text] against [concepts]. 75% concept coverage, 25% structure.
  static TextAssessment assess(
    String text,
    List<Concept> concepts, {
    int minWords = 40,
    int maxWords = 400,
  }) {
    final List<String> allWords = words(text);
    final List<String> substantive = sentences(text)
        .where((String s) => words(s).length >= 5)
        .toList();
    final String countable = substantive.join('. ');
    final List<Concept> hits = <Concept>[];
    final List<Concept> misses = <Concept>[];
    double got = 0;
    double total = 0;
    for (final Concept c in concepts) {
      total += c.weight;
      if (mentions(countable, c)) {
        hits.add(c);
        got += c.weight;
      } else {
        misses.add(c);
      }
    }
    final double coverage = total == 0 ? 1 : got / total;

    final List<String> notes = <String>[];
    final int n = allWords.length;
    double lengthFactor;
    if (n < minWords) {
      lengthFactor = minWords == 0 ? 1 : n / minWords;
      notes.add('Too short: $n words (at least $minWords expected).');
    } else if (n > maxWords) {
      lengthFactor = maxWords / n;
      notes.add('Too long: $n words (keep it under $maxWords).');
    } else {
      lengthFactor = 1;
    }
    double sentenceFactor = 1;
    if (substantive.length < 2) {
      sentenceFactor = 0.5;
      notes.add('Write in full sentences, not fragments or keyword lists.');
    }
    double repetition = 1;
    if (n >= 20) {
      final double unique = allWords.toSet().length / n;
      if (unique < 0.35) {
        repetition = 0.6;
        notes.add('Very repetitive wording.');
      }
    }
    final double structure = (lengthFactor * sentenceFactor).clamp(0, 1).toDouble();
    double raw = (0.75 * coverage + 0.25 * structure) * repetition;
    if (n < minWords / 2) raw = raw.clamp(0, 0.3).toDouble();
    if (allWords.isEmpty) raw = 0;
    return TextAssessment(
      score: (raw * 100).round().clamp(0, 100),
      coverage: coverage,
      structure: structure,
      words: n,
      sentences: substantive.length,
      hits: hits,
      misses: misses,
      notes: notes,
    );
  }
}
