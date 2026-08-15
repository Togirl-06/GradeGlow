import '../models/english_lesson.dart';
import 'english_lesson_engine.dart';

/// Instant local grading for typed English answers (no network wait).
class EnglishWritingGrader {
  const EnglishWritingGrader();

  GradeResult gradeSync({
    required EnglishActivity activity,
    required dynamic answer,
    required String lessonTitle,
  }) {
    final EnglishWrittenSubmission submission = _asSubmission(answer);
    final String body = submission.body.trim();
    if (body.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'Write your answer before submitting.',
        note: 'Empty',
      );
    }

    if (activity.kind == EnglishActivityKind.emailWriting) {
      return _gradeEmail(activity, submission);
    }

    if (activity.kind == EnglishActivityKind.essayWriting) {
      return _gradeEssay(activity, body);
    }

    if (_isMcKind(activity)) {
      return _gradeWrittenChoice(activity, body);
    }

    if (activity.kind == EnglishActivityKind.sentenceRewrite ||
        activity.kind == EnglishActivityKind.combineSentences ||
        activity.kind == EnglishActivityKind.transformWriting) {
      return _gradeText(activity, body);
    }

    if (activity.kind == EnglishActivityKind.paragraphCorrection) {
      return _gradeParagraph(activity, body);
    }

    if (_isChoiceAsWriting(activity)) {
      return _gradeWrittenChoice(activity, body);
    }

    if (activity.kind == EnglishActivityKind.shortWriting ||
        activity.gradingCriteria.isNotEmpty ||
        activity.targetName != null) {
      if (activity.targetName != null) {
        return _gradeNamedGreeting(activity, body);
      }
      return _gradeRubric(activity, body);
    }

    if (activity.kind == EnglishActivityKind.fillBlank ||
        activity.kind == EnglishActivityKind.questionCard ||
        activity.kind == EnglishActivityKind.miniConversation) {
      return _gradeText(activity, body);
    }

    if (activity.kind == EnglishActivityKind.correction) {
      return _gradeCorrection(activity, body);
    }

    if (activity.kind == EnglishActivityKind.speaking) {
      return _gradeText(activity, body);
    }

