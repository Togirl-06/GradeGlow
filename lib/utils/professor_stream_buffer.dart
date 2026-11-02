import 'dart:async';

/// Batches streamed tokens before calling [onUpdate] so the UI does not rebuild
/// markdown and LaTeX on every chunk (which can crash or disconnect the device).
class ProfessorStreamBuffer {
  ProfessorStreamBuffer({
    this.flushInterval = const Duration(milliseconds: 120),
    required this.onUpdate,
  });

  final Duration flushInterval;
  final void Function(String fullText) onUpdate;

  final StringBuffer _buf = StringBuffer();
  Timer? _timer;

  String get text => _buf.toString();

  void add(String chunk) {
    if (chunk.isEmpty) return;
    _buf.write(chunk);
    if (_timer != null) return;
    _timer = Timer(flushInterval, _flush);
  }

  void _flush() {
    _timer = null;
    onUpdate(_buf.toString());
  }

  void flushNow() {
    _timer?.cancel();
    _timer = null;
    onUpdate(_buf.toString());
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
