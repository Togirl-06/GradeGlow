import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/api_error_messages.dart';
import '../utils/speech_text.dart';

/// OpenAI Audio API text-to-speech (shows under Usage → Audio Speeches).
class OpenAiTtsService {
  static const String _url = 'https://api.openai.com/v1/audio/speech';

  /// [speed] is OpenAI's speaking rate (0.25–4.0). Prefer baking speed into
  /// the audio so playback works even when the platform ignores setPlaybackRate.
  Future<Uint8List> synthesizeBytes(String text, {double speed = 1}) async {
    if (!AppConfig.hasOpenAi) {
      throw Exception('Add OPENAI_API_KEY to your .env file.');
    }

    final String input = speechTextFromMarkdown(text);
    if (input.isEmpty) {
      throw Exception('Nothing to speak.');
    }

    final http.Response response = await http.post(
      Uri.parse(_url),
      headers: <String, String>{
        'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'model': 'tts-1',
        'input': input,
        'voice': 'nova',
        'response_format': 'mp3',
        'speed': speed.clamp(0.25, 4.0),
      }),
    );

    if (response.statusCode != 200) {
      final ApiErrorInfo info = ApiErrorMessages.fromOpenAiResponse(response.statusCode, response.body);
      throw Exception('${info.title}: ${info.message}');
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception('OpenAI returned empty audio.');
    }

    return response.bodyBytes;
  }
}
