import '../models/practice_lab_question.dart';

/// Manages question order with skip-and-return-later behavior.
class PracticeLabQuestionRunner {
  PracticeLabQuestionRunner(List<PracticeLabQuestion> questions)
      : _pending = List<PracticeLabQuestion>.from(questions),
        _deferred = <PracticeLabQuestion>[],
        _answered = <PracticeLabQuestionResponse>[];

  final List<PracticeLabQuestion> _pending;
  final List<PracticeLabQuestion> _deferred;
  final List<PracticeLabQuestionResponse> _answered;

  int get totalCount => _pending.length + _deferred.length + _answered.length;

  int get answeredCount => _answered.where((PracticeLabQuestionResponse r) => !r.skipped).length;

  int get skippedPendingCount => _deferred.length;

  bool get isComplete => _pending.isEmpty && _deferred.isEmpty;

  PracticeLabQuestion? get current => _pending.isNotEmpty ? _pending.first : null;

  List<PracticeLabQuestionResponse> get responses => List<PracticeLabQuestionResponse>.unmodifiable(_answered);

  int get displayIndex => answeredCount + 1;

  void skipCurrent() {
    if (_pending.isEmpty) return;
    final PracticeLabQuestion question = _pending.removeAt(0);
    _deferred.add(question);
    _pullDeferredIfNeeded();
  }

  void answerCurrent(String answer, {String? feedback}) {
    if (_pending.isEmpty) return;
    final PracticeLabQuestion question = _pending.removeAt(0);
    _answered.add(
      PracticeLabQuestionResponse(
        question: question,
        answer: answer.trim(),
        skipped: false,
        feedback: feedback,
      ),
    );
    _pullDeferredIfNeeded();
  }

  void _pullDeferredIfNeeded() {
    if (_pending.isEmpty && _deferred.isNotEmpty) {
      _pending.addAll(_deferred);
      _deferred.clear();
    }
  }
}
