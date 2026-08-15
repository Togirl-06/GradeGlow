import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_certificate_screen.dart';
import 'vu_v2_subscription_screen.dart';

class VuV2ProfileScreen extends StatelessWidget {
  const VuV2ProfileScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.onThemeChanged,
    this.embedded = false,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final ValueChanged<bool> onThemeChanged;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: embedded ? null : AppBar(title: const Text('Student profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 44,
                  backgroundColor: VuV2Colors.orange.withValues(alpha: 0.25),
                  child: Text(
                    session.displayName.isNotEmpty
                        ? session.displayName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: VuV2Colors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  session.displayName,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                Text(
                  session.majorLabel,
                  style: const TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 6),
                Text(
                  '${progress.completedLessonIds.length} lessons complete · '
                  'streak ${progress.streakDays} days',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Achievements'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Text(
              progress.completedLessonIds.isEmpty
                  ? 'Complete a lesson to unlock your first badge.'
                  : 'Campus explorer · ${progress.completedLessonIds.length} lessons · streak ${progress.streakDays}',
              style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),
          const VuV2SectionTitle('Skills learned'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (progress.skills.isEmpty
                    ? <String>['Curiosity', 'Consistency']
                    : progress.skills)
                .map(
                  (String s) => Chip(
                    label: Text(s),
                    backgroundColor: VuV2Colors.navyElevated,
                    side: const BorderSide(color: VuV2Colors.stroke),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          const VuV2SectionTitle('Certificates'),
          const SizedBox(height: 8),
          VuV2PrimaryButton(
            label: progress.earnedCertificateIds.isEmpty
                ? 'View sample certificate'
                : 'Open certificates (${progress.earnedCertificateIds.length})',
            icon: Icons.workspace_premium_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2CertificateScreen(
                    studentName: session.displayName,
                    courseTitle: session.majorLabel,
                    verificationId: 'GG-${session.majorId.toUpperCase()}-DEMO',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Account settings'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Light mode'),
                  subtitle: const Text('Campus theme preference'),
                  value: progress.preferLightTheme,
                  activeThumbColor: VuV2Colors.orange,
                  onChanged: (bool v) async {
                    await progress.setPreferLightTheme(v);
                    onThemeChanged(v);
                  },
                ),
                const Divider(color: VuV2Colors.stroke),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Subscription'),
                  subtitle: Text(progress.isPremium ? 'Premium' : 'Free'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2SubscriptionScreen(progress: progress),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
