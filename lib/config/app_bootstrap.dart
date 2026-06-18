import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';
import '../services/exam_notification_service.dart';

class AppBootstrap {
  static bool _initialized = false;
  static bool firebaseReady = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Asset missing in tests — caller may use dotenv.testLoad.
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
    } catch (_) {
      firebaseReady = false;
    }

    try {
      await ExamNotificationService.instance.initialize();
    } catch (_) {
      // Notifications optional if platform setup is incomplete.
    }

    _initialized = true;
  }
}
