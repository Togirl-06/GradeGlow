import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Unlabeled apparatus — label each piece and write its use.
class ChemistryEquipmentLabelLab extends StatefulWidget {
  const ChemistryEquipmentLabelLab({super.key});

  @override
  State<ChemistryEquipmentLabelLab> createState() =>
      _ChemistryEquipmentLabelLabState();
}

class _ChemItem {
  const _ChemItem(this.id, this.name, this.useHint, this.fx, this.fy);
  final String id;
  final String name;
  final String useHint;
  final double fx;
  final double fy;
}

class _ChemistryEquipmentLabelLabState extends State<ChemistryEquipmentLabelLab> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  static const List<_ChemItem> _items = <_ChemItem>[
    _ChemItem('erlenmeyer', 'Erlenmeyer flask', 'mixing', 0.22, 0.55),
    _ChemItem('beaker', 'Beaker', 'holding', 0.48, 0.62),
    _ChemItem('burette', 'Burette', 'titration', 0.72, 0.28),
    _ChemItem('pipette', 'Pipette', 'transfer', 0.38, 0.28),
    _ChemItem('graduated', 'Graduated cylinder', 'volume', 0.85, 0.62),
  ];

  String? _selected;
  final Map<String, String> _labels = <String, String>{};
  final Map<String, TextEditingController> _uses =
      <String, TextEditingController>{};
  String? _feedback;

  @override
  void initState() {
    super.initState();
    for (final _ChemItem i in _items) {
      _uses[i.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _uses.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _dropLabel(String itemId, String label) {
    setState(() {
      _labels[itemId] = label;
      _selected = itemId;
      _feedback = null;
    });
  }

  Future<void> _submit() async {
    int ok = 0;
    for (final _ChemItem i in _items) {
      final String? lab = _labels[i.id];
      final String use = (_uses[i.id]?.text ?? '').toLowerCase();
      final bool labelOk =
          lab != null && lab.toLowerCase() == i.name.toLowerCase();
      final bool useOk = use.contains(i.useHint) || use.length >= 8;
      if (labelOk && useOk) ok++;
    }
    if (ok < _items.length) {
      setState(() => _feedback =
          'Label every apparatus and write a short use (hint words help).');
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Not complete',
        body: 'Match each shape to its name and describe what it is used for.',
      );
      return;
    }
    await _store.addNote(
      'Equipment labeled: ${_items.map((_ChemItem i) => i.name).join(', ')}',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Bench ready',
      body: 'All apparatus labeled. Ross: “Know your glassware before you pour.”',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> bank =
        _items.map((_ChemItem i) => i.name).toList()..shuffle();

    return ScienceLabShell(
      theme: t,
      title: 'Equipment Bench',
      brief: 'Label each apparatus, then write what it is used for.',
      badgeLabel: 'BENCH',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'CHECK LABELS',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.35,
            child: sciencePanel(
              surface: t.surface,
              accent: t.accent,
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  return Stack(
                    children: <Widget>[
                      CustomPaint(
                        size: Size(c.maxWidth, c.maxHeight),
                        painter: _ApparatusPainter(accent: t.accent),
                      ),
                      ..._items.map((_ChemItem i) {
                        final bool placed = _labels.containsKey(i.id);
                        return Positioned(
                          left: i.fx * c.maxWidth - 28,
                          top: i.fy * c.maxHeight - 14,
                          child: DragTarget<String>(
                            onAcceptWithDetails: (DragTargetDetails<String> d) =>
                                _dropLabel(i.id, d.data),
                            builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
                              return GestureDetector(
                                onTap: () => setState(() => _selected = i.id),
                                child: Container(
                                  width: 56,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (_selected == i.id
                                            ? t.accent
                                            : Colors.black)
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: placed
                                          ? const Color(0xFF34D399)
                                          : t.accent,
                                    ),
                                  ),
                                  child: Text(
                                    placed ? (_labels[i.id] ?? '?') : '?',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Drag labels',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bank.map((String name) {
              return Draggable<String>(
                data: name,
                feedback: Material(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(name,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900)),
                  ),
                ),
                child: Chip(
                  label: Text(name),
                  backgroundColor: t.surface,
                  labelStyle: const TextStyle(color: Colors.white),
                  side: BorderSide(color: t.accent.withValues(alpha: 0.4)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (_selected != null) ...<Widget>[
            Text(
              'Use of ${_labels[_selected!] ?? 'selected item'}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _uses[_selected!],
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. used for mixing / measuring volume…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ApparatusPainter extends CustomPainter {
  _ApparatusPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = accent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final Paint fill = Paint()
      ..color = accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Erlenmeyer
    final Path flask = Path()
      ..moveTo(size.width * 0.14, size.height * 0.28)
      ..lineTo(size.width * 0.18, size.height * 0.28)
      ..lineTo(size.width * 0.28, size.height * 0.72)
      ..lineTo(size.width * 0.12, size.height * 0.72)
      ..close();
    canvas.drawPath(flask, fill);
    canvas.drawPath(flask, stroke);

    // Beaker
    final RRect beaker = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.38, size.height * 0.42, size.width * 0.18, size.height * 0.32),
      const Radius.circular(4),
    );
    canvas.drawRRect(beaker, fill);
    canvas.drawRRect(beaker, stroke);

    // Burette
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.08),
      Offset(size.width * 0.72, size.height * 0.55),
      stroke,
    );
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.58), 6, stroke);

    // Pipette
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.12),
      Offset(size.width * 0.38, size.height * 0.38),
      stroke..strokeWidth = 1.6,
    );

    // Graduated cylinder
    final RRect cyl = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.8, size.height * 0.38, size.width * 0.1, size.height * 0.36),
      const Radius.circular(3),
    );
    canvas.drawRRect(cyl, fill);
    canvas.drawRRect(cyl, stroke);
  }

  @override
  bool shouldRepaint(covariant _ApparatusPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
