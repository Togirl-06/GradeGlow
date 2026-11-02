import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import '../shared/science_workspace_shell.dart';

class ChemistryTitrationLab extends StatefulWidget {
  const ChemistryTitrationLab({
    super.key,
    this.embedded = false,
    this.onComplete,
  });

  final bool embedded;
  final VoidCallback? onComplete;

  @override
  State<ChemistryTitrationLab> createState() => _ChemistryTitrationLabState();
}

class _ChemistryTitrationLabState extends State<ChemistryTitrationLab> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  int _step = 0;
  double _volume = 0;
  bool _dripping = false;
  bool _stopped = false;
  bool _rushed = false;
  String _color = 'colorless';
  final TextEditingController _init = TextEditingController(text: '0.00');
  final TextEditingController _final = TextEditingController();
  final TextEditingController _calc = TextEditingController();
  String? _feedback;

  static const List<String> _steps = <String>[
    'Rinse & fill burette with 0.100 M NaOH',
    'Record initial burette reading',
    'Add phenolphthalein indicator',
    'Pipette 25.0 mL acid into flask',
    'Start dripping base',
    'Watch for pale-pink endpoint',
    'Stop at pale pink',
    'Record final volume & calculate',
  ];

  bool get _atEndpoint => _volume >= 24.5 && _volume <= 26.0;
  bool get _overshot => _volume > 26.0;

  Color get _flaskColor {
    if (_color == 'pale pink') return const Color(0xFFF9A8D4);
    if (_color == 'deep pink') return const Color(0xFFEC4899);
    return const Color(0xFFE0F2FE);
  }

  void _advance() {
    if (_step >= 4 && _step < 6 && !_dripping) {
      setState(() {
        _dripping = true;
        _feedback = 'Drip carefully. Stop at pale pink.';
      });
    }
    if (_step == 6 && !_stopped) {
      setState(() => _feedback = 'Stop at the endpoint before recording.');
      return;
    }
    setState(() {
      if (_step < _steps.length - 1) _step++;
      _feedback = null;
    });
  }

  void _drip({required bool rush}) {
    if (!_dripping || _stopped) return;
    setState(() {
      _volume += rush ? 3.5 : 0.4;
      if (rush) _rushed = true;
      _color = _overshot ? 'deep pink' : (_atEndpoint ? 'pale pink' : 'colorless');
      if (_overshot) {
        _feedback = 'Endpoint missed. Retry.';
        _stopped = true;
      } else if (_atEndpoint) {
        _feedback = 'Pale pink — stop now!';
      }
    });
  }

  void _stop() {
    if (!_dripping) return;
    setState(() {
      _stopped = true;
      if (_atEndpoint) {
        _step = 6;
        _final.text = (0.0 + _volume).toStringAsFixed(2);
        _feedback = 'Endpoint locked. Record and calculate.';
      } else if (_volume < 24.5) {
        _feedback = 'Too early — still colorless.';
        _rushed = true;
      } else {
        _feedback = 'Overshot. Retry.';
        _rushed = true;
      }
    });
  }

  void _retry() {
    setState(() {
      _step = 0;
      _volume = 0;
      _dripping = false;
      _stopped = false;
      _rushed = false;
      _color = 'colorless';
      _final.clear();
      _calc.clear();
      _feedback = 'Fresh flask.';
    });
  }

  Future<void> _finish() async {
    if (!_stopped || !_atEndpoint) {
      setState(() => _feedback = 'Need a clean pale-pink endpoint.');
      return;
    }
    final double? molarity = double.tryParse(_calc.text.trim());
    final double expected = (0.100 * _volume) / 25.0;
    if (molarity == null || (molarity - expected).abs() > 0.02) {
      setState(() => _feedback =
          'Molarity = (0.100 × ${_volume.toStringAsFixed(1)}) / 25.0');
      return;
    }
    await _store.addNote(
      'Titration: V=${_volume.toStringAsFixed(1)} mL → [acid]≈${molarity.toStringAsFixed(3)} M',
    );
    if (!mounted) return;
    if (widget.embedded) {
      widget.onComplete?.call();
      setState(() => _feedback = 'Titration complete — logged.');
      return;
    }
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Endpoint mastered',
      body: 'Volume ${_volume.toStringAsFixed(1)} mL logged.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _init.dispose();
    _final.dispose();
    _calc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ScienceSideCard(
          title: 'STEPS',
          accent: t.accent,
          dark: widget.embedded,
          child: ListView.builder(
            itemCount: _steps.length,
            itemBuilder: (BuildContext context, int i) {
              final bool done = i < _step;
              final bool cur = i == _step;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      done
                          ? Icons.check_circle
                          : (cur
                              ? Icons.radio_button_checked
                              : Icons.circle_outlined),
                      size: 16,
                      color: done || cur
                          ? t.accent
                          : (widget.embedded ? Colors.white24 : Colors.black26),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _steps[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: cur ? FontWeight.w800 : FontWeight.w500,
                          color: widget.embedded
                              ? (cur ? Colors.white : Colors.white60)
                              : (cur ? Colors.black : Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CustomPaint(
              painter: _TitrationPainter(
                flask: _flaskColor,
                volume: _volume,
                dripping: _dripping && !_stopped,
                accent: t.accent,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        ScienceSideCard(
          title: 'READINGS',
          accent: t.accent,
          dark: widget.embedded,
          child: ListView(
            children: <Widget>[
              Text(
                'Flask: $_color',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: widget.embedded ? Colors.white : null,
                ),
              ),
              Text(
                'Delivered ${_volume.toStringAsFixed(1)} mL',
                style: TextStyle(
                  color: widget.embedded ? Colors.white70 : null,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _init,
                style: TextStyle(
                  color: widget.embedded ? Colors.white : null,
                ),
                decoration: InputDecoration(
                  labelText: 'Initial volume (mL)',
                  isDense: true,
                  labelStyle: TextStyle(
                    color: widget.embedded ? Colors.white54 : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _final,
                style: TextStyle(
                  color: widget.embedded ? Colors.white : null,
                ),
                decoration: InputDecoration(
                  labelText: 'Final volume (mL)',
                  isDense: true,
                  labelStyle: TextStyle(
                    color: widget.embedded ? Colors.white54 : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Volume used: ${_volume.toStringAsFixed(2)} mL',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: t.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'M₁V₁ = M₂V₂',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: widget.embedded ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _calc,
                style: TextStyle(
                  color: widget.embedded ? Colors.white : null,
                ),
                decoration: InputDecoration(
                  labelText: 'Molarity',
                  isDense: true,
                  labelStyle: TextStyle(
                    color: widget.embedded ? Colors.white54 : null,
                  ),
                ),
              ),
              if (_feedback != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  _feedback!,
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final Widget tools = Row(
      children: <Widget>[
        _tool('Pipette', Icons.water_drop_outlined, () => _advance()),
        _tool('Dropper', Icons.science_outlined, () => _drip(rush: false)),
        _tool('Rush', Icons.flash_on, () => _drip(rush: true)),
        _tool('Stop', Icons.pause_circle, _stop),
        const Spacer(),
        if (_rushed || (_stopped && !_atEndpoint))
          TextButton(
            onPressed: _retry,
            child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        FilledButton(
          onPressed: _step >= 7 ? _finish : _advance,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: Colors.black,
          ),
          child: Text(
            _step >= 7 ? 'SUBMIT' : 'NEXT STEP',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(
        color: const Color(0xFF0B1320),
        child: Column(
          children: <Widget>[
            Expanded(child: body),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              color: const Color(0xFF121C2E),
              child: tools,
            ),
          ],
        ),
      );
    }

    return ScienceWorkspaceShell(
      theme: t,
      crumbs: const <String>['Chemistry Lab', 'Titration Lab', 'Acid–Base'],
      tools: tools,
      body: body,
    );
  }

  Widget _tool(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _TitrationPainter extends CustomPainter {
  _TitrationPainter({
    required this.flask,
    required this.volume,
    required this.dripping,
    required this.accent,
  });

  final Color flask;
  final double volume;
  final bool dripping;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      Paint()..color = Colors.white,
    );
    final Offset c = Offset(size.width * 0.5, size.height * 0.28);
    // stand
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.12, 10, size.height * 0.7),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.22, 90, 8),
      Paint()..color = const Color(0xFF475569),
    );
    // burette
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(40, 40), width: 18, height: 160),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFBAE6FD),
    );
    final double fillH = (volume / 30).clamp(0.0, 1.0) * 140;
    canvas.drawRect(
      Rect.fromLTWH(c.dx + 32, c.dy + 110 - fillH, 16, fillH),
      Paint()..color = accent.withValues(alpha: 0.55),
    );
    if (dripping) {
      canvas.drawCircle(
        c + const Offset(40, 130),
        4,
        Paint()..color = accent,
      );
    }
    // flask
    final Offset f = Offset(size.width * 0.52, size.height * 0.72);
    final Path p = Path()
      ..moveTo(f.dx - 12, f.dy - 70)
      ..lineTo(f.dx + 12, f.dy - 70)
      ..lineTo(f.dx + 12, f.dy - 20)
      ..lineTo(f.dx + 48, f.dy + 50)
      ..lineTo(f.dx - 48, f.dy + 50)
      ..lineTo(f.dx - 12, f.dy - 20)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(f.dx - 40, f.dy + 8, 80, 42),
      Paint()..color = flask,
    );
  }

  @override
  bool shouldRepaint(covariant _TitrationPainter oldDelegate) => true;
}
