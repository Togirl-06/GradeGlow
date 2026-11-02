import 'package:flutter/material.dart';

import 'lecture_recording_bar.dart';

/// Global floating recorder above the bottom nav / home indicator.
class RecordingBarOverlay extends StatelessWidget {
  const RecordingBarOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom + 80;
    return Positioned(
      left: 12,
      right: 12,
      bottom: bottom,
      child: const LectureRecordingBar(),
    );
  }
}
