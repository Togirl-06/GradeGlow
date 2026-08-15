import 'package:flutter/foundation.dart';

import '../models/english_lesson.dart';
import '../data/english/english_question_bank.dart';
import '../utils/spaced_repetition.dart';
import 'english_adaptive_service.dart';
import 'english_lesson_mixer.dart';
import 'english_writing_grader.dart';

/// Runtime lesson engine — mixes easy and hard steps each session.
class EnglishLessonEngine extends ChangeNotifier {
  EnglishLessonEngine(
    this.script, {
    this.streakMultiplier = 1.0,
    this.useQuestionBank = true,
    this.learnerLevel = EnglishCefrLevel.b1,
  });

  final EnglishLessonScript script;
  final double streakMultiplier;
  final bool useQuestionBank;
  final EnglishCefrLevel learnerLevel;
  final EnglishLessonMixer _mixer = const EnglishLessonMixer();
  final EnglishAdaptiveService _adaptive = const EnglishAdaptiveService();
  static const EnglishWritingGrader _writingGrader = EnglishWritingGrader();

  final List<EnglishActivity> _queue = <EnglishActivity>[];
  int _index = 0;
  EnglishLessonPhase _phase = EnglishLessonPhase.microPrompt;
  String? _feedback;
  bool _lastCorrect = false;
  int _baseXp = 0;
  int _bonusXp = 0;
  int _correct = 0;
  int _attempted = 0;
  int _streak = 0;
  int _maxStreak = 0;
  double _difficulty = 1.0;
  final List<EnglishMistakeRecord> _mistakes = <EnglishMistakeRecord>[];
  final Set<String> _wordsSeen = <String>{};
  final Map<String, Sm2State> _reviewSchedule = <String, Sm2State>{};
  EnglishLessonResult? _result;
  EnglishReadingGradeDetail? _lastReadingDetail;
  bool _disposed = false;
  int _retriesInjected = 0;

  int get currentIndex => _index;
  EnglishLessonPhase get phase => _phase;
  String? get feedback => _feedback;
  bool get lastCorrect => _lastCorrect;
  int get xp => _baseXp + _bonusXp;
  int get baseXp => _baseXp;
  int get bonusXp => _bonusXp;
  int get streak => _streak;
  int get maxStreak => _maxStreak;
  double get difficulty => _difficulty;
  EnglishLessonResult? get result => _result;
  bool get isComplete => _phase == EnglishLessonPhase.complete;
  bool get isGrading => _phase == EnglishLessonPhase.grading;
  int get totalSteps => _queue.length;

  EnglishActivity? get currentActivity =>
      _index < _queue.length ? _queue[_index] : null;

  EnglishActivityDifficulty? get currentDifficulty {
    final EnglishActivity? step = currentActivity;
    if (step == null) return null;
    return _mixer.resolveDifficulty(step);
  }

  double get progress =>
      _queue.isEmpty ? 0 : (_index + (_phase == EnglishLessonPhase.feedback ? 0.5 : 0)) / _queue.length;

  void begin() {
    if (_disposed) return;
    final List<EnglishActivity> expanded = useQuestionBank
        ? englishQuestionBank.expandLesson(
            script,
            learnerLevel: learnerLevel,
          )
        : script.activities;
    _queue
      ..clear()
      ..addAll(_mixer.buildQueue(expanded));
    _index = 0;
    _retriesInjected = 0;
    _enterStep();
  }

  void _enterStep() {
    if (_index >= _queue.length) {
      _finishLesson();
      return;
    }
    final EnglishActivity step = _queue[_index];
    if (step.vocabularyWord != null) _wordsSeen.add(step.vocabularyWord!);
    _phase = step.isMicroOnly
        ? EnglishLessonPhase.microPrompt
        : EnglishLessonPhase.active;
    _feedback = null;
    notifyListeners();
  }

  /// After micro-prompt timer — micro-only steps skip straight to next.
  void advanceFromMicroPrompt() {
    if (_disposed || _phase != EnglishLessonPhase.microPrompt) return;
    if (currentActivity?.isMicroOnly ?? false) {
      _index += 1;
      _enterStep();
      return;
    }
    _phase = EnglishLessonPhase.active;
    notifyListeners();
  }

  void beginGrading() {
    if (_disposed || _phase != EnglishLessonPhase.active) return;
    _phase = EnglishLessonPhase.grading;
    notifyListeners();
  }

