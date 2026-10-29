import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/appearance_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';

/// Labs tab — currently empty (all lab entries cleared).
class VuV2LabsHub extends StatelessWidget {
  const VuV2LabsHub({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceService>();
    VuV2Colors.syncTo(Theme.of(context));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: <Widget>[
        Text(
          'Labs',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 48),
        Icon(Icons.science_outlined, size: 48, color: VuV2Colors.mute),
        const SizedBox(height: 14),
        Text(
          'No labs yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This space is cleared. New labs will show up here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
      ],
    );
  }
}
