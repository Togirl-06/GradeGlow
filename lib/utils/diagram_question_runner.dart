/// Manages diagram question order — skipped items return at the end, no repeats otherwise.
class DiagramQuestionRunner<T> {
  DiagramQuestionRunner(List<T> questions)
      : _pending = List<T>.from(questions),
        _deferred = <T>[],
        _answered = <T>[];

  final List<T> _pending;
  final List<T> _deferred;
  final List<T> _answered;

  int get totalCount => _pending.length + _deferred.length + _answered.length;

  int get answeredCount => _answered.length;

  int get skippedPendingCount => _deferred.length;

  bool get isComplete => _pending.isEmpty && _deferred.isEmpty;

  T? get current => _pending.isNotEmpty ? _pending.first : null;

  void skipCurrent() {
    if (_pending.isEmpty) return;
    final T question = _pending.removeAt(0);
    _deferred.add(question);
    _pullDeferredIfNeeded();
  }

  void answerCurrent() {
    if (_pending.isEmpty) return;
    final T question = _pending.removeAt(0);
    _answered.add(question);
    _pullDeferredIfNeeded();
  }

  void _pullDeferredIfNeeded() {
    if (_pending.isEmpty && _deferred.isNotEmpty) {
      _pending.addAll(_deferred);
      _deferred.clear();
    }
  }
}
