import 'dart:io';
import 'dart:typed_data';

import 'lecture_record_config.dart';

/// Repairs the size fields in a WAV file's header so players read the whole clip.
///
/// Streaming WAV writers (including the `record` plugin on web and desktop) write
/// the header up front with placeholder/under-counted `RIFF` and `data` chunk sizes
/// and don't always patch them to the final length on stop. Players then only
/// play up to the declared `data` size, so audio "cuts off early" even though
/// the samples are present in the file.
///
/// [rebuildWavBytes] is preferred: it rewrites a clean header and keeps every PCM
/// byte from the data chunk through end-of-file, using the configured sample rate.
class WavHeaderLayout {
  const WavHeaderLayout({
    required this.dataSizeFieldOffset,
    required this.dataContentStart,
    required this.sampleRate,
    required this.channels,
    required this.bitsPerSample,
  });

  final int dataSizeFieldOffset;
  final int dataContentStart;
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
}

/// Locates the `data` chunk and PCM format in a WAV header.
WavHeaderLayout? parseWavHeader(Uint8List bytes) {
  if (bytes.length < 44) return null;
  if (_tag(bytes, 0) != 'RIFF' || _tag(bytes, 8) != 'WAVE') return null;

  int? dataSizeFieldOffset;
  int? dataContentStart;
  int sampleRate = lectureRecordingSampleRate();
  int channels = 1;
  int bitsPerSample = 16;

  int pos = 12;
  while (pos + 8 <= bytes.length) {
    final String id = _tag(bytes, pos);
    final int declared = _readU32(bytes, pos + 4);
    if (id == 'fmt ' && declared >= 16 && pos + 8 + 16 <= bytes.length) {
      channels = _readU16(bytes, pos + 10);
      sampleRate = _readU32(bytes, pos + 12);
      bitsPerSample = _readU16(bytes, pos + 22);
    } else if (id == 'data') {
      dataSizeFieldOffset = pos + 4;
      dataContentStart = pos + 8;
      break;
    }
    pos += 8 + declared + (declared.isOdd ? 1 : 0);
  }

  if (dataSizeFieldOffset == null || dataContentStart == null) return null;
  return WavHeaderLayout(
    dataSizeFieldOffset: dataSizeFieldOffset,
    dataContentStart: dataContentStart,
    sampleRate: sampleRate,
    channels: channels,
    bitsPerSample: bitsPerSample,
  );
}

/// Builds a standard PCM WAV from raw samples.
Uint8List buildCleanWav(
  Uint8List pcm, {
  required int sampleRate,
  int channels = 1,
  int bitsPerSample = 16,
}) {
  const int headerSize = 44;
  final int byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
  final int blockAlign = channels * (bitsPerSample ~/ 8);
  final Uint8List wav = Uint8List(headerSize + pcm.length);

  wav.setRange(0, 4, 'RIFF'.codeUnits);
  wav.setRange(8, 12, 'WAVE'.codeUnits);
  wav.setRange(12, 16, 'fmt '.codeUnits);
  wav.setRange(36, 40, 'data'.codeUnits);

  final ByteData header = ByteData.sublistView(wav);
  header.setUint32(4, headerSize + pcm.length - 8, Endian.little);
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  header.setUint32(40, pcm.length, Endian.little);

  wav.setRange(headerSize, wav.length, pcm);
  return wav;
}

/// Extracts all PCM from [source] and writes a fresh WAV with a correct header.
Uint8List rebuildWavBytes(
  Uint8List source, {
  int? sampleRate,
  int? channels,
  int? bitsPerSample,
}) {
  final int rate = sampleRate ?? lectureRecordingSampleRate();
  final WavHeaderLayout? layout = parseWavHeader(source);
  final Uint8List pcm;
  final int ch;
  final int bits;

  if (layout != null && layout.dataContentStart < source.length) {
    pcm = Uint8List.fromList(source.sublist(layout.dataContentStart));
    ch = channels ?? layout.channels;
    bits = bitsPerSample ?? layout.bitsPerSample;
  } else {
    pcm = source;
    ch = channels ?? 1;
    bits = bitsPerSample ?? 16;
  }

  return buildCleanWav(pcm, sampleRate: rate, channels: ch, bitsPerSample: bits);
}

/// Expected PCM byte count for a recording duration at the lecture sample rate.
int expectedPcmBytesForDuration(Duration duration, {int? sampleRate, int channels = 1}) {
  final int rate = sampleRate ?? lectureRecordingSampleRate();
  return (duration.inMilliseconds * rate * channels * 2 / 1000).round();
}

/// Returns true if [bytes] were rewritten in place.
bool repairWavHeaderBytes(Uint8List bytes) {
  final WavHeaderLayout? layout = parseWavHeader(bytes);
  if (layout == null) return false;

  final int actualDataSize = bytes.length - layout.dataContentStart;
  if (actualDataSize <= 0) return false;

  final int declaredData = _readU32(bytes, layout.dataSizeFieldOffset);
  final int declaredRiff = _readU32(bytes, 4);
  final int correctRiff = bytes.length - 8;

  if (declaredData == actualDataSize && declaredRiff == correctRiff) {
    return false;
  }

  final ByteData sizes = ByteData.sublistView(bytes);
  sizes.setUint32(4, correctRiff, Endian.little);
  sizes.setUint32(layout.dataSizeFieldOffset, actualDataSize, Endian.little);
  return true;
}

