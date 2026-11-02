import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

class _DissectionStep {
  const _DissectionStep({
    required this.title,
    required this.instruction,
    required this.requiredTool,
    required this.aiLine,
  });

  final String title;
  final String instruction;
  final String requiredTool;
  final String aiLine;
}

/// Guided dissection simulator — choose tools, complete incision steps, identify organs.
class BiologyDissectionScreen extends StatefulWidget {
  const BiologyDissectionScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyDissectionScreen> createState() => _BiologyDissectionScreenState();
}

class _BiologyDissectionScreenState extends State<BiologyDissectionScreen> {
  String _specimen = 'Frog';
  String _tool = 'Scalpel';
  int _step = 0;
  final Set<String> _identified = <String>{};
  String? _feedback;
  bool _incisionMade = false;

  static const List<String> _tools = <String>[
    'Scalpel',
    'Forceps',
    'Scissors',
    'Probe',
  ];

  static const List<String> _organs = <String>[
    'Heart',
    'Lungs',
    'Liver',
    'Stomach',
    'Intestine',
    'Kidney',
  ];

  static const List<_DissectionStep> _steps = <_DissectionStep>[
    _DissectionStep(
      title: 'Step 1 · First incision',
      instruction: 'Make a shallow midline incision through the ventral skin only.',
      requiredTool: 'Scalpel',
      aiLine: 'Professor: Scalpel ready. Keep the blade shallow — avoid deep organ damage.',
    ),
    _DissectionStep(
      title: 'Step 2 · Open the body wall',
      instruction: 'Cut body wall carefully and pin the flaps open.',
      requiredTool: 'Scissors',
      aiLine: 'Professor: Switch to scissors for controlled cutting of the wall.',
    ),
    _DissectionStep(
      title: 'Step 3 · Separate tissue',
      instruction: 'Use forceps to lift membrane and expose organs.',
      requiredTool: 'Forceps',
      aiLine: 'Professor: Forceps — grasp fascia gently and lift without tearing vessels.',
    ),
    _DissectionStep(
      title: 'Step 4 · Probe structures',
      instruction: 'Probe around the heart and digestive tract to identify relationships.',
      requiredTool: 'Probe',
      aiLine: 'Professor: Probe to explore cavities. Name organs before moving them.',
    ),
    _DissectionStep(
      title: 'Step 5 · Identify & quiz',
      instruction: 'Identify at least four organs and answer placement questions aloud.',
      requiredTool: 'Probe',
      aiLine: 'Professor: Tap organs to confirm. Relate structure to function from lecture.',
    ),
  ];

  String get _asset {
    switch (_specimen) {
      case 'Heart':
        return 'assets/anatomy/heart_real.png';
      case 'Eye':
        return 'assets/anatomy/neuron_real.png';
      case 'Flower':
        return 'assets/biology/plant_cell.svg';
      case 'Fish':
        return 'assets/anatomy/organs_real.png';
      default:
        return 'assets/anatomy/organs_labeled.png';
    }
  }

  void _advanceStep() {
    final _DissectionStep current = _steps[_step];
    if (_tool != current.requiredTool) {
      setState(() {
        _feedback =
            'Professor: Wrong instrument. This step needs the ${current.requiredTool}.';
      });
      return;
    }
    setState(() {
      _feedback = null;
      _incisionMade = true;
      if (_step < _steps.length - 1) {
        _step += 1;
        _feedback = _steps[_step].aiLine;
      } else {
        _feedback =
            'Professor: Dissection path complete. Finish organ IDs to lock mastery.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final _DissectionStep current = _steps[_step];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          '$_specimen Dissection',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: c.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(Icons.record_voice_over, color: c.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _feedback ?? current.aiLine,
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  children: <String>['Frog', 'Fish', 'Heart', 'Eye', 'Flower'].map((String s) {
                    return ChoiceChip(
                      label: Text(s),
                      selected: _specimen == s,
                      onSelected: (_) => setState(() {
                        _specimen = s;
                        _step = 0;
                        _identified.clear();
                        _incisionMade = false;
                        _feedback = null;
                      }),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: c.primary.withValues(alpha: 0.45), width: 2),
                    color: c.surface,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Opacity(
                          opacity: _incisionMade ? 1 : 0.85,
                          child: ColorFiltered(
                            colorFilter: _incisionMade
                                ? const ColorFilter.mode(
                                    Color(0x33EF4444),
                                    BlendMode.srcATop,
                                  )
                                : const ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.srcATop,
                                  ),
                            child: _asset.toLowerCase().endsWith('.svg')
                                ? SvgPicture.asset(
                                    _asset,
                                    height: 170,
                                    placeholderBuilder: (_) => Icon(
                                      Icons.pets,
                                      size: 100,
                                      color: c.primary,
                                    ),
                                  )
                                : Image.asset(
                                    _asset,
                                    height: 170,
                                    fit: BoxFit.contain,
                                    errorBuilder: (BuildContext context, Object error, StackTrace? stack) => Icon(
                                      Icons.pets,
                                      size: 100,
                                      color: c.primary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (_incisionMade)
                        Positioned(
                          left: 40,
                          right: 40,
                          top: 40,
                          child: CustomPaint(
                            size: const Size(double.infinity, 140),
                            painter: _IncisionPainter(c.primary),
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
                            'Tool: $_tool',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('Instruments', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tools.map((String t) {
                    return FilterChip(
                      avatar: Icon(_toolIcon(t), size: 18),
                      label: Text(t),
                      selected: _tool == t,
                      onSelected: (_) => setState(() => _tool = t),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(current.title, style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(current.instruction, style: TextStyle(height: 1.4, color: c.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        'Required tool: ${current.requiredTool}',
                        style: TextStyle(color: c.accent, fontWeight: FontWeight.w800, fontSize: 12.5),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _advanceStep,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_step >= _steps.length - 1 ? 'Confirm step' : 'Perform step'),
                        style: FilledButton.styleFrom(backgroundColor: c.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Identify organs (${_identified.length}/${_organs.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _organs.map((String o) {
                    final bool done = _identified.contains(o);
                    return ActionChip(
                      avatar: Icon(done ? Icons.check_circle : Icons.touch_app, size: 18),
                      label: Text(o),
                      backgroundColor: done ? c.success.withValues(alpha: 0.2) : null,
                      onPressed: () => setState(() {
                        _identified.add(o);
                        _feedback =
                            'Professor: Correct — locate $o relative to neighbors. Note blood supply.';
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_step + 1) / _steps.length,
                  minHeight: 6,
                  color: c.primary,
                  backgroundColor: c.border,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _identified.length >= 4 && _step >= _steps.length - 1
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Complete dissection', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            )
          : null,
    );
  }

  IconData _toolIcon(String t) {
    switch (t) {
      case 'Forceps':
        return Icons.push_pin;
      case 'Scissors':
        return Icons.content_cut;
      case 'Probe':
        return Icons.near_me;
      default:
        return Icons.straighten;
    }
  }
}

class _IncisionPainter extends CustomPainter {
  _IncisionPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.5, 10), Offset(size.width * 0.5, size.height - 10), p);
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.35),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _IncisionPainter oldDelegate) => false;
}
