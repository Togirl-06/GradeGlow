import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/microbiology_specimen.dart';

/// Microscope field-of-view illustration from bundled specimen SVG assets.
class MicroscopeSpecimenCanvas extends StatelessWidget {
  const MicroscopeSpecimenCanvas({super.key, required this.specimen});

  final MicrobiologySpecimen specimen;

  static String assetPathFor(MicrobiologySpecimen specimen) => 'assets/microbiology/${specimen.id}.svg';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: SvgPicture.asset(
            assetPathFor(specimen),
            fit: BoxFit.cover,
            placeholderBuilder: (BuildContext context) => const ColoredBox(
              color: Color(0xFF1B5E20),
              child: Center(child: Icon(Icons.biotech_rounded, color: Colors.white54, size: 48)),
            ),
          ),
        ),
      ),
    );
  }
}
