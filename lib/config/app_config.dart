import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';
import 'app_bootstrap.dart';

class AppConfig {
  static String _env(String key) => dotenv.env[key]?.trim() ?? '';

  static String get openAiApiKey => _env('OPENAI_API_KEY');

  /// Google OAuth web client ID — used for Google Sign-In on web and as server client on mobile.
  static String get googleWebClientId {
    final String fromEnv = _env('GOOGLE_WEB_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return DefaultFirebaseOptions.webGoogleClientId;
  }

  /// True when [Firebase.initializeApp] succeeded via [DefaultFirebaseOptions].
  static bool get hasFirebase => AppBootstrap.firebaseReady;

  static bool get hasOpenAi => openAiApiKey.isNotEmpty;
}
