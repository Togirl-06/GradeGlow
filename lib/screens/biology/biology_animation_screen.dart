import 'package:flutter/material.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

class BiologyAnimationScreen extends StatefulWidget {
  const BiologyAnimationScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyAnimationScreen> createState() => _BiologyAnimationScreenState();
}

class _BiologyAnimationScreenState extends State<BiologyAnimationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _step = 0;

  List<String> get _steps {
    final String t = widget.path.lesson.title.toLowerCase();
    if (t.contains('photosynthesis')) {
      return <String>[
        'Light hits the leaf',
        'Chloroplasts capture photons',
        'Water splits · O₂ released',
        'ATP & NADPH form',
        'CO₂ → sugar in Calvin cycle',
      ];
    }
    if (t.contains('dna') || t.contains('replication') || t.contains('transcription') || t.contains('translation')) {
      return <String>[
        'DNA helix presented',
        'Strands unwind',
        'Complementary bases pair',
        'mRNA / new strand forms',
        'Protein synthesis begins',
      ];
    }
    if (t.contains('mitosis') || t.contains('cell cycle') || t.contains('meiosis')) {
      return <String>[
        'Chromosomes condense',
        'Spindle attaches',
        'Alignment at equator',
        'Sister chromatids separate',
        'Two nuclei reform',
      ];
    }
    return <String>[
      'Professor zooms into the system',
      'Key structures appear',
      'Process begins to move',
      'Molecules / cells interact',
      'Outcome for the organism',
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addStatusListener((AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          setState(() => _step = (_step + 1).clamp(0, _steps.length - 1));
          _controller
            ..reset()
            ..forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final List<String> steps = _steps;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.path.lesson.title} · Animation',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.play_circle_outline, size: 64, color: c.primary.withValues(alpha: 0.5 + 0.5 * _controller.value)),
                        const SizedBox(height: 20),
                        Text(
                          'Step ${_step + 1} of ${steps.length}',
                          style: TextStyle(color: c.primaryLight, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            steps[_step],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 20, height: 1.35),
                          ),
                        ),
                        const SizedBox(height: 24),
                        LinearProgressIndicator(
                          value: (_step + _controller.value) / steps.length,
                          color: c.primary,
                          backgroundColor: c.border,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Professor: Pause and predict the next step before continuing.',
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = (_step - 1).clamp(0, steps.length - 1)),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_step >= steps.length - 1) {
                        Navigator.of(context).pop(true);
                      } else {
                        setState(() => _step += 1);
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white),
                    child: Text(_step >= steps.length - 1 ? 'Complete' : 'Next', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
