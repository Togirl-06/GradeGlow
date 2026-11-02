import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// National Policy Institute — Economic Policy Analyst under Dr. Okada.
class EconomicsPlayableScreen extends StatelessWidget {
  const EconomicsPlayableScreen({super.key});

  static const Color accent = Color(0xFFFBBF24);
  static const Color bg = Color(0xFF0A0E18);
  static const Color surface = Color(0xFF141B2C);

  static const PlayableCareer career = PlayableCareer(
    id: 'economics',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'National Policy Institute',
    clockLine: 'Monday — 8:40 AM',
    roleTitle: 'Economic Policy Analyst',
    supervisorName: 'Dr. Okada',
    supervisorRole: 'Director, Macro Unit',
    hireTagline: 'Every lever has a tradeoff. This is policy work — not a quiz.',
    supervisorBrief:
        '“Inflation spiked overnight. The country dashboard is live.\n\n'
        'Choose a policy. We advance one period. Then the next crisis hits.”',
    enterCta: 'ENTER THE INSTITUTE',
    startCta: 'OPEN THE DASHBOARD',
    startLocationId: 'warroom',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Lobby',
        icon: '🏛️',
        blurb: 'Briefings and badges.',
        atmosphere: 'National Policy Institute. Screens show overnight prints.',
      ),
      PlayableRoom(
        id: 'warroom',
        name: 'Macro War Room',
        icon: '📊',
        blurb: 'GDP, inflation, jobs, rates.',
        atmosphere: 'Inflation spike. Pick a response. Watch the tradeoff.',
      ),
      PlayableRoom(
        id: 'models',
        name: 'Model Bay',
        icon: '🧮',
        blurb: 'Scenarios and elasticities.',
        atmosphere: 'Staff already ran three paths. None are free.',
      ),
      PlayableRoom(
        id: 'okada',
        name: 'Dr. Okada\'s Office',
        icon: '🚪',
        blurb: 'Director review.',
        atmosphere: 'Okada wants the tradeoff named out loud.',
      ),
      PlayableRoom(
        id: 'briefing',
        name: 'Briefing Room',
        icon: '🎤',
        blurb: 'Period-two crisis.',
        atmosphere: 'Second-period shock. Manage again. Explain.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'warroom',
        bannerTitle: 'INFLATION SPIKE',
        bannerBody: 'Country dashboard live. Choose a policy; simulation advances one period.',
        cta: 'Respond to inflation',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'briefing',
        bannerTitle: 'SECOND-PERIOD CRISIS',
        bannerBody: 'Another shock. Manage the tradeoff again and explain your call.',
        cta: 'Manage period two',
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
            MaterialPageRoute<bool>(builder: (_) => const _EconomicsLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _EconomicsLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _MacroState {
  const _MacroState({
    required this.gdp,
    required this.inflation,
    required this.unemployment,
    required this.rates,
    required this.spending,
    required this.confidence,
  });

  final double gdp;
  final double inflation;
  final double unemployment;
  final double rates;
  final double spending;
  final double confidence;

  _MacroState copyWith({
    double? gdp,
    double? inflation,
    double? unemployment,
    double? rates,
    double? spending,
    double? confidence,
  }) {
    return _MacroState(
      gdp: gdp ?? this.gdp,
      inflation: inflation ?? this.inflation,
      unemployment: unemployment ?? this.unemployment,
      rates: rates ?? this.rates,
      spending: spending ?? this.spending,
      confidence: confidence ?? this.confidence,
    );
  }
}

class _EconomicsLab1Screen extends StatefulWidget {
  const _EconomicsLab1Screen();

  @override
  State<_EconomicsLab1Screen> createState() => _EconomicsLab1ScreenState();
}

class _EconomicsLab1ScreenState extends State<_EconomicsLab1Screen> {
  _MacroState _state = const _MacroState(
    gdp: 2.1,
    inflation: 6.8,
    unemployment: 4.2,
    rates: 3.5,
    spending: 100,
    confidence: 48,
  );
  bool _advanced = false;
  String? _policy;
  String? _tradeoff;

  void _apply(String id) {
    if (_advanced) return;
    _MacroState next = _state;
    String tradeoff;
    switch (id) {
      case 'raise_rates':
        next = _state.copyWith(
          rates: _state.rates + 1.0,
          inflation: _state.inflation - 1.4,
          gdp: _state.gdp - 0.6,
          unemployment: _state.unemployment + 0.5,
          confidence: _state.confidence - 4,
        );
        tradeoff = 'Inflation cools, but growth and jobs soften.';
      case 'cut_spending':
        next = _state.copyWith(
          spending: _state.spending - 8,
          inflation: _state.inflation - 0.9,
          gdp: _state.gdp - 0.8,
          unemployment: _state.unemployment + 0.7,
          confidence: _state.confidence - 6,
        );
        tradeoff = 'Demand pressure eases; near-term GDP and confidence take the hit.';
      case 'stimulus':
        next = _state.copyWith(
          spending: _state.spending + 10,
          inflation: _state.inflation + 0.8,
          gdp: _state.gdp + 0.7,
          unemployment: _state.unemployment - 0.3,
          confidence: _state.confidence + 5,
        );
        tradeoff = 'Growth lifts — inflation and spending jump further.';
      case 'hold':
        next = _state.copyWith(
          inflation: _state.inflation + 0.4,
          confidence: _state.confidence - 3,
        );
        tradeoff = 'You held the line; inflation drifts higher and confidence slips.';
      default:
        tradeoff = '';
    }
    setState(() {
      _policy = id;
      _state = next;
      _advanced = true;
      _tradeoff = tradeoff;
    });
  }

  void _finish() {
    if (!_advanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a policy to advance one period.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: EconomicsPlayableScreen.surface,
          title: const Text(
            'Dr. Okada — Period 1 logged',
            style: TextStyle(color: EconomicsPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '$_tradeoff\n\n'
            '“Name the tradeoff. Briefing room next — period two will not be kinder.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: EconomicsPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _metric(String label, String value, {Color? warn}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: EconomicsPlayableScreen.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (warn ?? Colors.white24).withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: warn ?? Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EconomicsPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: EconomicsPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Country dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            _advanced ? 'Period advanced' : 'Inflation spike — choose a policy',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 12),
          Row(children: <Widget>[
            _metric('GDP growth', '${_state.gdp.toStringAsFixed(1)}%'),
            _metric('Inflation', '${_state.inflation.toStringAsFixed(1)}%', warn: const Color(0xFFF87171)),
          ]),
          Row(children: <Widget>[
            _metric('Unemployment', '${_state.unemployment.toStringAsFixed(1)}%'),
            _metric('Policy rate', '${_state.rates.toStringAsFixed(1)}%'),
          ]),
          Row(children: <Widget>[
            _metric('Gov spending', _state.spending.toStringAsFixed(0)),
            _metric('Confidence', _state.confidence.toStringAsFixed(0)),
          ]),
          if (!_advanced) ...<Widget>[
            const SizedBox(height: 12),
            ...const <(String, String)>[
              ('raise_rates', 'Raise interest rates'),
              ('cut_spending', 'Cut government spending'),
              ('stimulus', 'Add fiscal stimulus'),
              ('hold', 'Hold policy steady'),
            ].map(((String, String) o) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: EconomicsPlayableScreen.surface,
                  title: Text(o.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.play_arrow, color: EconomicsPlayableScreen.accent),
                  onTap: () => _apply(o.$1),
                ),
              );
            }),
          ] else ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: EconomicsPlayableScreen.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EconomicsPlayableScreen.accent.withValues(alpha: 0.45)),
              ),
              child: Text(
                'Policy: $_policy\n$_tradeoff',
                style: const TextStyle(color: Colors.white, height: 1.45),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _finish,
            style: FilledButton.styleFrom(
              backgroundColor: EconomicsPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('LOG WITH DR. OKADA', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _EconomicsLab2Screen extends StatefulWidget {
  const _EconomicsLab2Screen();

  @override
  State<_EconomicsLab2Screen> createState() => _EconomicsLab2ScreenState();
}

class _EconomicsLab2ScreenState extends State<_EconomicsLab2Screen> {
  _MacroState _state = const _MacroState(
    gdp: 1.4,
    inflation: 5.6,
    unemployment: 4.8,
    rates: 4.5,
    spending: 96,
    confidence: 44,
  );
  bool _advanced = false;
  String? _policy;
  String? _tradeoff;
  final TextEditingController _explain = TextEditingController();

  @override
  void dispose() {
    _explain.dispose();
    super.dispose();
  }

  void _apply(String id) {
    if (_advanced) return;
    _MacroState next = _state;
    String tradeoff;
    // Crisis: unemployment jump + soft demand after period 1 tightening spillover
    switch (id) {
      case 'cut_rates':
        next = _state.copyWith(
          rates: _state.rates - 0.75,
          unemployment: _state.unemployment - 0.4,
          gdp: _state.gdp + 0.5,
          inflation: _state.inflation + 0.5,
          confidence: _state.confidence + 4,
        );
        tradeoff = 'Easing supports jobs/GDP but risks reigniting inflation.';
      case 'jobs_program':
        next = _state.copyWith(
          spending: _state.spending + 6,
          unemployment: _state.unemployment - 0.6,
          gdp: _state.gdp + 0.3,
          inflation: _state.inflation + 0.3,
          confidence: _state.confidence + 3,
        );
        tradeoff = 'Targeted jobs lift employment; spending and prices tick up.';
      case 'hold_tight':
        next = _state.copyWith(
          inflation: _state.inflation - 0.5,
          unemployment: _state.unemployment + 0.4,
          gdp: _state.gdp - 0.4,
          confidence: _state.confidence - 5,
        );
        tradeoff = 'You keep disinflation on track; jobs and confidence pay the cost.';
      case 'emergency_aid':
        next = _state.copyWith(
          spending: _state.spending + 12,
          confidence: _state.confidence + 8,
          inflation: _state.inflation + 0.7,
          gdp: _state.gdp + 0.4,
        );
        tradeoff = 'Aid restores confidence fast; inflation risk returns.';
      default:
        tradeoff = '';
    }
    setState(() {
      _policy = id;
      _state = next;
      _advanced = true;
      _tradeoff = tradeoff;
    });
  }

  void _finish() {
    if (!_advanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a period-two response first.')),
      );
      return;
    }
    if (_explain.text.trim().length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Explain the tradeoff to Dr. Okada.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: EconomicsPlayableScreen.surface,
          title: const Text(
            'Dr. Okada — Crisis brief filed',
            style: TextStyle(color: EconomicsPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '$_tradeoff\n\n'
            'Your note: ${_explain.text.trim()}\n\n'
            '“Policy is choosing which pain to accept. You did the work.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: EconomicsPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: EconomicsPlayableScreen.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EconomicsPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: EconomicsPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Period-two crisis', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EconomicsPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.45)),
            ),
            child: const Text(
              'Shock: layoffs spike after earlier tightening spillover. '
              'Unemployment jumps; markets want a response.',
              style: TextStyle(color: Colors.white, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: <Widget>[
            _metric('GDP', '${_state.gdp.toStringAsFixed(1)}%'),
            _metric('Inflation', '${_state.inflation.toStringAsFixed(1)}%'),
          ]),
          Row(children: <Widget>[
            _metric('Unemployment', '${_state.unemployment.toStringAsFixed(1)}%'),
            _metric('Rates', '${_state.rates.toStringAsFixed(1)}%'),
          ]),
          if (!_advanced) ...<Widget>[
            const SizedBox(height: 8),
            ...const <(String, String)>[
              ('cut_rates', 'Cut interest rates'),
              ('jobs_program', 'Launch jobs program'),
              ('hold_tight', 'Hold tight policy'),
              ('emergency_aid', 'Emergency household aid'),
            ].map(((String, String) o) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: EconomicsPlayableScreen.surface,
                  title: Text(o.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  onTap: () => _apply(o.$1),
                ),
              );
            }),
          ] else ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Policy: $_policy\n$_tradeoff',
              style: const TextStyle(color: EconomicsPlayableScreen.accent, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _explain,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Explain the tradeoff you accepted…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                filled: true,
                fillColor: EconomicsPlayableScreen.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _finish,
            style: FilledButton.styleFrom(
              backgroundColor: EconomicsPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('FILE BRIEF', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