  void applyGradeResult(GradeResult grade) {
    if (_disposed) return;
    if (_phase != EnglishLessonPhase.active &&
        _phase != EnglishLessonPhase.grading) {
      return;
    }
    _applyGrade(grade);
  }

  void submitAnswer(dynamic answer) {
    if (_disposed || _phase != EnglishLessonPhase.active) return;
    final EnglishActivity activity = currentActivity!;
    if (activity.isMicroOnly) return;

    try {
      final GradeResult grade = switch (activity.kind) {
        EnglishActivityKind.sentenceBuilder =>
          _gradeSentenceBuilder(activity, answer),
        _ => _writingGrader.gradeSync(
            activity: activity,
            answer: answer,
            lessonTitle: script.title,
          ),
      };
      _applyGrade(grade);
    } catch (e, st) {
      debugPrint('English submit failed: $e\n$st');
      _applyGrade(
        const GradeResult(
          correct: false,
          feedback: 'Something went wrong — tap Next question to continue.',
          note: 'Error',
        ),
      );
    }
  }

  void _applyGrade(GradeResult grade) {
    if (_disposed) return;
    final EnglishActivity activity = currentActivity!;
    _attempted += 1;
    _lastCorrect = grade.correct;

    if (grade.correct) {
      _correct += 1;
      _streak += 1;
      if (_streak > _maxStreak) _maxStreak = _streak;
      if (_streak >= EnglishXpRules.streakMultiplierThreshold &&
          _difficulty < 1.4) {
        _difficulty = (_difficulty + 0.05).clamp(1.0, 1.5);
      }
      _scheduleReview(activity.id, quality: 4);
      _awardXp(activity, correct: true);
    } else {
      _streak = 0;
      if (_difficulty > 0.85) _difficulty -= 0.08;
      _mistakes.add(
        EnglishMistakeRecord(
          activityId: activity.id,
          skill: activity.skill,
          note: grade.note,
          prompt: activity.prompt,
        ),
      );
      _scheduleReview(activity.id, quality: 1);
      _injectMistakeRetry(activity);
      _awardXp(activity, correct: false);
    }

    if (grade.readingDetail != null) {
      _lastReadingDetail = grade.readingDetail;
    }
    _feedback = grade.feedback;
    _phase = EnglishLessonPhase.feedback;
    notifyListeners();
  }

  void continueAfterFeedback() {
    if (_disposed || _phase != EnglishLessonPhase.feedback) return;
    _index += 1;
    _enterStep();
  }

  void _awardXp(EnglishActivity activity, {required bool correct}) {
    if (!correct) {
      _baseXp += 1;
      return;
    }
    int earned = EnglishXpRules.correctAnswer;
    if (activity.kind == EnglishActivityKind.speaking) {
      earned += EnglishXpRules.speakingBonus;
    }
    if (activity.kind == EnglishActivityKind.readingAloud) {
      earned += EnglishXpRules.speakingBonus;
    }
    if (activity.kind == EnglishActivityKind.emailWriting ||
        activity.kind == EnglishActivityKind.shortWriting ||
        activity.kind == EnglishActivityKind.essayWriting) {
      earned += 2;
    }
    final EnglishActivityDifficulty level = _mixer.resolveDifficulty(activity);
    if (level == EnglishActivityDifficulty.hard) {
      earned += EnglishXpRules.hardBonus;
    } else if (level == EnglishActivityDifficulty.easy) {
      earned += EnglishXpRules.easyBonus;
    }
    earned = (earned * streakMultiplier * _difficulty).round();
    _baseXp += earned;
    if (_streak >= 5 && _streak % 5 == 0) {
      _bonusXp += 5;
    }
    if (level == EnglishActivityDifficulty.hard && _streak >= 3) {
      _bonusXp += 3;
    }
  }

  void _injectMistakeRetry(EnglishActivity failed) {
    if (_retriesInjected >= 2) return;
    _retriesInjected += 1;
    final EnglishActivityDifficulty level = _mixer.resolveDifficulty(failed);
    final bool wasHard = level == EnglishActivityDifficulty.hard;
    final EnglishActivity retry = failed.copyWith(
      id: '${failed.id}_retry',
      prompt: wasHard
          ? 'Easier try: ${failed.prompt}'
          : 'Quick retry: ${failed.prompt}',
      feedbackWrong:
          failed.feedbackWrong ?? 'One more time — you\'ve got this.',
    );
    final int insertAt = wasHard
        ? (_index + 1).clamp(0, _queue.length)
        : (_index + 3).clamp(0, _queue.length);
    _queue.insert(insertAt, retry);
  }

