import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../data/science_diagram_catalog.dart';
import '../../../../widgets/science/anatomy_asset_canvas.dart';
import 'lab_blueprint.dart';
import 'lab_session.dart';
import 'pro_workspaces.dart';

class LabWorkspaceHost extends StatelessWidget {
  const LabWorkspaceHost({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    switch (session.blueprint.discipline) {
      case LabDiscipline.anatomy:
        return AnatomyWorkspace(session: session);
      case LabDiscipline.biology:
        return MicroscopeWorkspace(session: session);
      case LabDiscipline.chemistry:
        return ChemistryWorkspace(session: session);
      case LabDiscipline.physics:
        return PhysicsWorkspace(session: session);
      case LabDiscipline.mathematics:
        return MathWorkspace(session: session);
      case LabDiscipline.computerScience:
        return CsWorkspace(session: session);
      case LabDiscipline.engineering:
        return EngineeringWorkspace(session: session);
      case LabDiscipline.medicine:
      case LabDiscipline.nursing:
        return ClinicalWorkspace(session: session);
      case LabDiscipline.economics:
        return EconomicsWorkspace(session: session);
      case LabDiscipline.finance:
        return FinanceWorkspace(session: session);
      case LabDiscipline.accounting:
        return AccountingWorkspace(session: session);
      case LabDiscipline.business:
        return BusinessWorkspace(session: session);
      case LabDiscipline.marketing:
        return MarketingWorkspace(session: session);
      case LabDiscipline.law:
        return LawWorkspace(session: session);
      case LabDiscipline.psychology:
        return PsychWorkspace(session: session);
      case LabDiscipline.history:
        return HistoryWorkspace(session: session);
      case LabDiscipline.geography:
        return GeographyWorkspace(session: session);
      case LabDiscipline.architecture:
        return ArchitectureWorkspace(session: session);
    }
  }
}

/// Interactive atlas: orbit, layers, pins, optional heart-path trace.
class AnatomyWorkspace extends StatelessWidget {
  const AnatomyWorkspace({super.key, required this.session});
  final LabSession session;

  static const List<String> pathway = <String>[
    'vena cava',
    'right atrium',
    'tricuspid valve',
    'right ventricle',
    'pulmonary valve',
    'pulmonary artery',
    'lungs',
    'pulmonary veins',
    'left atrium',
    'mitral valve',
    'left ventricle',
    'aortic valve',
    'aorta',
  ];

  @override
  Widget build(BuildContext context) {
    final double yaw = (session.getv<double>('yaw') ?? 0);
    final int step = session.getv<int>('path') ?? 0;
    final Set<String> pins =
        (session.getv<List<dynamic>>('pins') ?? const <dynamic>[]).cast<String>().toSet();
    final bool heart = session.layersOn.contains('Cardiovascular') ||
        session.blueprint.title.toLowerCase().contains('heart') ||
        session.blueprint.unit.toLowerCase().contains('heart');

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[Color(0xFF1A1410), Color(0xFF050505)],
            ),
          ),
        ),
        if (session.layersOn.contains('Skeletal') && !heart)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(yaw),
            child: AnatomyAssetCanvas(
              diagram: ScienceDiagramCatalog.diagramById('skeleton')!,
              highlightRegionId: session.getv<String>('sel'),
              highlightRegionIds: pins,
              onRegionTap: (r) {
                session.act(
                  'pin',
                  data: r.id,
                  inspect: '${r.name} — tapped on the model. Isolate or keep exploring.',
                );
                final List<dynamic> next = List<dynamic>.from(
                  session.getv<List<dynamic>>('pins') ?? <dynamic>[],
                )..add(r.name);
                session.setVar('pins', next);
              },
            ),
          ),
        if (heart || session.layersOn.contains('Cardiovascular'))
          _HeartTrace(
            yaw: yaw,
            step: step,
            onYaw: (double dx) {
              session.setVar('yaw', yaw + dx * 0.012, inspectorText: 'Orbiting the heart model');
            },
            onTap: (String name) {
              if (step < pathway.length && pathway[step] == name) {
                final int n = step + 1;
                session.setVar('path', n);
                session.act(
                  n >= pathway.length ? 'trace_complete' : 'trace',
                  data: name,
                  inspect: n >= pathway.length
                      ? 'Pathway complete. You traced systemic ↔ pulmonary flow on the model.'
                      : 'Highlighted $name. Next: ${pathway[n]}',
                  say: n >= pathway.length
                      ? 'That is the circuit. You did not recite it — you walked it.'
                      : 'Correct structure. Continue the path.',
                );
              } else {
                session.act(
                  'trace_miss',
                  data: name,
                  say: 'That is $name, but it is not next in the path. Look at the highlighted chamber.',
                  inspect: 'Expected ${pathway[step.clamp(0, pathway.length - 1)]}',
                );
              }
            },
          ),
        if (session.layersOn.contains('Muscular') && !heart)
          IgnorePointer(
            child: Opacity(
              opacity: 0.35,
              child: CustomPaint(painter: _MuscleSilhouettePainter()),
            ),
          ),
      ],
    );
  }
}

