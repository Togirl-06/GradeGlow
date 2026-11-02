import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shows a local file on mobile/desktop and a blob/http URL on web.
class LocalOrNetworkImage extends StatelessWidget {
  const LocalOrNetworkImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  static bool _isRemote(String value) {
    return kIsWeb ||
        value.startsWith('blob:') ||
        value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('data:');
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemote(path)) {
      return Image.network(path, width: width, height: height, fit: fit);
    }
    return Image.file(File(path), width: width, height: height, fit: fit);
  }
}