  void _finishLesson() {
    final double accuracy =
        _attempted == 0 ? 1.0 : _correct / _attempted;
    final bool perfect = _mistakes.isEmpty && _attempted > 0;
    if (perfect) _bonusXp += EnglishXpRules.perfectLessonBonus;
    if (_maxStreak >= 5) _bonusXp += 10;

    final EnglishCefrLevel levelAfter = _adaptive.adjustAfterLesson(
      current: learnerLevel,
      accuracy: accuracy,
      maxStreak: _maxStreak,
      stepsAttempted: _attempted,
    );

    _result = EnglishLessonResult(
      xpEarned: xp,
      baseXp: _baseXp,
      bonusXp: _bonusXp,
      accuracy: accuracy,
      grammarMastered: accuracy >= 0.85,
      wordsLearned: <String>{
        ...script.vocabularyWords,
        ..._wordsSeen,
      }.toList(),
      mistakes: List<EnglishMistakeRecord>.unmodifiable(_mistakes),
      reviewTopics: _mistakes
          .map((EnglishMistakeRecord m) => m.note)
          .where((String n) => n.isNotEmpty)
          .toSet()
          .take(5)
          .toList(),
      nextSkill: accuracy >= 0.85 ? 'Past Perfect' : 'Present Perfect',
      stepsCompleted: _index,
      correctCount: _correct,
      perfectLesson: perfect,
      maxStreak: _maxStreak,
      readingDetail: _lastReadingDetail,
      levelAfter: levelAfter,
    );
    _phase = EnglishLessonPhase.complete;
    notifyListeners();
  }

  void _scheduleReview(String activityId, {required int quality}) {
    final Sm2State prev = _reviewSchedule[activityId] ?? const Sm2State();
    final Sm2Result result = applySm2(prev, quality);
    _reviewSchedule[activityId] = Sm2State(
      easeFactor: result.easeFactor,
      intervalDays: result.intervalDays,
      repetitions: result.repetitions,
    );
  }

  GradeResult _grade(EnglishActivity activity, dynamic answer) {
    switch (activity.kind) {
      case EnglishActivityKind.microPrompt:
        return const GradeResult(correct: true, feedback: '', note: '');
      case EnglishActivityKind.multipleChoice:
      case EnglishActivityKind.rapidReview:
        if (answer is String || answer is EnglishWrittenSubmission) {
          return _gradeWrittenChoice(activity, answer);
        }
        return _gradeMultipleChoice(activity, answer);
      case EnglishActivityKind.fillBlank:
      case EnglishActivityKind.questionCard:
      case EnglishActivityKind.miniConversation:
      case EnglishActivityKind.shortWriting:
        return _gradeText(activity, answer, lenient: true);
      case EnglishActivityKind.emailWriting:
        return const GradeResult(
          correct: false,
          feedback: 'Use Submit — emails are graded in detail.',
          note: '',
        );
      case EnglishActivityKind.sentenceBuilder:
        return _gradeSentenceBuilder(activity, answer);
      case EnglishActivityKind.speaking:
        return _gradeSpeaking(activity, answer);
      case EnglishActivityKind.readingAloud:
        return const GradeResult(
          correct: false,
          feedback: 'Use the mic to read the passage aloud.',
          note: 'Reading aloud',
        );
      case EnglishActivityKind.listening:
        if (answer is String || answer is EnglishWrittenSubmission) {
          return _gradeWrittenChoice(activity, answer);
        }
        return _gradeMultipleChoice(activity, answer);
      case EnglishActivityKind.correction:
        return _gradeCorrection(activity, answer);
      case EnglishActivityKind.sentenceRewrite:
      case EnglishActivityKind.combineSentences:
      case EnglishActivityKind.transformWriting:
      case EnglishActivityKind.paragraphCorrection:
      case EnglishActivityKind.essayWriting:
      case EnglishActivityKind.explainError:
      case EnglishActivityKind.bestSentence:
      case EnglishActivityKind.readingInference:
      case EnglishActivityKind.vocabularyContext:
      case EnglishActivityKind.scenarioIntro:
        return _writingGrader.gradeSync(
          activity: activity,
          answer: answer,
          lessonTitle: script.title,
        );
    }
  }

