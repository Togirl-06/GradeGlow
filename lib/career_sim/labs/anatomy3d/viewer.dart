import 'package:flutter/widgets.dart';

import 'viewer_io.dart' if (dart.library.js_interop) 'viewer_web.dart' as platform;

/// Sends commands to a live 3D view.
class Anatomy3DController {
  void Function(String json)? _send;
  void command(String json) => _send?.call(json);
}

/// The interactive 3D model, or null where 3D cannot run here (tests,
/// desktop) — callers then offer the list view.
Widget? anatomy3DViewer({required Anatomy3DController controller, required void Function(String id) onPick, required String initialCommand}) =>
    platform.viewer(onPick: onPick, bind: (void Function(String json) send) => controller._send = send, initialCommand: initialCommand);
