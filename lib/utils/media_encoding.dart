import 'dart:convert';
import 'dart:io';

/// Reads an image file and returns a data URL for OpenAI vision.
Future<String?> imageFileToDataUrl(String path) async {
  final File file = File(path);
  if (!await file.exists()) return null;

  final List<int> bytes = await file.readAsBytes();
  final String ext = path.split('.').last.toLowerCase();
  final String mime = switch (ext) {
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
  return 'data:$mime;base64,${base64Encode(bytes)}';
}
