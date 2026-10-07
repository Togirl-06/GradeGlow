import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'io_file_bytes_stub.dart'
    if (dart.library.io) 'io_file_bytes_io.dart' as impl;

/// Read file bytes only on platforms that support `dart:io`.
Future<Uint8List> readFileBytes(String path) => impl.readFileBytes(path);

/// Write bytes to a temp file. Unsupported on web.
Future<String> writeTempFileBytes(Uint8List bytes, String fileName) =>
    impl.writeTempFileBytes(bytes, fileName);

/// Byte length of a local file path. Unsupported on web.
Future<int> fileByteLength(String path) => impl.fileByteLength(path);

bool get supportsLocalFiles => !kIsWeb;
