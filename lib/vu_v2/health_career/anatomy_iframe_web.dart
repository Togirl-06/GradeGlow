// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

bool get anatomyThreeJsSupported => true;

ValueChanged<Map<String, String>>? _anatomySelectHandler;
bool _factoryReady = false;
bool _messageHooked = false;

Widget buildAnatomyThreeJsView({
  required String viewType,
  required ValueChanged<Map<String, String>> onSelect,
}) {
  _anatomySelectHandler = onSelect;

  if (!_factoryReady) {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..src = 'health_3d/anatomy_viewer.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen';
      return iframe;
    });
    _factoryReady = true;
  }

  if (!_messageHooked) {
    html.window.onMessage.listen((html.MessageEvent event) {
      final Object? data = event.data;
      if (data is! Map) return;
      if ('${data['type'] ?? ''}' != 'anatomy-select') return;
      _anatomySelectHandler?.call(<String, String>{
        'id': '${data['id'] ?? ''}',
        'name': '${data['name'] ?? ''}',
        'info': '${data['info'] ?? ''}',
      });
    });
    _messageHooked = true;
  }

  return HtmlElementView(viewType: viewType);
}
