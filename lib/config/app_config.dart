import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';
import 'app_bootstrap.dart';

class AppConfig {
  static String _env(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Prefer compile-time `--dart-define=OPENAI_API_KEY=...` so release builds
  /// do not need a bundled `.env` asset. Falls back to dotenv for local debug.
  static String get openAiApiKey {
    const String fromDefine = String.fromEnvironment('OPENAI_API_KEY');
    if (fromDefine.trim().isNotEmpty) return fromDefine.trim();
    return _env('OPENAI_API_KEY');
  }

  /// Optional backend proxy base URL (Cloud Function / Hosting rewrite).
  /// On web, callers also fall back to same-origin `/api/openai` when unset.
  static String get openAiProxyUrl {
    const String fromDefine = String.fromEnvironment('OPENAI_PROXY_URL');
    if (fromDefine.trim().isNotEmpty) return fromDefine.trim();
    return _env('OPENAI_PROXY_URL');
  }

  static bool get usesOpenAiProxy => openAiProxyUrl.isNotEmpty;

  /// Google OAuth web client ID — used for Google Sign-In on web and as server client on mobile.
  static String get googleWebClientId {
    final String fromEnv = _env('GOOGLE_WEB_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    const String fromDefine = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    if (fromDefine.isNotEmpty) return fromDefine;
    return DefaultFirebaseOptions.webGoogleClientId;
  }

  /// True when [Firebase.initializeApp] succeeded via [DefaultFirebaseOptions].
  static bool get hasFirebase => AppBootstrap.firebaseReady;

  /// Web uses the Hosting `/api/openai` proxy (server-side key).
  /// Native/desktop need OPENAI_API_KEY via --dart-define or local .env load.
  static bool get hasOpenAi =>
      openAiApiKey.isNotEmpty || usesOpenAiProxy || kIsWeb;

  static void debugLogKeySource() {
    if (!kDebugMode) return;
    if (usesOpenAiProxy) {
      debugPrint('OpenAI: using proxy $openAiProxyUrl');
    } else if (openAiApiKey.isNotEmpty) {
      debugPrint('OpenAI: key loaded (${openAiApiKey.length} chars)');
    } else {
      debugPrint('OpenAI: no key — offline / fallback modes only');
    }
  }
}