class _HeartTrace extends StatelessWidget {
  const _HeartTrace({
    required this.yaw,
    required this.step,
    required this.onTap,
    required this.onYaw,
  });
  final double yaw;
  final int step;
  final ValueChanged<String> onTap;
  final ValueChanged<double> onYaw;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return GestureDetector(
          onHorizontalDragUpdate: (DragUpdateDetails d) => onYaw(d.delta.dx),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(yaw),
            child: CustomPaint(
              painter: _HeartPainter(step: step),
              child: Stack(
                children: <Widget>[
                  for (final ({String name, Alignment a}) h in const <({String name, Alignment a})>[
                    (name: 'vena cava', a: Alignment(-0.55, -0.55)),
                    (name: 'right atrium', a: Alignment(-0.35, -0.15)),
                    (name: 'tricuspid valve', a: Alignment(-0.28, 0.05)),
                    (name: 'right ventricle', a: Alignment(-0.2, 0.38)),
                    (name: 'pulmonary valve', a: Alignment(-0.05, -0.25)),
                    (name: 'pulmonary artery', a: Alignment(0.02, -0.55)),
                    (name: 'lungs', a: Alignment(0.72, -0.2)),
                    (name: 'pulmonary veins', a: Alignment(0.45, -0.08)),
                    (name: 'left atrium', a: Alignment(0.28, -0.18)),
                    (name: 'mitral valve', a: Alignment(0.22, 0.05)),
                    (name: 'left ventricle', a: Alignment(0.18, 0.42)),
                    (name: 'aortic valve', a: Alignment(0.05, -0.05)),
                    (name: 'aorta', a: Alignment(0.08, -0.62)),
                  ])
                    Align(
                      alignment: h.a,
                      child: GestureDetector(
                        onTap: () => onTap(h.name),
                        child: _Pin(label: h.name, active: step < AnatomyWorkspace.pathway.length && AnatomyWorkspace.pathway[step] == h.name),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: active ? 22 : 14,
          height: active ? 22 : 14,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF3DDBAD) : const Color(0x99FF4D6D),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (active ? const Color(0xFF3DDBAD) : const Color(0xFFFF4D6D))
                    .withValues(alpha: 0.7),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF3DDBAD) : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.step});
  final int step;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.42, size.height * 0.48);
    final Path heart = Path()
      ..moveTo(c.dx, c.dy + 90)
      ..cubicTo(c.dx - 140, c.dy + 20, c.dx - 120, c.dy - 90, c.dx, c.dy - 20)
      ..cubicTo(c.dx + 120, c.dy - 90, c.dx + 140, c.dy + 20, c.dx, c.dy + 90);
    canvas.drawPath(
      heart,
      Paint()..color = const Color(0xFF7A2030),
    );
    canvas.drawPath(
      heart,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF3DDBAD).withValues(alpha: 0.5),
    );
    canvas.drawCircle(c + const Offset(-30, -10), 34, Paint()..color = const Color(0xFFC45C6A));
    canvas.drawCircle(c + const Offset(28, -8), 32, Paint()..color = const Color(0xFFE06B7A));
    canvas.drawCircle(c + const Offset(-24, 40), 40, Paint()..color = const Color(0xFF9B3040));
    canvas.drawCircle(c + const Offset(22, 42), 44, Paint()..color = const Color(0xFFB43B4C));
  }

  @override
  bool shouldRepaint(covariant _HeartPainter old) => old.step != step;
}

