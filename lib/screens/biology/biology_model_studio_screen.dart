import 'dart:math' as math;
import 'dart:ui' show PathMetric, PathMetrics, Tangent;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/biology_studio_data.dart';
import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

/// Full-screen 3D Exploration workspace — anatomy-software controls.
class BiologyModelStudioScreen extends StatefulWidget {
  const BiologyModelStudioScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyModelStudioScreen> createState() => _BiologyModelStudioScreenState();
}

class _BiologyModelStudioScreenState extends State<BiologyModelStudioScreen>
    with TickerProviderStateMixin {
  late BiologyModelAsset _model;
  BiologyOrganelle? _selected;
  double _scale = 1;
  double _rotation = 0;
  int _layer = 0;
  final Set<String> _isolated = <String>{};
  bool _damaged = false;
  bool _cutaway = false;
  bool _bloodFlow = false;
  bool _showLabels = true;
  String? _aiLine;

  late final AnimationController _pulse;
  late final AnimationController _flow;

  static const List<String> _bodyLayers = <String>[
    'Skin',
    'Muscles',
    'Blood vessels',
    'Organs',
    'Bones',
  ];

  @override
  void initState() {
    super.initState();
    _model = BiologyStudioData.modelForTopic(
      widget.path.lesson.title,
      widget.path.course.id,
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _aiLine =
        'Professor: Rotate and zoom the specimen. Tap a structure for function, isolation, and related disease.';
  }

  @override
  void dispose() {
    _pulse.dispose();
    _flow.dispose();
    super.dispose();
  }

  bool get _isAnatomy =>
      _model.id == 'heart' ||
      _model.id.contains('anatomy') ||
      _model.id == 'human_body' ||
      _model.id == 'organs';

  bool get _isCell => _model.id == 'animal_cell' || _model.id == 'plant_cell';

  List<BiologyOrganelle> get _targets => _isCell
      ? BiologyStudioData.animalCellOrganelles
      : <BiologyOrganelle>[
          const BiologyOrganelle(
            name: 'Left ventricle',
            function: 'Thick chamber that pumps oxygenated blood into the aorta.',
            diseases: 'Left ventricular hypertrophy; heart failure; MI complicating wall motion.',
            color: ColorValue(0xFFEF4444),
            dx: -0.2,
            dy: 0.25,
          ),
          const BiologyOrganelle(
            name: 'Right atrium',
            function: 'Receives deoxygenated blood from the vena cava.',
            diseases: 'Atrial fibrillation; atrial septal defects.',
            color: ColorValue(0xFF3B82F6),
            dx: 0.35,
            dy: -0.2,
          ),
          const BiologyOrganelle(
            name: 'Aorta',
            function: 'Largest artery — distributes systemic blood.',
            diseases: 'Aortic aneurysm; atherosclerosis; coarctation.',
            color: ColorValue(0xFFDC2626),
            dx: 0,
            dy: -0.55,
          ),
          const BiologyOrganelle(
            name: 'Pulmonary artery',
            function: 'Carries deoxygenated blood to the lungs.',
            diseases: 'Pulmonary hypertension; embolism.',
            color: ColorValue(0xFF8B5CF6),
            dx: 0.4,
            dy: -0.35,
          ),
        ];

  void _select(BiologyOrganelle o) {
    setState(() {
      _selected = o;
      _aiLine =
          'Professor: ${o.name} — ${o.function} Related pathology: ${o.diseases}';
      if (_bloodFlow) {
        _flow.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          '3D ${_model.title}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Done · +${BioLessonActivityKind.model3d.xpReward} XP',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_aiLine != null)
            Container(
              width: double.infinity,
              color: c.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.record_voice_over, color: c.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiLine!,
                      style: TextStyle(
                        color: c.textPrimary.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    c.surfaceElevated,
                    c.surface,
                    _damaged
                        ? const Color(0xFF3F1515)
                        : c.primaryDark.withValues(alpha: 0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.primary.withValues(alpha: 0.4), width: 2),
              ),
              child: Stack(
                children: <Widget>[
                  // Grid backdrop like imaging software
                  Positioned.fill(
                    child: CustomPaint(painter: _GridPainter(c.border.withValues(alpha: 0.35))),
                  ),
                  InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(<Listenable>[_pulse, _flow]),
                        builder: (BuildContext context, _) {
                          final double pulse =
                              _selected != null ? 1 + (_pulse.value * 0.04) : 1;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_rotation)
                              ..rotateX(_cutaway ? 0.35 : 0.08),
                            child: Transform.scale(
                              scale: _scale * pulse,
                              child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Opacity(
                                  opacity: _cutaway ? 0.55 : (_damaged ? 0.7 : 1),
                                  child: ColorFiltered(
                                    colorFilter: _damaged
                                        ? const ColorFilter.mode(
                                            Color(0x88EF4444),
                                            BlendMode.srcATop,
                                          )
                                        : const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.srcATop,
                                          ),
                                    child: _model.assetPath.toLowerCase().endsWith('.svg')
                                        ? SvgPicture.asset(
                                            _model.assetPath,
                                            height: 260,
                                            fit: BoxFit.contain,
                                            placeholderBuilder: (_) => Icon(
                                              Icons.biotech,
                                              size: 120,
                                              color: c.primary,
                                            ),
                                          )
                                        : Image.asset(
                                            _model.assetPath,
                                            height: 260,
                                            fit: BoxFit.contain,
                                            errorBuilder: (BuildContext context, Object error, StackTrace? stack) => Icon(
                                              Icons.biotech,
                                              size: 120,
                                              color: c.primary,
                                            ),
                                          ),
                                  ),
                                ),
                                if (_bloodFlow)
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _BloodFlowPainter(
                                        progress: _flow.value,
                                        highlight: _selected != null,
                                      ),
                                    ),
                                  ),
                                if (_showLabels)
                                  ..._targets.map((BiologyOrganelle o) {
                                    final bool lit = _selected?.name == o.name;
                                    final bool dim =
                                        _isolated.isNotEmpty && !_isolated.contains(o.name);
                                    return Transform.translate(
                                      offset: Offset(o.dx * 110, o.dy * 110),
                                      child: GestureDetector(
                                        onTap: () => _select(o),
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: dim ? 0.25 : 1,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: lit
                                                  ? Color(o.color.value)
                                                  : c.surface.withValues(alpha: 0.92),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Color(o.color.value),
                                                width: lit ? 2 : 1,
                                              ),
                                              boxShadow: lit
                                                  ? <BoxShadow>[
                                                      BoxShadow(
                                                        color: Color(o.color.value)
                                                            .withValues(alpha: 0.55),
                                                        blurRadius: 12,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              o.name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: lit ? Colors.white : c.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _damaged ? 'DISEASED VIEW' : 'HEALTHY VIEW',
                        style: TextStyle(
                          color: _damaged ? const Color(0xFFFCA5A5) : c.primaryLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tool strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _toolRow(
                  c,
                  icon: Icons.threesixty,
                  label: 'Rotate',
                  child: Slider(
                    value: _rotation,
                    min: -math.pi,
                    max: math.pi,
                    onChanged: (double v) => setState(() => _rotation = v),
                    activeColor: c.primary,
                  ),
                ),
                _toolRow(
                  c,
                  icon: Icons.zoom_in,
                  label: 'Zoom',
                  child: Slider(
                    value: _scale,
                    min: 0.7,
                    max: 2.2,
                    onChanged: (double v) => setState(() => _scale = v),
                    activeColor: c.primary,
                  ),
                ),
                if (_isAnatomy)
                  _toolRow(
                    c,
                    icon: Icons.layers,
                    label: 'Layer · ${_bodyLayers[_layer]}',
                    child: Slider(
                      value: _layer.toDouble(),
                      min: 0,
                      max: (_bodyLayers.length - 1).toDouble(),
                      divisions: _bodyLayers.length - 1,
                      onChanged: (double v) => setState(() {
                        _layer = v.round();
                        _aiLine = 'Professor: Viewing ${_bodyLayers[_layer]} layer.';
                      }),
                      activeColor: c.primary,
                    ),
                  ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    FilterChip(
                      label: const Text('Cutaway'),
                      selected: _cutaway,
                      onSelected: (bool v) => setState(() {
                        _cutaway = v;
                        _aiLine = v
                            ? 'Professor: Cutaway enabled — internal chambers exposed.'
                            : 'Professor: External surface view.';
                      }),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    ),
                    FilterChip(
                      label: const Text('Blood flow'),
                      selected: _bloodFlow,
                      onSelected: (bool v) => setState(() {
                        _bloodFlow = v;
                        if (v) {
                          _flow.repeat();
                        } else {
                          _flow.stop();
                          _flow.value = 0;
                        }
                      }),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    ),
                    FilterChip(
                      label: const Text('Show labels'),
                      selected: _showLabels,
                      onSelected: (bool v) => setState(() => _showLabels = v),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    ),
                    FilterChip(
                      label: Text(_damaged ? 'Diseased' : 'Healthy'),
                      selected: _damaged,
                      onSelected: (bool v) => setState(() {
                        _damaged = v;
                        _aiLine = v
                            ? 'Professor: Pathological overlay — compare morphology and function loss.'
                            : 'Professor: Healthy reference anatomy.';
                      }),
                      selectedColor: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: BiologyStudioData.models.map((BiologyModelAsset m) {
                      final bool selected = m.id == _model.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(m.title),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _model = m;
                            _selected = null;
                            _isolated.clear();
                          }),
                          selectedColor: c.primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_selected != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(14),
              decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.45)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _selected!.name,
                    style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text('Function: ${_selected!.function}',
                      style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.35)),
                  const SizedBox(height: 4),
                  Text('Related diseases: ${_selected!.diseases}',
                      style: TextStyle(color: c.accent, fontSize: 12.5, height: 1.35)),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          if (_isolated.contains(_selected!.name)) {
                            _isolated.remove(_selected!.name);
                          } else {
                            _isolated
                              ..clear()
                              ..add(_selected!.name);
                          }
                          _aiLine =
                              'Professor: ${_isolated.contains(_selected!.name) ? 'Isolating' : 'Restoring context for'} ${_selected!.name}.';
                        }),
                        icon: Icon(
                          _isolated.contains(_selected!.name)
                              ? Icons.visibility
                              : Icons.filter_center_focus,
                          size: 18,
                        ),
                        label: Text(
                          _isolated.contains(_selected!.name) ? 'Show all' : 'Isolate',
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isAnatomy || _model.id == 'heart')
                        OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _bloodFlow = true;
                            _flow.repeat();
                            _aiLine =
                                'Professor: Blood path through ${_selected!.name} — watch timing relative to systole.';
                          }),
                          icon: const Icon(Icons.bloodtype, size: 18),
                          label: const Text('Animate flow'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _toolRow(
    BiologyDegreeColors c, {
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: c.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 88,
          child: Text(label, style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w800, fontSize: 12)),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 0.6;
    const double step = 28;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}

class _BloodFlowPainter extends CustomPainter {
  _BloodFlowPainter({required this.progress, required this.highlight});

  final double progress;
  final bool highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Path path = Path()
      ..moveTo(center.dx - 40, center.dy + 30)
      ..quadraticBezierTo(center.dx - 60, center.dy, center.dx - 20, center.dy - 40)
      ..quadraticBezierTo(center.dx + 30, center.dy - 70, center.dx + 50, center.dy - 10)
      ..quadraticBezierTo(center.dx + 40, center.dy + 50, center.dx - 10, center.dy + 40);

    final Paint trail = Paint()
      ..color = const Color(0x88EF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlight ? 4 : 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, trail);

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      final double d = metric.length * progress;
      final Tangent? t = metric.getTangentForOffset(d);
      if (t != null) {
        canvas.drawCircle(
          t.position,
          highlight ? 7 : 5,
          Paint()..color = const Color(0xFFFF6B6B),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BloodFlowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.highlight != highlight;
}
