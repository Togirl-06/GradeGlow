import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Lumen Creative — Junior Marketing Strategist under Sol Vega.
class MarketingPlayableScreen extends StatelessWidget {
  const MarketingPlayableScreen({super.key});

  static const Color accent = Color(0xFFF472B6);
  static const Color bg = Color(0xFF140A12);
  static const Color surface = Color(0xFF22101C);

  static const PlayableCareer career = PlayableCareer(
    id: 'marketing',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Lumen Creative',
    clockLine: 'Monday — 10:04 AM',
    roleTitle: 'Junior Marketing Strategist',
    supervisorName: 'Sol Vega',
    supervisorRole: 'Creative Director',
    hireTagline: 'Interview first. Campaign second. Not a quiz.',
    supervisorBrief:
        '“Client wants more sales among college students. '
        'Interview them — unlock the brief facts.\n\n'
        'Then build a campaign we can measure.”',
    enterCta: 'ENTER THE AGENCY',
    startCta: 'MEET THE CLIENT',
    startLocationId: 'studio',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Lobby',
        icon: '✨',
        blurb: 'Mood boards and plant light.',
        atmosphere: 'Lumen Creative. Someone\'s pitching on the stairs. Music low.',
      ),
      PlayableRoom(
        id: 'studio',
        name: 'Strategy Studio',
        icon: '🎯',
        blurb: 'Briefs and whiteboards.',
        atmosphere: 'Client call booked. Ask well — facts unlock from the interview.',
      ),
      PlayableRoom(
        id: 'warroom',
        name: 'Campaign Bay',
        icon: '📣',
        blurb: 'Channels, budgets, creative.',
        atmosphere: 'Build objective, audience, budget, channels — then watch the sim.',
        lockedUntilStageId: 'lab1',
      ),
      PlayableRoom(
        id: 'sol',
        name: 'Sol\'s Office',
        icon: '🚪',
        blurb: 'Creative Director review.',
        atmosphere: 'Sol cares about clarity more than cleverness.',
      ),
      PlayableRoom(
        id: 'edit',
        name: 'Edit Suite',
        icon: '🎬',
        blurb: 'Cuts and captions.',
        atmosphere: 'Assets wait for a brief that actually names the audience.',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'studio',
        bannerTitle: 'CLIENT INTERVIEW',
        bannerBody: 'Free-text interview: increase sales among college students. Unlock brief facts.',
        cta: 'Start interview',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'warroom',
        bannerTitle: 'CAMPAIGN BUILDER',
        bannerBody: 'Set objective, audience, budget, channels → sim metrics → adjust one lever.',
        cta: 'Build campaign',
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
            MaterialPageRoute<bool>(builder: (_) => const _MarketingLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _MarketingLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _MarketingLab1Screen extends StatefulWidget {
  const _MarketingLab1Screen();

  @override
  State<_MarketingLab1Screen> createState() => _MarketingLab1ScreenState();
}

class _MarketingLab1ScreenState extends State<_MarketingLab1Screen> {
  final TextEditingController _input = TextEditingController();
  final List<({bool client, String text})> _log = <({bool client, String text})>[
    (
      client: true,
      text:
          'Hi — we\'re CampusFuel. We need more sales with college students. Ask whatever you need.',
    ),
  ];
  final Set<String> _unlocked = <String>{};

  static const Map<String, (List<String>, String)> _facts =
      <String, (List<String>, String)>{
    'audience': (
      <String>['audience', 'who', 'student', 'age', 'persona', 'target'],
      'Primary buyers: undergrads 18–22 living on or near campus. Peak spend Thu–Sat nights.',
    ),
    'product': (
      <String>['product', 'offer', 'what', 'sell', 'menu', 'sku'],
      'Hero SKU: \$6 energy drink 4-pack. Bundles beat singles. Subscriptions unused.',
    ),
    'channel': (
      <String>['channel', 'where', 'tiktok', 'instagram', 'social', 'ads', 'reach'],
      'They discover brands on TikTok/Reels. Email is weak. Campus ambassadors convert.',
    ),
    'barrier': (
      <String>['barrier', 'why', 'problem', 'objection', 'price', 'competitor'],
      'Students say “too pricey vs store brand” and “never see it at the dorm store.”',
    ),
    'goal': (
      <String>['goal', 'kpi', 'success', 'metric', 'sales', 'target'],
      'Goal: +25% unit sales in 6 weeks among 18–22 in three college towns.',
    ),
  };

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _ask() {
    final String q = _input.text.trim();
    if (q.isEmpty) return;
    final String lower = q.toLowerCase();
    _log.add((client: false, text: q));
    String reply = 'Hmm — can you ask more specifically about audience, product, channels, barriers, or goals?';
    for (final MapEntry<String, (List<String>, String)> e in _facts.entries) {
      if (_unlocked.contains(e.key)) continue;
      for (final String k in e.value.$1) {
        if (lower.contains(k)) {
          _unlocked.add(e.key);
          reply = e.value.$2;
          break;
        }
      }
      if (reply == e.value.$2) break;
    }
    _log.add((client: true, text: reply));
    _input.clear();
    setState(() {});
  }

  void _finish() {
    if (_unlocked.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unlock at least 3 brief facts before you wrap.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: MarketingPlayableScreen.surface,
          title: const Text(
            'Sol Vega — Brief unlocked',
            style: TextStyle(color: MarketingPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '“${_unlocked.length} facts locked in. Campaign Bay is open — build something measurable.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: MarketingPlayableScreen.accent,
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
      backgroundColor: MarketingPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: MarketingPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Client interview', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: <Widget>[
          if (_unlocked.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: MarketingPlayableScreen.surface,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _unlocked.map((String id) {
                  return Chip(
                    label: Text(id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    backgroundColor: MarketingPlayableScreen.accent.withValues(alpha: 0.2),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _log.length,
              itemBuilder: (BuildContext context, int i) {
                final ({bool client, String text}) m = _log[i];
                return Align(
                  alignment: m.client ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: m.client
                          ? MarketingPlayableScreen.surface
                          : MarketingPlayableScreen.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text, style: const TextStyle(color: Colors.white, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _input,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask about audience, channels, barriers…',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                      filled: true,
                      fillColor: MarketingPlayableScreen.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => _ask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _ask,
                  style: IconButton.styleFrom(backgroundColor: MarketingPlayableScreen.accent),
                  icon: const Icon(Icons.send, color: Colors.black),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _finish,
                style: FilledButton.styleFrom(
                  backgroundColor: MarketingPlayableScreen.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('LOCK THE BRIEF', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketingLab2Screen extends StatefulWidget {
  const _MarketingLab2Screen();

  @override
  State<_MarketingLab2Screen> createState() => _MarketingLab2ScreenState();
}

class _MarketingLab2ScreenState extends State<_MarketingLab2Screen> {
  String _objective = 'awareness';
  String _audience = 'college';
  double _budget = 0.5;
  final Set<String> _channels = <String>{'tiktok'};
  bool _simulated = false;
  bool _adjusted = false;
  String? _adjustNote;

  int get _impressions {
    final double base = 20000 + _budget * 80000;
    final double ch = _channels.length * 12000.0;
    final double aud = _audience == 'college' ? 1.25 : 0.75;
    return (base + ch * aud).round();
  }

  int get _clicks {
    final double ctr = _channels.contains('tiktok') || _channels.contains('reels') ? 0.028 : 0.012;
    final double obj = _objective == 'conversion' ? 0.85 : 1.0;
    return (_impressions * ctr * obj).round();
  }

  int get _conversions {
    final double rate = _audience == 'college' ? 0.045 : 0.02;
    final double boost = _channels.contains('campus') ? 1.4 : 1.0;
    final double obj = _objective == 'conversion' ? 1.35 : (_objective == 'traffic' ? 1.1 : 0.7);
    return (_clicks * rate * boost * obj * (0.8 + _budget * 0.5)).round();
  }

  void _sim() {
    if (_channels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one channel.')),
      );
      return;
    }
    setState(() {
      _simulated = true;
      _adjusted = false;
      _adjustNote = null;
    });
  }

  void _adjust(String lever) {
    if (!_simulated) return;
    setState(() {
      _adjusted = true;
      switch (lever) {
        case 'budget':
          _budget = (_budget + 0.15).clamp(0.1, 1.0);
          _adjustNote = 'Raised budget one notch.';
        case 'audience':
          _audience = 'college';
          _adjustNote = 'Refocused audience on college students.';
        case 'channel':
          _channels.add('campus');
          _adjustNote = 'Added campus ambassadors.';
        case 'objective':
          _objective = 'conversion';
          _adjustNote = 'Shifted objective to conversions.';
      }
    });
  }

  void _finish() {
    if (!_simulated || !_adjusted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulate, then adjust one lever before shipping.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: MarketingPlayableScreen.surface,
          title: const Text(
            'Sol Vega — Campaign greenlit',
            style: TextStyle(color: MarketingPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Impressions $_impressions · Clicks $_clicks · Conversions $_conversions\n'
            '${_adjustNote ?? ''}\n\n'
            '“You measured, then moved one lever. That\'s strategy.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: MarketingPlayableScreen.accent,
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
      backgroundColor: MarketingPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: MarketingPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Campaign builder', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          const Text('Objective', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            children: <String>['awareness', 'traffic', 'conversion'].map((String o) {
              final bool on = _objective == o;
              return ChoiceChip(
                label: Text(o),
                selected: on,
                onSelected: (_) => setState(() => _objective = o),
                selectedColor: MarketingPlayableScreen.accent,
                labelStyle: TextStyle(color: on ? Colors.black : Colors.white70),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Audience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            children: <String>['college', 'parents', 'alumni'].map((String o) {
              final bool on = _audience == o;
              return ChoiceChip(
                label: Text(o),
                selected: on,
                onSelected: (_) => setState(() => _audience = o),
                selectedColor: MarketingPlayableScreen.accent,
                labelStyle: TextStyle(color: on ? Colors.black : Colors.white70),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Budget  ${(_budget * 100).round()}k',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          Slider(
            value: _budget,
            onChanged: (double v) => setState(() {
              _budget = v;
              _simulated = false;
              _adjusted = false;
            }),
            activeColor: MarketingPlayableScreen.accent,
          ),
          const Text('Channels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            children: <String>['tiktok', 'reels', 'email', 'campus'].map((String c) {
              final bool on = _channels.contains(c);
              return FilterChip(
                label: Text(c),
                selected: on,
                onSelected: (bool v) => setState(() {
                  if (v) {
                    _channels.add(c);
                  } else {
                    _channels.remove(c);
                  }
                  _simulated = false;
                  _adjusted = false;
                }),
                selectedColor: MarketingPlayableScreen.accent,
                labelStyle: TextStyle(color: on ? Colors.black : Colors.white70),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _sim,
            style: OutlinedButton.styleFrom(
              foregroundColor: MarketingPlayableScreen.accent,
              side: const BorderSide(color: MarketingPlayableScreen.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('RUN SIMULATION', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_simulated) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MarketingPlayableScreen.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Impressions: $_impressions\nClicks: $_clicks\nConversions: $_conversions',
                style: const TextStyle(color: Colors.white, height: 1.5, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ADJUST ONE LEVER',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(onPressed: () => _adjust('budget'), child: const Text('+ Budget')),
                FilledButton(onPressed: () => _adjust('audience'), child: const Text('Audience')),
                FilledButton(onPressed: () => _adjust('channel'), child: const Text('+ Campus')),
                FilledButton(onPressed: () => _adjust('objective'), child: const Text('Objective')),
              ].map((Widget b) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    filledButtonTheme: FilledButtonThemeData(
                      style: FilledButton.styleFrom(
                        backgroundColor: MarketingPlayableScreen.surface,
                        foregroundColor: MarketingPlayableScreen.accent,
                      ),
                    ),
                  ),
                  child: b,
                );
              }).toList(),
            ),
            if (_adjustNote != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_adjustNote!, style: const TextStyle(color: MarketingPlayableScreen.accent)),
              const SizedBox(height: 8),
              Text(
                'Updated → Imp $_impressions · Clicks $_clicks · Conv $_conversions',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _finish,
            style: FilledButton.styleFrom(
              backgroundColor: MarketingPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SHIP TO SOL', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
