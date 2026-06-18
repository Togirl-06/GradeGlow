import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../utils/lecture_record_config.dart';
import '../utils/wav_header_repair.dart';

/// Writes streamed PCM from [AudioRecorder.startStream] to disk (or memory on web)
/// and builds a correct WAV file when recording stops.
class LectureStreamCapture {
  IOSink? _pcmSink;
  File? _pcmFile;
  BytesBuilder? _pcmBuilder;
  int _pcmBytes = 0;
  String? _wavOutputPath;

  int get pcmBytes => _pcmBytes;

  Duration get capturedDuration {
    final int rate = lectureRecordingSampleRate();
    if (_pcmBytes <= 0 || rate <= 0) return Duration.zero;
    return Duration(milliseconds: (_pcmBytes * 1000 / (rate * 2)).round());
  }

  Future<void> begin({required String wavPath}) async {
    await discard();
    _wavOutputPath = wavPath;
    _pcmBytes = 0;

    if (kIsWeb) {
      _pcmBuilder = BytesBuilder(copy: false);
      return;
    }

    final String pcmPath = wavPath.replaceAll(RegExp(r'\.wav$'), '.pcm');
    _pcmFile = File(pcmPath);
    if (await _pcmFile!.exists()) {
      await _pcmFile!.delete();
    }
    _pcmSink = _pcmFile!.openWrite();
  }

  void addChunk(Uint8List chunk) {
    if (chunk.isEmpty) return;
    _pcmBytes += chunk.length;
    if (kIsWeb) {
      _pcmBuilder?.add(chunk);
    } else {
      _pcmSink?.add(chunk);
    }
  }

  /// Finalizes the WAV file. Returns in-memory bytes on web, otherwise the wav path.
  Future<LectureCaptureResult> finish() async {
    final String? wavPath = _wavOutputPath;
    if (wavPath == null) {
      throw StateError('Call begin(wavPath: ...) before finish().');
    }

    await _pcmSink?.flush();
    await _pcmSink?.close();
    _pcmSink = null;

    final Uint8List pcm;
    if (kIsWeb) {
      pcm = _pcmBuilder?.toBytes() ?? Uint8List(0);
      _pcmBuilder = null;
    } else {
      final File? pcmFile = _pcmFile;
      if (pcmFile == null || !await pcmFile.exists()) {
        pcm = Uint8List(0);
      } else {
        pcm = await pcmFile.readAsBytes();
        try {
          await pcmFile.delete();
        } catch (_) {}
      }
      _pcmFile = null;
    }

    final Uint8List wav = buildCleanWav(
      pcm,
      sampleRate: lectureRecordingSampleRate(),
    );

    if (kIsWeb) {
      return LectureCaptureResult(path: wavPath, wavBytes: wav);
    }

    final File out = File(wavPath);
    await out.writeAsBytes(wav, flush: true);
    return LectureCaptureResult(path: wavPath, wavBytes: wav);
  }

  Future<void> discard() async {
    try {
      await _pcmSink?.close();
    } catch (_) {}
    _pcmSink = null;
    _pcmBuilder = null;
    _pcmBytes = 0;

    final File? pcmFile = _pcmFile;
    _pcmFile = null;
    if (pcmFile != null && await pcmFile.exists()) {
      try {
        await pcmFile.delete();
      } catch (_) {}
    }
  }
}

class LectureCaptureResult {
  const LectureCaptureResult({required this.path, required this.wavBytes});

  final String path;
  final Uint8List wavBytes;
}
