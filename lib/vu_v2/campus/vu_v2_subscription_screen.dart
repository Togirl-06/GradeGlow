import 'package:flutter/material.dart';

import '../../screens/membership_screen.dart';
import '../data/vu_v2_progress_store.dart';

/// Campus subscription entry — uses the shared professional Premium screen.
class VuV2SubscriptionScreen extends StatelessWidget {
  const VuV2SubscriptionScreen({super.key, required this.progress});

  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    // progress retained for campus call-site compatibility.
    return MembershipScreen(key: ValueKey<int>(progress.completedLessonIds.length));
  }
}
