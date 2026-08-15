import 'package:flutter/material.dart';

import 'visual_diagram_canvas.dart';
import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Drag / type / annotate labels onto diagram hotspots.
class VisualLabelLabScreen extends StatefulWidget {
  const VisualLabelLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualLabelLabScreen> createState() => _VisualLabelLabScreenState();
}

class _VisualLabelLabScreenState extends State<VisualLabelLabScreen> {
  late final List<String> _bank;
  final Map<String, String> _placed = <String, String>{};
  String? _selectedHotspot;
  final TextEditingController _typeCtrl = TextEditingController();
  final List<String> _annotations = <String>[];
  String? _flashWrong;

  VisualLabSpec get spec => widget.spec;
  LabelDifficulty get diff => spec.difficulty;

  @override
  void initState() {
    super.initState();
    final List<String> labels = spec.hotspots.map((Hotspot h) => h.correctLabel).toList();
    if (diff == LabelDifficulty.beginner) {
      _bank = List<String>.from(labels);
    } else if (diff == LabelDifficulty.intermediate) {
      _bank = List<String>.from(spec.wordBank.isNotEmpty ? spec.wordBank : labels)..shuffle();
    } else {
      _bank = List<String>.from(spec.wordBank.isNotEmpty ? spec.wordBank : labels)..shuffle();
    }
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  bool get _allCorrect {
    if (spec.hotspots.isEmpty) return false;
    for (final Hotspot h in spec.hotspots) {
      final String? v = _placed[h.id];
      if (v == null || v.toLowerCase().trim() != h.correctLabel.toLowerCase().trim()) {
        return false;
      }
    }
    return true;
  }

  void _placeOnHotspot(String hotspotId, String label) {
    setState(() {
      _placed[hotspotId] = label;
      _selectedHotspot = hotspotId;
    });
  }

  Future<void> _submit() async {
    if (!_allCorrect) {
      setState(() {
        for (final Hotspot h in spec.hotspots) {
          final String? v = _placed[h.id];
          if (v == null ||
              v.toLowerCase().trim() != h.correctLabel.toLowerCase().trim()) {
            _flashWrong = h.id;
          }
        }
      });
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) setState(() => _flashWrong = null);
      if (!mounted) return;
      await showVisualLabResult(
        context: context,
        spec: spec,
        passed: false,
        body: 'Some labels are still off. Zoom the diagram and match every hotspot.',
      );
      return;
    }
    if (!mounted) return;
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: true,
      body: 'Every structure labeled correctly. Anatomy check passed.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _matchAnnotations() async {
    // Expert: annotations must cover each correct label (order-free).
    final Set<String> need =
        spec.hotspots.map((Hotspot h) => h.correctLabel.toLowerCase().trim()).toSet();
    final Set<String> have =
        _annotations.map((String a) => a.toLowerCase().trim()).toSet();
    final bool ok = need.every(have.contains) && have.length >= need.length;
    if (!ok) {
      await showVisualLabResult(
        context: context,
        spec: spec,
        passed: false,
        body: 'Your annotation list must include every structure name once.',
      );
      return;
    }
    // Auto-place for scoring display
    for (final Hotspot h in spec.hotspots) {
      _placed[h.id] = h.correctLabel;
    }
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: true,
      body: 'Expert annotate list matched the diagram. Cleared.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool identifyMode = spec.kind == VisualLabKind.identify;

    return VisualLabShell(
      spec: spec,
      badgeLabel: identifyMode ? 'IDENTIFY' : 'LABEL',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: diff == LabelDifficulty.expert
            ? 'MATCH ANNOTATIONS'
            : (_allCorrect ? 'FINISH LAB' : 'CHECK LABELS'),
        onPressed: diff == LabelDifficulty.expert ? _matchAnnotations : _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: VisualDiagramCanvas(
                diagramTitle: spec.diagramTitle,
                accent: spec.accent,
                hotspots: spec.hotspots,
                selectedHotspotId: _selectedHotspot,
                placedLabels: _placed,
                flashWrongId: _flashWrong,
                onHotspotTap: (Hotspot h) {
                  setState(() => _selectedHotspot = h.id);
                  if (identifyMode && spec.correctIdentifyId != null) {
                    final bool ok = h.id == spec.correctIdentifyId;
                    if (ok) {
                      _placed[h.id] = h.correctLabel;
                      final NavigatorState nav = Navigator.of(context);
                      showVisualLabResult(
                        context: context,
                        spec: spec,
                        passed: true,
                        body: 'Correct identification: ${h.correctLabel}.',
                      ).then((_) {
                        if (!mounted) return;
                        nav.pop(true);
                      });
                    } else {
                      setState(() => _flashWrong = h.id);
                      Future<void>.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) setState(() => _flashWrong = null);
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            if (diff == LabelDifficulty.advanced && _selectedHotspot != null)
              _typeRow()
            else if (diff == LabelDifficulty.expert)
              _expertRow()
            else if (!identifyMode)
              _bankRow()
            else
              _identifyHint(),
          ],
        ),
      ),
    );
  }

  Widget _identifyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: spec.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spec.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        spec.identifyOptions.isNotEmpty
            ? 'Tap the structure that matches: ${spec.identifyOptions.join(' · ')}'
            : 'Tap the correct structure on the diagram.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
      ),
    );
  }

  Widget _bankRow() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _bank.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          final String label = _bank[i];
          final bool used = _placed.values.contains(label);
          return Draggable<String>(
            data: label,
            feedback: Material(
              color: Colors.transparent,
              child: _chip(label, glowing: true),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: _chip(label)),
            child: DragTarget<String>(
              onWillAcceptWithDetails: (_) => true,
              builder: (BuildContext context, _, _) {
                return GestureDetector(
                  onTap: () {
                    if (_selectedHotspot != null && !used) {
                      _placeOnHotspot(_selectedHotspot!, label);
                    }
                  },
                  child: Opacity(opacity: used ? 0.35 : 1, child: _chip(label)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _typeRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _typeCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type label for selected hotspot…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: spec.accent.withValues(alpha: 0.4)),
              ),
            ),
            onSubmitted: (String v) {
              if (_selectedHotspot != null && v.trim().isNotEmpty) {
                _placeOnHotspot(_selectedHotspot!, v.trim());
                _typeCtrl.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () {
            if (_selectedHotspot != null && _typeCtrl.text.trim().isNotEmpty) {
              _placeOnHotspot(_selectedHotspot!, _typeCtrl.text.trim());
              _typeCtrl.clear();
            }
          },
          style: IconButton.styleFrom(backgroundColor: spec.accent),
          icon: const Icon(Icons.check, color: Colors.black),
        ),
      ],
    );
  }

  Widget _expertRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _typeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Free annotate structure name…',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.35),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (String v) {
                  if (v.trim().isEmpty) return;
                  setState(() {
                    _annotations.add(v.trim());
                    _typeCtrl.clear();
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {
                if (_typeCtrl.text.trim().isEmpty) return;
                setState(() {
                  _annotations.add(_typeCtrl.text.trim());
                  _typeCtrl.clear();
                });
              },
              icon: Icon(Icons.add, color: spec.accent),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _annotations
              .map(
                (String a) => Chip(
                  label: Text(a),
                  onDeleted: () => setState(() => _annotations.remove(a)),
                  backgroundColor: spec.accent.withValues(alpha: 0.15),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _chip(String label, {bool glowing = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: glowing ? spec.accent : spec.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spec.accent.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: glowing ? Colors.black : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
