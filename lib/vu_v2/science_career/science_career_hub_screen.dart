import 'package:flutter/material.dart';

import 'career_center_screen.dart';
import 'coding_arena_screen.dart';
import 'company_district_screen.dart';
import 'interview_center_screen.dart';
import 'northwind_workplace_screen.dart';
import 'project_lab_screen.dart';
import 'science_career_content.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

/// School of Science career simulation hub — isometric cosmic campus.
class ScienceCareerHubScreen extends StatefulWidget {
  const ScienceCareerHubScreen({
    super.key,
    this.initialMajorId,
    this.playerName,
  });

  final String? initialMajorId;
  final String? playerName;

  @override
  State<ScienceCareerHubScreen> createState() => _ScienceCareerHubScreenState();
}

class _ScienceCareerHubScreenState extends State<ScienceCareerHubScreen> {
  final ScienceCareerProgress _progress = ScienceCareerProgress.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (widget.initialMajorId != null) {
      await _progress.setMajor(widget.initialMajorId!);
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, Animation<double> a, _, Widget child) {
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: SciCosmic.bg,
        body: Center(child: CircularProgressIndicator(color: SciCosmic.purple)),
      );
    }

    final ScienceMajor major = ScienceMajors.byId(_progress.majorId);
    final String name =
        (widget.playerName ?? 'Student').trim().split(' ').first;
    final String initial =
        name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: SciCosmic.bg,
      body: SciStarfield(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _progress,
            builder: (BuildContext context, _) {
              return Column(
                children: <Widget>[
                  _TopHud(
                    name: name,
                    initial: initial,
                    level: _progress.level,
                    stage: _progress.stageLabel,
                    xp: _progress.xpIntoLevel,
                    xpMax: _progress.xpToNextLevel,
                    balanceLabel: _progress.balanceLabel,
                    lifetimeEarnedLabel: _progress.lifetimeEarnedLabel,
                  ),
                  Expanded(
                    child: _IsoWorld(
                      employed: _progress.hasAnyJob,
                      jobActionLabel: _progress.jobActionLabel(),
                      interviewReady: _progress.appliedJobIds.any(
                        (String id) =>
                            _progress.statusFor(id) == 'applied' ||
                            _progress.statusFor(id) == 'interviewed',
                      ),
                      onArena: () => _open(
                        CodingArenaScreen(progress: _progress),
                      ),
                      onInterview: () => _open(
                        InterviewCenterScreen(progress: _progress),
                      ),
                      onCareer: () => _open(
                        CareerCenterScreen(progress: _progress),
                      ),
                      onCompany: () {
                        if (_progress.hasAnyJob) {
                          if (_progress.isEmployedAtNorthwind) {
                            _open(
                              NorthwindWorkplaceScreen(progress: _progress),
                            );
                          } else {
                            _open(CompanyDistrictScreen(progress: _progress));
                          }
                        } else {
                          _toast(
                            'Company District unlocks after you accept a job offer',
                          );
                        }
                      },
                      onProject: () => _open(
                        ProjectLabScreen(progress: _progress),
                      ),
                    ),
                  ),
                  _BottomHud(
                    major: major,
                    progress: _progress,
                    onMajorChanged: (String id) async {
                      await _progress.setMajor(id);
                      setState(() {});
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.name,
    required this.initial,
    required this.level,
    required this.stage,
    required this.xp,
    required this.xpMax,
    required this.balanceLabel,
    required this.lifetimeEarnedLabel,
  });

  final String name;
  final String initial;
  final int level;
  final String stage;
  final int xp;
  final int xpMax;
  final String balanceLabel;
  final String lifetimeEarnedLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: SciCosmic.mute,
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: SciCosmic.purple,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: SciCosmic.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Level $level · $stage',
                  style: const TextStyle(
                    color: SciCosmic.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (xp / xpMax).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: SciCosmic.stroke,
                    color: SciCosmic.electric,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xp / $xpMax XP',
                  style: const TextStyle(color: SciCosmic.mute, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SciCosmic.pill(
                  'Bank $balanceLabel',
                  icon: Icons.account_balance_wallet_rounded,
                  bg: SciCosmic.gold.withValues(alpha: 0.18),
                  fg: SciCosmic.gold,
                ),
                const SizedBox(height: 6),
                SciCosmic.pill(
                  'Made $lifetimeEarnedLabel',
                  icon: Icons.trending_up_rounded,
                  bg: SciCosmic.success.withValues(alpha: 0.16),
                  fg: SciCosmic.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IsoWorld extends StatelessWidget {
  const _IsoWorld({
    required this.employed,
    required this.jobActionLabel,
    required this.interviewReady,
    required this.onArena,
    required this.onInterview,
    required this.onCareer,
    required this.onCompany,
    required this.onProject,
  });

  final bool employed;
  final String jobActionLabel;
  final bool interviewReady;
  final VoidCallback onArena;
  final VoidCallback onInterview;
  final VoidCallback onCareer;
  final VoidCallback onCompany;
  final VoidCallback onProject;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool wide = c.maxWidth > 720;
        return Column(
          children: <Widget>[
            const SizedBox(height: 8),
            const Text(
              'School of Science',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Explore the campus · complete missions · build your career',
              style: TextStyle(
                color: SciCosmic.mute.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            ),
            Expanded(
              child: wide
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 920,
                          maxHeight: 520,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CustomPaint(
                              size: Size.infinite,
                              painter: _GridPainter(),
                            ),
                            _Building(
                              top: 0.06,
                              left: 0.38,
                              color: SciCosmic.purple,
                              label: '1. Coding Arena',
                              sub: 'Challenges and boss fights',
                              icon: Icons.code_rounded,
                              glow: true,
                              onTap: onArena,
                            ),
                            _Building(
                              top: 0.12,
                              left: 0.72,
                              color: const Color(0xFF1E3A5F),
                              label: '2. Career Center',
                              sub: 'Apply with résumé',
                              icon: Icons.work_rounded,
                              tall: true,
                              glow: true,
                              onTap: onCareer,
                            ),
                            _Building(
                              top: 0.28,
                              left: 0.62,
                              color: SciCosmic.electric,
                              label: '3. Interview Center',
                              sub: 'After you apply',
                              icon: Icons.chat_bubble_rounded,
                              badge: interviewReady ? '!' : null,
                              onTap: onInterview,
                            ),
                            _Building(
                              top: 0.52,
                              left: 0.28,
                              color: SciCosmic.teal,
                              label: '4. Company District',
                              sub: employed
                                  ? jobActionLabel
                                  : 'Locked until hired',
                              icon: Icons.apartment_rounded,
                              twin: true,
                              youMarker: employed,
                              glow: employed,
                              dim: !employed,
                              onTap: onCompany,
                            ),
                            _Building(
                              top: 0.48,
                              left: 0.08,
                              color: SciCosmic.gold,
                              label: 'Project Lab',
                              sub: 'Build résumé · add projects',
                              icon: Icons.science_rounded,
                              onTap: onProject,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: <Widget>[
                        _DestTile(
                          color: SciCosmic.purple,
                          label: '1. Coding Arena',
                          sub: 'Challenges and boss fights',
                          icon: Icons.code_rounded,
                          glow: true,
                          onTap: onArena,
                        ),
                        _DestTile(
                          color: const Color(0xFF1E3A5F),
                          label: '2. Career Center',
                          sub: 'Apply with résumé',
                          icon: Icons.work_rounded,
                          glow: true,
                          onTap: onCareer,
                        ),
                        _DestTile(
                          color: SciCosmic.electric,
                          label: '3. Interview Center',
                          sub: 'After you apply',
                          icon: Icons.chat_bubble_rounded,
                          badge: interviewReady ? '!' : null,
                          onTap: onInterview,
                        ),
                        _DestTile(
                          color: SciCosmic.teal,
                          label: '4. Company District',
                          sub: employed
                              ? jobActionLabel
                              : 'Locked until hired',
                          icon: Icons.apartment_rounded,
                          glow: employed,
                          dim: !employed,
                          youMarker: employed,
                          onTap: onCompany,
                        ),
                        _DestTile(
                          color: SciCosmic.gold,
                          label: 'Project Lab',
                          sub: 'Build résumé · add projects',
                          icon: Icons.science_rounded,
                          onTap: onProject,
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _DestTile extends StatelessWidget {
  const _DestTile({
    required this.color,
    required this.label,
    required this.sub,
    required this.icon,
    required this.onTap,
    this.glow = false,
    this.dim = false,
    this.youMarker = false,
    this.badge,
  });

  final Color color;
  final String label;
  final String sub;
  final IconData icon;
  final VoidCallback onTap;
  final bool glow;
  final bool dim;
  final bool youMarker;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: dim ? 0.6 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    color.withValues(alpha: 0.95),
                    color.withValues(alpha: 0.45),
                    SciCosmic.bgDeep.withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: glow
                      ? SciCosmic.electric
                      : Colors.white.withValues(alpha: 0.16),
                  width: glow ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (badge != null) ...<Widget>[
                              const SizedBox(width: 6),
                              SciCosmic.pill(
                                badge!,
                                bg: SciCosmic.orange.withValues(alpha: 0.25),
                                fg: SciCosmic.orange,
                              ),
                            ],
                            if (youMarker) ...<Widget>[
                              const SizedBox(width: 6),
                              SciCosmic.pill('You'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Building extends StatelessWidget {
  const _Building({
    required this.top,
    required this.left,
    required this.color,
    required this.label,
    required this.sub,
    required this.icon,
    required this.onTap,
    this.glow = false,
    this.tall = false,
    this.twin = false,
    this.youMarker = false,
    this.dim = false,
    this.badge,
  });

  final double top;
  final double left;
  final Color color;
  final String label;
  final String sub;
  final IconData icon;
  final VoidCallback onTap;
  final bool glow;
  final bool tall;
  final bool twin;
  final bool youMarker;
  final bool dim;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-1 + left * 2, -1 + top * 2),
      child: Opacity(
        opacity: dim ? 0.55 : 1,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: twin ? 148 : 128,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  color.withValues(alpha: 0.95),
                  color.withValues(alpha: 0.55),
                  SciCosmic.bgDeep.withValues(alpha: 0.9),
                ],
              ),
              border: Border.all(
                color: glow
                    ? SciCosmic.electric
                    : Colors.white.withValues(alpha: 0.18),
                width: glow ? 1.6 : 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: glow ? 0.55 : 0.28),
                  blurRadius: glow ? 22 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: tall ? 54 : 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      if (twin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _Block(color: color, h: 34),
                            const SizedBox(width: 6),
                            _Block(color: color.withValues(alpha: 0.8), h: 28),
                          ],
                        )
                      else
                        Icon(icon, color: Colors.white, size: tall ? 34 : 28),
                      if (badge != null)
                        Positioned(
                          right: 8,
                          top: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: SciCosmic.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      if (youMarker)
                        const Positioned(
                          bottom: 0,
                          child: Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.color, required this.h});
  final Color color;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = SciCosmic.electric.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    const int cols = 10;
    const int rows = 8;
    for (int i = 0; i <= cols; i++) {
      final double x = size.width * i / cols;
      canvas.drawLine(Offset(x, size.height * 0.15), Offset(x, size.height), line);
    }
    for (int j = 0; j <= rows; j++) {
      final double y = size.height * (0.15 + 0.85 * j / rows);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({
    required this.major,
    required this.progress,
    required this.onMajorChanged,
  });

  final ScienceMajor major;
  final ScienceCareerProgress progress;
  final ValueChanged<String> onMajorChanged;

  @override
  Widget build(BuildContext context) {
    final bool resumeDone = progress.resumeReadyToApply;
    final bool appliedDone = progress.appliedJobIds.isNotEmpty;
    final bool interviewDone = progress.applicationStatus.values.any(
          (String s) =>
              s == 'oa' ||
              s == 'technical' ||
              s == 'offered' ||
              s == 'hired',
        ) ||
        progress.interviewPassed;
    final bool hiredDone = progress.hasAnyJob;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: SciCosmic.panelBox(radius: 20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool stack = c.maxWidth < 700;
          final Widget majorDrop = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Your major',
                style: TextStyle(color: SciCosmic.mute, fontSize: 11),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: progress.majorId,
                  dropdownColor: SciCosmic.panelAlt,
                  style: const TextStyle(
                    color: SciCosmic.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  items: ScienceMajors.all
                      .map(
                        (ScienceMajor m) => DropdownMenuItem<String>(
                          value: m.id,
                          child: Text(m.title),
                        ),
                      )
                      .toList(),
                  onChanged: (String? id) {
                    if (id != null) onMajorChanged(id);
                  },
                ),
              ),
            ],
          );

          final Widget path = Row(
            children: <Widget>[
              _Step(
                n: 1,
                label: 'Build résumé',
                state: resumeDone ? 'Cleared' : 'Next up',
                done: resumeDone,
                active: !resumeDone,
              ),
              _Step(
                n: 2,
                label: 'Apply with résumé',
                state: appliedDone
                    ? 'Cleared'
                    : resumeDone
                        ? 'Next up'
                        : 'Locked',
                done: appliedDone,
                active: resumeDone && !appliedDone,
              ),
              _Step(
                n: 3,
                label: '3 interviews',
                state: hiredDone
                    ? 'Cleared'
                    : interviewDone
                        ? 'In loop'
                        : appliedDone
                            ? 'Next up'
                            : 'Locked',
                done: hiredDone,
                active: appliedDone && !hiredDone,
              ),
              _Step(
                n: 4,
                label: 'Offer · Start job',
                state: hiredDone
                    ? 'Cleared'
                    : progress.applicationStatus.values.contains('offered')
                        ? 'Accept offer'
                        : interviewDone
                            ? 'Next up'
                            : 'Locked',
                done: hiredDone,
                active: progress.applicationStatus.values.contains('offered') &&
                    !hiredDone,
                last: true,
              ),
            ],
          );

          final Widget daily = Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SciCosmic.panelAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SciCosmic.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Earnings · Made ${progress.lifetimeEarnedLabel}',
                  style: const TextStyle(
                    color: SciCosmic.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bank ${progress.balanceLabel}',
                  style: const TextStyle(
                    color: SciCosmic.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  progress.dailyMissionDone
                      ? 'Daily mission: Done'
                      : 'Daily mission: Solve 1 medium problem',
                  style: const TextStyle(
                    color: SciCosmic.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                majorDrop,
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: path,
                ),
                const SizedBox(height: 10),
                daily,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 180, child: majorDrop),
              Expanded(child: path),
              const SizedBox(width: 12),
              SizedBox(width: 200, child: daily),
            ],
          );
        },
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.n,
    required this.label,
    required this.state,
    required this.done,
    required this.active,
    this.last = false,
  });

  final int n;
  final String label;
  final String state;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? SciCosmic.blue
                    : active
                        ? SciCosmic.ink
                        : SciCosmic.stroke,
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '$n',
                      style: TextStyle(
                        color: active ? SciCosmic.bg : SciCosmic.mute,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: SciCosmic.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              state,
              style: TextStyle(
                color: done
                    ? SciCosmic.success
                    : active
                        ? SciCosmic.electric
                        : SciCosmic.mute,
                fontSize: 10,
              ),
            ),
          ],
        ),
        if (!last)
          Container(
            width: 28,
            height: 2,
            margin: const EdgeInsets.only(bottom: 28, left: 4, right: 4),
            color: SciCosmic.stroke,
          ),
      ],
    );
  }
}
