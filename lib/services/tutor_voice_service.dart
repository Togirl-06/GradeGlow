import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../config/app_config.dart';
import '../utils/lecture_record_config.dart';
import '../utils/speech_text.dart';
import 'mic_capture_service.dart';
import 'openai_tts_service.dart';
import 'openai_whisper_service.dart';

/// Result of initializing mic + text-to-speech.
class VoiceCapabilities {
  const VoiceCapabilities({
    required this.canListen,
    required this.canSpeak,
    this.statusMessage,
    this.usesOpenAiTts = false,
    this.usesWhisperVoiceNotes = false,
  });

  final bool canListen;
  final bool canSpeak;
  final String? statusMessage;
  final bool usesOpenAiTts;
  final bool usesWhisperVoiceNotes;

  bool get anyReady => canListen || canSpeak;
}

/// Mic input and spoken tutor replies (OpenAI Audio API + device TTS fallback).
class TutorVoiceService {
  TutorVoiceService({OpenAiTtsService? openAiTts, OpenAiWhisperService? openAiWhisper})
      : _openAiTts = openAiTts ?? OpenAiTtsService(),
        _openAiWhisper = openAiWhisper ?? OpenAiWhisperService();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  final OpenAiTtsService _openAiTts;
  final OpenAiWhisperService _openAiWhisper;
  final AudioPlayer _player = AudioPlayer();

  bool _speechReady = false;
  bool _recorderReady = false;
  bool _ttsReady = false;
  bool _useOpenAiTts = false;
  bool _listening = false;
  bool _audioCapturing = false;
  String? _capturePath;
  bool _speaking = false;
  VoidCallback? _onListenEnd;
  String? _statusMessage;
  String? _lastSpeakError;

  bool get canListen =>
      (AppConfig.hasOpenAi && (kIsWeb || _recorderReady)) || _speechReady;
  bool get canSpeak => _ttsReady || _useOpenAiTts;
  bool get isReady => _speechReady || _recorderReady;
  bool get isListening => _listening || _speech.isListening || _audioCapturing;
  bool get isAudioCapturing => _audioCapturing;
  /// OpenAI Whisper voice notes — record package on all platforms (incl. web).
  bool get usesWhisperVoiceNotes => AppConfig.hasOpenAi && _recorderReady;
  bool get isSpeaking => _speaking;
  bool get usesOpenAiTts => _useOpenAiTts;
  String? get statusMessage => _statusMessage;
  String? get lastSpeakError => _lastSpeakError;

  Future<VoiceCapabilities> initialize() async {
    _statusMessage = null;
    _useOpenAiTts = AppConfig.hasOpenAi;
    await _initDeviceTts();
    await _initAudioPlayer();
    await _initRecorder();

    final bool micOk = await _ensurePermissions();
    if (!micOk) {
      _statusMessage =
          'Microphone optional for typing. Allow mic in Settings for voice input.';
    }

    if (micOk || kIsWeb) {
      await ensureDeviceSpeechReady();
    }

    return VoiceCapabilities(
      canListen: canListen,
      canSpeak: canSpeak,
      statusMessage: _statusMessage,
      usesOpenAiTts: _useOpenAiTts,
      usesWhisperVoiceNotes: usesWhisperVoiceNotes,
    );
  }

  /// Browser / on-device speech recognition for live voice (fast path).
  Future<bool> ensureDeviceSpeechReady() async {
    if (_speechReady) return true;
    if (!kIsWeb && !await _ensurePermissions()) return false;

    _speechReady = await _speech.initialize(
      onError: (dynamic error) => debugPrint('Speech error: $error'),
      onStatus: (String status) {
        if (status == 'done' || status == 'notListening') {
          final bool wasListening = _listening;
          _listening = false;
          if (wasListening) {
            final VoidCallback? end = _onListenEnd;
            _onListenEnd = null;
            end?.call();
          }
        }
      },
    );

    if (!_speechReady) {
      _statusMessage ??= _platformSpeechHint();
    }
    return _speechReady;
  }

