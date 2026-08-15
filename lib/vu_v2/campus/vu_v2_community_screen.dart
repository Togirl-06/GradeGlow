import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../labs/winning_career_showcases.dart';
import 'vu_v2_adaptive_review_drill_screen.dart';

/// Campus Pulse — live showcase shortcuts (never a Coming Soon stub).
class VuV2CommunityScreen extends StatelessWidget {
  const VuV2CommunityScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const VuV2SectionTitle('Campus Pulse'),
        const SizedBox(height: 8),
        const Text(
          'Practice labs and professional simulations from across campus.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 16),
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Career showcases',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'CS incident · Law case · Engineering bridge — graded practicals.',
                style: TextStyle(color: VuV2Colors.mute, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () => WinningCareerShowcases.openCs(context),
                    child: const Text('CS'),
                  ),
                  OutlinedButton(
                    onPressed: () => WinningCareerShowcases.openLaw(context),
                    child: const Text('Law'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        WinningCareerShowcases.openEngineering(context),
                    child: const Text('Engineering'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Adaptive review',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Re-teach the exact confusion — radius vs ulna style drills.',
                style: TextStyle(color: VuV2Colors.mute, height: 1.4),
              ),
              const SizedBox(height: 12),
              VuV2PrimaryButton(
                label: 'Start 2-min drill',
                trailingArrow: true,
                onPressed: () => VuV2AdaptiveReviewDrillScreen.open(
                  context,
                  progress: progress,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
