import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sounds for in-lecture quick checks: alert chime on appear, soft tick while open.
class LectureQuestionTicker {
  LectureQuestionTicker._();

  static final AudioPlayer _tickPlayer = AudioPlayer();
  static final AudioPlayer _alertPlayer = AudioPlayer();
  static bool _ready = false;
  static bool _playing = false;

  static Future<void> _ensureReady() async {
    if (_ready) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: <AVAudioSessionOptions>{
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      await _tickPlayer.setReleaseMode(ReleaseMode.loop);
      await _tickPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _tickPlayer.setVolume(0.45);
      await _alertPlayer.setReleaseMode(ReleaseMode.release);
      await _alertPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _alertPlayer.setVolume(0.9);
      _ready = true;
    } catch (error) {
      debugPrint('LectureQuestionTicker init: $error');
    }
  }

  /// One-shot notification chime — play when the pop quiz appears.
  static Future<void> playAlert() async {
    await _ensureReady();
    try {
      await _alertPlayer.stop();
      await _alertPlayer.play(AssetSource('sounds/quiz_alert.wav'));
    } catch (error) {
      debugPrint('LectureQuestionTicker alert: $error');
    }
  }

  static Future<void> start() async {
    await _ensureReady();
    // Always alert first so the student notices the quiz popped up.
    await playAlert();
    await startTickOnly();
  }

  /// Resume the quiet countdown tick without replaying the alert chime.
  static Future<void> startTickOnly() async {
    await _ensureReady();
    if (_playing) return;
    try {
      await _tickPlayer.stop();
      await _tickPlayer.play(AssetSource('sounds/clock_tick.wav'));
      _playing = true;
    } catch (error) {
      debugPrint('LectureQuestionTicker startTickOnly: $error');
      _playing = false;
    }
  }

  static Future<void> stop() async {
    if (!_playing && !_ready) return;
    try {
      await _tickPlayer.stop();
      await _alertPlayer.stop();
    } catch (error) {
      debugPrint('LectureQuestionTicker stop: $error');
    } finally {
      _playing = false;
    }
  }
}
