import 'package:flutter/material.dart';

import '../campus/vu_v2_certificate_screen.dart';
import '../campus/vu_v2_notifications_screen.dart';
import '../campus/vu_v2_planner_screen.dart';
import '../campus/vu_v2_search_screen.dart';
import '../campus/vu_v2_subscription_screen.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';
import '../learn/vu_v2_faculty_screen.dart';

class VuV2CampusHome extends StatelessWidget {
  const VuV2CampusHome({
    super.key,
    required this.session,
    required this.progress,
    required this.onOpenLearn,
    this.onOpenPractice,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final VoidCallback onOpenLearn;
  final VoidCallback? onOpenPractice;

  static const List<({String id, String title, String emoji, String blurb})>
  _buildings = <({String id, String title, String emoji, String blurb})>[
    (id: 'lecture', title: 'Lecture Halls', emoji: '🏛️', blurb: 'Schools & programs'),
    (id: 'labs', title: 'Laboratories', emoji: '🧪', blurb: 'Practice & quizzes'),
    (id: 'library', title: 'Library', emoji: '📚', blurb: 'Search notes'),
    (id: 'student', title: 'Student Center', emoji: '🤝', blurb: 'Study planner'),
    (id: 'career', title: 'Career Center', emoji: '💼', blurb: 'Goals & schedule'),
    (id: 'events', title: 'Events Plaza', emoji: '🎟️', blurb: 'Notifications'),
    (id: 'grad', title: 'Graduation Hall', emoji: '🎓', blurb: 'Certificates'),
    (id: 'plans', title: 'Admissions Desk', emoji: '💳', blurb: 'Free & Premium'),
  ];

  void _openBuilding(BuildContext context, String id) {
    switch (id) {
      case 'lecture':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2FacultyScreen(
              session: session,
              progress: progress,
            ),
          ),
        );
      case 'labs':
        (onOpenPractice ?? onOpenLearn)();
      case 'library':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2SearchScreen(
              session: session,
              progress: progress,
            ),
          ),
        );
      case 'student':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2PlannerScreen(
              session: session,
              progress: progress,
            ),
          ),
        );
      case 'career':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2PlannerScreen(
              session: session,
              progress: progress,
            ),
          ),
        );
      case 'events':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2NotificationsScreen(progress: progress),
          ),
        );
      case 'grad':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2CertificateScreen(
              studentName: session.displayName,
              courseTitle: session.majorLabel,
              verificationId: 'GG-${session.majorId.toUpperCase()}-DEMO',
            ),
          ),
        );
      case 'plans':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VuV2SubscriptionScreen(progress: progress),
          ),
        );
      default:
        onOpenLearn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String hourLabel = () {
      final int h = DateTime.now().hour;
      if (h < 12) return 'Good morning';
      if (h < 17) return 'Good afternoon';
      return 'Good evening';
    }();

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$hourLabel, ${session.displayName}',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${session.majorLabel} path · ${session.weeklyMinutes} min / week'
                  '${progress.isPremium ? ' · Premium' : ' · Free'}',
                  style: const TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 18),
                VuV2Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: VuV2Colors.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        session.continueTitle ?? 'Start Orientation',
                        style: const TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.continueSubtitle ?? session.majorLabel,
                        style: const TextStyle(color: VuV2Colors.mute),
                      ),
                      const SizedBox(height: 12),
                      VuV2ProgressBar(value: session.continueProgress),
                      const SizedBox(height: 14),
                      VuV2PrimaryButton(
                        label: 'Continue learning',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => VuV2DegreeRoadmapScreen(
                                session: session,
                                subjectId: session.majorId,
                                progress: progress,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const VuV2SectionTitle('Campus map'),
                const SizedBox(height: 6),
                Text(
                  'Tap a building to enter — every door opens.',
                  style: TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int i) {
                final b = _buildings[i];
                return Material(
                  color: VuV2Colors.navyElevated,
                  borderRadius: BorderRadius.circular(VuV2Radii.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VuV2Radii.lg),
                    onTap: () => _openBuilding(context, b.id),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(VuV2Radii.lg),
                        border: Border.all(color: VuV2Colors.stroke),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            VuV2Colors.navyElevated,
                            VuV2Colors.orange.withValues(alpha: 0.12),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(b.emoji, style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(
                            b.title,
                            style: const TextStyle(
                              color: VuV2Colors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            b.blurb,
                            style: const TextStyle(
                              color: VuV2Colors.mute,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _buildings.length,
            ),
          ),
        ),
      ],
    );
  }
}