class _MuscleSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = const Color(0x88B54A3C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.45),
          width: size.width * 0.28,
          height: size.height * 0.7,
        ),
        const Radius.circular(80),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MicroscopeWorkspace extends StatelessWidget {
  const MicroscopeWorkspace({super.key, required this.session});
  final LabSession session;

  static const List<({String id, Offset n, double r})> organelles =
      <({String id, Offset n, double r})>[
    (id: 'cell wall', n: Offset(0.50, 0.32), r: 0.10),
    (id: 'nucleus', n: Offset(0.50, 0.50), r: 0.09),
    (id: 'chloroplast', n: Offset(0.36, 0.54), r: 0.08),
    (id: 'chloroplast', n: Offset(0.66, 0.44), r: 0.08),
    (id: 'vacuole', n: Offset(0.58, 0.64), r: 0.08),
  ];

  @override
  Widget build(BuildContext context) {
    final double focus = session.getv<double>('focus') ?? 0.35;
    final double mag = session.getv<double>('mag') ?? 4;
    final Offset pan = Offset(
      session.getv<double>('panx') ?? 0,
      session.getv<double>('pany') ?? 0,
    );
    final double blur = ((focus - 0.62).abs() * 18).clamp(0, 8);
    final bool lamp = session.getv<bool>('lamp') ?? false;
    final bool slide = session.getv<bool>('slide') ?? false;
    final bool sharp = (focus - 0.62).abs() < 0.1 && lamp && slide;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(color: Color(0xFF0A0A0A)),
        Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                return GestureDetector(
                  onPanUpdate: (DragUpdateDetails d) {
                    session.setVar('panx', pan.dx + d.delta.dx);
                    session.setVar('pany', pan.dy + d.delta.dy);
                  },
                  onTapDown: (TapDownDetails d) {
                    if (!slide) {
                      session.act('not_ready', say: 'Load the unknown slide first.');
                      return;
                    }
                    if (!sharp) {
                      session.act(
                        'unfocused_tap',
                        inspect:
                            'The field is not sharp. Lamp on, then 4×, then focus, then pin.',
                      );
                      return;
                    }
                    final Size size = Size(c.maxWidth, c.maxHeight);
                    String? hit;
                    for (final ({String id, Offset n, double r}) o in organelles) {
                      final Offset p = Offset(o.n.dx * size.width, o.n.dy * size.height);
                      if ((d.localPosition - p).distance < o.r * size.width) {
                        hit = o.id;
                        break;
                      }
                    }
                    if (hit == null) {
                      session.act('inspect', inspect: 'Missed a structure. Pan, then tap a green body or the nucleus.');
                      return;
                    }
                    final List<dynamic> pins = List<dynamic>.from(
                      session.getv<List<dynamic>>('pins') ?? <dynamic>[],
                    )..add(hit);
                    session.setVar('pins', pins);
                    session.act(
                      'pin',
                      data: hit,
                      inspect:
                          'Pinned $hit. Keep pinning until you can classify the specimen.',
                    );
                  },
                  child: ClipOval(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        color: lamp && slide ? const Color(0xFF1A1208) : Colors.black,
                        child: Transform.translate(
                          offset: pan / mag,
                          child: Transform.scale(
                            scale: mag / 4,
                            child: CustomPaint(painter: _PlantCellPainter()),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Center(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3DDBAD), width: 3),
              ),
            ),
          ),
        ),
        if (!slide)
          const Center(
            child: Text(
              'Load the unknown slide',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700),
            ),
          ),
        Positioned(
          right: 16,
          top: 24,
          bottom: 24,
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: focus.clamp(0, 1),
              onChanged: (double v) {
                session.setVar('focus', v, inspectorText: 'Focus ${v.toStringAsFixed(2)}');
                if ((v - 0.62).abs() < 0.06 && mag >= 4 && lamp && slide) {
                  session.act('focused', inspect: 'Sharp field. Tap a structure to pin it.');
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PlantCellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.55,
      height: size.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box.inflate(10), const Radius.circular(8)),
      Paint()..color = const Color(0xFF2E6B3A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(6)),
      Paint()..color = const Color(0xFF8FD19A),
    );
    canvas.drawCircle(box.center, 28, Paint()..color = const Color(0xFF4A3F7A));
    canvas.drawCircle(box.center + const Offset(-50, 10), 16, Paint()..color = const Color(0xFF2E8B3A));
    canvas.drawCircle(box.center + const Offset(48, -16), 14, Paint()..color = const Color(0xFF2E8B3A));
    canvas.drawCircle(box.center + const Offset(20, 30), 12, Paint()..color = const Color(0xFF2E8B3A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChemistryWorkspace extends StatelessWidget {
  const ChemistryWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final double delivered = session.getv<double>('ml') ?? 0;
    final bool pink = delivered >= 22.2;
    final bool deep = delivered >= 24.0;
    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails d) {
        final bool ready = session.getv<bool>('ready') ?? false;
        if (!ready) {
          session.act('not_ready', say: 'Charge the burette first — use the bench tools.');
          return;
        }
        final double next = (delivered - d.delta.dy * 0.08).clamp(0, 32);
        session.setVar('ml', next, inspectorText: '${next.toStringAsFixed(2)} mL delivered');
        if (next > 23.6 && delivered <= 23.6) {
          session.act('overshot', pause: next > 26, say: null);
        }
        if (next >= 22.2 && next <= 23.4) {
          session.act('endpoint_ok');
        }
        if (d.delta.dy.abs() > 18) {
          session.act('drop_too_fast');
        }
      },
      child: CustomPaint(
        painter: _TitrationPainter(ml: delivered, pink: pink, deep: deep),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TitrationPainter extends CustomPainter {
  _TitrationPainter({required this.ml, required this.pink, required this.deep});
  final double ml;
  final bool pink;
  final bool deep;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF12100C));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
      Paint()..color = const Color(0xFF3A2A1A),
    );
    final Offset flask = Offset(size.width * 0.55, size.height * 0.62);
    final Path f = Path()
      ..moveTo(flask.dx - 40, flask.dy - 50)
      ..lineTo(flask.dx - 70, flask.dy + 40)
      ..lineTo(flask.dx + 70, flask.dy + 40)
      ..lineTo(flask.dx + 40, flask.dy - 50)
      ..close();
    canvas.drawPath(
      f,
      Paint()
        ..color = deep
            ? const Color(0xFFC2185B)
            : pink
                ? const Color(0xFFF8BBD0)
                : const Color(0x33FFFFFF),
    );
    canvas.drawPath(
      f,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white54,
    );
    final Offset b = Offset(size.width * 0.55, size.height * 0.18);
    canvas.drawRect(
      Rect.fromCenter(center: b, width: 18, height: size.height * 0.42),
      Paint()..color = const Color(0xAA90CAF9),
    );
    canvas.drawCircle(b + Offset(0, size.height * 0.2), 10, Paint()..color = const Color(0xFF3DDBAD));
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '${ml.toStringAsFixed(2)} mL  ·  drag the stopcock',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(24, size.height - 48));
  }

  @override
  bool shouldRepaint(covariant _TitrationPainter old) => old.ml != ml;
}

