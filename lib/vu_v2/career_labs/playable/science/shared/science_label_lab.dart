import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../data/diagram_misconception_store.dart';
import 'science_ai_feedback.dart';
import 'science_lab_theme.dart';
import 'science_notebook_store.dart';

enum ScienceLabelMode { easy, normal, hard, expert }

class ScienceLabelHotspot {
  const ScienceLabelHotspot({
    required this.id,
    required this.correctLabel,
    required this.fx,
    required this.fy,
    this.hint,
  });

  final String id;
  final String correctLabel;
  final double fx;
  final double fy;
  final String? hint;
}

/// Multi-mode diagram labeling with AI-style coaching on misses.
class ScienceLabelLab extends StatefulWidget {
  const ScienceLabelLab({
    super.key,
    required this.theme,
    required this.hotspots,
    required this.mode,
    this.diagramChild,
    this.diagramTitle = 'Diagram',
    this.wordBank = const <String>[],
    this.notebook,
    this.saveNoteOnComplete = false,
    this.onComplete,
    this.popOnComplete = true,
    this.diagramId,
  });

  final ScienceLabTheme theme;
  final List<ScienceLabelHotspot> hotspots;
  final ScienceLabelMode mode;
  final Widget? diagramChild;
  final String diagramTitle;
  final List<String> wordBank;
  final ScienceNotebookStore? notebook;
  final bool saveNoteOnComplete;
  final ValueChanged<bool>? onComplete;
  final bool popOnComplete;
  final String? diagramId;

  @override
  State<ScienceLabelLab> createState() => _ScienceLabelLabState();
}

class _ScienceLabelLabState extends State<ScienceLabelLab> {
  late final List<String> _bank;
  final Map<String, String> _placed = <String, String>{};
  String? _selectedId;
  String? _feedback;
  String? _flashWrong;
  final TextEditingController _typeCtrl = TextEditingController();

  ScienceLabTheme get t => widget.theme;

