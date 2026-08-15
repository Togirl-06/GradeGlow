import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/science_badges.dart';
import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Launch package across 40 m gap; miss = fail analyze retry. Badge physics_engineer.
class PhysicsBossRescue extends StatefulWidget {
  const PhysicsBossRescue({super.key});

  @override
  State<PhysicsBossRescue> createState() => _PhysicsBossRescueState();
}

class _PhysicsBossRescueState extends State<PhysicsBossRescue> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  static const double _gap = 40;
  double _angle = 40;
  double _v = 22;
  double _h0 = 2;
  static const double _g = 9.8;
  bool _launched = false;
  bool _hit = false;
  double _landX = 0;
  String? _analysis;
  final TextEditingController _analyze = TextEditingController();
  String? _feedback;

  void _launch() {
    final double th = _angle * math.pi / 180;
    final double vx = _v * math.cos(th);
    final double vy = _v * math.sin(th);
    // Solve y=0: h0 + vy t - 0.5 g t^2 = 0
    final double a = -0.5 * _g;
    final double b = vy;
    final double c = _h0;
    final double disc = b * b - 4 * a * c;
    if (disc < 0) {
      setState(() {
        _feedback = 'No real flight time — check settings.';
        _launched = false;
      });
      return;
    }
    final double t = (-b - math.sqrt(disc)) / (2 * a);
    final double x = vx * t;
    final bool hit = (x - _gap).abs() < 2.2;
    setState(() {
      _launched = true;
      _landX = x;
      _hit = hit;
      _feedback = hit
          ? 'Package cleared the ${_gap.toStringAsFixed(0)} m gap!'
          : 'MISS — landed at ${x.toStringAsFixed(1)} m. Analyze and retry.';
    });
  }

  Future<void> _finish() async {
    if (!_hit) {
      if (_launched && _analyze.text.trim().length < 15) {
        setState(() => _feedback = 'Analyze the miss (angle / velocity / height) then retry.');
        return;
      }
      setState(() {
        _analysis = _analyze.text.trim();
        _feedback = 'Retry the launch after your analysis.';
      });
      return;
    }
    await _store.unlockBadge(ScienceBadges.physicsEngineer);
    await _store.addNote(
      'BOSS RESCUE: cleared ${_gap}m · θ=$_angle v=$_v h0=$_h0 [badge: physics_engineer]',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Package delivered',
      body: '40 m gap cleared. Badge unlocked: physics_engineer.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _analyze.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Boss · Engineering Challenge',
      brief: 'Launch a package across a 40 m gap. Miss → analyze → retry.',
      badgeLabel: 'BOSS',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: _hit ? 'CLAIM BADGE' : (_launched ? 'RETRY AFTER ANALYSIS' : 'STANDBY'),
        onPressed: _hit
            ? _finish
            : () {
                if (!_launched) {
                  setState(() => _feedback = 'Launch first.');
                  return;
                }
                if (_analyze.text.trim().length < 15) {
                  setState(() => _feedback = 'Write a short miss analysis first.');
                  return;
                }
                setState(() {
                  _launched = false;
                  _hit = false;
                  _analysis = _analyze.text.trim();
                  _feedback = 'Analysis saved. Adjust dials and launch again.';
                });
              },
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          sciencePanel(
            surface: t.surface,
            accent: t.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Gap: ${_gap.toStringAsFixed(0)} m',
                  style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                if (_launched)
                  Text(
                    _hit
                        ? 'SUCCESS · landed ${_landX.toStringAsFixed(1)} m'
                        : 'FAIL · landed ${_landX.toStringAsFixed(1)} m',
                    style: TextStyle(
                      color: _hit ? const Color(0xFF34D399) : const Color(0xFFF87171),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (_analysis != null)
                  Text('Last analysis: $_analysis',
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          _sl('Angle°', _angle, 20, 70, (double v) => setState(() => _angle = v)),
          _sl('Velocity', _v, 12, 40, (double v) => setState(() => _v = v)),
          _sl('Height', _h0, 0, 15, (double v) => setState(() => _h0 = v)),
          OutlinedButton(
            onPressed: _launch,
            style: OutlinedButton.styleFrom(foregroundColor: t.accent),
            child: const Text('LAUNCH PACKAGE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_launched && !_hit) ...<Widget>[
            const SizedBox(height: 10),
            TextField(
              controller: _analyze,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Analyze the miss',
                labelStyle: TextStyle(color: t.accent),
                filled: true,
                fillColor: t.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _sl(String label, double value, double min, double max, ValueChanged<double> onC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$label ${value.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        Slider(value: value, min: min, max: max, onChanged: onC, activeColor: t.accent),
      ],
    );
  }
}
