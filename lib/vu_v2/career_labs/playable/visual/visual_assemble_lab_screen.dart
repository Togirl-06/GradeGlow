import 'package:flutter/material.dart';

import 'visual_diagram_canvas.dart';
import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Drag parts into named assembly slots.
class VisualAssembleLabScreen extends StatefulWidget {
  const VisualAssembleLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualAssembleLabScreen> createState() => _VisualAssembleLabScreenState();
}

class _VisualAssembleLabScreenState extends State<VisualAssembleLabScreen> {
  final Map<String, String> _slotToPart = <String, String>{};
  String? _flashWrong;

  VisualLabSpec get spec => widget.spec;

  bool get _allFilled =>
      spec.slots.isNotEmpty && _slotToPart.length == spec.slots.length;

  bool get _allCorrect {
    for (final AssembleSlot s in spec.slots) {
      if (_slotToPart[s.id] != s.correctPartId) return false;
    }
    return _allFilled;
  }

  String _partLabel(String partId) {
    for (final AssemblePart p in spec.parts) {
      if (p.id == partId) return p.label;
    }
    return partId;
  }

  Future<void> _submit() async {
    if (!_allCorrect) {
      setState(() {
        for (final AssembleSlot s in spec.slots) {
          if (_slotToPart[s.id] != s.correctPartId) _flashWrong = s.id;
        }
      });
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _flashWrong = null);
      if (!mounted) return;
      await showVisualLabResult(
        context: context,
        spec: spec,
        passed: false,
        body: 'Assembly mapping is incomplete or incorrect. Re-seat the parts.',
      );
      return;
    }
    if (!mounted) return;
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: true,
      body: 'Assembly validated. Every slot holds the correct component.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> used = _slotToPart.values.toList();

    return VisualLabShell(
      spec: spec,
      badgeLabel: 'ASSEMBLE',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: _allCorrect ? 'FINISH ASSEMBLY' : 'VALIDATE',
        onPressed: _allFilled ? _submit : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Stack(
                children: <Widget>[
                  VisualDiagramCanvas(
                    diagramTitle: spec.diagramTitle,
                    accent: spec.accent,
                    hotspots: const <Hotspot>[],
                  ),
                  for (final AssembleSlot slot in spec.slots)
                    Align(
                      alignment: Alignment(slot.fx * 2 - 1, slot.fy * 2 - 1),
                      child: DragTarget<String>(
                        onAcceptWithDetails: (DragTargetDetails<String> d) {
                          setState(() => _slotToPart[slot.id] = d.data);
                        },
                        builder: (BuildContext context, List<String?> pending, _) {
                          final bool highlight = pending.isNotEmpty;
                          final String? partId = _slotToPart[slot.id];
                          final bool wrong = _flashWrong == slot.id;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 110,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: wrong
                                  ? Colors.redAccent.withValues(alpha: 0.35)
                                  : highlight
                                      ? spec.accent.withValues(alpha: 0.35)
                                      : Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: wrong
                                    ? Colors.redAccent
                                    : spec.accent.withValues(alpha: 0.55),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  slot.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  partId == null ? 'Drop part' : _partLabel(partId),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: partId == null
                                        ? Colors.white38
                                        : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: spec.parts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int i) {
                  final AssemblePart part = spec.parts[i];
                  final bool taken = used.contains(part.id);
                  return Draggable<String>(
                    data: part.id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _partChip(part, glowing: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.25,
                      child: _partChip(part),
                    ),
                    child: Opacity(
                      opacity: taken ? 0.35 : 1,
                      child: _partChip(part),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partChip(AssemblePart part, {bool glowing = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: glowing ? spec.accent : spec.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spec.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(part.glyph, style: const TextStyle(fontSize: 18)),
          Text(
            part.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: glowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