    return GradeResult(
      correct: false,
      feedback: activity.feedbackWrong ?? 'Check your answer and try again.',
      note: activity.prompt,
    );
  }

  bool _isMcKind(EnglishActivity activity) {
    return activity.kind == EnglishActivityKind.explainError ||
        activity.kind == EnglishActivityKind.bestSentence ||
        activity.kind == EnglishActivityKind.readingInference ||
        activity.kind == EnglishActivityKind.vocabularyContext;
  }

  bool _isChoiceAsWriting(EnglishActivity activity) {
    return activity.kind == EnglishActivityKind.multipleChoice ||
        activity.kind == EnglishActivityKind.rapidReview ||
        activity.kind == EnglishActivityKind.listening;
  }

  EnglishWrittenSubmission _asSubmission(dynamic answer) {
    if (answer is EnglishWrittenSubmission) return answer;
    return EnglishWrittenSubmission(body: answer is String ? answer : '$answer');
  }

  GradeResult _gradeEmail(
    EnglishActivity activity,
    EnglishWrittenSubmission submission,
  ) {
    final String body = submission.body.trim();
    final String recipient = (submission.recipient ?? '').trim();
    if (activity.pickRecipient && recipient.length < 2) {
      return const GradeResult(
        correct: false,
        feedback: 'Add who you are writing to (To: name or role).',
        note: 'Recipient',
      );
    }

    if (_wordCount(body) < activity.minWords) {
      return GradeResult(
        correct: false,
        feedback: 'Write a bit more (${activity.minWords}+ words in the email).',
        note: activity.prompt,
      );
    }

    return _gradeEmailRubric(activity, body, recipient);
  }

  GradeResult _gradeEmailRubric(
    EnglishActivity activity,
    String body,
    String recipient,
  ) {
    final String norm = _normalize(body);
    final EnglishWritingTone tone =
        activity.writingTone ?? EnglishWritingTone.any;
    int score = 0;
    final List<String> missing = <String>[];

    if (recipient.length >= 2) score += 1;

    if (tone == EnglishWritingTone.formal) {
      if (_hasFormalOpening(body)) {
        score += 2;
      } else {
        missing.add('formal opening (Dear …,)');
      }
      if (_hasFormalClosing(body)) {
        score += 2;
      } else {
        missing.add('formal closing (Best regards / Sincerely)');
      }
      if (_hasPoliteRequest(body)) score += 1;
      if (!_hasSlang(body)) score += 1;
    } else if (tone == EnglishWritingTone.informal) {
      if (_hasInformalOpening(body)) {
        score += 2;
      } else {
        missing.add('casual greeting (Hi / Hey …)');
      }
      if (_hasInformalClosing(body)) score += 1;
      if (norm.length >= 20) score += 2;
    } else {
      if (_hasFormalOpening(body) || _hasInformalOpening(body)) score += 2;
      if (_hasFormalClosing(body) || _hasInformalClosing(body)) score += 1;
    }

    if (_wordCount(body) >= activity.minWords) score += 1;

    for (final String criterion in activity.gradingCriteria) {
      final String key = _normalize(criterion);
      if (key.length >= 3 && norm.contains(key)) score += 1;
    }

    final bool correct = score >= 5;
    return GradeResult(
      correct: correct,
      feedback: correct
          ? (activity.feedbackCorrect ?? 'Well-written email!')
          : (missing.isEmpty
              ? (activity.feedbackWrong ??
                  'Add clearer structure — greeting, message, closing.')
              : 'Missing: ${missing.join(', ')}.'),
      note: activity.prompt,
    );
  }

  GradeResult _gradeNamedGreeting(EnglishActivity activity, String body) {
    final String norm = _normalize(body);
    final String name = _normalize(activity.targetName ?? '');
    final EnglishWritingTone tone =
        activity.writingTone ?? EnglishWritingTone.any;

    if (name.isNotEmpty && !norm.contains(name)) {
      return GradeResult(
        correct: false,
        feedback: activity.feedbackWrong ??
            'Include the name ${activity.targetName} in your greeting.',
        note: activity.prompt,
      );
    }

    if (tone == EnglishWritingTone.formal) {
      if (!_hasFormalOpening(body)) {
        return GradeResult(
          correct: false,
          feedback: activity.feedbackWrong ??
              'Formal letters start with Dear ${activity.targetName ?? 'name'},',
          note: activity.prompt,
        );
      }
    } else if (tone == EnglishWritingTone.informal) {
      if (!_hasInformalOpening(body)) {
        return GradeResult(
          correct: false,
          feedback: activity.feedbackWrong ??
              'Informal letters use Hi ${activity.targetName ?? 'name'}, or Hey ${activity.targetName ?? 'name'},',
          note: activity.prompt,
        );
      }
    }

    return GradeResult(
      correct: true,
      feedback: activity.feedbackCorrect ?? 'Good greeting!',
      note: '',
    );
  }

  GradeResult _gradeRubric(EnglishActivity activity, String body) {
    final String norm = _normalize(body);
    if (_wordCount(body) < activity.minWords) {
      return GradeResult(
        correct: false,
        feedback: 'Write at least ${activity.minWords} words.',
        note: activity.prompt,
      );
    }

    int hits = 0;
    for (final String token in activity.acceptableAnswers) {
      if (norm.contains(_normalize(token))) hits += 1;
    }
    for (final String criterion in activity.gradingCriteria) {
      if (norm.contains(_normalize(criterion))) hits += 1;
    }
    if (activity.correctAnswer != null &&
        norm.contains(_normalize(activity.correctAnswer!))) {
      hits += 2;
    }

    final bool correct = hits >= 1 || activity.acceptableAnswers.isEmpty;
    return GradeResult(
      correct: correct,
      feedback: correct
          ? (activity.feedbackCorrect ?? 'Good answer!')
          : (activity.feedbackWrong ?? 'Try again with more detail.'),
      note: activity.prompt,
    );
  }

  GradeResult _gradeWrittenChoice(EnglishActivity activity, String body) {
    final String? expected = _expectedChoiceText(activity);
    if (expected == null) {
      return const GradeResult(
        correct: false,
        feedback: 'Could not grade this question.',
        note: '',
      );
    }
    final String norm = _normalize(body);
    final String exp = _normalize(expected);

    if (norm == exp || norm.contains(exp) || exp.contains(norm)) {
      return GradeResult(
        correct: true,
        feedback: activity.feedbackCorrect ?? 'Correct!',
        note: '',
      );
    }

    for (final String option in activity.options) {
      final String optNorm = _normalize(option);
      if (optNorm == norm || norm.contains(optNorm) || optNorm.contains(norm)) {
        final bool ok = activity.options.indexOf(option) == activity.correctIndex;
        return GradeResult(
          correct: ok,
          feedback: ok
              ? (activity.feedbackCorrect ?? 'Correct!')
              : (activity.feedbackWrong ?? 'Not quite — check the pattern.'),
          note: activity.prompt,
        );
      }
    }

    return GradeResult(
      correct: false,
      feedback: activity.feedbackWrong ??
          'Write the full correct answer. Hint: "$expected"',
      note: activity.prompt,
    );
  }

  String? _expectedChoiceText(EnglishActivity activity) {
    final int? idx = activity.correctIndex;
    if (idx == null || idx < 0 || idx >= activity.options.length) return null;
    return activity.options[idx];
  }

  GradeResult _gradeText(EnglishActivity activity, String body) {
    final String norm = _normalize(body);
    final List<String> acceptable = <String>[
      if (activity.correctAnswer != null) activity.correctAnswer!,
      ...activity.acceptableAnswers,
    ];
    if (acceptable.isEmpty) {
      if (_wordCount(body) >= activity.minWords) {
        return GradeResult(
          correct: true,
          feedback: activity.feedbackCorrect ?? 'Good!',
          note: '',
        );
      }
      return GradeResult(
        correct: false,
        feedback: 'Try a bit more (${activity.minWords}+ words).',
        note: activity.prompt,
      );
    }
    for (final String candidate in acceptable) {
      final String c = _normalize(candidate);
      if (norm == c || norm.contains(c)) {
        return GradeResult(
          correct: true,
          feedback: activity.feedbackCorrect ?? 'Exactly!',
          note: '',
        );
      }
    }
    return GradeResult(
      correct: false,
      feedback: activity.feedbackWrong ?? 'Try again.',
      note: activity.prompt,
    );
  }

  GradeResult _gradeEssay(EnglishActivity activity, String body) {
    final String norm = _normalize(body);
    if (_wordCount(body) < activity.minWords) {
      return GradeResult(
        correct: false,
        feedback:
            'Develop your essay further (${activity.minWords}+ words). '
            'Include a clear thesis, supporting points, and conclusion.',
        note: activity.prompt,
      );
    }

    int score = 0;
    final List<String> missing = <String>[];
    if (body.contains('.') && _wordCount(body) >= activity.minWords) score += 2;
    if (RegExp(r'\b(first|second|however|therefore|because)\b',
            caseSensitive: false)
        .hasMatch(body)) {
      score += 1;
    }

    for (final String criterion in activity.gradingCriteria) {
      if (norm.contains(_normalize(criterion))) {
        score += 1;
      } else if (criterion.length >= 4) {
        missing.add(criterion);
      }
    }

    final bool correct = score >= 3;
    return GradeResult(
      correct: correct,
      feedback: correct
          ? (activity.feedbackCorrect ??
              'Strong essay structure and argument!')
          : (missing.isEmpty
              ? 'Strengthen your thesis and add more supporting evidence.'
              : 'Consider: ${missing.take(3).join(', ')}.'),
      note: activity.prompt,
    );
  }

  GradeResult _gradeParagraph(EnglishActivity activity, String body) {
    final String norm = _normalize(body);
    final String expected = _normalize(
      activity.correctedSentence ?? activity.correctAnswer ?? '',
    );
    if (norm.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'Type the corrected paragraph.',
        note: 'Paragraph correction',
      );
    }
    final double overlap = _tokenOverlap(norm, expected);
    final bool ok = overlap >= 0.72 || norm.contains(expected);
    return GradeResult(
      correct: ok,
      feedback: ok
          ? (activity.feedbackCorrect ?? 'All key corrections applied!')
          : (activity.feedbackWrong ??
              'Fix grammar throughout — check verb tenses, articles, and agreement.'),
      note: activity.incorrectSentence ?? activity.prompt,
    );
  }

  double _tokenOverlap(String a, String b) {
    final Set<String> ta = a.split(RegExp(r'\s+')).where((String w) => w.length > 2).toSet();
    final Set<String> tb = b.split(RegExp(r'\s+')).where((String w) => w.length > 2).toSet();
    if (ta.isEmpty || tb.isEmpty) return 0;
    int hits = 0;
    for (final String w in ta) {
      if (tb.contains(w)) hits++;
    }
    return hits / tb.length;
  }

  GradeResult _gradeCorrection(EnglishActivity activity, String body) {
    final String norm = _normalize(body);
    final String expected = _normalize(
      activity.correctedSentence ?? activity.correctAnswer ?? '',
    );
    if (norm.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'Type the corrected sentence.',
        note: 'Correction',
      );
    }
    final bool ok = norm == expected || norm.contains(expected);
    return GradeResult(
      correct: ok,
      feedback: ok
          ? (activity.feedbackCorrect ?? 'Fixed!')
          : (activity.feedbackWrong ??
              'Use: "${activity.correctedSentence ?? activity.correctAnswer}"'),
      note: activity.incorrectSentence ?? activity.prompt,
    );
  }

  int _wordCount(String text) =>
      text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;

  String _normalize(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();

  bool _hasFormalOpening(String body) =>
      RegExp(r'\bdear\b', caseSensitive: false).hasMatch(body);

  bool _hasInformalOpening(String body) =>
      RegExp(r'\b(hi|hey|hello)\b', caseSensitive: false).hasMatch(body);

  bool _hasFormalClosing(String body) =>
      RegExp(
        r'\b(best regards|kind regards|sincerely|yours sincerely)\b',
        caseSensitive: false,
      ).hasMatch(body);

  bool _hasInformalClosing(String body) =>
      RegExp(r'\b(bye|cheers|see you|talk soon|thanks)\b', caseSensitive: false)
          .hasMatch(body);

  bool _hasPoliteRequest(String body) =>
      RegExp(r'\b(could|would|please|may i)\b', caseSensitive: false)
          .hasMatch(body);

  bool _hasSlang(String body) =>
      RegExp(r'\b(yo|lol|gimme|thx|wtf)\b', caseSensitive: false).hasMatch(body);
}
