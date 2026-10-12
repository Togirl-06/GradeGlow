// Remove the white paper from the GradeGlow logo (GIMP-style color-to-alpha).
//
// Run: dart run tool/knockout_logo_background.dart

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  const String path = 'assets/images/gradeglow_logo.png';
  final File file = File(path);
  final img.Image? src = img.decodePng(file.readAsBytesSync());
  if (src == null) {
    stderr.writeln('Failed to decode $path');
    exit(1);
  }

  final img.Image logo = src.convert(numChannels: 4);
  for (final img.Pixel p in logo) {
    final double r = p.r.toDouble() / 255.0;
    final double g = p.g.toDouble() / 255.0;
    final double b = p.b.toDouble() / 255.0;
    // Distance from white → alpha. Then un-composite against white.
    final double a = 1.0 - math.min(r, math.min(g, b));
    if (a <= 0.02) {
      p.r = 0;
      p.g = 0;
      p.b = 0;
      p.a = 0;
      continue;
    }
    p.r = (((r - (1 - a)) / a).clamp(0.0, 1.0) * 255).round();
    p.g = (((g - (1 - a)) / a).clamp(0.0, 1.0) * 255).round();
    p.b = (((b - (1 - a)) / a).clamp(0.0, 1.0) * 255).round();
    p.a = (a * 255).round().clamp(0, 255);
  }

  final img.Image trimmed = img.trim(logo, mode: img.TrimMode.transparent);
  file.writeAsBytesSync(img.encodePng(trimmed));
  stdout.writeln(
    'Wrote $path (${trimmed.width}x${trimmed.height}, transparent background)',
  );
}
