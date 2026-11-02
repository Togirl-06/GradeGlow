import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// ParcelLogix — Math Analyst under Dr. Arjun Singh.
Widget mathematicsPlayableScreen() => const MathematicsPlayableScreen();

class MathematicsPlayableScreen extends StatelessWidget {
  const MathematicsPlayableScreen({super.key});

  static const Color accent = Color(0xFF60A5FA);
  static const Color bg = Color(0xFF070B14);
  static const Color surface = Color(0xFF101826);

  static const PlayableCareer career = PlayableCareer(
    id: 'mathematics',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'ParcelLogix',
    clockLine: 'Tuesday — 9:00 AM',
    roleTitle: 'Math Analyst',
    supervisorName: 'Dr. Arjun Singh',
    supervisorRole: 'Head of Analytics',
    hireTagline: 'Models earn their keep when they cut cost without breaking service.',
    supervisorBrief:
        '“Shipping cost is drifting. Pick a model, set variables, compute.\n\n'
        'Then defend why that model — I will challenge you.”',
    enterCta: 'ENTER ANALYTICS DESK',
    startCta: 'OPEN COST MODEL',
    startLocationId: 'desk',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Ops Lobby',
        icon: '📦',
        blurb: 'Conveyors and route boards.',
        atmosphere: 'ParcelLogix. Last-mile cost charts lean orange.',
      ),
      PlayableRoom(
        id: 'desk',
        name: 'Analyst Desk',
        icon: '🧮',
        blurb: 'Notebooks and solvers.',
        atmosphere: 'Variables wait. Choose the cost model carefully.',
      ),
      PlayableRoom(
        id: 'board',
        name: 'Model Board',
        icon: '📊',
        blurb: 'Compare fits.',
        atmosphere: 'Linear vs piecewise vs zone-based.',
      ),
      PlayableRoom(
        id: 'singh',
        name: 'Singh Review',
        icon: '🎓',
        blurb: 'AI professor challenge.',
        atmosphere: 'Explainability matters as much as the number.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'desk',
        bannerTitle: 'COST OPTIMIZATION',
        bannerBody: 'Choose a shipping cost model, set variables, compute the estimate.',
        cta: 'Build the model',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'singh',
        bannerTitle: 'MODEL DEFENSE',
        bannerBody: 'Explain why your model — face AI professor challenges.',
        cta: 'Defend the model',
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
            MaterialPageRoute<bool>(builder: (_) => const _MathLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _MathLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _MathLab1Screen extends StatefulWidget {
  const _MathLab1Screen();

  @override
  State<_MathLab1Screen> createState() => _MathLab1ScreenState();
}

class _MathLab1ScreenState extends State<_MathLab1Screen> {
  String? _model;
  double _distance = 0.5;
  double _weight = 0.4;
  double _zones = 0.3;
  bool _computed = false;
  String? _feedback;

  double get _cost {
    if (_model == 'linear') return 3.2 + _distance * 12 + _weight * 8;
    if (_model == 'piecewise') {
      final double base = _distance < 0.45 ? 4 : 7;
      return base + _distance * 9 + _weight * 10;
    }
    // zone
    return 5 + _zones * 15 + _weight * 6 + _distance * 4;
  }

  void _compute() {
    if (_model == null) {
      setState(() => _feedback = 'Select a model first.');
      return;
    }
    setState(() {
      _computed = true;
      _feedback = null;
    });
  }

  void _submit() {
    if (!_computed) {
      setState(() => _feedback = 'Compute before you hand off to Singh.');
      return;
    }
    // Prefer zone or piecewise for realism of shipping — linear alone is weak
    if (_model == 'linear' && _distance > 0.6) {
      setState(() =>
          _feedback = 'Singh: “Long-haul linear underfits zone pricing. Try again.”');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: MathematicsPlayableScreen.surface,
          title: const Text(
            'Dr. Singh — Estimate logged',
            style: TextStyle(color: MathematicsPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '“Computed cost \$${_cost.toStringAsFixed(2)} per parcel under $_model.\n\n'
            'Next: explain why this model.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: MathematicsPlayableScreen.accent,
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
      backgroundColor: MathematicsPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: MathematicsPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Shipping cost model', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          ...<(String, String)>[
            ('linear', 'Linear: base + distance + weight'),
            ('piecewise', 'Piecewise by distance band'),
            ('zone', 'Zone-based + weight'),
          ].map(((String, String) o) {
            final bool on = _model == o.$1;
            return ListTile(
              tileColor: MathematicsPlayableScreen.surface,
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: MathematicsPlayableScreen.accent),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() {
                _model = o.$1;
                _computed = false;
              }),
            );
          }),
          const SizedBox(height: 8),
          const Text('Distance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _distance,
            onChanged: (double v) => setState(() {
              _distance = v;
              _computed = false;
            }),
            activeColor: MathematicsPlayableScreen.accent,
          ),
          const Text('Weight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _weight,
            onChanged: (double v) => setState(() {
              _weight = v;
              _computed = false;
            }),
            activeColor: MathematicsPlayableScreen.accent,
          ),
          const Text('Zone density', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _zones,
            onChanged: (double v) => setState(() {
              _zones = v;
              _computed = false;
            }),
            activeColor: MathematicsPlayableScreen.accent,
          ),
          if (_computed)
            Text(
              'Estimate: \$${_cost.toStringAsFixed(2)}',
              style: const TextStyle(color: MathematicsPlayableScreen.accent, fontSize: 22, fontWeight: FontWeight.w900),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _compute,
            style: OutlinedButton.styleFrom(foregroundColor: MathematicsPlayableScreen.accent),
            child: const Text('COMPUTE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: MathematicsPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('HAND OFF TO SINGH', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _MathLab2Screen extends StatefulWidget {
  const _MathLab2Screen();

  @override
  State<_MathLab2Screen> createState() => _MathLab2ScreenState();
}

class _MathLab2ScreenState extends State<_MathLab2Screen> {
  final TextEditingController _why = TextEditingController();
  int _challenge = 0;
  String? _feedback;

  static const List<String> _challenges = <String>[
    'AI Professor: “What happens to error if distance is long-haul?”',
    'AI Professor: “Name one variable your model ignores.”',
    'AI Professor: “Why not pure linear for all routes?”',
  ];

  @override
  void dispose() {
    _why.dispose();
    super.dispose();
  }

  void _answer() {
    final String t = _why.text.toLowerCase();
    final bool keywords = t.contains('zone') ||
        t.contains('piece') ||
        t.contains('linear') ||
        t.contains('distance') ||
        t.contains('weight') ||
        t.contains('cost') ||
        t.contains('error') ||
        t.contains('fit');
    if (!keywords || t.length < 25) {
      setState(() => _feedback = 'Singh: “Be specific. Model words + tradeoff.”');
      return;
    }
    setState(() {
      _feedback = null;
      _why.clear();
      if (_challenge < _challenges.length - 1) {
        _challenge++;
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return AlertDialog(
              backgroundColor: MathematicsPlayableScreen.surface,
              title: const Text(
                'Dr. Singh — Defense accepted',
                style: TextStyle(color: MathematicsPlayableScreen.accent, fontWeight: FontWeight.w800),
              ),
              content: const Text(
                '“You survived the challenge round. The model stays.”',
                style: TextStyle(color: Colors.white, height: 1.45),
              ),
              actions: <Widget>[
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: MathematicsPlayableScreen.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MathematicsPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: MathematicsPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Model defense', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MathematicsPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MathematicsPlayableScreen.accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              _challenges[_challenge],
              style: const TextStyle(color: Colors.white, height: 1.45, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _why,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Explain why your model…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: MathematicsPlayableScreen.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _answer,
            style: FilledButton.styleFrom(
              backgroundColor: MathematicsPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _challenge < _challenges.length - 1 ? 'ANSWER CHALLENGE' : 'FINAL DEFENSE',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