  @override
  void initState() {
    super.initState();
    final List<String> labels =
        widget.hotspots.map((ScienceLabelHotspot h) => h.correctLabel).toList();
    switch (widget.mode) {
      case ScienceLabelMode.easy:
        _bank = List<String>.from(labels);
      case ScienceLabelMode.normal:
        _bank = List<String>.from(
          widget.wordBank.isNotEmpty ? widget.wordBank : labels,
        )..shuffle();
      case ScienceLabelMode.hard:
        _bank = List<String>.from(
          widget.wordBank.isNotEmpty ? widget.wordBank : labels,
        )..shuffle();
      case ScienceLabelMode.expert:
        _bank = <String>[];
    }
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  bool get _allCorrect {
    if (widget.hotspots.isEmpty) return false;
    for (final ScienceLabelHotspot h in widget.hotspots) {
      final String? v = _placed[h.id];
      if (v == null || !_matches(v, h.correctLabel)) return false;
    }
    return true;
  }

  bool _matches(String a, String b) =>
      a.toLowerCase().trim() == b.toLowerCase().trim();

  ScienceLabelHotspot? _nearestOther(ScienceLabelHotspot target) {
    ScienceLabelHotspot? best;
    double bestD = double.infinity;
    for (final ScienceLabelHotspot h in widget.hotspots) {
      if (h.id == target.id) continue;
      final double d = math.sqrt(
        math.pow(h.fx - target.fx, 2) + math.pow(h.fy - target.fy, 2),
      );
      if (d < bestD) {
        bestD = d;
        best = h;
      }
    }
    return best;
  }

  void _applyLabel(String hotspotId, String label) {
    final ScienceLabelHotspot hotspot = widget.hotspots.firstWhere(
      (ScienceLabelHotspot h) => h.id == hotspotId,
    );
    final bool ok = _matches(label, hotspot.correctLabel);
    setState(() {
      _placed[hotspotId] = label.trim();
      _selectedId = hotspotId;
      if (ok) {
        _feedback = null;
        _flashWrong = null;
      } else {
        _flashWrong = hotspotId;
        final ScienceLabelHotspot? near = _nearestOther(hotspot);
        _feedback = near == null
            ? ScienceAiFeedback.wrongLabelGeneric(
                wantedLabel: hotspot.correctLabel,
                hint: hotspot.hint,
              )
            : ScienceAiFeedback.wrongLabel(
                nearLabel: near.correctLabel,
                wantedLabel: hotspot.correctLabel,
                hint: hotspot.hint,
              );
        final String? diagramId = widget.diagramId;
        if (diagramId != null) {
          String? intendedId;
          for (final ScienceLabelHotspot h in widget.hotspots) {
            if (_matches(label, h.correctLabel)) {
              intendedId = h.id;
              break;
            }
          }
          if (intendedId != null && intendedId != hotspotId) {
            unawaited(
              DiagramMisconceptionStore.instance.recordConfusion(
                diagramId: diagramId,
                tappedRegionId: hotspotId,
                targetRegionId: intendedId,
              ),
            );
          }
        }
      }
    });
    if (_allCorrect) _finish();
  }

  Future<void> _finish() async {
    if (widget.saveNoteOnComplete && widget.notebook != null) {
      final String summary = widget.hotspots
          .map((ScienceLabelHotspot h) => h.correctLabel)
          .join(', ');
      await widget.notebook!.addNote(
        'Labeled ${widget.diagramTitle}: $summary',
      );
      await widget.notebook!.awardXp(25, coins: 5);
    }
    widget.onComplete?.call(true);
    if (widget.popOnComplete && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _submitTyped() {
    final String? id = _selectedId;
    if (id == null) return;
    final String text = _typeCtrl.text.trim();
    if (text.isEmpty) return;
    _applyLabel(id, text);
    _typeCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool showBank = widget.mode == ScienceLabelMode.easy ||
        widget.mode == ScienceLabelMode.normal;
    final bool typeMode = widget.mode == ScienceLabelMode.hard ||
        widget.mode == ScienceLabelMode.expert;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        foregroundColor: Colors.white,
        title: Text('${t.emoji} Label · ${widget.mode.name}'),
        actions: <Widget>[
          if (_allCorrect)
            TextButton(
              onPressed: _finish,
              child: Text('Done', style: TextStyle(color: t.accent)),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_feedback != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.danger.withValues(alpha: 0.45)),
              ),
              child: Text(
                _feedback!,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    border: Border.all(color: t.accent.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          if (widget.diagramChild != null)
                            widget.diagramChild!
                          else
                            CustomPaint(
                              painter: _FallbackDiagramPainter(
                                title: widget.diagramTitle,
                                accent: t.accent,
                              ),
                            ),
                          for (final ScienceLabelHotspot h in widget.hotspots)
                            _HotspotPin(
                              hotspot: h,
                              accent: t.accent,
                              danger: t.danger,
                              selected: _selectedId == h.id,
                              wrong: _flashWrong == h.id,
                              label: _placed[h.id],
                              onTap: () => setState(() => _selectedId = h.id),
                              onAccept: showBank
                                  ? (String label) => _applyLabel(h.id, label)
                                  : null,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (showBank)
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: <Widget>[
                  for (final String word in _bank)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.mode == ScienceLabelMode.easy
                          ? Draggable<String>(
                              data: word,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _BankChip(
                                  word: word,
                                  accent: t.accent,
                                  dragging: true,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: _BankChip(word: word, accent: t.accent),
                              ),
                              child: _BankChip(word: word, accent: t.accent),
                            )
                          : InkWell(
                              onTap: () {
                                final String? id = _selectedId;
                                if (id == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Select a hotspot first.'),
                                    ),
                                  );
                                  return;
                                }
                                _applyLabel(id, word);
                              },
                              child: _BankChip(word: word, accent: t.accent),
                            ),
                    ),
                ],
              ),
            ),
          if (typeMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _typeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _selectedId == null
                            ? 'Select a hotspot, then type…'
                            : 'Type the label…',
                        hintStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: t.accent.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _submitTyped(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: t.accent),
                    onPressed: _submitTyped,
                    child: const Text('Place', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BankChip extends StatelessWidget {
  const _BankChip({
    required this.word,
    required this.accent,
    this.dragging = false,
  });

  final String word;
  final Color accent;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: dragging ? 0.35 : 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HotspotPin extends StatelessWidget {
  const _HotspotPin({
    required this.hotspot,
    required this.accent,
    required this.danger,
    required this.selected,
    required this.wrong,
    required this.onTap,
    this.label,
    this.onAccept,
  });

  final ScienceLabelHotspot hotspot;
  final Color accent;
  final Color danger;
  final bool selected;
  final bool wrong;
  final String? label;
  final VoidCallback onTap;
  final void Function(String label)? onAccept;

  @override
  Widget build(BuildContext context) {
    final Color ring = wrong ? danger : accent;
    Widget pin = GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: selected ? 22 : 16,
            height: selected ? 22 : 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ring.withValues(alpha: 0.85),
              boxShadow: <BoxShadow>[
                BoxShadow(color: ring.withValues(alpha: 0.45), blurRadius: 8),
              ],
            ),
          ),
          if (label != null) ...<Widget>[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ring.withValues(alpha: 0.6)),
              ),
              child: Text(
                label!,
                style: TextStyle(color: ring, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );

    if (onAccept != null) {
      pin = DragTarget<String>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (DragTargetDetails<String> d) => onAccept!(d.data),
        builder: (BuildContext context, List<String?> candidate, List<dynamic> rejected) {
          return Opacity(
            opacity: candidate.isNotEmpty ? 1 : 0.95,
            child: pin,
          );
        },
      );
    }

    return Align(
      alignment: Alignment(hotspot.fx * 2 - 1, hotspot.fy * 2 - 1),
      child: pin,
    );
  }
}

class _FallbackDiagramPainter extends CustomPainter {
  _FallbackDiagramPainter({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()..color = const Color(0xFF020617);
    canvas.drawRect(Offset.zero & size, bg);
    final Paint ring = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: size.center(Offset.zero),
          width: size.width * 0.7,
          height: size.height * 0.55,
        ),
        const Radius.circular(24),
      ),
      ring,
    );
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: accent.withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.8);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, size.height * 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant _FallbackDiagramPainter oldDelegate) =>
      oldDelegate.title != title || oldDelegate.accent != accent;
}
