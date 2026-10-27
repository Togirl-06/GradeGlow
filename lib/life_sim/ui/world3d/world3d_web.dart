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
void Function(Map<String, dynamic> event)? _handler;

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
      _frame = iframe;
      return iframe;
    });
    _factoryReady = true;
  }

  if (!_messageHooked) {
    html.window.onMessage.listen((html.MessageEvent event) {
      final Object? data = event.data;
      if (data is! String || !data.contains('"gg-')) return;
      Object? decoded;
      try {
        decoded = jsonDecode(data);
      } catch (_) {
        return;
      }
      if (decoded is! Map<String, dynamic>) return;
      if (!'${decoded['type'] ?? ''}'.startsWith('gg-')) return;
      _handler?.call(decoded);
    });
    _messageHooked = true;
  }

  return HtmlElementView(viewType: _viewType);
}

/// Sends a scene/frame message to the 3D page (no-op until the iframe exists).
void world3dSend(Map<String, Object?> message) {
  _frame?.contentWindow?.postMessage(jsonEncode(message), '*');
}

/// Stops delivering events to [onEvent] (call from dispose).
void world3dDetach(void Function(Map<String, dynamic> event) onEvent) {
  if (_handler == onEvent) _handler = null;
}
