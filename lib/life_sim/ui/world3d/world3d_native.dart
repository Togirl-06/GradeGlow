import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Android / iOS: the same three.js world as the website
/// (web/life_world/index.html, served by Firebase Hosting) runs in a WebView.
/// Dart keeps all game rules; the page renders and sends input back through
/// the `GGNative` JavaScript channel. If the page never reports ready (for
/// example offline), LifeGameScreen falls back to the 2D city.
///
/// Override the page with --dart-define=LIFE_WORLD_URL=... (e.g. a staging site).
const String kLifeWorldUrl = String.fromEnvironment(
  'LIFE_WORLD_URL',
  defaultValue: 'https://gradeglow-virtualuni.web.app/life_world/index.html',
);

bool get world3dSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

WebViewController? _controller;
bool _ready = false;
void Function(Map<String, dynamic> event)? _handler;
final List<String> _outbox = <String>[];

bool get world3dReady => _controller != null && _ready;

Map<String, dynamic>? _decode(String text) {
  if (!text.contains('"gg-')) return null;
  try {
    final Object? v = jsonDecode(text);
    if (v is Map) return v.map((Object? k, Object? val) => MapEntry<String, dynamic>('$k', val));
  } catch (_) {}
  return null;
}

void _deliver(String payload) {
  final WebViewController? c = _controller;
  if (c == null) return;
  unawaited(c.runJavaScript('window.__ggReceive && window.__ggReceive($payload);').catchError((Object _) {}));
}

void _flush() {
  while (_ready && _outbox.isNotEmpty) {
    _deliver(_outbox.removeAt(0));
  }
}

Widget buildWorld3dView({required void Function(Map<String, dynamic> event) onEvent}) {
  _handler = onEvent;
  _controller ??= WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0xFF0B1220))
    ..addJavaScriptChannel(
      'GGNative',
      onMessageReceived: (JavaScriptMessage m) {
        final Map<String, dynamic>? event = _decode(m.message);
        if (event == null) return;
        final String type = '${event['type'] ?? ''}';
        if (type == 'gg-ready' || type == 'gg-scene-ack') {
          _ready = true;
          _flush();
        }
        _handler?.call(event);
      },
    )
    ..setNavigationDelegate(NavigationDelegate(
      onPageStarted: (String _) => _ready = false,
    ))
    ..loadRequest(Uri.parse(kLifeWorldUrl));
  return WebViewWidget(controller: _controller!);
}

/// Sends a scene/frame message to the 3D page. Returns false (and keeps the
/// latest scene queued) until the page has reported ready.
bool world3dSend(Map<String, Object?> message) {
  final String payload = jsonEncode(message);
  if (_controller == null || !_ready) {
    if (message['type'] == 'gg-scene') {
      _outbox.removeWhere((String s) => s.contains('"gg-scene"'));
      _outbox.add(payload);
    }
    return false;
  }
  _deliver(payload);
  return true;
}

void world3dDetach(void Function(Map<String, dynamic> event) onEvent) {
  if (_handler == onEvent) _handler = null;
}
