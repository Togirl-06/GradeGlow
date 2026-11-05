import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'lab_runner.dart';
import 'lab_runner_io.dart';

Widget hostFor(LabRunner runner) {
  if (runner is! WebViewLabRunner) return const SizedBox.shrink();
  return SizedBox(width: 1, height: 1, child: WebViewWidget(controller: runner.controller));
}
