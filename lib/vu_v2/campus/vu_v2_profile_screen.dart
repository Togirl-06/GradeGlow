import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/vu_schools_catalog.dart';
import '../../services/auth_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_account_screen.dart';
import 'vu_v2_certificate_screen.dart';

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

  String get _initials {
    final String name = session.displayName.trim();
    if (name.isEmpty) return 'S';
    final List<String> parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  List<String> get _enrolledTitles {
    final List<String> titles = <String>[];
    for (final VuSchool school in VuSchoolsCatalog.schools) {
      for (final VuSchoolProgram program in school.programs) {
        if (progress.enrolledDegreeIds.contains(program.roadmapSubjectId) ||
            progress.enrolledDegreeIds.contains(program.id)) {
          titles.add(program.title);
        }
      }
    }
    if (titles.isEmpty) titles.add(session.majorLabel);
    return titles;
  }

  @override
  Widget build(BuildContext context) {
    final String email = _safeEmail(context);
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: embedded ? null : AppBar(title: const Text('Student profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          _StudentIdCard(
            initials: _initials,
            name: session.displayName,
            major: session.majorLabel,
            email: email,
            studentId: _studentId(context),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  label: 'Lessons',
                  value: '${progress.completedLessonIds.length}',
                  icon: Icons.menu_book_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'Streak',
                  value: '${progress.streakDays}d',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  label: 'Pred. GPA',
                  value: progress.quizScores.isEmpty ? '—' : progress.gpaLabel,
                  icon: Icons.school_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'XP',
                  value: '${progress.lessonXp}',
                  icon: Icons.bolt_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Academic record'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  session.majorLabel,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.weeklyMinutes} min / week · '
                  '${progress.studyMinutes} min logged · '
                  '${progress.enrolledDegreeIds.length} programs enrolled',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _enrolledTitles
                      .take(8)
                      .map(
                        (String t) => Chip(
                          label: Text(t),
                          backgroundColor: VuV2Colors.navyElevated,
                          side: const BorderSide(color: VuV2Colors.stroke),
                          labelStyle: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Skills & achievements'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  progress.completedLessonIds.isEmpty
                      ? 'Complete a lecture, lab, and knowledge check to earn your first badge.'
                      : 'Campus explorer · ${progress.completedLessonIds.length} lessons mastered · streak ${progress.streakDays}',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (progress.skills.isEmpty
                          ? <String>['Curiosity', 'Consistency']
                          : progress.skills)
                      .map(
                        (String s) => Chip(
                          avatar: const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: VuV2Colors.mint,
                          ),
                          label: Text(s),
                          backgroundColor: VuV2Colors.navyElevated,
                          side: BorderSide(
                            color: VuV2Colors.mint.withValues(alpha: 0.35),
                          ),
                          labelStyle: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Certificates'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  progress.earnedCertificateIds.isEmpty
                      ? 'Learning certificates unlock as you complete courses. Preview the format anytime.'
                      : '${progress.earnedCertificateIds.length} certificate(s) earned.',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                VuV2PrimaryButton(
                  label: progress.earnedCertificateIds.isEmpty
                      ? 'Preview certificate'
                      : 'Open certificates',
                  icon: Icons.workspace_premium_rounded,
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          VuV2PrimaryButton(
            label: 'Account settings',
            icon: Icons.manage_accounts_rounded,
            trailingArrow: true,
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
          ),
        ],
      ),
    );
  }

  String _safeEmail(BuildContext context) {
    try {
      final String email = context.read<AuthService>().email.trim();
      return email.isEmpty ? 'Campus student' : email;
    } catch (_) {
      return 'Campus student';
    }
  }

  String _studentId(BuildContext context) {
    try {
      final String? uid = context.read<AuthService>().uid;
      if (uid == null || uid.isEmpty) return 'GG-GUEST';
      final String tail = uid.length >= 6 ? uid.substring(0, 6) : uid;
      return 'GG-${tail.toUpperCase()}';
    } catch (_) {
      return 'GG-CAMPUS';
    }
  }
}

class _StudentIdCard extends StatelessWidget {
  const _StudentIdCard({
    required this.initials,
    required this.name,
    required this.major,
    required this.email,
    required this.studentId,
  });

  final String initials;
  final String name;
  final String major;
  final String email;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VuV2Radii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF123044),
            Color(0xFF0F3D34),
            Color(0xFF1A2744),
          ],
        ),
        border: Border.all(color: VuV2Colors.mint.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'GRADE GLOW  ·  VIRTUAL UNIVERSITY',
                style: TextStyle(
                  color: VuV2Colors.mint,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                studentId,
                style: const TextStyle(
                  color: VuV2Colors.mute,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 34,
                backgroundColor: VuV2Colors.mint.withValues(alpha: 0.22),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: VuV2Colors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      major,
                      style: const TextStyle(
                        color: VuV2Colors.mint,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Student ID  ·  Campus included at no cost',
              style: TextStyle(
                color: VuV2Colors.mute,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: VuV2Colors.mint, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
