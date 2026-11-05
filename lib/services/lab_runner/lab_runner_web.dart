import 'dart:js_interop';

import '../code_judge_service.dart';
import 'lab_runner.dart';

@JS('Worker')
extension type _Worker._(JSObject _) implements JSObject {
  external factory _Worker(String url);
  external void postMessage(JSAny? message);
  external void terminate();
  external set onmessage(JSFunction? handler);
  external set onerror(JSFunction? handler);
}

extension type _MessageEvent._(JSObject _) implements JSObject {
  external JSAny? get data;
}

/// Runs code in a Web Worker (web/code_runner/worker.js).
class WebWorkerLabRunner extends MessageLabRunner {
  WebWorkerLabRunner(super.fallback);

  _Worker? _worker;

  @override
  String get where => 'Runs in your browser';

  _Worker _get() {
    final _Worker? w = _worker;
    if (w != null) return w;
    final _Worker created = _Worker('code_runner/worker.js');
    created.onmessage = ((_MessageEvent e) {
      final Object? data = e.data.dartify();
      if (data is String) receive(data);
    }).toJS;
    _worker = created;
    return created;
  }

  @override
  void send(String json) => _get().postMessage(json.toJS);

  @override
  void reset() {
    _worker?.terminate();
    _worker = null;
  }
}

LabRunner createPlatformLabRunner(CodeJudgeService Function() fallback) => WebWorkerLabRunner(fallback);
