import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../utils/tutor_limits.dart';
import '../screens/membership_screen.dart';

/// Banner when free daily photo/video/file limit is reached.
class TutorLimitBanner extends StatelessWidget {
  const TutorLimitBanner({
    super.key,
    required this.usage,
  });

  final TutorMediaUsage usage;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color fill = brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFF1F2937);
    const Color text = Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.attach_file, color: StudyColors.primaryLight, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You\'ve reached today\'s Free limit of ${TutorLimits.freeDailyMediaAttachments} photos, videos, or files. '
              'Upgrade for unlimited attachments.',
              style: const TextStyle(color: text, fontSize: 13, height: 1.35),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: text,
              backgroundColor: Colors.white12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

/// Remaining attachment count for free users.
class TutorUsageHint extends StatelessWidget {
  const TutorUsageHint({super.key, required this.usage});

  final TutorMediaUsage usage;

  @override
  Widget build(BuildContext context) {
    if (usage.isPremium) return const SizedBox.shrink();
    final Color muted = StudyColors.textSecondary(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        usage.isAtLimit
            ? 'No free photo/video/file attachments left today'
            : '${usage.remaining} of ${usage.limit} free tutor attachments left today',
        style: TextStyle(color: muted, fontSize: 12),
      ),
    );
  }
}
