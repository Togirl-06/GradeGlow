import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import '../shared/science_workspace_shell.dart';

/// Angle / velocity / gravity / height → trajectory; hit target with lowest v.
class PhysicsProjectileLab extends StatefulWidget {
  const PhysicsProjectileLab({
    super.key,
    this.embedded = false,
    this.onComplete,
  });

  final bool embedded;
  final VoidCallback? onComplete;

  @override
  State<PhysicsProjectileLab> createState() => _PhysicsProjectileLabState();
}

class _PhysicsProjectileLabState extends State<PhysicsProjectileLab> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  double _angleDeg = 45;
  double _v = 18;
  double _g = 9.8;
  double _h0 = 0;
  bool _fired = false;
  List<Offset> _path = <Offset>[];
  double _range = 0;
  double _maxH = 0;
  double _flightT = 0;
  bool _hit = false;
  double? _bestV;
  static const double _targetX = 28; // meters
  String? _feedback;

  void _fire() {
    final double theta = _angleDeg * math.pi / 180;
    final double vx = _v * math.cos(theta);
    final double vy0 = _v * math.sin(theta);
    final List<Offset> pts = <Offset>[];
    double t = 0;
    double x = 0;
    double y = _h0;
    double maxH = _h0;
    const double dt = 0.05;
    while (y >= 0 && t < 20) {
      pts.add(Offset(x, y));
      t += dt;
      x = vx * t;
      y = _h0 + vy0 * t - 0.5 * _g * t * t;
      if (y > maxH) maxH = y;
    }
    final bool hit = (x - _targetX).abs() < 1.8 && y <= 0.5;
    setState(() {
      _path = pts;
      _range = x;
      _maxH = maxH;
      _flightT = t;
      _fired = true;
      _hit = hit;
      if (hit) {
        _bestV = _bestV == null ? _v : math.min(_bestV!, _v);
      }
      _feedback = hit ? 'Target hit!' : 'Missed — adjust angle/velocity/height.';
    });
  }

  Future<void> _submit() async {
    if (!_hit) {
      setState(() => _feedback = 'Hit the target before completing the challenge.');
      return;
    }
    await _store.addNote(
      'Projectile: θ=$_angleDeg° v=$_v g=$_g h0=$_h0 → R=${_range.toStringAsFixed(1)} hit',
    );
    if (!mounted) return;
    if (widget.embedded) {
      widget.onComplete?.call();
      setState(() => _feedback = 'Target hit — logged.');
      return;
    }
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Target down',
      body:
          'Range ${_range.toStringAsFixed(1)} m · H ${_maxH.toStringAsFixed(1)} m · t ${_flightT.toStringAsFixed(2)} s'
          '${_bestV != null ? '\nBest hit velocity: ${_bestV!.toStringAsFixed(1)} m/s' : ''}',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.embedded;
    final Widget body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ScienceSideCard(
          title: 'SETTINGS',
          accent: t.accent,
          dark: dark,
          child: ListView(
            children: <Widget>[
              _sl('Angle °', _angleDeg, 15, 75, (double v) => setState(() => _angleDeg = v), dark),
              _sl('Velocity m/s', _v, 8, 45, (double v) => setState(() => _v = v), dark),
              _sl('Gravity', _g, 5, 15, (double v) => setState(() => _g = v), dark),
              _sl('Height m', _h0, 0, 12, (double v) => setState(() => _h0 = v), dark),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _fire,
                  style: FilledButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'LAUNCH',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CustomPaint(
              painter: _TrajPainter(
                path: _path,
                accent: t.accent,
                targetX: _targetX,
                maxRange: math.max(_range, _targetX + 5),
                maxH: math.max(_maxH, 8),
                light: !dark,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        ScienceSideCard(
          title: 'RESULTS',
          accent: t.accent,
          dark: dark,
          child: ListView(
            children: <Widget>[
              _kv('Range', _fired ? '${_range.toStringAsFixed(1)} m' : '—', dark),
              _kv('Max height', _fired ? '${_maxH.toStringAsFixed(1)} m' : '—', dark),
              _kv('Time of flight', _fired ? '${_flightT.toStringAsFixed(2)} s' : '—', dark),
              _kv('Target', _hit ? 'HIT' : (_fired ? 'MISS' : '—'), dark),
              if (_bestV != null)
                _kv('Best hit v', '${_bestV!.toStringAsFixed(1)} m/s', dark),
              if (_feedback != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _feedback!,
                  style: TextStyle(
                    color: dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                child: const Text('COMPLETE'),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFF0B1320), child: body);
    }

    return ScienceWorkspaceShell(
      theme: t,
      crumbs: const <String>['Physics Lab', 'Energy', 'Projectile Motion'],
      body: body,
    );
  }

  Widget _kv(String k, String v, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              k,
              style: TextStyle(color: dark ? Colors.white54 : Colors.black54),
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: dark ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sl(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onC,
    bool dark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label  ${value.toStringAsFixed(1)}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: dark ? Colors.white70 : null,
          ),
        ),
        Slider(value: value, min: min, max: max, onChanged: onC, activeColor: t.accent),
      ],
    );
  }
}

class _TrajPainter extends CustomPainter {
  _TrajPainter({
    required this.path,
    required this.accent,
    required this.targetX,
    required this.maxRange,
    required this.maxH,
    this.light = false,
  });

  final List<Offset> path;
  final Color accent;
  final double targetX;
  final double maxRange;
  final double maxH;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      Paint()..color = light ? const Color(0xFFF8FAFC) : Colors.black26,
    );
    final Paint grid = Paint()
      ..color = (light ? Colors.black12 : Colors.white12)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      final double x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      final double y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final Paint ground = Paint()
      ..color = light ? const Color(0xFF64748B) : Colors.white24
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, size.height - 8), Offset(size.width, size.height - 8), ground);

    Offset map(Offset p) {
      final double x = (p.dx / maxRange) * (size.width - 20) + 8;
      final double y = size.height - 8 - (p.dy / maxH) * (size.height - 24);
      return Offset(x, y);
    }

    final Offset tgt = map(Offset(targetX, 0));
    canvas.drawCircle(tgt, 8, Paint()..color = const Color(0xFFF87171));

    if (path.length < 2) return;
    final Path traj = Path()..moveTo(map(path.first).dx, map(path.first).dy);
    for (final Offset p in path.skip(1)) {
      final Offset m = map(p);
      traj.lineTo(m.dx, m.dy);
    }
    canvas.drawPath(
      traj,
      Paint()
        ..color = accent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TrajPainter oldDelegate) => true;
}