  /// Lightweight setup for spoken output only (Listen / read-aloud buttons).
  ///
  /// Unlike [initialize], this never requests microphone permission — it only
  /// prepares text-to-speech, so screens that just read content aloud don't
  /// trigger a mic prompt. Returns whether the tutor can speak.
  Future<bool> initializeForSpeechOutput() async {
    _useOpenAiTts = AppConfig.hasOpenAi;
    await _initDeviceTts();
    await _initAudioPlayer();
    return canSpeak;
  }

  /// Capture a single spoken answer end-to-end and return the recognized text
  /// (trimmed), or null if nothing was heard.
  ///
  /// Picks OpenAI Whisper when available and falls back to on-device speech
  /// recognition. Auto-stops after [silenceFor] of quiet or [maxDuration].
  /// Pass a [shouldContinue] that flips to false to cancel early (e.g. the user
  /// tapped stop); callers may also invoke [stopListening] to cancel.
  Future<String?> captureSpokenAnswer({
    required bool Function() shouldContinue,
    void Function(double level)? onLevel,
    void Function(String partial)? onPartial,
    Duration silenceFor = const Duration(milliseconds: 2000),
    Duration maxDuration = const Duration(seconds: 30),
    Duration minCaptureDuration = const Duration(milliseconds: 1500),
    bool preferDeviceSpeech = false,
    bool fastResume = false,
  }) async {
    if (!_speechReady && !_recorderReady) {
      await initialize();
    }
    if (!canListen) return null;

    if (preferDeviceSpeech) {
      if (!await ensureDeviceSpeechReady()) return null;

      final Completer<String?> completer = Completer<String?>();
      String last = '';
      final bool started = await startListening(
        pauseFor: silenceFor,
        listenFor: maxDuration,
        fastResume: fastResume,
        onWords: (String words, bool isFinal) {
          last = words;
          onPartial?.call(words);
          onLevel?.call(words.trim().isEmpty ? 0.2 : 0.7);
          if (isFinal && words.trim().isNotEmpty && !completer.isCompleted) {
            completer.complete(words.trim());
          }
        },
        onListeningState: () {},
        onListeningStopped: () {
          if (!completer.isCompleted) {
            final String text = last.trim();
            completer.complete(text.isEmpty ? null : text);
          }
        },
      );
      if (!started && !completer.isCompleted) {
        completer.complete(null);
      }
      final String? result = await completer.future;
      if (!shouldContinue()) return null;
      if (result != null && result.isNotEmpty) return result;
      if (!started) return null;
      return '';
    }

    if (usesWhisperVoiceNotes) {
      return (await captureUtteranceWithWhisper(
        shouldContinue: shouldContinue,
        onLevel: onLevel,
        silenceFor: silenceFor,
        maxDuration: maxDuration,
        minCaptureDuration: minCaptureDuration,
        fastResume: fastResume,
      ))?.trim();
    }

    if (!_speechReady) return null;

    final Completer<String?> completer = Completer<String?>();
    String last = '';
    final bool started = await startListening(
      pauseFor: silenceFor,
      listenFor: maxDuration,
      fastResume: fastResume,
      onWords: (String words, bool isFinal) {
        last = words;
        onPartial?.call(words);
        onLevel?.call(words.trim().isEmpty ? 0.2 : 0.7);
        if (isFinal && words.trim().isNotEmpty && !completer.isCompleted) {
          completer.complete(words.trim());
        }
      },
      onListeningState: () {},
      onListeningStopped: () {
        if (!completer.isCompleted) {
          final String text = last.trim();
          completer.complete(text.isEmpty ? null : text);
        }
      },
    );
    if (!started && !completer.isCompleted) {
      completer.complete(null);
    }
    return completer.future;
  }

