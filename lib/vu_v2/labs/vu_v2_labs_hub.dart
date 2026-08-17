import 'package:flutter/material.dart';

import '../../config/vu_schools_catalog.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'course_labs_catalog.dart';

/// Fields asked before the student enters Virtual University.
const Set<String> kVuIntakeSubjectIds = <String>{
  'biology',
  'chemistry',
  'physics',
  'mathematics',
  'computer_science',
  'engineering',
  'medicine',
  'nursing',
  'psychology',
  'business',
  'accounting',
  'finance',
  'economics',
  'marketing',
  'law',
};

/// Virtual Labs — schools from the campus directory, plus intake-question fields.
class VuV2LabsHub extends StatelessWidget {
  const VuV2LabsHub({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final List<CourseLabEntry> myLabs =
        CourseLabsCatalog.forMajor(session.majorId);
    final List<VuSchool> schools = VuSchoolsCatalog.schools;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const VuV2SectionTitle('Virtual Labs'),
        const SizedBox(height: 8),
        Text(
          'Open a school, then a program. Your choices change the simulation.\n'
          '${session.majorLabel}: ${myLabs.length} labs ready.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.45),
        ),
        if (myLabs.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          VuV2SectionTitle('Your course · ${session.majorLabel}'),
          const SizedBox(height: 8),
          Text(
            'Walk into this workplace and complete the mission.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
          const SizedBox(height: 12),
          ...myLabs.map(
            (CourseLabEntry lab) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LabCard(
                emoji: lab.emoji,
                title: lab.title,
                subtitle: lab.subtitle,
                accent: VuV2Colors.mint,
                onTap: () => lab.open(context),
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        const VuV2SectionTitle('Schools'),
        const SizedBox(height: 8),
        Text(
          'The ten Virtual University schools — including Biology, Chemistry, '
          'Physics, Math, Computer Science, Engineering, Medicine, Nursing, '
          'Psychology, Business, Accounting, Finance, Economics, Marketing, and Law.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.45),
        ),
        const SizedBox(height: 12),
        ...schools.map((VuSchool school) {
          final bool mine = school.programs.any(
            (VuSchoolProgram p) =>
                p.roadmapSubjectId == session.majorId ||
                p.id == session.majorId,
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
                      builder: (_) => _SchoolLabsScreen(
                        session: session,
                        progress: progress,
                        school: school,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(VuV2Radii.lg),
                    border: Border.all(
                      color: mine ? VuV2Colors.mint : VuV2Colors.stroke,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(school.emoji, style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              school.title,
                              style: TextStyle(
                                color: VuV2Colors.ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            if (school.blurb != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                school.blurb!,
                                style: TextStyle(
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
                                color: VuV2Colors.mint,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
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
    );
  }
}

class _SchoolLabsScreen extends StatelessWidget {
  const _SchoolLabsScreen({
    required this.session,
    required this.progress,
    required this.school,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final VuSchool school;

  @override
  Widget build(BuildContext context) {
    final List<VuSchoolProgram> programs = List<VuSchoolProgram>.from(
      school.programs,
    )..sort((VuSchoolProgram a, VuSchoolProgram b) {
        final int ai = kVuIntakeSubjectIds.contains(a.roadmapSubjectId) ? 0 : 1;
        final int bi = kVuIntakeSubjectIds.contains(b.roadmapSubjectId) ? 0 : 1;
        if (ai != bi) return ai - bi;
        return a.title.compareTo(b.title);
      });

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(title: Text(school.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          if (school.blurb != null)
            Text(
              school.blurb!,
              style: TextStyle(color: VuV2Colors.mute, height: 1.45),
            ),
          const SizedBox(height: 16),
          ...programs.map((VuSchoolProgram program) {
            final bool intake =
                kVuIntakeSubjectIds.contains(program.roadmapSubjectId);
            final int labCount =
                CourseLabsCatalog.forMajor(program.roadmapSubjectId).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LabCard(
                emoji: school.emoji,
                title: program.title,
                subtitle: intake
                    ? (labCount > 0
                        ? 'Campus field · $labCount labs'
                        : 'Campus field')
                    : (program.blurb ?? '${school.title} program'),
                accent: VuV2Colors.mint,
                onTap: labCount == 0
                    ? null
                    : () => CourseLabsCatalog.openCoursePicker(
                          context,
                          majorId: program.roadmapSubjectId,
                          session: session,
                          progress: progress,
                        ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool locked = onTap == null;
    return Material(
      color: VuV2Colors.navyElevated,
      borderRadius: BorderRadius.circular(VuV2Radii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(VuV2Radii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VuV2Radii.lg),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Row(
            children: <Widget>[
              Text(emoji, style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: locked ? VuV2Colors.mute : VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right_rounded,
                color: locked ? VuV2Colors.mute : accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
