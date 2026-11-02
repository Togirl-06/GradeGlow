import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';
import 'biology_dissection_screen.dart';
import 'biology_microscope_screen.dart';

/// Full-screen Virtual Experiment workspace with live variables and graphs.
class BiologyVirtualLabScreen extends StatefulWidget {
  const BiologyVirtualLabScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyVirtualLabScreen> createState() => _BiologyVirtualLabScreenState();
}

class _BiologyVirtualLabScreenState extends State<BiologyVirtualLabScreen> {
  int _mode = 0; // 0 experiment, 1 method, 2 data
  double _temp = 24;
  double _water = 70;
  double _light = 70;
  double _co2 = 55;
  double _ph = 7;
  bool _running = false;
  int _tick = 0;
  Timer? _timer;
  String? _aiLine;
  String? _hypothesis;
  int? _dataAnswer;
  String? _dataFeedback;
  final TextEditingController _hypothesisController = TextEditingController();
  final List<double> _o2History = <double>[];
  final List<double> _growthHistory = <double>[];
  final List<double> _atpHistory = <double>[];

  @override
  void initState() {
    super.initState();
    _aiLine =
        'Professor: Adjust light, water, CO₂, and temperature — then press Start. '
        'Watch the plant and the live graph respond.';
    _snapshot();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hypothesisController.dispose();
    super.dispose();
  }

  bool get _isPhoto {
    final String t = widget.path.lesson.title.toLowerCase();
    return t.contains('photo') || t.contains('plant') || t.contains('leaf');
  }

  bool get _isEnzyme {
    final String t = widget.path.lesson.title.toLowerCase();
    return t.contains('enzyme');
  }

  double get _photoRate {
    final double lightF = (_light / 100).clamp(0.05, 1);
    final double co2F = (_co2 / 100).clamp(0.05, 1);
    final double waterF = (_water / 100).clamp(0.05, 1);
    final double tempF = (1 - ((_temp - 25).abs() / 35)).clamp(0.05, 1);
    return (lightF * co2F * waterF * tempF).clamp(0.02, 1);
  }

  double get _enzymeRate {
    return (1 - ((_temp - 37).abs() / 40) - ((_ph - 7).abs() / 7)).clamp(0.05, 1);
  }

  double get _rate => _isEnzyme ? _enzymeRate : _photoRate;

  bool get _wilted => _water < 25 || _temp > 42 || _light < 8;

  String get _plantEmoji {
    if (_wilted) return '🥀';
    if (_rate > 0.7) return '🌿';
    if (_rate > 0.4) return '🌱';
    return '🪴';
  }

  void _snapshot() {
    final double r = _rate;
    _o2History.add(r * 100);
    _growthHistory.add(r * 80 + (_water / 5));
    _atpHistory.add(r * 90);
    if (_o2History.length > 24) {
      _o2History.removeAt(0);
      _growthHistory.removeAt(0);
      _atpHistory.removeAt(0);
    }
  }

