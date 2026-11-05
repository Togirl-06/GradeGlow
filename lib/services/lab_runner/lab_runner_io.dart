import 'dart:async';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

import '../code_judge_service.dart';
import 'lab_runner.dart';

/// Runs code in an invisible WebView (web/code_runner/mobile.html) on phones.
/// The page must be attached to the widget tree — see [LabRunnerHost].
class WebViewLabRunner extends MessageLabRunner {
  WebViewLabRunner(super.fallback);

  WebViewController? _controller;
  Completer<void> _ready = Completer<void>();
  final List<String> _queue = <String>[];

  @override
  String get where => 'Runs on this phone';

  WebViewController get controller {
    final WebViewController? c = _controller;
    if (c != null) return c;
    final WebViewController created = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('GGRunnerChannel', onMessageReceived: (JavaScriptMessage m) {
        if (m.message.contains('"ready":true')) {
          if (!_ready.isCompleted) _ready.complete();
          _flush();
          return;
        }
        receive(m.message);
      })
      ..loadFlutterAsset('web/code_runner/mobile.html');
    _controller = created;
    return created;
  }

  void _flush() {
    final WebViewController c = controller;
    while (_queue.isNotEmpty) {
      final String json = _queue.removeAt(0);
      unawaited(c.runJavaScript('ggRun(${_jsString(json)})'));
    }
  }

  static String _jsString(String s) =>
      "'${s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAll('\r', r'\r').replaceAll(' ', r' ').replaceAll(' ', r' ')}'";

  @override
  void send(String json) {
    _queue.add(json);
    controller;
    if (_ready.isCompleted) _flush();
  }

  @override
  void reset() {
    _ready = Completer<void>();
    _queue.clear();
    unawaited(_controller?.reload());
  }
}

LabRunner createPlatformLabRunner(CodeJudgeService Function() fallback) {
  if (Platform.isAndroid || Platform.isIOS) return WebViewLabRunner(fallback);
  return ServerLabRunner(fallback());
}
