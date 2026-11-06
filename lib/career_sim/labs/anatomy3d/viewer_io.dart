import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Phones: the 3D page runs in a WebView from the app's bundled assets.
Widget? viewer({required void Function(String id) onPick, required void Function(void Function(String json) send) bind, required String initialCommand}) {
  if (!(Platform.isAndroid || Platform.isIOS)) return null;
  return _PhoneViewer(onPick: onPick, bind: bind, initialCommand: initialCommand);
}

class _PhoneViewer extends StatefulWidget {
  const _PhoneViewer({required this.onPick, required this.bind, required this.initialCommand});
  final void Function(String id) onPick;
  final void Function(void Function(String json) send) bind;
  final String initialCommand;
  @override
  State<_PhoneViewer> createState() => _PhoneViewerState();
}

class _PhoneViewerState extends State<_PhoneViewer> {
  late final WebViewController _c;
  bool _ready = false;
  final List<String> _queue = <String>[];

  void _send(String json) {
    if (!_ready) {
      _queue.add(json);
      return;
    }
    _c.runJavaScript('window.ggAnatomy(${jsonEncode(json)})');
  }

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('GGAnatomyChannel', onMessageReceived: (JavaScriptMessage m) {
        final Object? d = jsonDecode(m.message);
        if (d is! Map) return;
        if (d['type'] == 'ready') {
          _ready = true;
          _send(widget.initialCommand);
          for (final String q in List<String>.of(_queue)) {
            _send(q);
          }
          _queue.clear();
        } else if (d['type'] == 'pick' && d['id'] is String) {
          widget.onPick(d['id'] as String);
        }
      })
      ..loadFlutterAsset('web/anatomy_3d/index.html');
    widget.bind(_send);
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _c);
}
