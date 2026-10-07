import 'package:flutter/foundation.dart';

import 'app_config.dart';

/// Resolves chat / audio OpenAI URLs.
/// On web, prefer the Hosting Cloud Function proxy so the API key stays server-side.
abstract final class OpenAiEndpoints {
  OpenAiEndpoints._();

  static const String _directChat = 'https://api.openai.com/v1/chat/completions';
  static const String _directSpeech = 'https://api.openai.com/v1/audio/speech';
  static const String _directTranscriptions =
      'https://api.openai.com/v1/audio/transcriptions';

  static String get _proxyBase {
    final String configured = AppConfig.openAiProxyUrl.trim();
    if (configured.isNotEmpty) {
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }
    if (kIsWeb) {
      final String host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'https://gradeglow-virtualuni.web.app/api/openai';
      }
      return '${Uri.base.origin}/api/openai';
    }
    return '';
  }

  static bool get usesProxy => kIsWeb || AppConfig.usesOpenAiProxy;

  static String get chatCompletions =>
      usesProxy ? '$_proxyBase/v1/chat/completions' : _directChat;

  static String get audioSpeech =>
      usesProxy ? '$_proxyBase/v1/audio/speech' : _directSpeech;

  static String get audioTranscriptions =>
      usesProxy ? '$_proxyBase/v1/audio/transcriptions' : _directTranscriptions;

  static Map<String, String> jsonHeaders() {
    if (usesProxy) {
      return const <String, String>{'Content-Type': 'application/json'};
    }
    return <String, String>{
      'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
      'Content-Type': 'application/json',
    };
  }

  static Map<String, String> authHeadersOnly() {
    if (usesProxy) return const <String, String>{};
    return <String, String>{
      'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
    };
  }
}
