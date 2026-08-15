import 'package:flutter/material.dart';

import '../../config/vu_schools_catalog.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_scope.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_degree_roadmap_screen.dart';

/// V2 Learn: browse Grade Glow Virtual University by school → program.
class VuV2FacultyScreen extends StatelessWidget {
  const VuV2FacultyScreen({
    super.key,
    required this.session,
    this.progress,
    this.initialFacultyId,
  });

  final VuV2Session session;
  final VuV2ProgressStore? progress;
  final String? initialFacultyId;

  VuV2ProgressStore? _progressOf(BuildContext context) =>
      progress ?? VuV2Scope.maybeOf(context)?.progress;

  @override
  Widget build(BuildContext context) {
    final List<VuSchool> schools = VuSchoolsCatalog.schools;
    final VuV2ProgressStore? store = _progressOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lecture Halls')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          Text(
            'Grade Glow Virtual University · ${VuSchoolsCatalog.schoolCount} schools · '
            '${VuSchoolsCatalog.programCount} programs',
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Open a school, then enroll in any program and start its full roadmap.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...schools.map((VuSchool school) {
            final bool recommended = school.programs.any(
              (VuSchoolProgram p) =>
                  p.roadmapSubjectId ==
                      (initialFacultyId ?? session.majorId) ||
                  p.id == (initialFacultyId ?? session.majorId),
            );
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
                        builder: (_) => VuV2SchoolProgramsScreen(
                          session: session,
                          progress: store,
                          school: school,
                          initialFacultyId: initialFacultyId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VuV2Radii.lg),
                      border: Border.all(
                        color: recommended
                            ? VuV2Colors.orange
                            : VuV2Colors.stroke,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(school.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                school.title,
                                style: const TextStyle(
                                  color: VuV2Colors.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              if (school.blurb != null) ...<Widget>[
                                const SizedBox(height: 4),
                                Text(
                                  school.blurb!,
                                  style: const TextStyle(
                                    color: VuV2Colors.mute,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                '${school.programs.length} programs',
                                style: TextStyle(
                                  color: VuV2Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: VuV2Colors.mute,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Programs inside one school — every program opens a live roadmap.
class VuV2SchoolProgramsScreen extends StatelessWidget {
  const VuV2SchoolProgramsScreen({
    super.key,
    required this.session,
    required this.school,
    this.progress,
    this.initialFacultyId,
  });

  final VuV2Session session;
  final VuSchool school;
  final VuV2ProgressStore? progress;
  final String? initialFacultyId;

  VuV2ProgressStore? _progressOf(BuildContext context) =>
      progress ?? VuV2Scope.maybeOf(context)?.progress;

  @override
  Widget build(BuildContext context) {
    final VuV2ProgressStore? store = _progressOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${school.emoji} ${school.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          if (school.blurb != null) ...<Widget>[
            Text(
              school.blurb!,
              style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
          ...school.programs.map((VuSchoolProgram program) {
            final String subjectId = program.roadmapSubjectId;
            final VuV2DegreeRoadmap roadmap =
                VuV2RoadmapSync.forSubjectId(subjectId);
            final bool recommended =
                subjectId == (initialFacultyId ?? session.majorId) ||
                    program.id == (initialFacultyId ?? session.majorId);
            final bool enrolled =
                store?.enrolledDegreeIds.contains(subjectId) ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: VuV2Colors.navyElevated,
                borderRadius: BorderRadius.circular(VuV2Radii.lg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(VuV2Radii.lg),
                  onTap: () async {
                    await store?.enroll(subjectId);
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2DegreeRoadmapScreen(
                          session: session,
                          subjectId: subjectId,
                          progress: store,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VuV2Radii.lg),
                      border: Border.all(
                        color: recommended
                            ? VuV2Colors.orange
                            : VuV2Colors.stroke,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                program.title,
                                style: const TextStyle(
                                  color: VuV2Colors.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              if (program.blurb != null) ...<Widget>[
                                const SizedBox(height: 4),
                                Text(
                                  program.blurb!,
                                  style: const TextStyle(
                                    color: VuV2Colors.mute,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                enrolled
                                    ? 'Enrolled · ${roadmap.lessonCount} lessons'
                                    : 'Tap to enroll · ${roadmap.lessonCount} lessons',
                                style: TextStyle(
                                  color: enrolled
                                      ? VuV2Colors.success
                                      : VuV2Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: VuV2Colors.mute,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class VuV2LearnTab extends StatelessWidget {
  const VuV2LearnTab({
    super.key,
    required this.session,
    this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore? progress;

  @override
  Widget build(BuildContext context) {
    return VuV2FacultyScreen(session: session, progress: progress);
  }
}
