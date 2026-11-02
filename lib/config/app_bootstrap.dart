import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';
import '../services/exam_notification_service.dart';
import '../utils/test_environment.dart';
import 'app_config.dart';

class AppBootstrap {
  static bool _initialized = false;
  static bool firebaseReady = false;

  static bool get isInitialized => _initialized;

  static const Duration _stepTimeout = Duration(seconds: 10);

  static Future<void> initialize() async {
    if (_initialized) return;

    if (isFlutterTest) {
      _initialized = true;
      return;
    }

    // Prefer --dart-define for secrets. Local `.env` asset is optional (debug).
    try {
      await dotenv.load(fileName: '.env').timeout(const Duration(seconds: 3));
    } catch (_) {
      // Missing asset is fine when using dart-define.
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(_stepTimeout);
      firebaseReady = true;
    } catch (e) {
      debugPrint('Firebase init failed/timed out: $e');
      firebaseReady = false;
    }

    // Crashlytics in debug reports Flutter errors as fatal native crashes, which
    // drops the observatory connection ("Lost connection to device") and spams
    // "Unable to read App Quality Sessions session id" on emulators.
    if (firebaseReady && !kIsWeb && kReleaseMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      try {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true)
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    } else if (firebaseReady && !kIsWeb) {
      try {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false)
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    // Notifications are native-only; web path is a no-op inside the service.
    if (!kIsWeb) {
      try {
        await ExamNotificationService.instance
            .initialize()
            .timeout(_stepTimeout);
      } catch (e) {
        debugPrint('Exam notifications init failed/timed out: $e');
      }
    } else {
      await ExamNotificationService.instance.initialize();
    }

    AppConfig.debugLogKeySource();
    _initialized = true;
  }
}