  /// Call from a user tap before voice notes / live voice (web needs the gesture).
  Future<bool> prepareForVoiceNoteCapture() async {
    await prepareForSpeechInput();
    if (AppConfig.hasOpenAi) {
      if (kIsWeb) {
        await MicCaptureService.instance.prepareSession();
      }
      await _initRecorder(force: true);
      await ensureDeviceSpeechReady();
      return _recorderReady || _speechReady;
    }
    return ensureDeviceSpeechReady();
  }

  Future<void> _initRecorder({bool force = false}) async {
    if (_recorderReady && !force) return;
    try {
      if (!kIsWeb && !await _ensurePermissions()) {
        _recorderReady = false;
        return;
      }
      _recorderReady = await _recorder.hasPermission();
    } catch (error) {
      debugPrint('Recorder init error: $error');
      _recorderReady = false;
    }
  }

  String get _recordingExtension => lectureRecordingExtension();

  RecordConfig get _recordConfig => lectureRecordConfig(enableAndroidService: false);

  Future<String?> _waitForRecordingFile(String path, {int maxAttempts = 20}) async {
    if (kIsWeb) {
      for (int i = 0; i < maxAttempts; i++) {
        if (path.startsWith('blob:') || path.startsWith('http')) {
          try {
            final http.Response response = await http.get(Uri.parse(path));
            if (response.statusCode == 200 && response.bodyBytes.length >= 300) {
              return path;
            }
          } catch (_) {}
        }
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
      return null;
    }

    for (int i = 0; i < maxAttempts; i++) {
      final File file = File(path);
      if (await file.exists() && await file.length() >= 300) return path;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    final File file = File(path);
    if (await file.exists() && await file.length() > 0) return path;
    return null;
  }

  /// Records mic audio for voice notes (transcribed with OpenAI Whisper on stop).
  Future<bool> startVoiceNoteAudio() async {
    if (!AppConfig.hasOpenAi) return false;
    if (_audioCapturing) return true;

    await _initRecorder(force: true);
    if (!_recorderReady) return false;

    try {
      if (kIsWeb) {
        final bool supported = await _recorder.isEncoderSupported(_recordConfig.encoder);
        if (!supported) return false;
        _capturePath = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.$_recordingExtension';
      } else {
        final Directory dir = await getTemporaryDirectory();
        _capturePath = '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.$_recordingExtension';
      }
      if (kIsWeb) {
        await MicCaptureService.instance.prepareSession();
      }
      await _recorder.start(
        _recordConfig,
        path: _capturePath!,
      );
      _audioCapturing = true;
      return true;
    } catch (error) {
      debugPrint('Voice note record start: $error');
      _audioCapturing = false;
      _capturePath = null;
      return false;
    }
  }

  Future<String?> finishVoiceNoteAudio() async {
    if (!_audioCapturing) return null;

    String? filePath;
    try {
      filePath = await _recorder.stop();
    } catch (error) {
      debugPrint('Voice note record stop: $error');
    } finally {
      _audioCapturing = false;
    }

    filePath ??= _capturePath;
    _capturePath = null;
    if (filePath == null || filePath.isEmpty) return null;

    final String? readyPath = await _waitForRecordingFile(filePath);
    if (readyPath == null) return null;

    try {
      return await _openAiWhisper.transcribeFile(readyPath);
    } catch (error) {
      _lastSpeakError = error.toString().replaceFirst('Exception: ', '');
      debugPrint('Whisper error: $error');
      rethrow;
    }
  }

  Future<void> cancelVoiceNoteAudio() async {
    if (!_audioCapturing) return;
    try {
      await _recorder.stop();
    } catch (_) {}
    _audioCapturing = false;
    _capturePath = null;
  }

  /// Live mic level 0–1 while recording a voice note.
  Stream<double> watchVoiceNoteLevel() {
    if (!_audioCapturing) {
      return Stream<double>.value(0);
    }
    return _recorder.onAmplitudeChanged(const Duration(milliseconds: 80)).map((Amplitude amplitude) {
      return ((amplitude.current + 45) / 45).clamp(0.05, 1.0);
    });
  }

  /// Optional live caption while the WAV records (UI preview only).
  Future<bool> startVoiceNotePreview({
    required void Function(String words) onWords,
  }) async {
    if (!_speechReady || _listening || _speech.isListening) return false;

    final String? localeId = await _preferredLocaleId();
    _listening = true;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) => onWords(result.recognizedWords),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          pauseFor: const Duration(seconds: 45),
          listenFor: const Duration(minutes: 5),
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          localeId: localeId,
        ),
      );
    } catch (error) {
      debugPrint('Voice note preview listen: $error');
      _listening = false;
      return false;
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!_speech.isListening) {
      _listening = false;
      return false;
    }
    return true;
  }

  /// Record one spoken turn and transcribe with Whisper (reliable when device STT is unavailable).
  Future<String?> captureUtteranceWithWhisper({
    required bool Function() shouldContinue,
    void Function(double level)? onLevel,
    Duration silenceFor = const Duration(milliseconds: 2500),
    Duration maxDuration = const Duration(minutes: 2),
    double speechLevelThreshold = 0.12,
    Duration minCaptureDuration = const Duration(milliseconds: 1500),
    bool fastResume = false,
  }) async {
    if (!AppConfig.hasOpenAi) return null;

    await prepareForSpeechInput(
      settleDelay: fastResume ? const Duration(milliseconds: 80) : const Duration(milliseconds: 300),
    );
    if (!fastResume) {
      await _initRecorder(force: true);
    } else if (!_recorderReady) {
      await _initRecorder(force: true);
    }
    if (!_recorderReady) return null;

    final bool started = await startVoiceNoteAudio();
    if (!started) return null;

    DateTime lastSpeech = DateTime.now();
    final DateTime startedAt = DateTime.now();
    StreamSubscription<double>? levelSub;

    try {
      levelSub = watchVoiceNoteLevel().listen((double level) {
        onLevel?.call(level);
        if (level >= speechLevelThreshold) {
          lastSpeech = DateTime.now();
        }
      });

      while (shouldContinue()) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final Duration elapsed = DateTime.now().difference(startedAt);
        final Duration quiet = DateTime.now().difference(lastSpeech);
        if (elapsed >= minCaptureDuration && quiet >= silenceFor) break;
        if (elapsed >= maxDuration) break;
      }
    } finally {
      await levelSub?.cancel();
    }

    if (!shouldContinue()) {
      await cancelVoiceNoteAudio();
      return null;
    }

    try {
      final String? text = (await finishVoiceNoteAudio())?.trim();
      return text == null || text.isEmpty ? '' : text;
    } catch (error) {
      debugPrint('Whisper live capture error: $error');
      rethrow;
    }
  }

  Future<void> stopVoiceNotePreview() async {
    if (!_listening && !_speech.isListening) return;
    try {
      await _speech.stop();
    } catch (_) {}
    _listening = false;
  }

  /// Release the mic from recording / preview so live speech can start.
  Future<void> prepareForSpeechInput({
    Duration settleDelay = const Duration(milliseconds: 300),
  }) async {
    if (_audioCapturing) {
      await cancelVoiceNoteAudio();
    }
    await stopVoiceNotePreview();
    if (_speech.isListening) {
      try {
        await _speech.stop();
      } catch (_) {}
    }
    _listening = false;
    _onListenEnd = null;
    if (settleDelay > Duration.zero) {
      await Future<void>.delayed(settleDelay);
    }
  }

  Future<void> _initAudioPlayer() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: <AVAudioSessionOptions>{
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      await _player.setVolume(1.0);
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
    } catch (error) {
      debugPrint('AudioPlayer init: $error');
    }
  }

  String _platformSpeechHint() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      if (AppConfig.hasOpenAi) {
        return 'Voice notes use OpenAI Whisper on Windows. Tap mic, speak, tap mic again.';
      }
      return 'Voice input needs OPENAI_API_KEY in .env on Windows. Replies can still be spoken.';
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      return 'Voice input is not supported on Linux. Type your question — replies can still be spoken.';
    }
    return 'Speech recognition unavailable. Type your question or allow microphone access.';
  }

  Future<bool> _ensurePermissions() async {
    if (kIsWeb) return true;

    PermissionStatus mic = await Permission.microphone.status;
    if (!mic.isGranted) {
      mic = await Permission.microphone.request();
    }
    if (!mic.isGranted) return false;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      PermissionStatus speech = await Permission.speech.status;
      if (!speech.isGranted) {
        speech = await Permission.speech.request();
      }
      if (!speech.isGranted) return false;
    }

    return true;
  }

  Future<void> _initDeviceTts() async {
    if (_ttsReady) return;

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        final dynamic voices = await _tts.getVoices;
        if (voices is List && voices.isNotEmpty) {
          for (final dynamic voice in voices) {
            if (voice is Map && (voice['locale'] as String?)?.startsWith('en') == true) {
              await _tts.setVoice(Map<String, String>.from(
                voice.map((dynamic k, dynamic v) => MapEntry(k.toString(), v.toString())),
              ));
              break;
            }
          }
        }
      }
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);

      _tts.setStartHandler(() => _speaking = true);
      _tts.setCompletionHandler(() => _speaking = false);
      _tts.setErrorHandler((dynamic _) => _speaking = false);

      _ttsReady = true;
    } catch (error) {
      debugPrint('Device TTS init error: $error');
      _ttsReady = false;
    }
  }

  Future<bool> speak(String text, {bool preferDeviceVoice = false}) async {
    final String trimmed = speechTextFromMarkdown(text);
    if (trimmed.isEmpty) return false;

    _lastSpeakError = null;
    await stopSpeaking();

    if (preferDeviceVoice) {
      if (!_ttsReady) {
        await _initDeviceTts();
      }
      if (_ttsReady) {
        final bool spoke = await _speakWithDevice(trimmed);
        if (spoke) return true;
      }
    }

    if (_useOpenAiTts && AppConfig.hasOpenAi) {
      try {
        final Uint8List audio = await _openAiTts.synthesizeBytes(trimmed);
        final bool played = await _playMp3Bytes(audio);
        if (played) return true;
        _lastSpeakError = 'Audio player did not start. Trying device voice…';
        debugPrint(_lastSpeakError);
      } catch (error) {
        _lastSpeakError = error.toString().replaceFirst('Exception: ', '');
        debugPrint('OpenAI TTS error: $error');
      }
    }

    if (!_ttsReady) {
      await _initDeviceTts();
    }
    if (!_ttsReady) return false;

    return _speakWithDevice(trimmed);
  }

  Future<bool> _playMp3Bytes(Uint8List bytes) async {
    _speaking = true;
    StreamSubscription<PlayerState>? stateSub;
    StreamSubscription<void>? completeSub;
    String? tmpPath;

    try {
      final Source source;
      if (kIsWeb) {
        // No filesystem on web — play the bytes directly via a blob URL.
        source = BytesSource(bytes);
      } else {
        // Playing from a temp file is far more reliable on Android than an
        // in-memory BytesSource (which often reports "playing" but stays silent).
        final Directory dir = await getTemporaryDirectory();
        tmpPath = '${dir.path}/tutor_tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        await File(tmpPath).writeAsBytes(bytes, flush: true);
        source = DeviceFileSource(tmpPath);
      }

      await _player.stop();
      await _player.setVolume(1.0);

      final Completer<void> done = Completer<void>();
      completeSub = _player.onPlayerComplete.listen((_) {
        if (!done.isCompleted) done.complete();
      });
      stateSub = _player.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed && !done.isCompleted) {
          done.complete();
        }
      });

      await _player.play(source);

      // Confirm playback actually started.
      final bool started = await _waitForPlaying(timeout: const Duration(seconds: 4));
      if (!started) {
        debugPrint('OpenAI audio: play() called but player never entered playing state.');
        return false;
      }

      final int maxMs = (bytes.length / 160).round().clamp(3000, 180000);
      await done.future.timeout(
        Duration(milliseconds: maxMs),
        onTimeout: () => debugPrint('OpenAI audio: completion timeout after ${maxMs}ms'),
      );
      return true;
    } catch (error) {
      debugPrint('MP3 playback error: $error');
      return false;
    } finally {
      await stateSub?.cancel();
      await completeSub?.cancel();
      _speaking = false;
      if (tmpPath != null) {
        try {
          await File(tmpPath).delete();
        } catch (_) {}
      }
    }
  }

  Future<bool> _waitForPlaying({required Duration timeout}) async {
    if (_player.state == PlayerState.playing) return true;
    try {
      await _player.onPlayerStateChanged
          .firstWhere((PlayerState s) => s == PlayerState.playing)
          .timeout(timeout);
      return true;
    } catch (_) {
      return _player.state == PlayerState.playing;
    }
  }

  Future<bool> _speakWithDevice(String text) async {
    _speaking = true;
    try {
      await _tts.stop();
      final dynamic result = await _tts.speak(text);
      if (result is int && result != 1) {
        _lastSpeakError = 'Device voice unavailable (code $result).';
        debugPrint('Device TTS speak returned $result');
        return false;
      }
      return true;
    } catch (error) {
      _lastSpeakError = error.toString().replaceFirst('Exception: ', '');
      debugPrint('Device TTS speak error: $error');
      return false;
    } finally {
      _speaking = false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _player.stop();
    } catch (_) {}
    if (_ttsReady) {
      await _tts.stop();
    }
    _speaking = false;
  }

  Future<String?> _preferredLocaleId() async {
    final dynamic locales = await _speech.locales();
    if (locales is! List || locales.isEmpty) return null;
    for (final dynamic locale in locales) {
      final String id = locale.localeId as String? ?? '';
      if (id.startsWith('en')) return id;
    }
    return locales.first.localeId as String?;
  }

  Future<bool> startListening({
    required void Function(String words, bool isFinal) onWords,
    required VoidCallback onListeningState,
    VoidCallback? onListeningStopped,
    Duration pauseFor = const Duration(seconds: 2),
    Duration listenFor = const Duration(seconds: 60),
    bool fastResume = false,
  }) async {
    await prepareForSpeechInput(
      settleDelay: fastResume ? const Duration(milliseconds: 50) : const Duration(milliseconds: 300),
    );

    if (!_speechReady) {
      final VoiceCapabilities cap = await initialize();
      if (!cap.canListen) return false;
    }

    final String? localeId = await _preferredLocaleId();

    for (int attempt = 0; attempt < 3; attempt++) {
      if (_listening || _speech.isListening) {
        await prepareForSpeechInput();
      }

      _onListenEnd = onListeningStopped;
      _listening = true;
      onListeningState();

      try {
        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            onWords(result.recognizedWords, result.finalResult);
          },
          listenOptions: SpeechListenOptions(
            partialResults: true,
            pauseFor: pauseFor,
            listenFor: listenFor,
            cancelOnError: false,
            listenMode: ListenMode.dictation,
            localeId: localeId,
          ),
        );
      } catch (error) {
        debugPrint('listen error (attempt ${attempt + 1}): $error');
        _listening = false;
        _onListenEnd = null;
        continue;
      }

      final Duration settle = Duration(milliseconds: attempt == 0 ? 500 : 800);
      await Future<void>.delayed(settle);
      if (_speech.isListening) return true;

      try {
        await _speech.stop();
      } catch (_) {}
      _listening = false;
      _onListenEnd = null;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    return false;
  }

  Future<void> stopListening() async {
    if (_audioCapturing) {
      await cancelVoiceNoteAudio();
    }
    if (!_listening && !_speech.isListening) return;
    await _speech.stop();
    _listening = false;
    final VoidCallback? end = _onListenEnd;
    _onListenEnd = null;
    end?.call();
  }

  Future<void> dispose() async {
    await stopListening();
    await cancelVoiceNoteAudio();
    await stopSpeaking();
    await _recorder.dispose();
    await _player.dispose();
  }
}
