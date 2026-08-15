import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_topic_content.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_assessment_screen.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const VuV2SectionTitle('Practice lab'),
        const SizedBox(height: 8),
        Text(
          'Quizzes, flash checks, and quick drills for your enrolled path.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 16),
        _PracticeCard(
          emoji: '✅',
          title: 'Quick knowledge check',
          subtitle: '5–8 mixed questions · MC · T/F · short answer',
          onTap: () {
            final pack = VuV2TopicContent.forLesson(
              subjectId: session.majorId,
              facultyTitle: session.majorLabel,
              facultyEmoji: '🎓',
              trackTitle: 'Practice',
              courseTitle: session.majorLabel,
              topicTitle: 'Weekly check-in',
              interactive: true,
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => VuV2AssessmentScreen(
                  title: 'Weekly check-in',
                  subtitle: '${session.majorLabel} · pass ≥70%',
                  questions: pack.topicQuiz,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _PracticeCard(
          emoji: '🧪',
          title: 'Course simulations',
          subtitle: 'Open your degree roadmap and jump into a lab lesson.',
          onTap: () {
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
        const SizedBox(height: 12),
        VuV2Surface(
          child: Text(
            progress.isPremium
                ? 'Premium unlocked — unlimited AI practice sessions.'
                : 'Free plan: limited AI tutoring. Upgrade in Subscription for unlimited professor time.',
            style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VuV2Colors.navyElevated,
      borderRadius: BorderRadius.circular(VuV2Radii.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(VuV2Radii.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VuV2Radii.xl),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: VuV2Colors.mute, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: VuV2Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
