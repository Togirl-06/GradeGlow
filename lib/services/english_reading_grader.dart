import '../config/app_config.dart';
import '../models/english_lesson.dart';
import 'english_lesson_engine.dart';
import 'openai_service.dart';

/// Grades read-aloud attempts — OpenAI when available, word overlap locally.
class EnglishReadingGrader {
  const EnglishReadingGrader({OpenAiService? openAi}) : _openAi = openAi;

  final OpenAiService? _openAi;

  Future<GradeResult> grade({
    required EnglishActivity activity,
    required String transcript,
    required String lessonTitle,
  }) async {
    final String passage = (activity.listeningScript ?? '').trim();
    final String spoken = transcript.trim();

    if (spoken.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'We did not catch your voice — tap the mic and read the passage.',
        note: 'Empty transcript',
      );
    }

    if (passage.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'This reading step is missing its passage text.',
        note: 'Missing passage',
      );
    }

    final OpenAiService? openAi = _openAi;
    if (AppConfig.hasOpenAi && openAi != null) {
      try {
        final Map<String, dynamic> ai = await openAi.gradeEnglishReadingAloud(
          lessonTitle: lessonTitle,
          passage: passage,
          studentTranscript: spoken,
          taskPrompt: activity.prompt,
        );
        return _fromAi(activity, ai, passage, spoken);
      } catch (_) {
        // Fall through to local grading.
      }
    }

    return _gradeLocally(activity, passage, spoken);
  }

  GradeResult _fromAi(
    EnglishActivity activity,
    Map<String, dynamic> ai,
    String passage,
    String spoken,
  ) {
    final bool correct = ai['correct'] == true;
    final String? feedbackRaw = (ai['feedback'] as String?)?.trim();
    final int overall = _intOr(ai['overall'], correct ? 82 : 58);
    final int pronunciation = _intOr(ai['pronunciation'], overall);
    final int fluency = _intOr(ai['fluency'], overall);
    final int accuracy = _intOr(ai['accuracy'], overall);
    final List<String> mispronounced = _stringList(ai['mispronouncedWords']);
    final List<String> practice = _stringList(ai['practiceWords']);

    final EnglishReadingGradeDetail detail = EnglishReadingGradeDetail(
      overall: overall,
      pronunciation: pronunciation,
      fluency: fluency,
      accuracy: accuracy,
      feedback: feedbackRaw ??
          (correct
              ? 'Strong reading!'
              : 'Read the passage more clearly and try again.'),
      mispronouncedWords: mispronounced,
      practiceWords: practice,
      correct: correct,
    );

    final String feedback = _formatFeedback(detail, mispronounced, practice);

    return GradeResult(
      correct: correct,
      feedback: feedback,
      note: 'AI reading grade',
      readingDetail: detail,
    );
  }

  GradeResult _gradeLocally(
    EnglishActivity activity,
    String passage,
    String spoken,
  ) {
    final double wordAccuracy = _wordAccuracy(passage, spoken);
    final double coverage = _wordCoverage(passage, spoken);
    final bool correct = wordAccuracy >= 0.72 && coverage >= 0.65;

    final int overall = (wordAccuracy * 55 + coverage * 45).round().clamp(0, 100);
    final int pronunciation = (wordAccuracy * 100).round().clamp(0, 100);
    final int fluency = (coverage * 100).round().clamp(0, 100);
    final int accuracy = overall;

    final List<String> missed = _missedWords(passage, spoken);

    String baseFeedback;
    if (correct) {
      baseFeedback = activity.feedbackCorrect ??
          'Nice reading — you covered the passage clearly.';
    } else if (coverage < 0.65) {
      baseFeedback = activity.feedbackWrong ??
          'Read the entire passage — you stopped too early or skipped words.';
    } else {
      baseFeedback = activity.feedbackWrong ??
          'Several words did not match — slow down and read each line carefully.';
    }

    final EnglishReadingGradeDetail detail = EnglishReadingGradeDetail(
      overall: overall,
      pronunciation: pronunciation,
      fluency: fluency,
      accuracy: accuracy,
      feedback: baseFeedback,
      mispronouncedWords: missed.take(8).toList(),
      practiceWords: missed.take(5).toList(),
      correct: correct,
    );

    return GradeResult(
      correct: correct,
      feedback: _formatFeedback(detail, detail.mispronouncedWords, detail.practiceWords),
      note: 'Local reading ($overall/100)',
      readingDetail: detail,
    );
  }

  String _formatFeedback(
    EnglishReadingGradeDetail detail,
    List<String> mispronounced,
    List<String> practice,
  ) {
    final StringBuffer buf = StringBuffer(detail.feedback);
    buf.write(
      '\n\nScores — Overall: ${detail.overall}/100 · '
      'Pronunciation: ${detail.pronunciation} · '
      'Fluency: ${detail.fluency} · '
      'Accuracy: ${detail.accuracy}',
    );
    if (mispronounced.isNotEmpty) {
      buf.write('\n\nWords to practice: ${mispronounced.join(', ')}');
    }
    if (practice.isNotEmpty && practice.length != mispronounced.length) {
      buf.write('\nFocus on: ${practice.join(', ')}');
    }
    return buf.toString();
  }

  List<String> _missedWords(String expected, String spoken) {
    final List<String> exp = _tokens(expected);
    final Set<String> got = _tokens(spoken).toSet();
    final List<String> missed = <String>[];
    for (final String word in exp) {
      if (!got.contains(word) && word.length > 3) {
        missed.add(word);
      }
    }
    return missed;
  }

  double _wordAccuracy(String expected, String spoken) {
    final List<String> exp = _tokens(expected);
    final List<String> got = _tokens(spoken);
    if (exp.isEmpty || got.isEmpty) return 0;

    int hits = 0;
    int j = 0;
    for (final String word in exp) {
      while (j < got.length && got[j] != word) {
        j++;
      }
      if (j < got.length) {
        hits++;
        j++;
      }
    }
    return hits / exp.length;
  }

  double _wordCoverage(String expected, String spoken) {
    final List<String> exp = _tokens(expected);
    final List<String> got = _tokens(spoken);
    if (exp.isEmpty) return 0;
    final Set<String> gotSet = got.toSet();
    int hits = 0;
    for (final String word in exp) {
      if (gotSet.contains(word)) hits++;
    }
    return hits / exp.length;
  }

  List<String> _tokens(String raw) => _normalize(raw)
      .split(RegExp(r'\s+'))
      .where((String w) => w.length > 1)
      .toList();

  String _normalize(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();

  int _intOr(dynamic value, int fallback) {
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.round().clamp(0, 100);
    return fallback.clamp(0, 100);
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((dynamic e) => '$e').where((String s) => s.isNotEmpty).toList();
  }
}