  void _start() {
    if (_running) return;
    setState(() {
      _running = true;
      _aiLine = 'Professor: Experiment running. Change a variable and watch the response curve shift.';
    });
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() {
        _tick += 1;
        _snapshot();
        if (_wilted && _tick % 4 == 0) {
          _aiLine =
              'Professor: Stress response — tissue wilt / low water potential. Recover water or cool temperature.';
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _aiLine = 'Professor: Paused. Note your last readings before changing conditions.';
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _tick = 0;
      _temp = 24;
      _water = 70;
      _light = 70;
      _co2 = 55;
      _ph = 7;
      _o2History
        ..clear()
        ..add(50);
      _growthHistory
        ..clear()
        ..add(40);
      _atpHistory
        ..clear()
        ..add(45);
      _aiLine = 'Professor: Reset to baseline conditions.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final String title = _isEnzyme
        ? 'Enzyme Kinetics Experiment'
        : _isPhoto
            ? 'Photosynthesis Experiment'
            : '${widget.path.lesson.title} Experiment';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ),
      body: Column(
        children: <Widget>[
          if (_aiLine != null)
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: <Widget>[
                _modeChip(c, 0, 'Experiment'),
                const SizedBox(width: 6),
                _modeChip(c, 1, 'Method'),
                const SizedBox(width: 6),
                _modeChip(c, 2, 'Data analysis'),
                const Spacer(),
                IconButton(
                  tooltip: 'Microscope',
                  onPressed: () => Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => BiologyMicroscopeScreen(path: widget.path),
                    ),
                  ),
                  icon: Icon(Icons.biotech, color: c.primary),
                ),
                IconButton(
                  tooltip: 'Dissection',
                  onPressed: () => Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => BiologyDissectionScreen(path: widget.path),
                    ),
                  ),
                  icon: Icon(Icons.content_cut, color: c.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: _mode == 0
                ? _buildExperiment(c)
                : _mode == 1
                    ? _buildMethod(c)
                    : _buildData(c),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _tick > 0 || _dataFeedback != null || (_hypothesis?.length ?? 0) > 8
                ? () => Navigator.of(context).pop(true)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: c.success,
              foregroundColor: Colors.white,
              disabledBackgroundColor: c.border,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Complete experiment · +${BioLessonActivityKind.virtualLab.xpReward} XP',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeChip(BiologyDegreeColors c, int mode, String label) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _mode == mode,
      onSelected: (_) => setState(() => _mode = mode),
      selectedColor: c.primary.withValues(alpha: 0.35),
    );
  }

  Widget _buildExperiment(BiologyDegreeColors c) {
    final double r = _rate;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.primary.withValues(alpha: 0.4), width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color.lerp(const Color(0xFF87CEEB), const Color(0xFFFFF59D), _light / 100)!,
                Color.lerp(const Color(0xFF1B5E20), const Color(0xFF795548), _wilted ? 0.7 : 0)!,
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: AnimatedScale(
                  scale: 0.85 + (r * 0.35),
                  duration: const Duration(milliseconds: 400),
                  child: Text(_plantEmoji, style: TextStyle(fontSize: 72 + (r * 20))),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _running ? 'LIVE · t=$_tick' : 'READY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              if (_wilted)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Text(
                    'Stress: wilting / reduced turgor',
                    style: TextStyle(
                      color: Colors.orange.shade100,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _slider(c, 'Light intensity', _light, 0, 100, '%', (double v) {
          setState(() {
            _light = v;
            if (_running) _snapshot();
          });
        }),
        _slider(c, 'Water', _water, 0, 100, '%', (double v) {
          setState(() {
            _water = v;
            if (_running) _snapshot();
          });
        }),
        if (!_isEnzyme)
          _slider(c, 'CO₂', _co2, 0, 100, '%', (double v) {
            setState(() {
              _co2 = v;
              if (_running) _snapshot();
            });
          }),
        if (_isEnzyme)
          _slider(c, 'pH', _ph, 1, 14, '', (double v) {
            setState(() {
              _ph = v;
              if (_running) _snapshot();
            });
          }),
        _slider(c, 'Temperature', _temp, 0, 50, '°C', (double v) {
          setState(() {
            _temp = v;
            if (_running) _snapshot();
          });
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.35)),
          child: Column(
            children: <Widget>[
              _metricRow(c, 'Oxygen produced', r, Icons.air),
              _metricRow(c, 'Growth rate', (r * 0.9 + _water / 500).clamp(0, 1), Icons.trending_up),
              _metricRow(c, 'ATP / energy', r * 0.95, Icons.bolt),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Live graph', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: CustomPaint(
            painter: _MultiSeriesPainter(
              series: <List<double>>[_o2History, _growthHistory, _atpHistory],
              colors: <Color>[c.primary, c.accent, const Color(0xFFF59E0B)],
            ),
            child: Container(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Green = O₂ · Cyan = growth · Amber = ATP',
          style: TextStyle(color: c.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: _running ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: FilledButton.styleFrom(backgroundColor: c.primary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _running ? _pause : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricRow(BiologyDegreeColors c, String label, double value, IconData icon) {
    final String arrow = value > 0.55 ? '↑' : value < 0.3 ? '↓' : '→';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(
            '${(value * 100).round()}% $arrow',
            style: TextStyle(
              color: value > 0.55 ? c.success : (value < 0.3 ? Colors.orange : c.textSecondary),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    BiologyDegreeColors c,
    String label,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label  ${value.round()}$unit',
          style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w800, fontSize: 12.5),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: c.primary,
        ),
      ],
    );
  }

  Widget _buildMethod(BiologyDegreeColors c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Scientific method for ${widget.path.lesson.title}',
          style: TextStyle(color: c.primary, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _hypothesisController,
          decoration: const InputDecoration(
            labelText: 'Hypothesis',
            hintText: 'If … then … because …',
            border: OutlineInputBorder(),
          ),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        Text(
          '1 Question → 2 Hypothesis → 3 IV / DV / Controls → 4 Procedure → 5 Data → 6 Conclusion',
          style: TextStyle(color: c.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () {
            setState(() {
              _hypothesis = _hypothesisController.text.trim();
              _aiLine = (_hypothesis == null || _hypothesis!.length < 8)
                  ? 'Professor: Strengthen the hypothesis — If / Then / Because, and name IV + DV.'
                  : 'Professor: Hypothesis logged. Keep controls constant while you sweep one variable.';
            });
          },
          style: FilledButton.styleFrom(backgroundColor: c.primary),
          child: const Text('Check design', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Widget _buildData(BiologyDegreeColors c) {
    const List<double> growth = <double>[2, 5, 12, 28, 45, 52, 55, 56];
    const List<String> options = <String>[
      'Temperature dropped suddenly',
      'Lack of nutrients / waste buildup',
      'Oxygen became limiting',
      'A beneficial mutation appeared',
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Analyze the Results', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          'Graph of bacterial growth (relative units)',
          style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _MultiSeriesPainter(
              series: <List<double>>[growth],
              colors: <Color>[c.primary],
            ),
            child: Container(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Question 1 — Why did growth slow after Hour 8?',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...List<Widget>.generate(options.length, (int i) {
          final bool selected = _dataAnswer == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _dataFeedback == null
                    ? () => setState(() => _dataAnswer = i)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? c.primary : c.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '${String.fromCharCode(65 + i)}) ${options[i]}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          );
        }),
        if (_dataFeedback == null)
          FilledButton(
            onPressed: _dataAnswer == null
                ? null
                : () => setState(() {
                      final bool ok = _dataAnswer == 1;
                      _dataFeedback = ok
                          ? 'Professor: Correct — stationary phase usually reflects nutrient limit and waste. Cite the plateau on the graph.'
                          : 'Professor: Re-read the plateau. Temperature / O₂ matter, but the classic lab explanation is nutrient depletion / waste.';
                      _aiLine = _dataFeedback;
                    }),
            style: FilledButton.styleFrom(backgroundColor: c.primary),
            child: const Text('Check interpretation', style: TextStyle(fontWeight: FontWeight.w900)),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
            child: Text(_dataFeedback!, style: TextStyle(height: 1.4, color: c.textPrimary.withValues(alpha: 0.9))),
          ),
      ],
    );
  }
}

class _MultiSeriesPainter extends CustomPainter {
  _MultiSeriesPainter({required this.series, required this.colors});

  final List<List<double>> series;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = colors.first.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axis);
    canvas.drawLine(Offset.zero, Offset(0, size.height), axis);

    double maxV = 1;
    for (final List<double> s in series) {
      for (final double v in s) {
        maxV = math.max(maxV, v);
      }
    }

    for (var si = 0; si < series.length; si++) {
      final List<double> values = series[si];
      if (values.length < 2) continue;
      final Path path = Path();
      for (var i = 0; i < values.length; i++) {
        final double x = size.width * (i / (values.length - 1));
        final double y = size.height - (values[i] / maxV) * size.height * 0.92;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[si % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MultiSeriesPainter oldDelegate) => true;
}
