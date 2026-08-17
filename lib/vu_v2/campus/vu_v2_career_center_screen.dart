import 'package:flutter/material.dart';

import '../career_labs/career_lab_registry.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../platform/vu_v2_platform.dart';

class VuV2CareerCenterScreen extends StatelessWidget {
  const VuV2CareerCenterScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  List<CareerLabDef> get _recommended {
    final String m = session.majorId.toLowerCase();
    final List<CareerLabDef> sims = CareerLabRegistry.simulations;
    final List<CareerLabDef> hit = sims.where((CareerLabDef d) {
      return d.id.contains(m) ||
          d.title.toLowerCase().contains(session.majorLabel.toLowerCase().split(' ').first);
    }).toList();
    if (hit.isNotEmpty) return hit;
    return sims.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<CareerLabDef> rec = _recommended;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const VuV2SectionTitle('Career Center'),
        const SizedBox(height: 8),
        Text(
          'You want to become a professional in ${session.majorLabel}. '
          'Path: courses → labs → workplace simulations → portfolio.',
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
                    ? 'Complete a few lessons and a simulation. Coaching gets specific once there is evidence.'
                    : 'You have ${progress.completedLessonIds.length} lessons on record. '
                        'Next: run a workplace simulation and keep the debrief — that becomes portfolio proof.',
                style: TextStyle(color: VuV2Colors.ink, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const VuV2SectionTitle('Recommended simulations'),
        const SizedBox(height: 10),
        ...rec.map(
          (CareerLabDef lab) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => openCareerLab(context, lab),
              tileColor: VuV2Colors.navyElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VuV2Radii.md),
              ),
              leading: Text(lab.emoji, style: TextStyle(fontSize: 24)),
              title: Text(
                lab.title,
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                lab.role,
                style: TextStyle(color: VuV2Colors.mute),
              ),
              trailing: const Icon(Icons.play_arrow_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const VuV2SectionTitle('Portfolio'),
        const SizedBox(height: 8),
        VuV2Surface(
          child: Text(
            progress.completedLessonIds.isEmpty
                ? 'Empty. Finished labs, memos, and simulation debriefs will collect here.'
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
