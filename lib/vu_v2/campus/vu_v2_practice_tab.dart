import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../labs/vu_v2_labs_hub.dart';

/// Practice tab entry — Virtual Labs (learn by doing).
class VuV2PracticeTab extends StatelessWidget {
  const VuV2PracticeTab({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return VuV2LabsHub(session: session, progress: progress);
  }
}
