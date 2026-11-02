import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';
import '../models/course.dart';
import '../utils/lecture_record_config.dart';
import '../utils/recording_limits.dart';
import 'mic_capture_service.dart';

enum LectureRecordingPhase { idle, recording, saved, summarizing }

/// Keeps lecture recording alive while the user navigates the app.
class LectureRecordingService extends ChangeNotifier {
  final MicCaptureService _mic = MicCaptureService.instance;
  Timer? _timer;
  DateTime? _recordingStartedAt;

  LectureRecordingPhase _phase = LectureRecordingPhase.idle;
  Duration _elapsed = Duration.zero;
  String? _filePath;
  Course? _course;
  String? _title;
  String? _error;

  LectureRecordingPhase get phase => _phase;
  Duration get elapsed => _elapsed;
  Course? get course => _course;
  String? get title => _title;
  String? get error => _error;
  bool get isActive => _phase != LectureRecordingPhase.idle;

  String get statusLabel => switch (_phase) {
        LectureRecordingPhase.recording => 'Recording lecture',
        LectureRecordingPhase.saved => 'Recording saved',
        LectureRecordingPhase.summarizing => 'Building notes…',
        LectureRecordingPhase.idle => '',
      };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> start({required Course course, required String title}) async {
    if (_phase != LectureRecordingPhase.idle) {
      _error = 'Finish or cancel the current recording first.';
      notifyListeners();
      return false;
    }

    if (!AppConfig.hasOpenAi) {
      _error = 'Add OPENAI_API_KEY to your .env file.';
      notifyListeners();
      return false;
    }

    try {
      if (!kIsWeb) {
        final PermissionStatus mic = await Permission.microphone.request();
        if (!mic.isGranted) {
          _error = 'Microphone permission is required to record.';
          notifyListeners();
          return false;
        }
      }

      final bool permitted = await _mic.recorder.hasPermission();
      if (!permitted) {
        _error = kIsWeb
            ? 'Microphone blocked. Allow mic access in your browser settings.'
            : 'Microphone permission is required to record.';
        notifyListeners();
        return false;
      }

      final String ext = lectureRecordingExtension();
      final String path = kIsWeb
          ? 'lecture_${DateTime.now().millisecondsSinceEpoch}.$ext'
          : '${(await getTemporaryDirectory()).path}/lecture_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _mic.start(path: path);
      _course = course;
      _title = title;
      _filePath = path;
      _elapsed = Duration.zero;
      _recordingStartedAt = DateTime.now();
      _error = null;
      _phase = LectureRecordingPhase.recording;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _syncElapsedFromClock();
        if (_elapsed >= RecordingLimits.maxDuration) {
          unawaited(stop());
          return;
        }
        notifyListeners();
      });
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not start recording.';
      notifyListeners();
      return false;
    }
  }

  Future<void> stop() async {
    if (_phase != LectureRecordingPhase.recording) return;
    _timer?.cancel();
    try {
      final String? stoppedPath = await _mic.stop();
      if (stoppedPath != null && stoppedPath.isNotEmpty) {
        _filePath = stoppedPath;
      }
    } catch (_) {}
    _phase = LectureRecordingPhase.saved;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    if (_phase == LectureRecordingPhase.recording) {
      await stop();
    }
  }

  Future<String?> validatedFilePath() async {
    final String? path = _filePath;
    if (path == null) return null;
    if (kIsWeb) {
      if (path.startsWith('blob:') || path.startsWith('http')) return path;
      return null;
    }
    final File file = File(path);
    if (!await file.exists() || await file.length() < 500) {
      _error = 'Recording too short. Speak longer and try again.';
      notifyListeners();
      return null;
    }
    return path;
  }

  void beginSummarizing() {
    _phase = LectureRecordingPhase.summarizing;
    _error = null;
    notifyListeners();
  }

  void failSummarize(String message) {
    _phase = LectureRecordingPhase.saved;
    _error = message;
    notifyListeners();
  }

  Future<void> cancel() async {
    _timer?.cancel();
    if (_phase == LectureRecordingPhase.recording) {
      try {
        await _mic.stop();
      } catch (_) {}
    }
    final String? path = _filePath;
    if (path != null && !kIsWeb) {
      try {
        final File file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    _reset();
  }

  void _reset() {
    _timer?.cancel();
    _phase = LectureRecordingPhase.idle;
    _elapsed = Duration.zero;
    _recordingStartedAt = null;
    _filePath = null;
    _course = null;
    _title = null;
    _error = null;
    notifyListeners();
  }

  void complete() => _reset();

  String formatElapsed() => formatRecordingDuration(_elapsed);

  void _syncElapsedFromClock() {
    final DateTime? startedAt = _recordingStartedAt;
    if (startedAt == null) return;
    final Duration live = DateTime.now().difference(startedAt);
    _elapsed = live > RecordingLimits.maxDuration ? RecordingLimits.maxDuration : live;
  }
}
