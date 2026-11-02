import 'dart:typed_data';

import 'package:ai_study_buddy/utils/wav_header_repair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repairWavHeaderBytes fixes under-reported data size', () {
    const int pcmBytes = 16000 * 2 * 10; // 10 seconds at 16 kHz mono 16-bit
    final Uint8List wav = _syntheticWav(pcmBytes: pcmBytes, declaredPcmBytes: 16000 * 2 * 3);

    expect(repairWavHeaderBytes(wav), isTrue);
    expect(_readU32(wav, 4), pcmBytes + 44 - 8);
    expect(_readU32(wav, 40), pcmBytes);
    expect(durationFromWavBytes(wav), const Duration(seconds: 10));
  });

  test('rebuildWavBytes fixes wrong header size and sample rate', () {
    const int pcmBytes = 16000 * 2 * 20; // 20 seconds at 16 kHz mono 16-bit
    final Uint8List wav = _syntheticWav(
      pcmBytes: pcmBytes,
      declaredPcmBytes: 16000 * 2 * 8,
      sampleRateInHeader: 48000,
    );

    final Uint8List rebuilt = rebuildWavBytes(wav, sampleRate: 16000);
    expect(durationFromWavBytes(rebuilt, sampleRate: 16000), const Duration(seconds: 20));
    expect(rebuilt.length, 44 + pcmBytes);
  });

  test('repairWavHeaderBytes is a no-op when sizes are correct', () {
    const int pcmBytes = 16000 * 2 * 5;
    final Uint8List wav = _syntheticWav(pcmBytes: pcmBytes, declaredPcmBytes: pcmBytes);

    expect(repairWavHeaderBytes(wav), isFalse);
    expect(durationFromWavBytes(wav), const Duration(seconds: 5));
  });

  test('boostWavForSpeech raises quiet recordings', () {
    const int pcmBytes = 44100 * 2;
    final Uint8List wav = _syntheticWav(
      pcmBytes: pcmBytes,
      declaredPcmBytes: pcmBytes,
      sampleRate: 44100,
      sampleRateInHeader: 44100,
    );
    ByteData.sublistView(wav).setInt16(44, 250, Endian.little);

    final Uint8List boosted = boostWavForSpeech(wav, sampleRate: 44100);
    expect(peakPcmLevel(boosted), greaterThan(5000));
  });

  test('boostWavForSpeech rejects silent recordings', () {
    const int pcmBytes = 44100 * 2;
    final Uint8List wav = _syntheticWav(
      pcmBytes: pcmBytes,
      declaredPcmBytes: pcmBytes,
      sampleRate: 44100,
      sampleRateInHeader: 44100,
    );

    expect(() => boostWavForSpeech(wav, sampleRate: 44100), throwsException);
  });
}

Uint8List _syntheticWav({
  required int pcmBytes,
  required int declaredPcmBytes,
  int sampleRate = 16000,
  int sampleRateInHeader = 16000,
}) {
  const int headerSize = 44;
  final Uint8List wav = Uint8List(headerSize + pcmBytes);
  wav.setRange(0, 4, 'RIFF'.codeUnits);
  wav.setRange(8, 12, 'WAVE'.codeUnits);
  wav.setRange(12, 16, 'fmt '.codeUnits);
  wav.setRange(36, 40, 'data'.codeUnits);

  final ByteData header = ByteData.sublistView(wav);
  header.setUint32(4, headerSize + declaredPcmBytes - 8, Endian.little);
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, sampleRateInHeader, Endian.little);
  header.setUint32(28, sampleRateInHeader * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  header.setUint32(40, declaredPcmBytes, Endian.little);
  return wav;
}

int _readU32(Uint8List bytes, int offset) {
  return ByteData.sublistView(bytes, offset, offset + 4).getUint32(0, Endian.little);
}
