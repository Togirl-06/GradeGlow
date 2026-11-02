import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'science_asset_catalog.dart';
import 'science_drawing_canvas.dart';
import 'science_lab_theme.dart';
import 'science_notebook_store.dart';

enum ScienceImageMode { view, label, annotate, measure, quiz, explain }

class ScienceImageHotspot {
  const ScienceImageHotspot({
    required this.id,
    required this.label,
    required this.fx,
    required this.fy,
  });

  final String id;
  final String label;
  final double fx;
  final double fy;
}

/// Work with a scientific image: VIEW · LABEL · ANNOTATE · MEASURE · QUIZ · EXPLAIN.
class ScienceInteractiveImageLab extends StatefulWidget {
  const ScienceInteractiveImageLab({
    super.key,
    required this.theme,
    required this.asset,
    required this.title,
    required this.crumbs,
    this.hotspots = const <ScienceImageHotspot>[],
    this.wordBank = const <String>[],
    this.notebook,
    this.explainText =
        'Study the structures carefully. Switch to LABEL or ANNOTATE to work the image.',
    this.embedded = false,
    this.onComplete,
  });

  final ScienceLabTheme theme;
  final ScienceLabAsset asset;
  final String title;
  final List<String> crumbs;
  final List<ScienceImageHotspot> hotspots;
  final List<String> wordBank;
  final ScienceNotebookStore? notebook;
  final String explainText;
  final bool embedded;
  final VoidCallback? onComplete;

  @override
  State<ScienceInteractiveImageLab> createState() =>
      _ScienceInteractiveImageLabState();
}

class _ScienceInteractiveImageLabState extends State<ScienceInteractiveImageLab> {
  ScienceImageMode _mode = ScienceImageMode.view;
  bool _useDiagram = false;
  int? _selected;
  final Map<int, String> _placed = <int, String>{};
  String? _feedback;
  Offset? _measureA;
  Offset? _measureB;
  final TransformationController _zoom = TransformationController();

  ScienceLabTheme get t => widget.theme;

  String get _path {
    if (_useDiagram && widget.asset.diagramPath != null) {
      return widget.asset.diagramPath!;
    }
    return widget.asset.assetPath;
  }

  Future<void> _checkLabels() async {
    if (widget.hotspots.isEmpty) return;
    if (_placed.length < widget.hotspots.length) {
      setState(() => _feedback = 'Label every numbered marker.');
      return;
    }
    int ok = 0;
    for (int i = 0; i < widget.hotspots.length; i++) {
      if (_placed[i + 1] == widget.hotspots[i].label) ok++;
    }
    if (ok < widget.hotspots.length) {
      setState(() => _feedback = '$ok / ${widget.hotspots.length} correct. Retry — no reveal.');
      return;
    }
    await widget.notebook?.addNote(
      '${widget.title}: labeled ${widget.hotspots.length} structures on ${widget.asset.id}.',
    );
    if (!mounted) return;
    if (widget.embedded) {
      widget.onComplete?.call();
      setState(() => _feedback = 'Labels correct — logged to notebook.');
      return;
    }
    Navigator.pop(context, true);
  }

