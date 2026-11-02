import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2CareerCenterScreen extends StatelessWidget {
  const VuV2CareerCenterScreen({
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
        const VuV2SectionTitle('Career Center'),
        const SizedBox(height: 8),
        Text(
          'You want to become a professional in ${session.majorLabel}. '
          'Path: courses → study tools → portfolio.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.45),
        ),
        const SizedBox(height: 16),
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'AI CAREER COACH',
                style: TextStyle(
                  color: VuV2Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progress.completedLessonIds.isEmpty
                    ? 'Complete a few lessons. Coaching gets specific once there is evidence.'
                    : 'You have ${progress.completedLessonIds.length} lessons on record. '
                        'Keep building mastery — portfolio tools come next.',
                style: TextStyle(color: VuV2Colors.ink, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const VuV2SectionTitle('Portfolio'),
        const SizedBox(height: 8),
        VuV2Surface(
          child: Text(
            progress.completedLessonIds.isEmpty
                ? 'Empty. Finished lessons and certificates will collect here.'
                : '${progress.completedLessonIds.length} lesson artifacts · '
                    '${progress.earnedCertificateIds.length} certificates. '
                    'Full portfolio builder is coming soon.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
        ),
      ],
    );
  }
}