class PhysicsWorkspace extends StatefulWidget {
  const PhysicsWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  State<PhysicsWorkspace> createState() => _PhysicsWorkspaceState();
}

class _PhysicsWorkspaceState extends State<PhysicsWorkspace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  final List<Offset> _path = <Offset>[];
  int _runsSeen = 0;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSession);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSession);
    _c.dispose();
    super.dispose();
  }

  void _onSession() {
    final int n =
        widget.session.events.where((LabEvent e) => e.id == 'run').length;
    if (n > _runsSeen) {
      _runsSeen = n;
      _animate();
    }
  }

  void _animate() {
    _path.clear();
    _c
      ..reset()
      ..forward();
  }

  void _launch() {
    widget.session.act('run', inspect: 'Projectile in flight. Read range when it lands.');
  }

  @override
  Widget build(BuildContext context) {
    final double angle = widget.session.getv<double>('angle') ?? 42;
    final double v0 = widget.session.getv<double>('v0') ?? 18;
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, _) {
        return GestureDetector(
          onHorizontalDragUpdate: (DragUpdateDetails d) {
            widget.session.setVar(
              'angle',
              (angle - d.delta.dx * 0.2).clamp(15, 75),
              inspectorText: 'θ = ${angle.toStringAsFixed(0)}°',
            );
            setState(() {});
          },
          onTap: _launch,
          child: CustomPaint(
            painter: _ProjectilePainter(
              t: _c.value,
              angle: angle * math.pi / 180,
              v0: v0,
              path: _path,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _ProjectilePainter extends CustomPainter {
  _ProjectilePainter({
    required this.t,
    required this.angle,
    required this.v0,
    required this.path,
  });
  final double t;
  final double angle;
  final double v0;
  final List<Offset> path;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B1220));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18),
      Paint()..color = const Color(0xFF1B3A2A),
    );
    final Offset origin = Offset(40, size.height * 0.82);
    const double g = 9.81;
    final double time = t * 2.4;
    final double x = origin.dx + v0 * math.cos(angle) * time * 8;
    final double y = origin.dy - (v0 * math.sin(angle) * time - 0.5 * g * time * time) * 8;
    path.add(Offset(x, y));
    final Paint trail = Paint()
      ..color = const Color(0xFF3DDBAD)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (path.length > 1) {
      canvas.drawPoints(PointMode.polygon, path, trail);
    }
    canvas.drawCircle(Offset(x, y), 8, Paint()..color = const Color(0xFFFFB74D));
    canvas.drawLine(
      origin,
      origin + Offset(math.cos(angle) * 50, -math.sin(angle) * 50),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter old) => old.t != t || old.angle != angle;
}

