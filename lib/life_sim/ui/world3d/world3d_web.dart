// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Web: the 3D world (web/life_world/index.html, three.js) runs in an iframe.
/// Dart keeps all game rules; the page only renders and sends input back.
bool get world3dSupported => true;

const String _viewType = 'gradeglow-life-world-3d';
bool _factoryReady = false;
bool _messageHooked = false;
html.IFrameElement? _frame;
bool _iframeLoaded = false;
void Function(Map<String, dynamic> event)? _handler;
final List<String> _outbox = <String>[];

bool get world3dReady => _frame != null && _iframeLoaded;

Widget buildWorld3dView({required void Function(Map<String, dynamic> event) onEvent}) {
  _handler = onEvent;

  if (!_factoryReady) {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..src = 'life_world/index.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen';
      _iframeLoaded = false;
      // onLoad only means the document arrived — wait for gg-ready (scripts up)
      // before flushing the outbox, otherwise the first scene is dropped.
      iframe.onLoad.listen((_) {});
      _frame = iframe;
      return iframe;
    });
    _factoryReady = true;
  }

  if (!_messageHooked) {
    html.window.onMessage.listen((html.MessageEvent event) {
      final Map<String, dynamic>? decoded = _decodeMessage(event.data);
      if (decoded == null) return;
      final String type = '${decoded['type'] ?? ''}';
      if (!type.startsWith('gg-')) return;
      if (type == 'gg-ready' || type == 'gg-scene-ack') {
        _iframeLoaded = true;
        _flushOutbox();
      }
      _handler?.call(decoded);
    });
    _messageHooked = true;
  }

  return HtmlElementView(viewType: _viewType);
}

Map<String, dynamic>? _decodeMessage(Object? data) {
  String? text;
  if (data is String) {
    text = data;
  } else if (data != null) {
    // dart2js sometimes surfaces JS strings as opaque objects.
    text = data.toString();
    if (!text.contains('gg-')) return null;
  }
  if (text == null || !text.contains('"gg-')) return null;
  try {
    final Object? decoded = jsonDecode(text);
    if (decoded is Map) {
      return decoded.map((Object? k, Object? v) => MapEntry('$k', v));
    }
  } catch (_) {}
  return null;
}

void _flushOutbox() {
  final html.WindowBase? win = _frame?.contentWindow;
  if (win == null || !_iframeLoaded) return;
  while (_outbox.isNotEmpty) {
    win.postMessage(_outbox.removeAt(0), '*');
  }
}

/// Sends a scene/frame message to the 3D page.
/// Returns false if the iframe is not ready yet (message is queued).
bool world3dSend(Map<String, Object?> message) {
  final String payload = jsonEncode(message);
  final html.WindowBase? win = _frame?.contentWindow;
  if (win == null || !_iframeLoaded) {
    // Keep only the latest scene; queue frames only after load.
    if (message['type'] == 'gg-scene') {
      _outbox.removeWhere((String s) => s.contains('"gg-scene"'));
      _outbox.add(payload);
    } else if (_iframeLoaded) {
      _outbox.add(payload);
    }
    return false;
  }
  win.postMessage(payload, '*');
  return true;
}

/// Stops delivering events to [onEvent] (call from dispose).
void world3dDetach(void Function(Map<String, dynamic> event) onEvent) {
  if (_handler == onEvent) _handler = null;
}
