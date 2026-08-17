import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/vu_schools_catalog.dart';
import '../../services/auth_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import 'vu_v2_account_screen.dart';
import 'vu_v2_certificate_screen.dart';
import 'vu_v2_registrar_style.dart';

/// Official student record — registrar office, not a game profile.
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
    final String email = _email(context);
    final String id = _studentId(context);
    final String standing = _standing();
    final List<_EnrollmentRow> enrollments = _enrollments();
    final int credits = progress.completedLessonIds.length * 3;
    final String gpa = progress.quizScores.isEmpty ? '—' : progress.gpaLabel;

    return RegistrarScaffold(
      title: 'Student record',
      showAppBar: !embedded,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: <Widget>[
          if (embedded) ...<Widget>[
            const Text(
              'OFFICE OF THE REGISTRAR',
              style: RegistrarType.kicker,
            ),
            const SizedBox(height: 6),
            const Text('Student record', style: RegistrarType.serifName),
            const SizedBox(height: 16),
          ],
          RegistrarCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  color: RegistrarColors.navy,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'GRADE GLOW VIRTUAL UNIVERSITY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Academic record',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Text(session.displayName, style: RegistrarType.serifName),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: RegistrarColors.rule, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    children: <Widget>[
                      RegistrarRow(label: 'Student ID', value: id),
                      RegistrarRow(label: 'Email', value: email),
                      RegistrarRow(label: 'College', value: _college()),
                      RegistrarRow(label: 'Program', value: session.majorLabel),
                      RegistrarRow(label: 'Standing', value: standing),
                      RegistrarRow(label: 'Term GPA', value: gpa),
                      RegistrarRow(
                        label: 'Credits earned',
                        value: credits == 0 ? 'None posted' : '$credits CH',
                      ),
                      RegistrarRow(
                        label: 'Contact hours',
                        value: '${progress.studyMinutes} recorded',
                      ),
                      RegistrarRow(
                        label: 'Attendance',
                        value: progress.attendanceDays.isEmpty
                            ? 'No sessions posted'
                            : '${progress.attendanceDays.length} session days',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Current enrollment'),
          RegistrarCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                const _TableHead(
                  a: 'Program',
                  b: 'Status',
                ),
                if (enrollments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No degree programs on file. Enroll from the Schools catalog.',
                        style: RegistrarType.body,
                      ),
                    ),
                  )
                else
                  ...enrollments.map(
                    (_EnrollmentRow row) => _TableLine(a: row.title, b: row.status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Transcript notes'),
          RegistrarCard(
            child: Text(
              progress.completedLessonIds.isEmpty
                  ? 'No coursework has been posted. Complete a lecture, laboratory, and examination to begin the official record.'
                  : '${progress.completedLessonIds.length} lesson${progress.completedLessonIds.length == 1 ? '' : 's'} posted. '
                      'Laboratory and examination grades contribute to the predicted term GPA ($gpa).',
              style: RegistrarType.body,
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Credentials'),
          RegistrarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  progress.earnedCertificateIds.isEmpty
                      ? 'No certificates issued. Course certificates are recorded here when requirements are complete.'
                      : '${progress.earnedCertificateIds.length} certificate${progress.earnedCertificateIds.length == 1 ? '' : 's'} on file.',
                  style: RegistrarType.body,
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2CertificateScreen(
                          studentName: session.displayName,
                          courseTitle: session.majorLabel,
                          verificationId:
                              'GG-${session.majorId.toUpperCase()}-CAMPUS',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RegistrarColors.navy,
                    side: const BorderSide(color: RegistrarColors.navy),
                    minimumSize: const Size.fromHeight(44),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    progress.earnedCertificateIds.isEmpty
                        ? 'View certificate specimen'
                        : 'Open certificates',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2AccountScreen(
                    session: session,
                    progress: progress,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: RegistrarColors.ink,
              side: const BorderSide(color: RegistrarColors.rule),
              backgroundColor: RegistrarColors.panel,
              minimumSize: const Size.fromHeight(48),
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('Account & billing'),
          ),
        ],
      ),
    );
  }

  String _college() {
    final String id = session.majorId.toLowerCase();
    for (final VuSchool school in VuSchoolsCatalog.schools) {
      for (final VuSchoolProgram program in school.programs) {
        if (program.roadmapSubjectId == session.majorId ||
            program.id == session.majorId ||
            program.title.toLowerCase() == session.majorLabel.toLowerCase()) {
          return school.title;
        }
      }
      if (school.id.contains(id) || id.contains(school.id)) {
        return school.title;
      }
    }
    return 'Virtual University';
  }

  List<_EnrollmentRow> _enrollments() {
    final List<_EnrollmentRow> rows = <_EnrollmentRow>[];
    for (final VuSchool school in VuSchoolsCatalog.schools) {
      for (final VuSchoolProgram program in school.programs) {
        if (progress.enrolledDegreeIds.contains(program.roadmapSubjectId) ||
            progress.enrolledDegreeIds.contains(program.id)) {
          rows.add(
            _EnrollmentRow(
              title: program.title,
              status: 'Enrolled · ${school.title}',
            ),
          );
        }
      }
    }
    if (rows.isEmpty) {
      rows.add(
        _EnrollmentRow(title: session.majorLabel, status: 'Declared'),
      );
    }
    return rows.take(12).toList();
  }

  String _standing() {
    if (progress.completedLessonIds.isEmpty) return 'Matriculated';
    if (progress.quizScores.isNotEmpty && progress.gpa < 2.0) {
      return 'Academic warning';
    }
    if (progress.quizScores.isNotEmpty && progress.gpa >= 3.5) {
      return 'Good standing · Dean’s list eligible';
    }
    return 'Good academic standing';
  }

  String _email(BuildContext context) {
    try {
      final String email = context.read<AuthService>().email.trim();
      return email.isEmpty ? 'Not on file' : email;
    } catch (_) {
      return 'Not on file';
    }
  }

  String _studentId(BuildContext context) {
    try {
      final String? uid = context.read<AuthService>().uid;
      if (uid == null || uid.isEmpty) return 'GG-000000';
      final String tail = uid.length >= 8 ? uid.substring(0, 8) : uid;
      return 'GG-${tail.toUpperCase()}';
    } catch (_) {
      return 'GG-000000';
    }
  }
}

class _EnrollmentRow {
  const _EnrollmentRow({required this.title, required this.status});
  final String title;
  final String status;
}

class _TableHead extends StatelessWidget {
  const _TableHead({required this.a, required this.b});
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEE8DC),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(a.toUpperCase(), style: RegistrarType.label),
          ),
          Expanded(
            flex: 2,
            child: Text(b.toUpperCase(), style: RegistrarType.label),
          ),
        ],
      ),
    );
  }
}

class _TableLine extends StatelessWidget {
  const _TableLine({required this.a, required this.b});
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RegistrarColors.rule)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(a, style: RegistrarType.body.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(b, style: RegistrarType.body.copyWith(color: RegistrarColors.mute)),
          ),
        ],
      ),
    );
  }
}
