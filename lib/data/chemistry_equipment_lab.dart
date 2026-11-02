import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'diagram_asset_registry.dart';

/// Drag-and-drop targets for chemistry bench labeling.
class DragDropLabItem {
  const DragDropLabItem({
    required this.id,
    required this.label,
    required this.hint,
    required this.center,
    required this.size,
  });

  final String id;
  final String label;
  final String hint;
  final Offset center;
  final Size size;

  Rect hitRect(Size canvasSize) {
    final double w = size.width * canvasSize.width;
    final double h = size.height * canvasSize.height;
    final Offset c = Offset(center.dx * canvasSize.width, center.dy * canvasSize.height);
    return Rect.fromCenter(center: c, width: w, height: h);
  }
}

class ChemistryEquipmentLab {
  ChemistryEquipmentLab._();

  static const List<DragDropLabItem> items = <DragDropLabItem>[
    DragDropLabItem(
      id: 'test_tube',
      label: 'Test Tube',
      hint: 'Small tube for samples and quick reactions.',
      center: Offset(0.156, 0.51),
      size: Size(0.08, 0.47),
    ),
    DragDropLabItem(
      id: 'beaker',
      label: 'Beaker',
      hint: 'Wide-mouth vessel for mixing and heating liquids.',
      center: Offset(0.312, 0.5),
      size: Size(0.13, 0.56),
    ),
    DragDropLabItem(
      id: 'flask',
      label: 'Erlenmeyer Flask',
      hint: 'Conical flask for titrations and reactions.',
      center: Offset(0.479, 0.44),
      size: Size(0.13, 0.56),
    ),
    DragDropLabItem(
      id: 'pipette',
      label: 'Pipette',
      hint: 'Transfers precise volumes of liquid.',
      center: Offset(0.635, 0.47),
      size: Size(0.06, 0.53),
    ),
    DragDropLabItem(
      id: 'burette',
      label: 'Burette',
      hint: 'Delivers precise volumes during titration.',
      center: Offset(0.771, 0.46),
      size: Size(0.08, 0.58),
    ),
  ];

  static List<DragDropLabItem> shuffledDeck(String seed) {
    final List<DragDropLabItem> deck = List<DragDropLabItem>.from(items);
    deck.shuffle(Random(seed.hashCode));
    return deck;
  }
}

/// Reusable bench canvas — real lab equipment SVG with invisible drop zones.
class ChemistryBenchCanvas extends StatelessWidget {
  const ChemistryBenchCanvas({
    super.key,
    required this.placed,
    this.highlightId,
    required this.onAccept,
  });

  final Map<String, String> placed;
  final String? highlightId;
  final void Function(String itemId, String label) onAccept;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: SvgPicture.asset(
                DiagramAssetRegistry.labEquipment,
                fit: BoxFit.contain,
              ),
            ),
            ...ChemistryEquipmentLab.items.map((DragDropLabItem item) {
              final Rect r = item.hitRect(size);
              final bool highlight = highlightId == item.id;
              final String? label = placed[item.id];
              return Positioned.fromRect(
                rect: r,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    DragTarget<String>(
                      onWillAcceptWithDetails: (DragTargetDetails<String> details) => !placed.containsKey(item.id),
                      onAcceptWithDetails: (DragTargetDetails<String> details) => onAccept(item.id, details.data),
                      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
                        final bool hovering = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: hovering || highlight ? const Color(0xFF38BDF8) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    if (label != null)
                      Positioned(
                        top: -20,
                        left: 0,
                        right: 0,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: highlight ? const Color(0xFF22C55E) : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            shadows: const <Shadow>[Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
