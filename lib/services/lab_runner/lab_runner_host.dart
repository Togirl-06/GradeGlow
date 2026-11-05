import 'package:flutter/widgets.dart';

import 'lab_runner.dart';
import 'lab_runner_host_io.dart' if (dart.library.js_interop) 'lab_runner_host_web.dart' as platform;

/// Keeps the phone's invisible code-runner page attached while a code lab is
/// open. Renders nothing on the web, where code runs in a Web Worker.
class LabRunnerHost extends StatelessWidget {
  const LabRunnerHost({super.key, required this.runner});
  final LabRunner runner;

  @override
  Widget build(BuildContext context) => platform.hostFor(runner);
}
