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
    this.highlightRegionIds = const <String>{},
    this.enabledRegionIds,
    this.showOverlays = true,
    this.dimNonHighlighted = false,
    this.feedbackRegionId,
    this.feedbackCorrect,
    this.pulse = false,
    this.showSpokenLabels = false,
    this.autoFocus = false,
    this.spokenLabel,
  });

  final ScienceDiagram diagram;
  final String? highlightRegionId;
  final Set<String> highlightRegionIds;
  final Set<String>? enabledRegionIds;
  final bool showOverlays;
  final bool dimNonHighlighted;
  final String? feedbackRegionId;
  final bool? feedbackCorrect;
  final bool pulse;
  final bool showSpokenLabels;
  final bool autoFocus;
  final String? spokenLabel;
  final ValueChanged<ScienceDiagramRegion> onRegionTap;

  Set<String> get _allHighlights => <String>{
        if (highlightRegionId != null && highlightRegionId!.trim().isNotEmpty)
          highlightRegionId!,
        ...highlightRegionIds,
      };

  @override
  Widget build(BuildContext context) {
    final DiagramAssetSource source = DiagramAssetService.instance.resolve(
      diagram.id,
      bundledOverride: diagram.assetPath ?? DiagramAssetRegistry.bundledPath(diagram.id),
    );
    final Set<String> highlights = _allHighlights;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = (width * diagram.aspectRatio).clamp(0, constraints.maxHeight);
        final Size canvasSize = Size(width, height);
        final Alignment focusAlign = _focusAlignment(highlights);

        return InteractiveViewer(
          minScale: 0.85,
          maxScale: 4.5,
          boundaryMargin: const EdgeInsets.all(24),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOutCubic,
              scale: autoFocus && highlights.isNotEmpty && highlights.length <= 3
                  ? 1.18
                  : 1.0,
              alignment: focusAlign,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(child: _DiagramImage(source: source)),
                    if (dimNonHighlighted && highlights.isNotEmpty)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DimExceptHolesPainter(
                            holes: _holes(canvasSize, highlights),
                            color: const Color(0xCC1C1917).withValues(alpha: 0.42),
                          ),
                        ),
                      ),
                    ...diagram.regions.map((ScienceDiagramRegion region) {
                      final bool highlighted = highlights.contains(region.id);
                      final bool enabled = enabledRegionIds == null ||
                          enabledRegionIds!.contains(region.id);
                      if (!enabled && !highlighted && region.id != feedbackRegionId) {
                        return const SizedBox.shrink();
                      }
                      return _RegionLayer(
                        region: region,
                        canvasSize: canvasSize,
                        highlighted: highlighted && showOverlays,
                        feedback: region.id == feedbackRegionId,
                        feedbackCorrect: feedbackCorrect,
                        pulse: pulse && highlighted,
                        showSpokenLabel: showSpokenLabels && highlighted && showOverlays,
                        spokenLabel: highlighted ? spokenLabel : null,
                        onTap: enabled ? () => onRegionTap(region) : () {},
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Rect> _holes(Size canvasSize, Set<String> highlights) {
    return diagram.regions
        .where((ScienceDiagramRegion r) => highlights.contains(r.id))
        .map((ScienceDiagramRegion r) => r.hitRect(canvasSize).inflate(8))
        .toList(growable: false);
  }

  Alignment _focusAlignment(Set<String> highlights) {
    if (highlights.isEmpty) return Alignment.center;
    double x = 0;
    double y = 0;
    int n = 0;
    for (final ScienceDiagramRegion region in diagram.regions) {
      if (!highlights.contains(region.id)) continue;
      x += region.center.dx;
      y += region.center.dy;
      n += 1;
    }
    if (n == 0) return Alignment.center;
    return Alignment((x / n - 0.5) * 2, (y / n - 0.5) * 2);
  }
}

class _DimExceptHolesPainter extends CustomPainter {
  _DimExceptHolesPainter({required this.holes, required this.color});

  final List<Rect> holes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path dim = Path()..addRect(Offset.zero & size);
    final Path cut = Path();
    for (final Rect hole in holes) {
      cut.addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(16)));
    }
    canvas.drawPath(
      Path.combine(PathOperation.difference, dim, cut),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _DimExceptHolesPainter oldDelegate) {
    if (oldDelegate.color != color || oldDelegate.holes.length != holes.length) {
      return true;
    }
    for (int i = 0; i < holes.length; i++) {
      if (oldDelegate.holes[i] != holes[i]) return true;
    }
    return false;
  }
}

class _DiagramImage extends StatelessWidget {
  const _DiagramImage({required this.source});

  final DiagramAssetSource source;

  @override
  Widget build(BuildContext context) {
    final bool assetIsSvg = source.assetPath.toLowerCase().endsWith('.svg');
    final Widget bundled = assetIsSvg
        ? SvgPicture.asset(source.assetPath, fit: BoxFit.contain)
        : Image.asset(source.assetPath, fit: BoxFit.contain);

    if (!source.isNetwork) return bundled;

    final String url = source.networkUrl!;
    final bool netIsSvg = url.toLowerCase().contains('.svg');
    if (netIsSvg) {
      return SvgPicture.network(
        url,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => bundled,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) => bundled,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
        if (progress == null) return child;
        return bundled;
      },
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
    required this.showSpokenLabel,
    required this.spokenLabel,
    required this.onTap,
  });

  final ScienceDiagramRegion region;
  final Size canvasSize;
  final bool highlighted;
  final bool feedback;
  final bool? feedbackCorrect;
  final bool pulse;
  final bool showSpokenLabel;
  final String? spokenLabel;
  final VoidCallback onTap;

  @override
  State<_RegionLayer> createState() => _RegionLayerState();
}

class _RegionLayerState extends State<_RegionLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
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

  Widget _buildOverlay({required double strokeWidth, required double borderAlpha, required double glow}) {
    final Rect rect = widget.region.hitRect(widget.canvasSize);
    final bool showMarker = widget.highlighted || widget.feedback;

    Color border = Colors.transparent;
    if (widget.feedback) {
      border = widget.feedbackCorrect == true ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    } else if (widget.highlighted) {
      border = const Color(0xFF38BDF8);
    }

    if (!showMarker) return const SizedBox.expand();

    final String label = (widget.spokenLabel ?? widget.region.name).trim().toUpperCase();
    final bool labelOnRight = widget.region.center.dx <= 0.62;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _borderRadius(),
            color: widget.highlighted
                ? const Color(0xFF38BDF8).withValues(alpha: 0.10 + glow * 0.12)
                : Colors.transparent,
            border: Border.all(color: border.withValues(alpha: borderAlpha), width: strokeWidth),
            boxShadow: widget.highlighted
                ? <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.35 + glow * 0.35),
                      blurRadius: 14 + glow * 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
        else if (widget.showSpokenLabel && label.isNotEmpty)
          Positioned(
            left: labelOnRight ? rect.width + 6 : null,
            right: labelOnRight ? null : rect.width + 6,
            top: (rect.height / 2) - 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.6,
                ),
              ),
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
              glow: _pulseController.value,
            ),
          )
        : _buildOverlay(
            strokeWidth: widget.highlighted ? 2.5 : 2,
            borderAlpha: 0.95,
            glow: 0.55,
          );

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
