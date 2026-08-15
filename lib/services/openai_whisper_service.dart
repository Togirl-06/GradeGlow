import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/api_error_messages.dart';
import '../utils/lecture_record_config.dart';
import '../utils/wav_audio_chunker.dart';
import '../utils/wav_header_repair.dart';

/// OpenAI Whisper speech-to-text (Usage → Audio Transcriptions).
class OpenAiWhisperService {
  static const String _url = 'https://api.openai.com/v1/audio/transcriptions';
  static const int _maxUploadBytes = 24 * 1024 * 1024;

  Future<String> transcribeFile(String filePath) async {
    if (kIsWeb && (filePath.startsWith('blob:') || filePath.startsWith('http'))) {
      final http.Response response = await http.get(Uri.parse(filePath));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Recording file not found.');
      }
      return _transcribeAudioBytes(
        response.bodyBytes,
        fileName: _fileNameFromPath(filePath),
      );
    }

    final File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Recording file not found.');
    }
    if (await file.length() < 300) {
      throw Exception('Recording too short. Speak for at least 2 seconds, then tap ✓.');
    }

    final Uint8List bytes = await file.readAsBytes();
    return _transcribeAudioBytes(bytes, fileName: _fileNameFromPath(filePath));
  }

  Uint8List _prepareAudioBytes(Uint8List bytes) {
    if (bytes.length < 44) return bytes;
    final Uint8List rebuilt = rebuildWavBytes(bytes, sampleRate: lectureRecordingSampleRate());
    if (kIsWeb) return rebuilt;
    return boostWavForSpeech(rebuilt, sampleRate: lectureRecordingSampleRate());
  }

  Future<String> _transcribeAudioBytes(Uint8List bytes, {required String fileName}) async {
    final Uint8List prepared = _prepareAudioBytes(bytes);
    if (prepared.length <= _maxUploadBytes) {
      return transcribeBytes(prepared, fileName: fileName);
    }

    final String ext = fileName.split('.').last.toLowerCase();
    if (ext == 'wav') {
      final List<Uint8List> chunks = WavAudioChunker.split(prepared);
      final StringBuffer transcript = StringBuffer();
      for (int i = 0; i < chunks.length; i++) {
        final String part = await transcribeBytes(
          chunks[i],
          fileName: 'recording_part_${i + 1}.wav',
        );
        if (part.isNotEmpty) {
          if (transcript.isNotEmpty) transcript.write(' ');
          transcript.write(part);
        }
      }
      final String text = transcript.toString().trim();
      if (text.isEmpty) {
        throw Exception('Could not understand the audio. Try speaking louder and closer to the mic.');
      }
      return text;
    }

    throw Exception(
      'Recording is too long to transcribe as a single file. '
      'Use WAV format or keep recordings under 4 hours.',
    );
  }

  Future<String> transcribeBytes(Uint8List bytes, {required String fileName}) async {
    if (!AppConfig.hasOpenAi) {
      throw Exception('Add OPENAI_API_KEY to your .env file.');
    }
    final Uint8List prepared = _prepareAudioBytes(bytes);
    if (prepared.length < 300) {
      throw Exception('Recording too short. Speak for at least 2 seconds, then tap ✓.');
    }

    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(_url));
    request.headers['Authorization'] = 'Bearer ${AppConfig.openAiApiKey}';
    request.fields['model'] = 'whisper-1';
    request.fields['prompt'] = 'Lecture recording, class notes, educational content.';
    request.fields['temperature'] = '0';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      prepared,
      filename: fileName.endsWith('.') ? 'recording.wav' : fileName,
    ));

    final http.StreamedResponse streamed = await request.send();
    final String body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      final ApiErrorInfo info = ApiErrorMessages.fromOpenAiResponse(streamed.statusCode, body);
      throw Exception('${info.title}: ${info.message}');
    }

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    final String text = (json['text'] as String? ?? '').trim();
    if (text.isEmpty) {
      throw Exception('Could not understand the audio. Try speaking louder and closer to the mic.');
    }
    return text;
  }

  static String _fileNameFromPath(String path) {
    final String name = path.split(RegExp(r'[/\\]')).last;
    if (name.isEmpty || !name.contains('.')) return 'recording.wav';
    return name;
  }
}
