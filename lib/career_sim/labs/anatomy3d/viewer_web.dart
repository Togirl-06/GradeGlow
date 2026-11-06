import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

@JS('document.createElement')
external _Frame _createElement(String tag);

@JS('window.addEventListener')
external void _addListener(String type, JSFunction f);

@JS('window.removeEventListener')
external void _removeListener(String type, JSFunction f);

extension type _Frame(JSObject _) implements JSObject {
  external set src(String v);
  external _Style get style;
  external _Win? get contentWindow;
  external void setAttribute(String name, String value);
}

extension type _Style(JSObject _) implements JSObject {
  external set border(String v);
  external set width(String v);
  external set height(String v);
}

extension type _Win(JSObject _) implements JSObject {
  external void postMessage(JSAny? message, String origin);
}

extension type _MessageEvent(JSObject _) implements JSObject {
  external JSAny? get data;
}

int _seq = 0;

/// Web: the 3D page runs in an iframe served from the app's web folder.
Widget? viewer({required void Function(String id) onPick, required void Function(void Function(String json) send) bind, required String initialCommand}) =>
    _WebViewer(onPick: onPick, bind: bind, initialCommand: initialCommand);

class _WebViewer extends StatefulWidget {
  const _WebViewer({required this.onPick, required this.bind, required this.initialCommand});
  final void Function(String id) onPick;
  final void Function(void Function(String json) send) bind;
  final String initialCommand;
  @override
  State<_WebViewer> createState() => _WebViewerState();
}

class _WebViewerState extends State<_WebViewer> {
  late final String _type = 'gg-anatomy-${_seq++}';
  late final _Frame _frame;
  late final JSFunction _listener;
  bool _ready = false;
  final List<String> _queue = <String>[];

  void _send(String json) {
    if (!_ready) {
      _queue.add(json);
      return;
    }
    _frame.contentWindow?.postMessage(<String, Object>{'source': 'gg-host', 'data': json}.jsify(), '*');
  }

  @override
  void initState() {
    super.initState();
    _frame = _createElement('iframe')
      ..src = 'anatomy_3d/index.html'
      ..setAttribute('title', '3D anatomy model');
    _frame.style
      ..border = '0'
      ..width = '100%'
      ..height = '100%';
    ui_web.platformViewRegistry.registerViewFactory(_type, (int _) => _frame);
    _listener = ((_MessageEvent e) {
      final Object? d = e.data.dartify();
      if (d is! Map || d['source'] != 'gg-anatomy' || d['data'] is! String) return;
      final Object? m = jsonDecode(d['data'] as String);
      if (m is! Map) return;
      if (m['type'] == 'ready') {
        _ready = true;
        _send(widget.initialCommand);
        for (final String q in List<String>.of(_queue)) {
          _send(q);
        }
        _queue.clear();
      } else if (m['type'] == 'pick' && m['id'] is String) {
        widget.onPick(m['id'] as String);
      }
    }).toJS;
    _addListener('message', _listener);
    widget.bind(_send);
  }

  @override
  void dispose() {
    _removeListener('message', _listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _type);
}
