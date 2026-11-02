import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// River City Public Works — Junior Civil Engineer under Carla Brooks.
Widget civilEngineeringPlayableScreen() => const CivilEngineeringPlayableScreen();

class CivilEngineeringPlayableScreen extends StatelessWidget {
  const CivilEngineeringPlayableScreen({super.key});

  static const Color accent = Color(0xFFFB923C);
  static const Color bg = Color(0xFF120E0A);
  static const Color surface = Color(0xFF1F1812);

  static const PlayableCareer career = PlayableCareer(
    id: 'civil_engineering',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'River City Public Works',
    clockLine: 'Wednesday — 6:45 AM',
    roleTitle: 'Junior Civil Engineer',
    supervisorName: 'Carla Brooks',
    supervisorRole: 'Site Superintendent',
    hireTagline: 'Jobsite reality: materials, budget, schedule — then weather hits.',
    supervisorBrief:
        '“You manage the site today. Balance materials, budget, and schedule.\n\n'
        'When severe weather delays us, adjust the plan without blowing safety.”',
    enterCta: 'ENTER JOBSITE',
    startCta: 'OPEN SITE BOARD',
    startLocationId: 'trailer',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'gate',
        name: 'Site Gate',
        icon: '🚧',
        blurb: 'Hard hats and haul roads.',
        atmosphere: 'River City span rehab. Dust and diesel.',
      ),
      PlayableRoom(
        id: 'trailer',
        name: 'Site Trailer',
        icon: '📋',
        blurb: 'Plans and procurement.',
        atmosphere: 'Brooks wants a live board: materials, budget, schedule.',
      ),
      PlayableRoom(
        id: 'yard',
        name: 'Material Yard',
        icon: '🧱',
        blurb: 'Steel, concrete, aggregate.',
        atmosphere: 'Deliveries slip if you underschedule staging.',
      ),
      PlayableRoom(
        id: 'storm',
        name: 'Weather Desk',
        icon: '🌧️',
        blurb: 'Radar and delay logs.',
        atmosphere: 'Severe weather inbound. Adjust or fail the milestone.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'trailer',
        bannerTitle: 'SITE MANAGEMENT',
        bannerBody: 'Balance materials, budget, and schedule for the week.',
        cta: 'Manage the site',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'storm',
        bannerTitle: 'WEATHER DELAY',
        bannerBody: 'Severe weather hits — adjust plan for schedule and safety.',
        cta: 'Adjust the plan',
        unlockKey: 'lab2',
        requiresKey: 'lab1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return PlayableWorkplaceScreen(
      career: augmentCareerWithVisualLabs(career),
      onOpenStage: (BuildContext ctx, PlayableStage stage) async {
        final bool? visual = await tryRunVisualStage(ctx, stage);
        if (visual != null) return visual;
        if (!ctx.mounted) return false;
        if (stage.id == 'lab1') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _CivilLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _CivilLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _CivilLab1Screen extends StatefulWidget {
  const _CivilLab1Screen();

  @override
  State<_CivilLab1Screen> createState() => _CivilLab1ScreenState();
}

class _CivilLab1ScreenState extends State<_CivilLab1Screen> {
  double _materials = 0.55;
  double _crew = 0.5;
  double _overtime = 0.2;
  String? _feedback;

  int get _budget => (100 - _materials * 35 - _crew * 30 - _overtime * 25).round().clamp(0, 100);
  int get _schedule => (40 + _crew * 35 + _materials * 20 + _overtime * 25 - 15).round().clamp(0, 100);
  int get _readiness => (30 + _materials * 50 + _crew * 20).round().clamp(0, 100);

  void _submit() {
    if (_budget < 25) {
      setState(() => _feedback = 'Brooks: “Budget blown. Rebalance.”');
      return;
    }
    if (_schedule < 50 || _readiness < 55) {
      setState(() => _feedback = 'Site not ready for the pour window.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: CivilEngineeringPlayableScreen.surface,
          title: const Text(
            'Carla Brooks — Site set',
            style: TextStyle(color: CivilEngineeringPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Materials staged, budget alive, schedule credible.\n\n'
            'Radar just turned ugly — meet me at Weather Desk.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: CivilEngineeringPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _meter(String label, int v, Color c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))),
              Text('$v', style: TextStyle(color: c, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: v / 100, color: c, backgroundColor: Colors.white12, minHeight: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivilEngineeringPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: CivilEngineeringPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Site board', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          _meter('Budget headroom', _budget, CivilEngineeringPlayableScreen.accent),
          _meter('Schedule health', _schedule, const Color(0xFF34D399)),
          _meter('Material readiness', _readiness, const Color(0xFF60A5FA)),
          const SizedBox(height: 8),
          const Text('Material orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _materials,
            onChanged: (double v) => setState(() => _materials = v),
            activeColor: CivilEngineeringPlayableScreen.accent,
          ),
          const Text('Crew size', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _crew,
            onChanged: (double v) => setState(() => _crew = v),
            activeColor: CivilEngineeringPlayableScreen.accent,
          ),
          const Text('Overtime / acceleration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _overtime,
            onChanged: (double v) => setState(() => _overtime = v),
            activeColor: CivilEngineeringPlayableScreen.accent,
          ),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: CivilEngineeringPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('LOCK WEEK PLAN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _CivilLab2Screen extends StatefulWidget {
  const _CivilLab2Screen();

  @override
  State<_CivilLab2Screen> createState() => _CivilLab2ScreenState();
}

class _CivilLab2ScreenState extends State<_CivilLab2Screen> {
  final Set<String> _actions = <String>{};
  String? _feedback;

  static const List<(String, String)> _options = <(String, String)>[
    ('pause_pour', 'Pause concrete pour during storm window'),
    ('secure', 'Secure loose materials and crane'),
    ('shift', 'Shift non-critical tasks indoors / later'),
    ('ignore', 'Push through pour anyway to save schedule'),
  ];

  void _submit() {
    final bool safe = _actions.contains('pause_pour') &&
        _actions.contains('secure') &&
        _actions.contains('shift') &&
        !_actions.contains('ignore');
    if (!safe) {
      setState(() =>
          _feedback = 'Brooks: “Safety first. Pause pour, secure site, resequence — don’t force it.”');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: CivilEngineeringPlayableScreen.surface,
          title: const Text(
            'Carla Brooks — Delay plan accepted',
            style: TextStyle(color: CivilEngineeringPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Weather delay absorbed without a safety incident. Milestone slips one day — acceptable.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: CivilEngineeringPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivilEngineeringPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: CivilEngineeringPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Severe weather delay', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CivilEngineeringPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
            ),
            child: const Text(
              'ALERT · Severe thunderstorm · 4-hour work stoppage likely\n'
              'Adjust the plan.',
              style: TextStyle(color: Colors.white, height: 1.4, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          ..._options.map(((String, String) o) {
            final bool on = _actions.contains(o.$1);
            return CheckboxListTile(
              value: on,
              activeColor: CivilEngineeringPlayableScreen.accent,
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onChanged: (bool? v) {
                setState(() {
                  if (v == true) {
                    _actions.add(o.$1);
                  } else {
                    _actions.remove(o.$1);
                  }
                });
              },
            );
          }),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: CivilEngineeringPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SUBMIT ADJUSTED PLAN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
