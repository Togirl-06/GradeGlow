import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/vu_schools_catalog.dart';
import '../../services/auth_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_account_screen.dart';
import 'vu_v2_certificate_screen.dart';
import 'vu_v2_registrar_style.dart';

/// Student record — GradeGlow profile card, not a registrar letterhead.
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
    final int credits = progress.completedLessonIds.length * 3;
    final String gpa = progress.quizScores.isEmpty ? '—' : progress.gpaLabel;
    final String college = _college();
    final String collegeShort = _collegeShort(college);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return RegistrarScaffold(
      title: 'Profile',
      showAppBar: !embedded,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: <Widget>[
          RegistrarCard(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _AvatarMark(name: session.displayName),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            session.displayName,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$id · $college',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(label: standing),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: scheme.outline),
                const SizedBox(height: 6),
                _FactGrid(
                  pairs: <(String, String)>[
                    ('Email', email),
                    ('Student ID', id),
                    ('Program', session.majorLabel),
                    ('College', collegeShort),
                    ('Term GPA', gpa),
                    (
                      'Contact hours',
                      '${progress.studyMinutes} recorded',
                    ),
                    (
                      'Credits earned',
                      credits == 0 ? 'None posted' : '$credits CH',
                    ),
                    (
                      'Attendance',
                      progress.attendanceDays.isEmpty
                          ? 'No sessions posted'
                          : '${progress.attendanceDays.length} session day${progress.attendanceDays.length == 1 ? '' : 's'}',
                    ),
                  ],
                ),
              ],
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
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
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

  String _collegeShort(String college) {
    if (college.contains('Technology')) return 'School of Technology & CS';
    if (college.contains('Engineering')) return 'School of Engineering';
    if (college.contains('Health') || college.contains('Medicine')) {
      return 'School of Health';
    }
    if (college.contains('Business')) return 'School of Business';
    return college;
  }

  String _standing() {
    if (progress.completedLessonIds.isEmpty) return 'Matriculated';
    if (progress.quizScores.isNotEmpty && progress.gpa < 2.0) {
      return 'Academic warning';
    }
    if (progress.quizScores.isNotEmpty && progress.gpa >= 3.5) {
      return 'Dean’s list';
    }
    return 'Good standing';
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

class _AvatarMark extends StatelessWidget {
  const _AvatarMark({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final String trimmed = name.trim();
    final String letter =
        trimmed.isEmpty ? 'G' : trimmed.substring(0, 1).toUpperCase();
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            VuV2Colors.gold,
            VuV2Colors.mint,
          ],
        ),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: VuV2Colors.mint.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: VuV2Colors.mint,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.pairs});
  final List<(String, String)> pairs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool two = c.maxWidth >= 520;
        if (!two) {
          return Column(
            children: <Widget>[
              for (final (String label, String value) pair in pairs)
                _FactCell(label: pair.$1, value: pair.$2),
            ],
          );
        }
        final List<Widget> rows = <Widget>[];
        for (int i = 0; i < pairs.length; i += 2) {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _FactCell(label: pairs[i].$1, value: pairs[i].$2),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: i + 1 < pairs.length
                      ? _FactCell(label: pairs[i + 1].$1, value: pairs[i + 1].$2)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class _FactCell extends StatelessWidget {
  const _FactCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
