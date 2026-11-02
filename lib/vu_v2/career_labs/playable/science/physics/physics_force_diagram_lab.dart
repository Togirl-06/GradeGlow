import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Place force arrows; evaluate directions; optional freehand overlay.
class PhysicsForceDiagramLab extends StatefulWidget {
  const PhysicsForceDiagramLab({super.key});

  @override
  State<PhysicsForceDiagramLab> createState() => _PhysicsForceDiagramLabState();
}

enum _ForceKind { weight, normal, friction, applied }

class _PhysicsForceDiagramLabState extends State<PhysicsForceDiagramLab> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  final Map<_ForceKind, String> _dirs = <_ForceKind, String>{};
  bool _freehand = false;
  final List<Offset> _strokes = <Offset>[];
  String? _feedback;

  static const Map<_ForceKind, String> _correct = <_ForceKind, String>{
    _ForceKind.weight: 'down',
    _ForceKind.normal: 'up',
    _ForceKind.friction: 'left',
    _ForceKind.applied: 'right',
  };

  Future<void> _submit() async {
    int ok = 0;
    for (final _ForceKind k in _ForceKind.values) {
      if (_dirs[k] == _correct[k]) ok++;
    }
    if (ok < 4) {
      setState(() => _feedback = 'Check each arrow direction (block pushed right).');
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Forces off',
        body: 'Weight↓ normal↑ friction← applied→ for a rightward push on a surface.',
      );
      return;
    }
    await _store.addNote(
      'Force diagram: W↓ N↑ f← F→ ${_freehand ? '+ freehand' : ''}',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'FBD clear',
      body: 'All four forces oriented correctly.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Force Diagram',
      brief: 'Place weight, normal, friction, applied — check directions.',
      badgeLabel: 'FORCES',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'EVALUATE DIAGRAM',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.3,
            child: sciencePanel(
              surface: t.surface,
              accent: t.accent,
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  return GestureDetector(
                    onPanUpdate: _freehand
                        ? (DragUpdateDetails d) {
                            setState(() => _strokes.add(d.localPosition));
                          }
                        : null,
                    child: CustomPaint(
                      size: Size(c.maxWidth, c.maxHeight),
                      painter: _FbdPainter(
                        dirs: _dirs,
                        accent: t.accent,
                        strokes: _strokes,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Freehand overlay', style: TextStyle(color: Colors.white70)),
            value: _freehand,
            activeThumbColor: t.accent,
            onChanged: (bool v) => setState(() => _freehand = v),
          ),
          ..._ForceKind.values.map((_ForceKind k) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 88,
                    child: Text(_name(k),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: <String>['up', 'down', 'left', 'right'].map((String d) {
                        return ChoiceChip(
                          label: Text(d),
                          selected: _dirs[k] == d,
                          selectedColor: t.accent.withValues(alpha: 0.4),
                          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          onSelected: (_) => setState(() => _dirs[k] = d),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_feedback != null)
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
        ],
      ),
    );
  }

  String _name(_ForceKind k) {
    switch (k) {
      case _ForceKind.weight:
        return 'Weight';
      case _ForceKind.normal:
        return 'Normal';
      case _ForceKind.friction:
        return 'Friction';
      case _ForceKind.applied:
        return 'Applied';
    }
  }
}

class _FbdPainter extends CustomPainter {
  _FbdPainter({required this.dirs, required this.accent, required this.strokes});
  final Map<_ForceKind, String> dirs;
  final Color accent;
  final List<Offset> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.55);
    final Paint block = Paint()..color = accent.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 70, height: 44),
        const Radius.circular(6),
      ),
      block,
    );
    canvas.drawLine(
      Offset(20, size.height * 0.72),
      Offset(size.width - 20, size.height * 0.72),
      Paint()
        ..color = Colors.white38
        ..strokeWidth = 2,
    );

    void arrow(String? dir, Color color) {
      if (dir == null) return;
      final Paint p = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      Offset tip;
      switch (dir) {
        case 'up':
          tip = c.translate(0, -70);
        case 'down':
          tip = c.translate(0, 70);
        case 'left':
          tip = c.translate(-80, 0);
        default:
          tip = c.translate(80, 0);
      }
      canvas.drawLine(c, tip, p);
      canvas.drawCircle(tip, 4, Paint()..color = color);
    }

    arrow(dirs[_ForceKind.weight], const Color(0xFFF87171));
    arrow(dirs[_ForceKind.normal], const Color(0xFF34D399));
    arrow(dirs[_ForceKind.friction], const Color(0xFFFBBF24));
    arrow(dirs[_ForceKind.applied], accent);

    if (strokes.length >= 2) {
      final Path path = Path()..moveTo(strokes.first.dx, strokes.first.dy);
      for (final Offset o in strokes.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FbdPainter oldDelegate) => true;
}
