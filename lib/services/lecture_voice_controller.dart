import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../utils/textbook_speech.dart';
import 'openai_tts_service.dart';
import 'tutor_voice_service.dart';

/// Safe text-to-speech for lectures — speech output only, no microphone.
/// Uses OpenAI natural voice when configured; never falls back to the robotic
/// device TTS during a lecture (that voice sounded wrong and mixed mid-talk).
class LectureVoiceController {
  final TutorVoiceService _voice = TutorVoiceService();
  bool _ready = false;

  bool _stopRequested = false;

  bool get isAvailable => _ready;

  bool get isPaused => _voice.isPlaybackPaused;

  /// 0–1 progress through the current spoken utterance (drives slide sync).
  ValueListenable<double> get utteranceProgress => _voice.utteranceProgress;

  Future<bool> ensureReady() async {
    if (_ready) return true;
    try {
      _ready = await _voice.initializeForSpeechOutput();
    } catch (e) {
      debugPrint('Lecture voice unavailable: $e');
      _ready = false;
    }
    return _ready;
  }

  Future<void> speak(String text, double speed) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!await ensureReady()) return;
    try {
      await _voice.setPlaybackSpeed(speed);
      await _voice.speak(
        trimmed,
        preferDeviceVoice: false,
        // OpenAI only when keyed; otherwise device is the sole engine.
        allowDeviceFallback: !AppConfig.hasOpenAi,
      );
    } catch (e) {
      debugPrint('Lecture speak failed: $e');
    }
  }

  /// Warm the next utterance so slide changes do not sit in silence.
  Future<void> prefetch(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!await ensureReady()) return;
    try {
      await _voice.prefetchSpeak(trimmed);
    } catch (e) {
      debugPrint('Lecture prefetch failed: $e');
    }
  }

  /// Apply speed immediately to the current lecture audio.
  Future<void> setSpeed(double speed) async {
    try {
      if (!_ready) await ensureReady();
      await _voice.setPlaybackSpeed(speed);
    } catch (e) {
      debugPrint('Lecture setSpeed failed: $e');
    }
  }

  String get voiceId => _voice.openAiVoice;

  String get voiceLabel => OpenAiTtsVoices.labelFor(_voice.openAiVoice);

  Future<void> setVoice(String voiceId) async {
    try {
      if (!_ready) await ensureReady();
      await _voice.setOpenAiVoice(voiceId);
    } catch (e) {
      debugPrint('Lecture setVoice failed: $e');
    }
  }

  /// Read sentences one at a time with optional highlight callback.
  Future<bool> speakSequence({
    required List<String> sentences,
    required double speed,
    int startIndex = 0,
    void Function(int index, String sentence)? onSentence,
  }) async {
    _stopRequested = false;
    if (sentences.isEmpty) return false;
    if (!await ensureReady()) return false;
    await _voice.setPlaybackSpeed(speed);
    bool spokeAny = false;
    final int from = startIndex.clamp(0, sentences.length - 1);
    for (int i = from; i < sentences.length; i++) {
      if (_stopRequested) break;
      while (_voice.isPlaybackPaused && !_stopRequested) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
      if (_stopRequested) break;
      final String line = sentences[i].trim();
      if (line.isEmpty) continue;
      onSentence?.call(i, line);
      try {
        final bool spoke = await _voice.speak(
          speechSentence(line),
          preferDeviceVoice: false,
          allowDeviceFallback: !AppConfig.hasOpenAi,
        );
        if (!spoke) {
          _ready = false;
          return spokeAny;
        }
        spokeAny = true;
      } catch (e) {
        debugPrint('Lecture sequence speak failed: $e');
        _ready = false;
        break;
      }
    }
    return spokeAny;
  }

  /// Soft pause — keeps the current utterance so resume does not restart it.
  Future<void> pause() async {
    try {
      await _voice.pauseSpeaking();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await _voice.resumeSpeaking();
    } catch (_) {}
  }

  Future<void> stop() async {
    _stopRequested = true;
    try {
      await _voice.stopSpeaking();
    } catch (_) {}
  }

  /// Seek within the current utterance (0–1) so scrubber and voice stay aligned.
  Future<void> seekUtterance(double fraction) async {
    try {
      if (!_ready) await ensureReady();
      await _voice.seekUtterance(fraction);
    } catch (e) {
      debugPrint('Lecture seekUtterance failed: $e');
    }
  }

  void dispose() {
    unawaited(_voice.stopSpeaking().catchError((Object _) {}));
  }
}