  Future<void> _saveAnnotate(List<DrawnStroke> strokes) async {
    await widget.notebook?.addDiagramStrokes(
      title: '${widget.title} annotation',
      strokes: strokes.map((DrawnStroke s) => s.toJson()).toList(),
      extra: <String, dynamic>{'assetId': widget.asset.id},
    );
    if (!mounted) return;
    setState(() => _feedback = 'Annotation saved to lab notebook.');
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool light =
        !widget.embedded && _mode != ScienceImageMode.annotate;
    final Widget body = Column(
      children: <Widget>[
        if (!widget.embedded) _topBar(light),
        _modeBar(),
        if (widget.asset.diagramPath != null) _viewToggle(light),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_mode == ScienceImageMode.label ||
                  _mode == ScienceImageMode.quiz)
                _wordBankPanel(light),
              Expanded(child: _stage(light)),
              if (_mode == ScienceImageMode.explain ||
                  _mode == ScienceImageMode.measure ||
                  _mode == ScienceImageMode.view)
                _infoPanel(light),
            ],
          ),
        ),
        if (_feedback != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              _feedback!,
              style: TextStyle(
                color: light ? const Color(0xFFB45309) : const Color(0xFFFBBF24),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (_mode == ScienceImageMode.label || _mode == ScienceImageMode.quiz)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _checkLabels,
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'CHECK LABELS',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFF0B1320), child: body);
    }
    return Scaffold(
      backgroundColor: light ? const Color(0xFFE8EEF5) : const Color(0xFF0B1020),
      body: SafeArea(child: body),
    );
  }

  Widget _topBar(bool light) {
    final Color ink = light ? const Color(0xFF0F172A) : Colors.white;
    return Container(
      height: 52,
      color: light ? Colors.white : const Color(0xFF121A2A),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: Icon(Icons.arrow_back, color: ink),
          ),
          Expanded(
            child: Text(
              widget.crumbs.join('  ›  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withValues(alpha: 0.75), fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Source / license',
            onPressed: _showLicense,
            icon: Icon(Icons.info_outline, color: t.accent),
          ),
        ],
      ),
    );
  }

  void _showLicense() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Image source'),
        content: Text(
          'Asset: ${widget.asset.id}\n'
          'Topic: ${widget.asset.topic}\n'
          'Kind: ${widget.asset.kind.name}\n'
          'Source: ${widget.asset.source}\n'
          'License: ${widget.asset.license}\n'
          '${widget.asset.attribution.isEmpty ? '' : 'Attribution: ${widget.asset.attribution}\n'}'
          '${widget.asset.notes}',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _modeBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: ScienceImageMode.values.map((ScienceImageMode m) {
          final bool on = _mode == m;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(m.name.toUpperCase()),
              selected: on,
              onSelected: (_) => setState(() {
                _mode = m;
                _feedback = null;
                _measureA = null;
                _measureB = null;
              }),
              selectedColor: t.accent,
              labelStyle: TextStyle(
                color: on ? Colors.black : Colors.white70,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
              backgroundColor: const Color(0xFF1E293B),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _viewToggle(bool light) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: <Widget>[
          _toggleChip('PHOTO', !_useDiagram, () => setState(() => _useDiagram = false)),
          const SizedBox(width: 8),
          _toggleChip('DIAGRAM', _useDiagram, () => setState(() => _useDiagram = true)),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool on, VoidCallback tap) {
    return ChoiceChip(
      label: Text(label),
      selected: on,
      onSelected: (_) => tap(),
      selectedColor: t.accent,
      labelStyle: TextStyle(
        color: on ? Colors.black : Colors.white70,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
      backgroundColor: const Color(0xFF1E293B),
    );
  }

  Widget _wordBankPanel(bool light) {
    return Container(
      width: 180,
      color: light ? Colors.white : const Color(0xFF151C2C),
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: <Widget>[
          Text(
            'WORD BANK',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.wordBank.map((String w) {
            final bool used = _placed.values.contains(w);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: used
                    ? t.accent.withValues(alpha: 0.2)
                    : (light ? const Color(0xFFF1F5F9) : Colors.white10),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    if (_selected == null) {
                      setState(() => _feedback = 'Tap a numbered marker first.');
                      return;
                    }
                    setState(() {
                      _placed[_selected!] = w;
                      _selected = null;
                      _feedback = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      w,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: light ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoPanel(bool light) {
    return Container(
      width: 200,
      color: light ? Colors.white : const Color(0xFF151C2C),
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: <Widget>[
          Text(
            _mode == ScienceImageMode.measure ? 'MEASURE' : 'GUIDE',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _mode == ScienceImageMode.measure
                ? 'Tap two points on the image. Relative distance is shown for practice.'
                : widget.explainText,
            style: TextStyle(
              color: light ? Colors.black54 : Colors.white70,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          if (_measureA != null && _measureB != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Span: ${(_measureA! - _measureB!).distance.toStringAsFixed(0)} px',
              style: TextStyle(
                color: t.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stage(bool light) {
    final Widget image = _buildAssetImage();
    if (_mode == ScienceImageMode.annotate) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: ScienceDrawingCanvas(
          accent: t.accent,
          onSubmit: _saveAnnotate,
          child: image,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InteractiveViewer(
          transformationController: _zoom,
          minScale: 0.8,
          maxScale: 5,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              return GestureDetector(
                onTapDown: (TapDownDetails d) => _onTap(d.localPosition, c.biggest),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ColoredBox(
                      color: light ? Colors.white : const Color(0xFF0B1020),
                      child: image,
                    ),
                    if (_mode == ScienceImageMode.label ||
                        _mode == ScienceImageMode.quiz)
                      ..._hotspotOverlays(c.biggest),
                    if (_measureA != null)
                      CustomPaint(
                        painter: _MeasurePainter(a: _measureA, b: _measureB, color: t.accent),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAssetImage() {
    final String path = _path;
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object e, StackTrace? s) {
        return Center(
          child: Text(
            'Asset missing: $path',
            style: const TextStyle(color: Colors.redAccent),
          ),
        );
      },
    );
  }

  List<Widget> _hotspotOverlays(Size size) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < widget.hotspots.length; i++) {
      final ScienceImageHotspot h = widget.hotspots[i];
      final int n = i + 1;
      final Offset o = Offset(h.fx * size.width, h.fy * size.height);
      final bool sel = _selected == n;
      out.add(
        Positioned(
          left: o.dx - 14,
          top: o.dy - 14,
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: sel ? t.accent : Colors.white,
                child: Text(
                  '$n',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_placed[n] != null)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: Colors.white.withValues(alpha: 0.9),
                  child: Text(
                    _placed[n]!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return out;
  }

  void _onTap(Offset p, Size size) {
    if (_mode == ScienceImageMode.measure) {
      setState(() {
        if (_measureA == null || _measureB != null) {
          _measureA = p;
          _measureB = null;
        } else {
          _measureB = p;
        }
      });
      return;
    }
    if (_mode != ScienceImageMode.label && _mode != ScienceImageMode.quiz) return;
    for (int i = 0; i < widget.hotspots.length; i++) {
      final ScienceImageHotspot h = widget.hotspots[i];
      final Offset o = Offset(h.fx * size.width, h.fy * size.height);
      if ((p - o).distance < 28) {
        setState(() {
          _selected = i + 1;
          _feedback = 'Marker #${i + 1} — pick a label from the bank.';
        });
        return;
      }
    }
  }
}

class _MeasurePainter extends CustomPainter {
  _MeasurePainter({required this.a, required this.b, required this.color});
  final Offset? a;
  final Offset? b;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (a == null) return;
    canvas.drawCircle(a!, 5, Paint()..color = color);
    if (b == null) return;
    canvas.drawCircle(b!, 5, Paint()..color = color);
    canvas.drawLine(
      a!,
      b!,
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _MeasurePainter oldDelegate) => true;
}
