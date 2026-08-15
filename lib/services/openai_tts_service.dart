import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/api_error_messages.dart';
import '../utils/speech_text.dart';

/// OpenAI TTS voice ids students can pick in lecture settings.
class OpenAiTtsVoices {
  static const List<({String id, String label, String blurb})> all =
      <({String id, String label, String blurb})>[
    (id: 'nova', label: 'Nova', blurb: 'Warm · clear · default professor'),
    (id: 'alloy', label: 'Alloy', blurb: 'Neutral · steady'),
    (id: 'echo', label: 'Echo', blurb: 'Soft · conversational'),
    (id: 'fable', label: 'Fable', blurb: 'Expressive · storytelling'),
    (id: 'onyx', label: 'Onyx', blurb: 'Deep · authoritative'),
    (id: 'shimmer', label: 'Shimmer', blurb: 'Bright · energetic'),
  ];

  static const String defaultId = 'nova';

  static bool isValid(String id) => all.any((v) => v.id == id);

  static String labelFor(String id) {
    for (final v in all) {
      if (v.id == id) return v.label;
    }
    return id;
  }
}

/// OpenAI Audio API text-to-speech (shows under Usage → Audio Speeches).
class OpenAiTtsService {
  static const String _url = 'https://api.openai.com/v1/audio/speech';

  /// Prefer baking voice into audio; keep [speed] near 1.0 and use player rate
  /// for live speed changes so pause/unpause stays instant.
  Future<Uint8List> synthesizeBytes(
    String text, {
    double speed = 1,
    String voice = OpenAiTtsVoices.defaultId,
  }) async {
    if (!AppConfig.hasOpenAi) {
      throw Exception('Add OPENAI_API_KEY to your .env file.');
    }

    final String input = speechTextFromMarkdown(text);
    if (input.isEmpty) {
      throw Exception('Nothing to speak.');
    }

    final String voiceId =
        OpenAiTtsVoices.isValid(voice) ? voice : OpenAiTtsVoices.defaultId;

    final http.Response response = await http.post(
      Uri.parse(_url),
      headers: <String, String>{
        'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'model': 'tts-1',
        'input': input,
        'voice': voiceId,
        'response_format': 'mp3',
        'speed': speed.clamp(0.25, 4.0),
      }),
    );

    if (response.statusCode != 200) {
      final ApiErrorInfo info =
          ApiErrorMessages.fromOpenAiResponse(response.statusCode, response.body);
      throw Exception('${info.title}: ${info.message}');
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception('OpenAI returned empty audio.');
    }

    return response.bodyBytes;
  }
}
