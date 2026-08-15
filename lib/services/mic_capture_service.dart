import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../utils/lecture_record_config.dart';
import 'lecture_stream_capture.dart';

/// Single shared microphone recorder for lecture / summarize capture.
///
/// Uses PCM streaming so every sample is captured — the WAV file encoder in the
/// `record` plugin often truncates or mislabels long recordings.
class MicCaptureService {
  MicCaptureService._();

  static final MicCaptureService instance = MicCaptureService._();

  final AudioRecorder recorder = AudioRecorder();
  final LectureStreamCapture _capture = LectureStreamCapture();

  StreamSubscription<RecordState>? _stateSub;
  StreamSubscription<Uint8List>? _streamSub;
  bool _sessionPrepared = false;
  bool _intentionalStop = false;
  VoidCallback? onUnexpectedStop;

  Uint8List? _lastWavBytes;

  bool get isCapturing => _capturing;
  bool _capturing = false;

  int get streamedPcmBytes => _capture.pcmBytes;
  Duration get capturedDuration => _capture.capturedDuration;
  Uint8List? get lastWavBytes => _lastWavBytes;

  Future<void> prepareForPlayback() async {
    if (kIsWeb) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: <AVAudioSessionOptions>{
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            audioMode: AndroidAudioMode.normal,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _sessionPrepared = false;
    } catch (error) {
      debugPrint('Playback session prep: $error');
    }
  }

  Future<void> prepareSession() async {
    if (kIsWeb || _sessionPrepared) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: <AVAudioSessionOptions>{
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.allowBluetooth,
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            audioMode: AndroidAudioMode.normal,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.voiceCommunication,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      _sessionPrepared = true;
      await Future<void>.delayed(const Duration(milliseconds: 120));
    } catch (error) {
      debugPrint('Mic session prep: $error');
    }
  }

  void _bindStateListener() {
    _stateSub ??= recorder.onStateChanged().listen((RecordState state) {
      if (state == RecordState.record || state == RecordState.pause) {
        _capturing = true;
        return;
      }
      if (state == RecordState.stop && _capturing && !_intentionalStop) {
        _capturing = false;
        onUnexpectedStop?.call();
      }
    });
  }

  Future<void> start({required String path}) async {
    // Android keeps microphone capture alive outside the app through the
    // recorder's foreground service. Request notification access first so its
    // required ongoing recording indicator is visible on Android 13+.
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await Permission.notification.request();
      } catch (error) {
        debugPrint('Recording notification permission: $error');
      }
    }

    await prepareSession();
    _bindStateListener();
    _lastWavBytes = null;

    if (await recorder.isRecording()) {
      try {
        await recorder.stop();
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    await _streamSub?.cancel();
    _streamSub = null;

    await _capture.begin(wavPath: path);

    final Stream<Uint8List> stream =
        await recorder.startStream(lectureStreamRecordConfig());
    _streamSub = stream.listen(
      _capture.addChunk,
      onDone: () {
        if (_capturing && !_intentionalStop) {
          _capturing = false;
          onUnexpectedStop?.call();
        }
      },
      onError: (Object error) => debugPrint('Lecture stream error: $error'),
    );

    _capturing = true;
  }

  Future<String> startLecture({required String path}) async {
    await start(path: path);
    return path;
  }

  Future<String?> stop() async {
    _intentionalStop = true;
    _capturing = false;
    try {
      try {
        await recorder.stop();
      } catch (error) {
        debugPrint('Mic capture stop: $error');
      }
      await _streamSub?.cancel();
      _streamSub = null;

      final LectureCaptureResult result = await _capture.finish();
      _lastWavBytes = result.wavBytes;
      return result.path;
    } catch (error) {
      debugPrint('Mic capture finalize: $error');
      return null;
    } finally {
      _intentionalStop = false;
    }
  }

  Future<void> pause() => recorder.pause();

  Future<void> resume() => recorder.resume();

  Future<void> cancelIfActive() async {
    if (!await recorder.isRecording()) {
      _capturing = false;
      return;
    }
    try {
      await recorder.stop();
    } catch (_) {}
    await _streamSub?.cancel();
    _streamSub = null;
    await _capture.discard();
    _lastWavBytes = null;
    _capturing = false;
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    _stateSub = null;
    await _streamSub?.cancel();
    _streamSub = null;
    await _capture.discard();
    await recorder.dispose();
    _capturing = false;
    _sessionPrepared = false;
    _lastWavBytes = null;
  }
}
