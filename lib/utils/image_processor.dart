import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Auto-enhance scan: grayscale, contrast, slight sharpen. Optional [rotationDegrees].
Uint8List enhanceScan(Uint8List bytes, {int rotationDegrees = 0}) {
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return bytes;

  if (rotationDegrees != 0) {
    image = img.copyRotate(image, angle: rotationDegrees);
  }

  image = img.grayscale(image);
  image = img.adjustColor(image, contrast: 1.15, brightness: 0.02);
  image = img.convolution(image, filter: <double>[
    0, -1, 0,
    -1, 5, -1,
    0, -1, 0,
  ]);

  return Uint8List.fromList(img.encodeJpg(image, quality: 92));
}
