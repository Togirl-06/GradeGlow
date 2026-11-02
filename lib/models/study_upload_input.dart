import 'dart:typed_data';

/// One file picked for multi-file study-set upload.
class StudyUploadInput {
  const StudyUploadInput({
    required this.fileName,
    this.filePath,
    this.bytes,
  });

  final String fileName;
  final String? filePath;
  final Uint8List? bytes;
}
