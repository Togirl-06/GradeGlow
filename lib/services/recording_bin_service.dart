import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/binned_recording.dart';
import '../utils/test_environment.dart';

/// Keeps recently deleted recordings for restore (mobile/desktop).
class RecordingBinService extends ChangeNotifier {
  static const int maxItems = 20;
  static const Duration retention = Duration(days: 30);

  final List<BinnedRecording> _items = <BinnedRecording>[];
  bool _loaded = false;

  List<BinnedRecording> get items => List<BinnedRecording>.unmodifiable(_items);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (kIsWeb || isFlutterTest) {
      _loaded = true;
      return;
    }

    try {
      final File index = await _indexFile();
      if (!await index.exists()) {
        _loaded = true;
        return;
      }
      final List<dynamic> raw = jsonDecode(await index.readAsString()) as List<dynamic>;
      _items
        ..clear()
        ..addAll(
          raw
              .whereType<Map<String, dynamic>>()
              .map(BinnedRecording.fromJson)
              .where((BinnedRecording item) => _fileExists(item.filePath)),
        );
      await _pruneExpired();
      await _saveIndex();
    } catch (_) {
      _items.clear();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<BinnedRecording?> moveToBin({
    required String sourcePath,
    required Duration duration,
    String? label,
    Uint8List? bytes,
  }) async {
    await ensureLoaded();
    final String fileName = sourcePath.split(RegExp(r'[/\\]')).last;
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final String binFileName = '${id}_${fileName.isEmpty ? 'recording.wav' : fileName}';

    if (kIsWeb) {
      if (bytes == null || bytes.isEmpty) return null;
      final BinnedRecording item = BinnedRecording(
        id: id,
        fileName: binFileName,
        filePath: 'web:$id',
        durationSeconds: duration.inSeconds,
        deletedAt: DateTime.now(),
        label: label,
      );
      _items.insert(0, item);
      await _trim();
      notifyListeners();
      return item;
    }

    final Directory binDir = await _binDirectory();
    final String destPath = '${binDir.path}/$binFileName';
    final File source = File(sourcePath);
    if (await source.exists()) {
      await source.rename(destPath);
    } else if (bytes != null && bytes.isNotEmpty) {
      await File(destPath).writeAsBytes(bytes, flush: true);
    } else {
      return null;
    }

    final BinnedRecording item = BinnedRecording(
      id: id,
      fileName: binFileName,
      filePath: destPath,
      durationSeconds: duration.inSeconds,
      deletedAt: DateTime.now(),
      label: label,
    );
    _items.insert(0, item);
    await _trim();
    await _saveIndex();
    notifyListeners();
    return item;
  }

  Future<String?> restore(BinnedRecording item) async {
    await ensureLoaded();
    if (kIsWeb) {
      _items.removeWhere((BinnedRecording entry) => entry.id == item.id);
      notifyListeners();
      return null;
    }

    final File binFile = File(item.filePath);
    if (!await binFile.exists()) {
      _items.removeWhere((BinnedRecording entry) => entry.id == item.id);
      await _saveIndex();
      notifyListeners();
      return null;
    }

    final Directory restoreDir = await _restoreDirectory();
    final String restoredPath = '${restoreDir.path}/${item.fileName.replaceFirst('${item.id}_', '')}';
    await binFile.copy(restoredPath);
    _items.removeWhere((BinnedRecording entry) => entry.id == item.id);
    await binFile.delete();
    await _saveIndex();
    notifyListeners();
    return restoredPath;
  }

  Future<void> deletePermanently(BinnedRecording item) async {
    await ensureLoaded();
    if (!kIsWeb) {
      final File file = File(item.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _items.removeWhere((BinnedRecording entry) => entry.id == item.id);
    if (!kIsWeb) await _saveIndex();
    notifyListeners();
  }

  Future<void> emptyBin() async {
    await ensureLoaded();
    for (final BinnedRecording item in List<BinnedRecording>.from(_items)) {
      await deletePermanently(item);
    }
  }

  Future<Directory> _binDirectory() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory bin = Directory('${docs.path}/recording_bin');
    if (!await bin.exists()) {
      await bin.create(recursive: true);
    }
    return bin;
  }

  Future<Directory> _restoreDirectory() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory restored = Directory('${docs.path}/restored_recordings');
    if (!await restored.exists()) {
      await restored.create(recursive: true);
    }
    return restored;
  }

  Future<File> _indexFile() async {
    final Directory bin = await _binDirectory();
    return File('${bin.path}/index.json');
  }

  Future<void> _saveIndex() async {
    final File index = await _indexFile();
    final String encoded = jsonEncode(_items.map((BinnedRecording item) => item.toJson()).toList());
    await index.writeAsString(encoded);
  }

  Future<void> _trim() async {
    while (_items.length > maxItems) {
      await deletePermanently(_items.last);
    }
    await _pruneExpired();
  }

  Future<void> _pruneExpired() async {
    final DateTime cutoff = DateTime.now().subtract(retention);
    for (final BinnedRecording item in List<BinnedRecording>.from(_items)) {
      if (item.deletedAt.isBefore(cutoff)) {
        await deletePermanently(item);
      }
    }
  }

  bool _fileExists(String path) {
    if (path.startsWith('web:')) return true;
    return File(path).existsSync();
  }
}