/// Duration derived from actual PCM byte length (not the declared header size).
Duration? durationFromWavBytes(Uint8List bytes, {int? sampleRate}) {
  final WavHeaderLayout? layout = parseWavHeader(bytes);
  if (layout == null) return null;
  final int rate = sampleRate ?? layout.sampleRate;
  return _durationFromPcmBytes(
    bytes.length - layout.dataContentStart,
    layout.sampleRate,
    layout.channels,
    layout.bitsPerSample,
    overrideSampleRate: rate,
  );
}

/// Duration from a WAV file without reading the full PCM payload into memory.
Future<Duration?> durationFromWavPath(String path, {int? sampleRate}) async {
  try {
    final File file = File(path);
    if (!await file.exists()) return null;
    final int fileSize = await file.length();
    if (fileSize < 44) return null;

    final int scanLen = fileSize < 4096 ? fileSize : 4096;
    final Uint8List head = await file.openRead(0, scanLen).fold<Uint8List>(
      Uint8List(0),
      (Uint8List previous, List<int> chunk) => Uint8List.fromList(<int>[...previous, ...chunk]),
    );
    final WavHeaderLayout? layout = parseWavHeader(head);
    if (layout == null) return null;
    final int rate = sampleRate ?? layout.sampleRate;
    return _durationFromPcmBytes(
      fileSize - layout.dataContentStart,
      layout.sampleRate,
      layout.channels,
      layout.bitsPerSample,
      overrideSampleRate: rate,
    );
  } catch (_) {
    return null;
  }
}

Duration? _durationFromPcmBytes(
  int dataBytes,
  int headerSampleRate,
  int channels,
  int bitsPerSample, {
  int? overrideSampleRate,
}) {
  if (dataBytes <= 0) return null;

  final int bytesPerSample = bitsPerSample ~/ 8;
  if (bytesPerSample <= 0 || channels <= 0) return null;

  final int sampleRate = overrideSampleRate ?? headerSampleRate;
  if (sampleRate <= 0) return null;

  final int bytesPerSecond = sampleRate * channels * bytesPerSample;
  if (bytesPerSecond <= 0) return null;

  return Duration(milliseconds: (dataBytes * 1000 / bytesPerSecond).round());
}

/// Rewrites [path] with a clean WAV built from every PCM byte on disk.
Future<bool> rebuildWavFile(String path, {int? sampleRate}) async {
  try {
    final File file = File(path);
    if (!await file.exists()) return false;
    final Uint8List source = await file.readAsBytes();
    if (source.length < 44) return false;

    final Uint8List rebuilt = rebuildWavBytes(source, sampleRate: sampleRate);
    await file.writeAsBytes(rebuilt, flush: true);
    return true;
  } catch (_) {
    return false;
  }
}

/// Repairs a WAV file on disk. Returns true if the header was rewritten.
Future<bool> repairWavHeaderIfNeeded(String path) async {
  try {
    final File file = File(path);
    if (!await file.exists()) return false;
    final int fileSize = await file.length();
    if (fileSize < 44) return false;

    final Uint8List head = await file.openRead(0, fileSize < 4096 ? fileSize : 4096).fold<Uint8List>(
      Uint8List(0),
      (Uint8List previous, List<int> chunk) => Uint8List.fromList(<int>[...previous, ...chunk]),
    );

    final WavHeaderLayout? layout = parseWavHeader(head);
    if (layout == null) return false;

    final int actualDataSize = fileSize - layout.dataContentStart;
    if (actualDataSize <= 0) return false;

    final int declaredData = _readU32(head, layout.dataSizeFieldOffset);
    final int declaredRiff = _readU32(head, 4);
    final int correctRiff = fileSize - 8;

    if (declaredData == actualDataSize && declaredRiff == correctRiff) {
      return false;
    }

    final RandomAccessFile raf = await file.open(mode: FileMode.append);
    try {
      await raf.setPosition(4);
      await raf.writeFrom(_u32le(correctRiff));
      await raf.setPosition(layout.dataSizeFieldOffset);
      await raf.writeFrom(_u32le(actualDataSize));
      await raf.flush();
      return true;
    } finally {
      await raf.close();
    }
  } catch (_) {
    return false;
  }
}

String _tag(Uint8List b, int offset) {
  if (offset + 4 > b.length) return '';
  return String.fromCharCodes(b.sublist(offset, offset + 4));
}

int _readU16(Uint8List b, int offset) {
  return ByteData.sublistView(b, offset, offset + 2).getUint16(0, Endian.little);
}

int _readU32(Uint8List b, int offset) {
  return ByteData.sublistView(b, offset, offset + 4).getUint32(0, Endian.little);
}

Uint8List _u32le(int value) {
  final ByteData d = ByteData(4)..setUint32(0, value, Endian.little);
  return d.buffer.asUint8List();
}
