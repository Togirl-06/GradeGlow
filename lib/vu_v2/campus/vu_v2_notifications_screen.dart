import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2NotificationsScreen extends StatelessWidget {
  const VuV2NotificationsScreen({super.key, required this.progress});

  final VuV2ProgressStore progress;

  IconData _icon(String kind) {
    return switch (kind) {
      'assignment' => Icons.assignment_outlined,
      'exam' => Icons.timer_outlined,
      'achievement' => Icons.emoji_events_outlined,
      _ => Icons.lightbulb_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: progress.notifications.isEmpty
          ? const VuV2EmptyState(
              title: 'Inbox clear',
              subtitle: 'Reminders and AI tips will show up here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: progress.notifications.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int i) {
                final VuV2NotificationItem n = progress.notifications[i];
                return Material(
                  color: VuV2Colors.navyElevated,
                  borderRadius: BorderRadius.circular(VuV2Radii.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VuV2Radii.lg),
                    onTap: () => progress.markNotificationRead(n.id),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(VuV2Radii.lg),
                        border: Border.all(
                          color: n.read
                              ? VuV2Colors.stroke
                              : VuV2Colors.orange.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(_icon(n.kind), color: VuV2Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  n.title,
                                  style: TextStyle(
                                    color: VuV2Colors.ink,
                                    fontWeight:
                                        n.read ? FontWeight.w700 : FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.body,
                                  style: const TextStyle(
                                    color: VuV2Colors.mute,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
