import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/diagram_asset_registry.dart';
import '../../models/science_diagram.dart';
import '../../services/diagram_asset_service.dart';

/// Invisible tap targets over a real diagram image — outline only when needed.
class AnatomyAssetCanvas extends StatelessWidget {
  const AnatomyAssetCanvas({
    super.key,
    required this.diagram,
    required this.highlightRegionId,
    required this.onRegionTap,
    this.feedbackRegionId,
    this.feedbackCorrect,
    this.pulse = false,
  });

  final ScienceDiagram diagram;
  final String? highlightRegionId;
  final String? feedbackRegionId;
  final bool? feedbackCorrect;
  final bool pulse;
  final ValueChanged<ScienceDiagramRegion> onRegionTap;

  @override
  Widget build(BuildContext context) {
    final DiagramAssetSource source = DiagramAssetService.instance.resolve(
      diagram.id,
      bundledOverride: diagram.assetPath ?? DiagramAssetRegistry.bundledPath(diagram.id),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = (width * diagram.aspectRatio).clamp(0, constraints.maxHeight);

        return InteractiveViewer(
          minScale: 0.85,
          maxScale: 4.5,
          boundaryMargin: const EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(child: _DiagramImage(source: source)),
                  ...diagram.regions.map((ScienceDiagramRegion region) => _RegionLayer(
                        region: region,
                        canvasSize: Size(width, height),
                        highlighted: region.id == highlightRegionId,
                        feedback: region.id == feedbackRegionId,
                        feedbackCorrect: feedbackCorrect,
                        pulse: pulse && region.id == highlightRegionId,
                        onTap: () => onRegionTap(region),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DiagramImage extends StatelessWidget {
  const _DiagramImage({required this.source});

  final DiagramAssetSource source;

  @override
  Widget build(BuildContext context) {
    final Widget bundled = source.assetPath.toLowerCase().endsWith('.svg')
        ? SvgPicture.asset(source.assetPath, fit: BoxFit.contain)
        : Image.asset(source.assetPath, fit: BoxFit.contain);

    if (!source.isNetwork) return bundled;

    return SvgPicture.network(
      source.networkUrl!,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => bundled,
    );
  }
}

class _RegionLayer extends StatefulWidget {
  const _RegionLayer({
    required this.region,
    required this.canvasSize,
    required this.highlighted,
    required this.feedback,
    required this.feedbackCorrect,
    required this.pulse,
    required this.onTap,
  });

  final ScienceDiagramRegion region;
  final Size canvasSize;
  final bool highlighted;
  final bool feedback;
  final bool? feedbackCorrect;
  final bool pulse;
  final VoidCallback onTap;

  @override
  State<_RegionLayer> createState() => _RegionLayerState();
}

class _RegionLayerState extends State<_RegionLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  BorderRadius _borderRadius() {
    return switch (widget.region.shape) {
      ScienceRegionShape.rect => BorderRadius.circular(6),
      ScienceRegionShape.ring => BorderRadius.circular(8),
      ScienceRegionShape.ellipse => BorderRadius.circular(8),
    };
  }

  Widget _buildOverlay({required double strokeWidth, required double borderAlpha}) {
    final Rect rect = widget.region.hitRect(widget.canvasSize);
    final bool showMarker = widget.highlighted || widget.feedback;

    Color border = Colors.transparent;
    if (widget.feedback) {
      border = widget.feedbackCorrect == true ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    } else if (widget.highlighted) {
      border = const Color(0xFF38BDF8);
    }

    if (!showMarker) return const SizedBox.expand();

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _borderRadius(),
            border: Border.all(color: border.withValues(alpha: borderAlpha), width: strokeWidth),
          ),
        ),
        if (widget.feedback)
          Positioned(
            top: 2,
            right: 2,
            child: Icon(
              widget.feedbackCorrect == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: border,
              size: 20,
            ),
          )
        else if (widget.highlighted)
          Positioned(
            left: rect.width / 2 - 11,
            top: -4,
            child: Icon(Icons.place_rounded, color: border, size: 22),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Rect rect = widget.region.hitRect(widget.canvasSize);

    final Widget overlay = widget.pulse
        ? AnimatedBuilder(
            animation: _pulseController,
            builder: (BuildContext context, Widget? child) => _buildOverlay(
              strokeWidth: 2 + _pulseController.value * 1.5,
              borderAlpha: 0.55 + _pulseController.value * 0.45,
            ),
          )
        : _buildOverlay(strokeWidth: widget.highlighted ? 2.5 : 2, borderAlpha: 0.95);

    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: overlay,
      ),
    );
  }
}
