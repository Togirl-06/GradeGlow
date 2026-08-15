import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../shared/science_ai_feedback.dart';
import '../shared/science_badges.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import 'biology_station_chrome.dart';

/// Interactive microscope: mag · focus · stage · illumination · identify.
class BiologyMicroscopeLab extends StatefulWidget {
  const BiologyMicroscopeLab({super.key});

  @override
  State<BiologyMicroscopeLab> createState() => _BiologyMicroscopeLabState();
}

class _BiologyMicroscopeLabState extends State<BiologyMicroscopeLab> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  final ScienceNotebookStore _nb = ScienceNotebookStore('biology');

  int _mag = 40;
  double _focus = 0.35;
  double _stageX = 0.5;
  double _stageY = 0.5;
  double _illum = 0.55;
  bool _nucleusMarked = false;
  bool _labeled = false;
  final TextEditingController _label = TextEditingController();
  final TextEditingController _obs = TextEditingController();
  String? _feedback;

  static const List<int> _mags = <int>[40, 100, 400];

  bool get _sharp =>
      _focus >= 0.55 && _focus <= 0.82 && _illum >= 0.35 && _mag >= 100;

  double get _clarity {
    final double focusScore = 1 - ((_focus - 0.68).abs() / 0.68);
    final double magScore = _mag == 40 ? 0.35 : (_mag == 100 ? 0.75 : 1.0);
    return (focusScore.clamp(0.05, 1) * magScore * (_illum * 0.6 + 0.4))
        .clamp(0.05, 1);
  }

  Future<void> _submit() async {
    final String lab = _label.text.toLowerCase().trim();
    final String obs = _obs.text.trim();
    if (!_sharp) {
      setState(() {
        _feedback = ScienceAiFeedback.microscopeHint(
          focusIssue: 'field is still soft — raise mag to 100×+, center focus, then light',
        );
      });
      return;
    }
    if (!_nucleusMarked) {
      setState(() => _feedback = 'Mark the nucleus on the specimen first.');
      return;
    }
    if (!lab.contains('epithelial') &&
        !lab.contains('onion') &&
        !lab.contains('cheek') &&
        !lab.contains('tissue')) {
      setState(() {
        _feedback =
            'Label the tissue type (e.g. epithelial / onion epidermis / cheek cells).';
      });
      return;
    }
    if (obs.length < 20) {
      setState(() => _feedback = 'Record a fuller observation in the notebook field.');
      return;
    }
    await _nb.addNote(
      'Microscope $_mag× · focus=${_focus.toStringAsFixed(2)} · '
      'label=$lab · $obs',
    );
    await _nb.awardXp(40, coins: 12);
    await _nb.unlockBadge(ScienceBadges.masterMicroscopist);
    await _nb.markComplete('microscope');
    if (!mounted) return;
    await showBioResult(
      context: context,
      passed: true,
      title: 'Master Microscopist',
      body: 'Unknown tissue identified, nucleus marked, observation logged.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _label.dispose();
    _obs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BiologyStationScaffold(
      title: 'Microscope Bay',
      brief: 'Identify unknown tissue → mark nucleus → label → record.',
      badgeLabel: 'SCOPE',
      footer: bioPrimaryButton(label: 'SUBMIT OBSERVATION', onPressed: _submit),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.15,
            child: GestureDetector(
              onTapDown: (TapDownDetails d) {
                if (!_sharp) {
                  setState(() {
                    _feedback = ScienceAiFeedback.microscopeHint(
                      focusIssue: 'sharpen the field before marking structures',
                    );
                  });
                  return;
                }
                setState(() {
                  _nucleusMarked = true;
                  _feedback = 'Nucleus marked.';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.accent.withValues(alpha: 0.55), width: 4),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: t.accent.withValues(alpha: 0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  painter: _ScopePainter(
                    clarity: _clarity,
                    stageX: _stageX,
                    stageY: _stageY,
                    illum: _illum,
                    mag: _mag,
                    nucleusMarked: _nucleusMarked,
                    accent: t.accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _sharp
                ? 'Field sharp — tap to mark the nucleus'
                : 'Blurred field — adjust optics',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _sharp ? t.accent : Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Magnification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            children: _mags.map((int m) {
              final bool on = _mag == m;
              return ChoiceChip(
                label: Text('$m×'),
                selected: on,
                onSelected: (_) => setState(() => _mag = m),
                selectedColor: t.accent,
                labelStyle: TextStyle(
                  color: on ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
                backgroundColor: t.surface,
              );
            }).toList(),
          ),
          _slider('Focus', _focus, (double v) => setState(() => _focus = v)),
          _slider('Stage X', _stageX, (double v) => setState(() => _stageX = v)),
          _slider('Stage Y', _stageY, (double v) => setState(() => _stageY = v)),
          _slider('Illumination', _illum, (double v) => setState(() => _illum = v)),
          const SizedBox(height: 8),
          TextField(
            controller: _label,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) => setState(() => _labeled = _label.text.isNotEmpty),
            decoration: InputDecoration(
              labelText: 'Tissue label',
              labelStyle: TextStyle(color: t.accent),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _obs,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Notebook observation',
              labelStyle: TextStyle(color: t.accent),
              hintText: 'Describe nuclei, cell boundaries, stain contrast…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
          if (_labeled && _nucleusMarked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Progress toward ${ScienceBadges.labelOf(ScienceBadges.masterMicroscopist)}',
                style: TextStyle(color: t.accent.withValues(alpha: 0.8), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: t.accent,
        ),
      ],
    );
  }
}

class _ScopePainter extends CustomPainter {
  _ScopePainter({
    required this.clarity,
    required this.stageX,
    required this.stageY,
    required this.illum,
    required this.mag,
    required this.nucleusMarked,
    required this.accent,
  });

  final double clarity;
  final double stageX;
  final double stageY;
  final double illum;
  final int mag;
  final bool nucleusMarked;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide * 0.48;
    canvas.drawCircle(c, r, Paint()..color = Color.lerp(Colors.black, const Color(0xFF052e16), illum)!);

    final double blur = ((1 - clarity) * 8).clamp(0, 8);
    final double scale = mag == 40 ? 0.7 : (mag == 100 ? 1.0 : 1.35);
    final Offset pan = Offset(
      (stageX - 0.5) * size.width * 0.25,
      (stageY - 0.5) * size.height * 0.25,
    );

    canvas.saveLayer(Offset.zero & size, Paint());
    final math.Random rng = math.Random(42);
    for (int i = 0; i < 14; i++) {
      final Offset o = c +
          pan +
          Offset(
            (rng.nextDouble() - 0.5) * size.width * 0.55 * scale,
            (rng.nextDouble() - 0.5) * size.height * 0.55 * scale,
          );
      final double cellR = (10 + rng.nextDouble() * 16) * scale;
      final Paint cell = Paint()
        ..color = Color.lerp(
          const Color(0xFF166534).withValues(alpha: 0.25),
          const Color(0xFF86EFAC).withValues(alpha: 0.75),
          clarity,
        )!
        ..maskFilter = blur > 0.4 ? ui.MaskFilter.blur(ui.BlurStyle.normal, blur) : null;
      canvas.drawOval(
        Rect.fromCenter(center: o, width: cellR * 1.4, height: cellR),
        cell,
      );
      if (clarity > 0.55) {
        canvas.drawCircle(
          o + Offset(-cellR * 0.15, 0),
          cellR * 0.22,
          Paint()
            ..color = const Color(0xFF14532D).withValues(alpha: 0.85 * clarity)
            ..maskFilter =
                blur > 0.4 ? ui.MaskFilter.blur(ui.BlurStyle.normal, blur * 0.5) : null,
        );
      }
    }
    if (nucleusMarked && clarity > 0.5) {
      canvas.drawCircle(
        c + pan + Offset(-12 * scale, -8 * scale),
        14 * scale,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = accent,
      );
    }
    canvas.restore();

    // Vignette
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.transparent,
            Colors.black.withValues(alpha: 0.55),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(covariant _ScopePainter oldDelegate) =>
      oldDelegate.clarity != clarity ||
      oldDelegate.stageX != stageX ||
      oldDelegate.stageY != stageY ||
      oldDelegate.illum != illum ||
      oldDelegate.mag != mag ||
      oldDelegate.nucleusMarked != nucleusMarked;
}
