import 'dart:convert';

/// User-visible API errors (OpenAI, etc.).
class ApiErrorInfo {
  const ApiErrorInfo({
    required this.title,
    required this.message,
    this.steps = const <String>[],
  });

  final String title;
  final String message;
  final List<String> steps;
}

class ApiErrorMessages {
  static ApiErrorInfo fromException(Object error) {
    final String raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.toLowerCase().contains('quota') || raw.toLowerCase().contains('insufficient_quota')) {
      return quotaExceeded;
    }
    if (raw.toLowerCase().contains('invalid') && raw.toLowerCase().contains('api key')) {
      return invalidApiKey;
    }
    if (raw.toLowerCase().contains('not configured') || raw.contains('OPENAI_API_KEY')) {
      return missingApiKey;
    }
    return ApiErrorInfo(title: 'Something went wrong', message: raw);
  }

  static ApiErrorInfo fromOpenAiResponse(int statusCode, String body) {
    String? apiMessage;
    String? apiCode;
    try {
      final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
      final Map<String, dynamic>? error = json['error'] as Map<String, dynamic>?;
      apiMessage = error?['message'] as String?;
      apiCode = error?['code'] as String?;
    } catch (_) {}

    if (statusCode == 429 || apiCode == 'insufficient_quota') {
      return quotaExceeded;
    }
    if (statusCode == 401) {
      return invalidApiKey;
    }
    if (statusCode == 403) {
      return const ApiErrorInfo(
        title: 'OpenAI access denied',
        message: 'This API key cannot use the requested model.',
        steps: <String>[
          'Check permissions at platform.openai.com',
          'Try a new key from an account with API access',
        ],
      );
    }
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return ApiErrorInfo(title: 'OpenAI error', message: apiMessage);
    }
    return ApiErrorInfo(
      title: 'OpenAI request failed',
      message: 'The server returned status $statusCode. Try again in a moment.',
    );
  }

  static const ApiErrorInfo quotaExceeded = ApiErrorInfo(
    title: 'OpenAI credits ran out',
    message: 'Your API key has no remaining quota, so the tutor cannot reply.',
    steps: <String>[
      'Open platform.openai.com → Settings → Billing and add credits',
      'Or create a new API key on an account with credits',
      'Put the key in your project .env as OPENAI_API_KEY=sk-...',
      'Stop the app and run it again (hot restart may not reload .env)',
    ],
  );

  static const ApiErrorInfo invalidApiKey = ApiErrorInfo(
    title: 'Invalid API key',
    message: 'OpenAI rejected your API key.',
    steps: <String>[
      'Copy a fresh key from platform.openai.com/api-keys',
      'Update OPENAI_API_KEY in your .env file',
      'Restart the app',
    ],
  );

  static const ApiErrorInfo missingApiKey = ApiErrorInfo(
    title: 'OpenAI not set up',
    message: 'No API key was found for the AI tutor.',
    steps: <String>[
      'Add OPENAI_API_KEY=sk-... to your .env file in the project root',
      'Restart the app',
    ],
  );
}
