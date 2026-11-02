import 'dart:typed_data';

import 'package:ai_study_buddy/utils/recording_limits.dart';
import 'package:ai_study_buddy/utils/wav_audio_chunker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('max recording duration is 4 hours', () {
    expect(RecordingLimits.maxDuration, const Duration(hours: 4));
    expect(RecordingLimits.maxDurationSeconds, 4 * 60 * 60);
  });

  test('formatRecordingDuration shows hours for long recordings', () {
    expect(formatRecordingDuration(const Duration(hours: 1, minutes: 5, seconds: 7)), '1:05:07');
    expect(formatRecordingDuration(const Duration(minutes: 5, seconds: 7)), '5:07');
  });

  test('WavAudioChunker splits oversized wav files', () {
    final Uint8List wav = _syntheticWav(pcmBytes: WavAudioChunker.maxPcmBytesPerChunk + 1024);
    final List<Uint8List> chunks = WavAudioChunker.split(wav);
    expect(chunks.length, 2);
    for (final Uint8List chunk in chunks) {
      expect(chunk.length, lessThanOrEqualTo(44 + WavAudioChunker.maxPcmBytesPerChunk));
      expect(String.fromCharCodes(chunk.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(chunk.sublist(8, 12)), 'WAVE');
    }
  });
}

Uint8List _syntheticWav({required int pcmBytes}) {
  const int headerSize = 44;
  final Uint8List wav = Uint8List(headerSize + pcmBytes);
  wav.setRange(0, 4, 'RIFF'.codeUnits);
  wav.setRange(8, 12, 'WAVE'.codeUnits);
  wav.setRange(12, 16, 'fmt '.codeUnits);
  wav.setRange(36, 40, 'data'.codeUnits);
  final ByteData sizes = ByteData.sublistView(wav);
  sizes.setUint32(4, headerSize + pcmBytes - 8, Endian.little);
  sizes.setUint32(16, 16, Endian.little);
  sizes.setUint32(40, pcmBytes, Endian.little);
  return wav;
}