class MathWorkspace extends StatelessWidget {
  const MathWorkspace({super.key, required this.session});
  final LabSession session;

  static double f(double x) => x * x * x - 3 * x;
  static double fp(double x) => 3 * x * x - 3;

  @override
  Widget build(BuildContext context) {
    final double x = session.getv<double>('x') ?? -0.5;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        final double nx = (x + d.delta.dx * 0.01).clamp(-2.2, 2.2);
        session.setVar(
          'x',
          nx,
          inspectorText:
              'x = ${nx.toStringAsFixed(2)}   f = ${f(nx).toStringAsFixed(2)}   f′ = ${fp(nx).toStringAsFixed(2)}',
        );
        if (fp(nx) > 8.5) {
          session.act('g_ok', inspect: 'You are on the steepest visible climb of f′.');
        }
      },
      child: CustomPaint(
        painter: _CalcPainter(x: x),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CalcPainter extends CustomPainter {
  _CalcPainter({required this.x});
  final double x;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0A0E14));
    final Offset o = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(20, o.dy), Offset(size.width - 20, o.dy), Paint()..color = Colors.white24);
    canvas.drawLine(Offset(o.dx, 20), Offset(o.dx, size.height - 20), Paint()..color = Colors.white24);
    final Path p = Path();
    for (int i = 0; i < 200; i++) {
      final double xv = -2.4 + i * 4.8 / 200;
      final Offset pt = Offset(o.dx + xv * 90, o.dy - MathWorkspace.f(xv) * 28);
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF3DDBAD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final Offset pt = Offset(o.dx + x * 90, o.dy - MathWorkspace.f(x) * 28);
    final double m = MathWorkspace.fp(x);
    canvas.drawLine(
      pt + Offset(-40, 40 * m / 3),
      pt + Offset(40, -40 * m / 3),
      Paint()
        ..color = const Color(0xFFFFB74D)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(pt, 7, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CalcPainter old) => old.x != x;
}
