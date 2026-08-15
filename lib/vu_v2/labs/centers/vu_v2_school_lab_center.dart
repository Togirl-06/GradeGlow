import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../vu_v2_lab_models.dart';
import 'vu_v2_job_careers.dart';
import 'vu_v2_job_shift_screen.dart';
import 'vu_v2_lab_game.dart';
import 'vu_v2_lab_progress_store.dart';
import 'vu_v2_school_lab_identity.dart';

/// Virtual job career HQ — levels, bosses, patients. Not a quiz list.
class VuV2SchoolLabCenter extends StatefulWidget {
  const VuV2SchoolLabCenter({
    super.key,
    required this.school,
    this.initialExperimentId,
  });

  final VuV2LabSchool school;
  final String? initialExperimentId;

  @override
  State<VuV2SchoolLabCenter> createState() => _VuV2SchoolLabCenterState();
}

class _VuV2SchoolLabCenterState extends State<VuV2SchoolLabCenter> {
  final VuV2LabProgressStore _progress = VuV2LabProgressStore();
  late final VuV2SchoolLabIdentity _identity;
  late final VuV2JobCareer _career;
  bool _booted = false;

  @override
  void initState() {
    super.initState();
    _identity = VuV2SchoolLabIdentity.forSchool(widget.school);
    _career = VuV2JobCareers.forSchool(widget.school);
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (!mounted) return;
    setState(() => _booted = true);
    if (!_progress.sawDayOne(widget.school)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dayOne();
      });
    }
  }

  Future<void> _dayOne() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: VuV2Colors.navyElevated,
          title: Text(
            'Hire date · ${_career.jobTitle}',
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Workplace: ${_career.workplace}\n'
            'Boss: ${_career.bossName}\n\n'
            '${_career.tagline}\n\n'
            'This is a job sim. Clear levels by dealing with real situations — '
            'patients, bosses, deadlines. No multiple-choice test mode.',
            style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(backgroundColor: _identity.accent),
              child: const Text('Clock in'),
            ),
          ],
        );
      },
    );
    await _progress.markDayOne(widget.school);
  }

  Future<void> _openLevel(VuV2JobLevel level) async {
    final int unlocked = _progress.unlockedJobLevel(_career.school.name);
    if (level.levelNumber > unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Locked. Clear Level ${level.levelNumber - 1} for ${_career.bossName} first.',
          ),
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => VuV2JobShiftScreen(
          career: _career,
          level: level,
          identity: _identity,
          progress: _progress,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int cleared = _progress.jobLevelCleared[_career.school.name] ?? 0;
    final int unlocked = _progress.unlockedJobLevel(_career.school.name);
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              VuV2Colors.navy,
              Color.lerp(VuV2Colors.navy, _identity.accent, 0.14)!,
              VuV2Colors.navyElevated,
            ],
          ),
        ),
        child: SafeArea(
          child: !_booted
              ? Center(
                  child: CircularProgressIndicator(color: _identity.accent),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: VuV2Colors.ink,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _career.workplace.toUpperCase(),
                                  style: TextStyle(
                                    color: _identity.accent,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _career.jobTitle,
                                  style: const TextStyle(
                                    color: VuV2Colors.ink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '🔥 ${_progress.streak}',
                            style: TextStyle(
                              color: _identity.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        children: <Widget>[
                          VuV2LabGlass(
                            accent: _identity.accent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'VIRTUAL JOB · ${_career.bossName}',
                                  style: const TextStyle(
                                    color: VuV2Colors.ink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _career.tagline,
                                  style: TextStyle(
                                    color: _identity.accent,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                VuV2LabGameHud(
                                  xp: _progress.xp,
                                  streak: _progress.streak,
                                  bestStreak: _progress.bestStreak,
                                  accent: _identity.accent,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Career progress $cleared / ${_career.levels.length} levels',
                                  style: const TextStyle(
                                    color: VuV2Colors.mute,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _career.levels.isEmpty
                                        ? 0
                                        : cleared / _career.levels.length,
                                    minHeight: 8,
                                    color: _identity.accent,
                                    backgroundColor: VuV2Colors.stroke,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Level select',
                            style: TextStyle(
                              color: VuV2Colors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Walk into the shift. Make decisions. Live with the meters.',
                            style: TextStyle(
                              color: VuV2Colors.mute,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final VuV2JobLevel lv in _career.levels)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _levelCard(lv, unlocked),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _levelCard(VuV2JobLevel lv, int unlocked) {
    final bool locked = lv.levelNumber > unlocked;
    final bool done =
        (_progress.jobLevelCleared[_career.school.name] ?? 0) >= lv.levelNumber;
    return VuV2LabGlass(
      accent: locked
          ? VuV2Colors.mute
          : done
              ? VuV2Colors.success
              : _identity.accent,
      onTap: locked ? null : () => _openLevel(lv),
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _identity.accent.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    'LEVEL ${lv.levelNumber}',
                    style: TextStyle(
                      color: _identity.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  locked
                      ? Icons.lock
                      : done
                          ? Icons.check_circle
                          : Icons.play_circle_fill,
                  color: locked
                      ? VuV2Colors.mute
                      : done
                          ? VuV2Colors.success
                          : _identity.accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              lv.title,
              style: const TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lv.brief,
              style: const TextStyle(
                color: VuV2Colors.mute,
                height: 1.35,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              locked
                  ? 'Locked'
                  : done
                      ? 'Cleared · replay shift'
                      : 'Clock in →',
              style: TextStyle(
                color: locked
                    ? VuV2Colors.mute
                    : done
                        ? VuV2Colors.success
                        : _identity.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
