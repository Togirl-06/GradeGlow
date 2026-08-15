import 'package:flutter/material.dart';

import '../../config/vu_schools_catalog.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';
import '../learn/vu_v2_faculty_screen.dart';

class VuV2MyCoursesScreen extends StatelessWidget {
  const VuV2MyCoursesScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final List<String> ids = progress.enrolledDegreeIds.toList()..sort();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const VuV2SectionTitle('My Courses'),
        const SizedBox(height: 8),
        const Text(
          'Programs you are enrolled in. Open a roadmap to continue Learn → Practice → Test.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 16),
        if (ids.isEmpty)
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'No enrollments yet',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse Lecture Halls and enroll in a program.',
                  style: TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 12),
                VuV2PrimaryButton(
                  label: 'Browse programs',
                  icon: Icons.menu_book_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2FacultyScreen(
                          session: session,
                          progress: progress,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        else
          ...ids.map((String id) {
            final _Prog meta = _lookup(id);
            final VuV2DegreeRoadmap roadmap = VuV2RoadmapSync.forSubjectId(id);
            final List<String> lessonIds = roadmap.tracks
                .expand((VuV2RoadmapTrack t) => t.courses)
                .expand((VuV2RoadmapCourse c) => c.allLessons)
                .map((VuV2RoadmapLesson l) => l.id)
                .toList();
            final double pct = progress.degreeProgress(lessonIds: lessonIds);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: VuV2Colors.navyElevated,
                borderRadius: BorderRadius.circular(VuV2Radii.lg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(VuV2Radii.lg),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2DegreeRoadmapScreen(
                          session: session,
                          subjectId: id,
                          progress: progress,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          meta.title,
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta.school,
                          style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        VuV2ProgressBar(value: pct),
                        const SizedBox(height: 6),
                        Text(
                          '${(pct * 100).round()}% · ${lessonIds.length} lessons',
                          style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  _Prog _lookup(String id) {
    for (final VuSchool school in VuSchoolsCatalog.schools) {
      for (final VuSchoolProgram p in school.programs) {
        if (p.roadmapSubjectId == id || p.id == id) {
          return _Prog(title: p.title, school: school.title);
        }
      }
    }
    return _Prog(title: id, school: 'Program');
  }
}

class _Prog {
  const _Prog({required this.title, required this.school});
  final String title;
  final String school;
}
