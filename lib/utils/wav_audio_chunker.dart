import 'dart:typed_data';

/// Splits PCM WAV bytes into smaller WAV files for Whisper's upload limit.
class WavAudioChunker {
  WavAudioChunker._();

  static const int maxPcmBytesPerChunk = 24 * 1024 * 1024;

  static List<Uint8List> split(Uint8List wavBytes, {int maxPcmBytes = maxPcmBytesPerChunk}) {
    if (wavBytes.length < 44) {
      throw FormatException('Invalid WAV file.');
    }

    final _WavLayout layout = _WavLayout.parse(wavBytes);
    final int pcmLength = wavBytes.length - layout.dataOffset;
    if (pcmLength <= maxPcmBytes) {
      return <Uint8List>[wavBytes];
    }

    final List<Uint8List> chunks = <Uint8List>[];
    for (int offset = 0; offset < pcmLength; offset += maxPcmBytes) {
      final int length = (offset + maxPcmBytes > pcmLength) ? pcmLength - offset : maxPcmBytes;
      chunks.add(_buildChunk(wavBytes, layout, offset, length));
    }
    return chunks;
  }

  static Uint8List _buildChunk(
    Uint8List source,
    _WavLayout layout,
    int pcmOffset,
    int pcmLength,
  ) {
    final Uint8List header = Uint8List.fromList(source.sublist(0, layout.dataOffset));
    final ByteData sizes = ByteData.sublistView(header);
    final int riffSize = header.length - 8 + pcmLength;
    sizes.setUint32(4, riffSize, Endian.little);
    sizes.setUint32(layout.dataSizeOffset, pcmLength, Endian.little);

    final Uint8List chunk = Uint8List(header.length + pcmLength);
    chunk.setRange(0, header.length, header);
    chunk.setRange(
      header.length,
      header.length + pcmLength,
      source,
      layout.dataOffset + pcmOffset,
    );
    return chunk;
  }
}

class _WavLayout {
  const _WavLayout({required this.dataOffset, required this.dataSizeOffset});

  final int dataOffset;
  final int dataSizeOffset;

  static _WavLayout parse(Uint8List bytes) {
    if (String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
        String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
      throw FormatException('Unsupported WAV format.');
    }

    int offset = 12;
    while (offset + 8 <= bytes.length) {
      final String chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final int chunkSize = ByteData.sublistView(bytes, offset + 4, offset + 8).getUint32(0, Endian.little);
      if (chunkId == 'data') {
        return _WavLayout(dataOffset: offset + 8, dataSizeOffset: offset + 4);
      }
      offset += 8 + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    throw FormatException('WAV data chunk not found.');
  }
}
