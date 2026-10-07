import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> readFileBytes(String path) async {
  return File(path).readAsBytes();
}

Future<String> writeTempFileBytes(Uint8List bytes, String fileName) async {
  final File temp = File(
    '${Directory.systemTemp.path}/study_${DateTime.now().millisecondsSinceEpoch}_$fileName',
  );
  await temp.writeAsBytes(bytes);
  return temp.path;
}

Future<int> fileByteLength(String path) async {
  return File(path).length();
}
