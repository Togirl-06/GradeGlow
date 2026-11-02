// Generates a square launcher icon: original wide logo centered with padding (never stretched).
//
// Run: dart run tool/generate_app_icon.dart
// Then: dart run flutter_launcher_icons

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const String sourcePath = 'assets/images/gradeglow_logo.png';
  const String outputPath = 'assets/images/gradeglow_app_icon.png';
  const int canvasSize = 1024;
  const double paddingFraction = 0.16;

  final img.Image? logo = img.decodePng(File(sourcePath).readAsBytesSync());
  if (logo == null) {
    stderr.writeln('Failed to decode $sourcePath');
    exit(1);
  }

  final img.Image canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

  final double maxW = canvasSize * (1 - 2 * paddingFraction);
  final double maxH = canvasSize * (1 - 2 * paddingFraction);
  final double logoAspect = logo.width / logo.height;

  final int targetW;
  final int targetH;
  if (logoAspect >= maxW / maxH) {
    targetW = maxW.round();
    targetH = (targetW / logoAspect).round();
  } else {
    targetH = maxH.round();
    targetW = (targetH * logoAspect).round();
  }

  final img.Image resized = img.copyResize(logo, width: targetW, height: targetH);
  img.compositeImage(
    canvas,
    resized,
    dstX: (canvasSize - targetW) ~/ 2,
    dstY: (canvasSize - targetH) ~/ 2,
  );

  File(outputPath).writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Wrote $outputPath (${targetW}x$targetH logo on ${canvasSize}x$canvasSize, aspect preserved)');
}
