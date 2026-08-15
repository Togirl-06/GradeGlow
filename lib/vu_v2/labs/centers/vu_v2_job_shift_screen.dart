import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../vu_v2_lab_models.dart';
import 'vu_v2_job_careers.dart';
import 'vu_v2_lab_progress_store.dart';
import 'vu_v2_school_lab_identity.dart';

/// Play one job level: deal with patients/bosses — no quiz.
class VuV2JobShiftScreen extends StatefulWidget {
  const VuV2JobShiftScreen({
    super.key,
    required this.career,
    required this.level,
    required this.identity,
    required this.progress,
  });

  final VuV2JobCareer career;
  final VuV2JobLevel level;
  final VuV2SchoolLabIdentity identity;
  final VuV2LabProgressStore progress;

  @override
  State<VuV2JobShiftScreen> createState() => _VuV2JobShiftScreenState();
}

class _VuV2JobShiftScreenState extends State<VuV2JobShiftScreen> {
  late String _beatId;
  int _trust = 55;
  int _stress = 25;
  int _quality = 50;
  int _patient = 60;
  bool _ended = false;
  String _lastResult = '';
  final List<String> _log = <String>[];

  VuV2JobCareer get career => widget.career;
  VuV2JobLevel get level => widget.level;
  Color get accent => widget.identity.accent;

  @override
  void initState() {
    super.initState();
    _beatId = level.startBeatId;
    _log.add('${career.bossName}: ${level.brief}');
  }

  VuV2JobBeat get _beat => level.beat(_beatId);

  Future<void> _pick(VuV2JobChoice c) async {
    if (_ended) return;
    setState(() {
      _trust = (_trust + c.deltaTrust).clamp(0, 100);
      _stress = (_stress + c.deltaStress).clamp(0, 100);
      _quality = (_quality + c.deltaQuality).clamp(0, 100);
      _patient = (_patient + c.deltaPatient).clamp(0, 100);
      _lastResult = c.result;
      _log.add('You: ${c.label}');
      _log.add(c.result);
    });

    if (c.failShift || _trust <= 15 || _patient <= 10) {
      await _finish(false);
      return;
    }
    if (c.winShift) {
      await _finish(true);
      return;
    }
    if (c.nextBeatId != null) {
      setState(() => _beatId = c.nextBeatId!);
    }
  }

  Future<void> _finish(bool won) async {
    setState(() {
      _ended = true;
    });
    final int xp = won
        ? (80 + (_trust ~/ 5) + (_quality ~/ 5) + level.levelNumber * 20)
        : 15;
    final List<String> badges = await widget.progress.completeJobLevel(
      careerId: career.school.name,
      levelId: level.id,
      levelNumber: level.levelNumber,
      won: won,
      xpGain: xp,
      maxLevel: career.levels.length,
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: VuV2Colors.navyElevated,
          title: Text(
            won ? 'SHIFT CLEARED' : 'SHIFT FAILED',
            style: TextStyle(
              color: won ? accent : const Color(0xFFFB7185),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                won
                    ? '${career.bossName} signed off Level ${level.levelNumber}. '
                        '${level.levelNumber < career.levels.length ? 'Next level unlocked.' : 'Career path complete.'}'
                    : 'You are pulled off the floor. Retry when ready — the job does not pause for pride.',
                style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
              ),
              const SizedBox(height: 12),
              Text(
                'XP +$xp · Trust $_trust · Quality $_quality',
                style: TextStyle(color: accent, fontWeight: FontWeight.w900),
              ),
              if (badges.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Unlocked: ${badges.join(', ')}',
                  style: const TextStyle(color: Color(0xFFFBBF24)),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, won);
              },
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(won ? 'Back to career map' : 'Try again later'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        title: Text('Lv${level.levelNumber} · ${level.title}'),
      ),
      body: Column(
        children: <Widget>[
          _meterBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: <Widget>[
                Text(
                  '${career.workplace} · ${career.jobTitle}',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _beat.title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withValues(alpha: 0.6)),
                    gradient: LinearGradient(
                      colors: <Color>[
                        VuV2Colors.navyElevated,
                        accent.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                  child: Text(
                    _beat.scene,
                    style: const TextStyle(
                      color: VuV2Colors.ink,
                      height: 1.45,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_lastResult.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    _lastResult,
                    style: TextStyle(
                      color: accent,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'WHAT DO YOU DO?',
                  style: TextStyle(
                    color: VuV2Colors.mute,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                if (!_ended)
                  for (final VuV2JobChoice c in _beat.choices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: VuV2Colors.navyElevated,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _pick(c),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: VuV2Colors.stroke),
                            ),
                            child: Text(
                              c.label,
                              style: const TextStyle(
                                color: VuV2Colors.ink,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                Text(
                  'Shift log',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (final String line in _log.reversed.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: VuV2Colors.mute,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meterBar() {
    Widget m(String name, int v, Color c) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$name $v',
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: v / 100,
                  minHeight: 6,
                  color: c,
                  backgroundColor: VuV2Colors.stroke,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final String patientLabel = career.school == VuV2LabSchool.nursing
        ? 'Patient'
        : 'Outcome';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      color: VuV2Colors.navyElevated,
      child: Row(
        children: <Widget>[
          m('Trust', _trust, accent),
          m(patientLabel, _patient, const Color(0xFF34D399)),
          m('Quality', _quality, const Color(0xFFFBBF24)),
          m('Stress', _stress, const Color(0xFFFB7185)),
        ],
      ),
    );
  }
}
