import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';

/// Simulations removed from Virtual University for good.
class VuV2SimulationsHub extends StatelessWidget {
  const VuV2SimulationsHub({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Simulations have been removed from GradeGlow Virtual University.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VuV2Colors.mute, height: 1.45),
        ),
      ),
    );
  }
}