  GradeResult _gradeWrittenChoice(EnglishActivity activity, dynamic answer) {
    final String body = answer is EnglishWrittenSubmission
        ? answer.body
        : (answer is String ? answer : '$answer');
    final String text = _normalize(body);
    if (text.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'Write your answer.',
        note: 'Empty',
      );
    }
    final int? idx = activity.correctIndex;
    if (idx == null || idx < 0 || idx >= activity.options.length) {
      return const GradeResult(
        correct: false,
        feedback: 'Could not grade this question.',
        note: '',
      );
    }
    final String expected = _normalize(activity.options[idx]);
    if (text == expected || text.contains(expected) || expected.contains(text)) {
      return GradeResult(
        correct: true,
        feedback: activity.feedbackCorrect ?? 'Correct!',
        note: '',
      );
    }
    for (int i = 0; i < activity.options.length; i++) {
      if (_normalize(activity.options[i]) == text) {
        final bool ok = i == idx;
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
          'Write the full answer. Hint: "${activity.options[idx]}"',
      note: activity.prompt,
    );
  }

  GradeResult _gradeMultipleChoice(EnglishActivity activity, dynamic answer) {
    final int? chosen = answer is int ? answer : int.tryParse('$answer');
    final bool ok = chosen == activity.correctIndex;
    return GradeResult(
      correct: ok,
      feedback: ok
          ? (activity.feedbackCorrect ?? 'Nice!')
          : (activity.feedbackWrong ?? 'Not quite — try the pattern again.'),
      note: activity.prompt,
    );
  }

  GradeResult _gradeSentenceBuilder(EnglishActivity activity, dynamic answer) {
    final String built = (answer is String ? answer : '$answer').trim();
    final String expected = (activity.correctSentence ?? '').trim();
    final bool ok = _normalize(built) == _normalize(expected);
    return GradeResult(
      correct: ok,
      feedback: ok
          ? (activity.feedbackCorrect ?? 'Perfect sentence!')
          : (activity.feedbackWrong ?? 'Try: "$expected"'),
      note: 'Sentence order',
    );
  }

  GradeResult _gradeCorrection(EnglishActivity activity, dynamic answer) {
    final String text = _normalize(answer is String ? answer : '$answer');
    final String expected = _normalize(
      activity.correctedSentence ?? activity.correctAnswer ?? '',
    );
    if (text.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'Type the corrected sentence.',
        note: 'Correction',
      );
    }
    final bool strict =
        _mixer.resolveDifficulty(activity) == EnglishActivityDifficulty.hard;
    final bool ok = strict
        ? text == expected
        : text == expected || text.contains(expected);
    return GradeResult(
      correct: ok,
      feedback: ok
          ? (activity.feedbackCorrect ?? 'Fixed!')
          : (activity.feedbackWrong ??
              'Use: "${activity.correctedSentence ?? activity.correctAnswer}"'),
      note: activity.incorrectSentence ?? activity.prompt,
    );
  }

  GradeResult _gradeSpeaking(EnglishActivity activity, dynamic answer) {
    final bool lenient =
        _mixer.resolveDifficulty(activity) != EnglishActivityDifficulty.hard;
    final GradeResult base = _gradeText(activity, answer, lenient: lenient);
    if (base.correct) {
      return GradeResult(
        correct: true,
        feedback: activity.feedbackCorrect ?? 'Great pronunciation and grammar!',
        note: '',
      );
    }
    return base;
  }

  GradeResult _gradeText(
    EnglishActivity activity,
    dynamic answer, {
    bool lenient = false,
  }) {
    final String text = _normalize(answer is String ? answer : '$answer');
    if (text.isEmpty) {
      return const GradeResult(
        correct: false,
        feedback: 'Say or type your answer.',
        note: 'Empty',
      );
    }
    final List<String> acceptable = <String>[
      if (activity.correctAnswer != null) activity.correctAnswer!,
      ...activity.acceptableAnswers,
    ];
    if (acceptable.isEmpty) {
      final int words =
          text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
      if (words >= activity.minWords) {
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
      final String norm = _normalize(candidate);
      if (text == norm || (lenient && text.contains(norm))) {
        return GradeResult(
          correct: true,
          feedback: activity.feedbackCorrect ?? 'Exactly!',
          note: '',
        );
      }
    }
    return GradeResult(
      correct: false,
      feedback: activity.feedbackWrong ??
          'Try again. Hint: "${acceptable.first}"',
      note: activity.prompt,
    );
  }

  String _normalize(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class GradeResult {
  const GradeResult({
    required this.correct,
    required this.feedback,
    required this.note,
    this.readingDetail,
  });

  final bool correct;
  final String feedback;
  final String note;
  final EnglishReadingGradeDetail? readingDetail;
}
