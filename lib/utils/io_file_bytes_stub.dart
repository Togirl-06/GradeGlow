import 'dart:typed_data';

Future<Uint8List> readFileBytes(String path) async {
  throw UnsupportedError(
    'Local files are not available in the browser. Upload with file bytes, or paste text.',
  );
}

Future<String> writeTempFileBytes(Uint8List bytes, String fileName) async {
  throw UnsupportedError(
    'Temporary files are not available in the browser. Keep content in memory.',
  );
}

Future<int> fileByteLength(String path) async {
  throw UnsupportedError('Local files are not available in the browser.');
}
