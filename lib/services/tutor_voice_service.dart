import 'dart:async';
import 'dart:collection';
import 'dart:io';

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
  bool _playbackPaused = false;
  double _playbackSpeed = 1;
  /// Speed baked into the current OpenAI MP3 (player rate is relative to this).
  double _bakedSpeed = 1;
  String _openAiVoice = OpenAiTtsVoices.defaultId;
  Duration? _pausedAt;
  Completer<void>? _resumeGate;
  Completer<void>? _mp3Done;
  Uint8List? _activeMp3Bytes;
  String? _activeMp3Text;
  String? _activeMp3Path;
  /// Prefetched OpenAI MP3s keyed by `text|voice` so the next segment starts instantly.
  final LinkedHashMap<String, Uint8List> _ttsPrefetchCache =
      LinkedHashMap<String, Uint8List>();
  static const int _ttsPrefetchCacheMax = 8;
  bool _ignoreNextMp3Complete = false;
  VoidCallback? _onListenEnd;
  String? _statusMessage;
  String? _lastSpeakError;
  String? _lastListenError;

  /// 0–1 progress through the current spoken utterance (audio-backed when MP3).
  final ValueNotifier<double> utteranceProgress = ValueNotifier<double>(0);

  bool get canListen =>
      (AppConfig.hasOpenAi && (kIsWeb || _recorderReady)) || _speechReady;
  bool get canSpeak => _ttsReady || _useOpenAiTts;
  bool get isReady => _speechReady || _recorderReady;
  bool get isListening => _listening || _speech.isListening || _audioCapturing;
  bool get isAudioCapturing => _audioCapturing;
  /// OpenAI Whisper voice notes — record package on all platforms (incl. web).
  bool get usesWhisperVoiceNotes => AppConfig.hasOpenAi && _recorderReady;
  bool get isSpeaking => _speaking;
  bool get isPlaybackPaused => _playbackPaused;
  bool get usesOpenAiTts => _useOpenAiTts;
  String get openAiVoice => _openAiVoice;
  String? get statusMessage => _statusMessage;
  String? get lastSpeakError => _lastSpeakError;
  String? get lastListenError => _lastListenError;

  /// Switch professor voice. Clears cached audio so the next speak uses it.
  Future<void> setOpenAiVoice(String voiceId) async {
    final String next =
        OpenAiTtsVoices.isValid(voiceId) ? voiceId : OpenAiTtsVoices.defaultId;
    if (next == _openAiVoice) return;
    _openAiVoice = next;
    _activeMp3Text = null;
    _activeMp3Bytes = null;
  }

  Future<void> setPlaybackSpeed(double multiplier) async {
    final double next = multiplier.clamp(0.5, 2.5);
    _playbackSpeed = next;
    // Stretch/compress with player rate — no network re-synthesis on speed tap.
    await _applyEffectivePlayerRate(reinforce: true);
    if (_ttsReady) {
      try {
        await _tts.setSpeechRate((0.42 * _playbackSpeed).clamp(0.2, 1.0));
      } catch (_) {}
    }
  }

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

    // Web Speech API still needs getUserMedia granted in most browsers.
    if (kIsWeb && !await ensureMicrophoneAccess()) return false;

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

  /// Ensures the OS / browser has granted microphone access.
  Future<bool> ensureMicrophoneAccess() async {
    if (kIsWeb) {
      await _initRecorder(force: true);
      if (!_recorderReady) {
        _statusMessage = 'Allow microphone access when your browser asks.';
      }
      return _recorderReady;
    }
    return _ensurePermissions();
  }

  /// Live voice needs both mic access and on-device / browser speech recognition.
  Future<bool> prepareForLiveVoice() async {
    _lastListenError = null;
    await prepareForSpeechInput(settleDelay: Duration.zero);
    if (!await ensureMicrophoneAccess()) return false;
    if (!await ensureDeviceSpeechReady()) {
      _lastListenError = _statusMessage ?? _platformSpeechHint();
      return false;
    }
    return true;
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
      if (!await ensureDeviceSpeechReady()) {
        _lastListenError = _statusMessage ?? 'Speech recognition is not available.';
        return null;
      }

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
      if (!started) {
        _lastListenError ??= 'Could not open the microphone for speech recognition.';
        return null;
      }
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

  /// OpenAI audio is synthesized at [_bakedSpeed]; player rate = desired / baked.
  Future<void> _applyEffectivePlayerRate({bool reinforce = false}) async {
    final double baked = _bakedSpeed <= 0 ? 1 : _bakedSpeed;
    final double effective = (_playbackSpeed / baked).clamp(0.5, 2.5);
    try {
      await _player.setPlaybackRate(effective);
    } catch (e) {
      debugPrint('AudioPlayer setPlaybackRate failed: $e');
    }
    if (!reinforce) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    try {
      await _player.setPlaybackRate(effective);
    } catch (_) {}
  }

  /// Synthesize OpenAI audio ahead of time so the next lecture beat starts with
  /// almost no network gap.
  Future<void> prefetchSpeak(String text) async {
    if (!_useOpenAiTts || !AppConfig.hasOpenAi) return;
    final String trimmed = speechTextFromMarkdown(text);
    if (trimmed.isEmpty) return;
    final List<String> chunks = speechChunksForTts(trimmed);
    for (final String chunk in chunks) {
      final String cacheKey = '$chunk|$_openAiVoice';
      if (_cachedTtsBytes(cacheKey) != null) continue;
      try {
        final Uint8List audio = await _openAiTts.synthesizeBytes(
          chunk,
          speed: 1.0,
          voice: _openAiVoice,
        );
        _storeTtsCache(cacheKey, audio);
      } catch (e) {
        debugPrint('TTS prefetch skipped: $e');
        return;
      }
    }
  }

  Uint8List? _cachedTtsBytes(String cacheKey) {
    final Uint8List? prefetched = _ttsPrefetchCache[cacheKey];
    if (prefetched != null) return prefetched;
    if (_activeMp3Text == cacheKey && _activeMp3Bytes != null) {
      return _activeMp3Bytes;
    }
    return null;
  }

  void _storeTtsCache(String cacheKey, Uint8List audio) {
    _ttsPrefetchCache.remove(cacheKey);
    _ttsPrefetchCache[cacheKey] = audio;
    while (_ttsPrefetchCache.length > _ttsPrefetchCacheMax) {
      _ttsPrefetchCache.remove(_ttsPrefetchCache.keys.first);
    }
  }

  Future<bool> speak(
    String text, {
    bool preferDeviceVoice = false,
    /// When OpenAI TTS is configured, device fallback is off by default so the
    /// robotic system voice never interrupts a natural lecture/tutor reply.
    bool allowDeviceFallback = false,
  }) async {
    final String trimmed = speechTextFromMarkdown(text);
    if (trimmed.isEmpty) return false;

    _lastSpeakError = null;
    final int generation = ++_speakGeneration;
    _playbackPaused = false;
    utteranceProgress.value = 0;
    final Completer<void>? gate = _resumeGate;
    _resumeGate = null;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
    await _haltPlayback();

    final List<String> chunks = speechChunksForTts(trimmed);
    if (chunks.isEmpty) return false;

    bool spokeAny = false;
    final int totalChars =
        chunks.fold<int>(0, (int a, String c) => a + c.length).clamp(1, 1000000);
    int offsetChars = 0;
    for (int i = 0; i < chunks.length; i++) {
      final String chunk = chunks[i];
      if (generation != _speakGeneration) break;
      await _waitWhilePaused(generation);
      if (generation != _speakGeneration) break;
      // Warm the following chunk while this one plays (OpenAI network gap).
      if (_useOpenAiTts && AppConfig.hasOpenAi && i + 1 < chunks.length) {
        final String nextKey = '${chunks[i + 1]}|$_openAiVoice';
        if (_cachedTtsBytes(nextKey) == null) {
          unawaited(() async {
            try {
              final Uint8List audio = await _openAiTts.synthesizeBytes(
                chunks[i + 1],
                speed: 1.0,
                voice: _openAiVoice,
              );
              if (generation == _speakGeneration) {
                _storeTtsCache(nextKey, audio);
              }
            } catch (_) {}
          }());
        }
      }
      final double span = chunk.length / totalChars;
      final double base = offsetChars / totalChars;
      final bool ok = await _speakOneChunk(
        chunk,
        preferDeviceVoice: preferDeviceVoice,
        allowDeviceFallback: allowDeviceFallback,
        progressBase: base,
        progressSpan: span,
      );
      offsetChars += chunk.length;
      if (generation != _speakGeneration) break;
      if (ok) {
        spokeAny = true;
      } else if (!spokeAny) {
        return false;
      }
    }
    if (spokeAny && generation == _speakGeneration) {
      utteranceProgress.value = 1;
    }
    return spokeAny && generation == _speakGeneration;
  }

  Future<void> _waitWhilePaused(int generation) async {
    while (_playbackPaused && generation == _speakGeneration) {
      _resumeGate ??= Completer<void>();
      try {
        await _resumeGate!.future;
      } catch (_) {
        break;
      }
    }
  }

  /// Bumped by [stopSpeaking] so in-flight chunk loops exit.
  int _speakGeneration = 0;

  Future<bool> _speakOneChunk(
    String trimmed, {
    required bool preferDeviceVoice,
    bool allowDeviceFallback = false,
    double progressBase = 0,
    double progressSpan = 1,
  }) async {
    final bool openAiReady = _useOpenAiTts && AppConfig.hasOpenAi;

    // Explicit device preference (legacy / offline tests only).
    if (preferDeviceVoice && !openAiReady) {
      if (!_ttsReady) {
        await _initDeviceTts();
      }
      if (_ttsReady) {
        final bool spoke = await _speakWithDevice(
          trimmed,
          progressBase: progressBase,
          progressSpan: progressSpan,
        );
        if (spoke) return true;
      }
    }

    if (openAiReady) {
      try {
        Uint8List audio;
        // Cache by text + voice only — speed is applied via player rate.
        final String cacheKey = '$trimmed|$_openAiVoice';
        final Uint8List? cached = _cachedTtsBytes(cacheKey);
        if (cached != null) {
          audio = cached;
        } else {
          audio = await _openAiTts.synthesizeBytes(
            trimmed,
            speed: 1.0,
            voice: _openAiVoice,
          );
          _storeTtsCache(cacheKey, audio);
        }
        _activeMp3Bytes = audio;
        _activeMp3Text = cacheKey;
        _bakedSpeed = 1.0;
        final bool played = await _playMp3Bytes(
          audio,
          progressBase: progressBase,
          progressSpan: progressSpan,
        );
        if (played) return true;
        _lastSpeakError = 'Audio player did not start.';
        debugPrint(_lastSpeakError);
      } catch (error) {
        _lastSpeakError = error.toString().replaceFirst('Exception: ', '');
        debugPrint('OpenAI TTS error: $error');
      }
      // Never switch to the robotic device voice mid-session unless asked.
      if (!allowDeviceFallback) return false;
    }

    if (!_ttsReady) {
      await _initDeviceTts();
    }
    if (!_ttsReady) return false;

    return _speakWithDevice(
      trimmed,
      progressBase: progressBase,
      progressSpan: progressSpan,
    );
  }

  Future<bool> _playMp3Bytes(
    Uint8List bytes, {
    double progressBase = 0,
    double progressSpan = 1,
  }) async {
    _speaking = true;
    StreamSubscription<PlayerState>? stateSub;
    StreamSubscription<void>? completeSub;
    StreamSubscription<Duration>? positionSub;
    final int generation = _speakGeneration;
    final Completer<void> done = Completer<void>();
    _mp3Done = done;
    _activeMp3Bytes = bytes;
    final double span = progressSpan.clamp(0.0, 1.0);
    final double base = progressBase.clamp(0.0, 1.0);
    utteranceProgress.value = base;

    try {
      final Source source = await _sourceForMp3(bytes);

      await _player.stop();
      await _player.setVolume(1.0);
      // Audio is already synthesized at [_bakedSpeed] — start at relative rate 1.
      await _applyEffectivePlayerRate();

      void setProgress(double local) {
        utteranceProgress.value =
            (base + local.clamp(0.0, 1.0) * span).clamp(0.0, 1.0);
      }

      void maybeComplete() {
        if (_playbackPaused || done.isCompleted) return;
        if (_ignoreNextMp3Complete) {
          _ignoreNextMp3Complete = false;
          return;
        }
        setProgress(1);
        done.complete();
      }

      completeSub = _player.onPlayerComplete.listen((_) => maybeComplete());
      stateSub = _player.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) maybeComplete();
      });

      Duration? knownDuration;
      positionSub = _player.onPositionChanged.listen((Duration pos) async {
        if (generation != _speakGeneration || _playbackPaused) return;
        knownDuration ??= await _player.getDuration();
        final Duration? d = knownDuration;
        if (d == null || d.inMilliseconds <= 0) return;
        final double p =
            (pos.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
        final double mapped = (base + p * span).clamp(0.0, 1.0);
        if ((mapped - utteranceProgress.value).abs() >= 0.008 || p >= 0.99) {
          utteranceProgress.value = mapped;
        }
      });

      await _player.play(source);
      await _applyEffectivePlayerRate(reinforce: true);

      // Confirm playback actually started.
      final bool started =
          await _waitForPlaying(timeout: const Duration(seconds: 4));
      if (!started) {
        debugPrint(
            'OpenAI audio: play() called but player never entered playing state.');
        return false;
      }
      knownDuration ??= await _player.getDuration();

      // Generous upper bound; clock does not advance while soft-paused.
      // Faster playback finishes sooner — scale timeout by speed.
      final int maxMs =
          ((bytes.length / 12) / _playbackSpeed).round().clamp(5000, 600000);
      await _awaitMp3Done(
        done: done,
        generation: generation,
        maxMs: maxMs,
      );
      if (generation == _speakGeneration) {
        setProgress(1);
      }
      return generation == _speakGeneration;
    } catch (error) {
      debugPrint('MP3 playback error: $error');
      return false;
    } finally {
      await positionSub?.cancel();
      await stateSub?.cancel();
      await completeSub?.cancel();
      if (identical(_mp3Done, done)) {
        _mp3Done = null;
      }
      if (!done.isCompleted) {
        done.complete();
      }
      _speaking = false;
    }
  }

  /// Seek within the current utterance (0–1). Used to keep scrubber + voice in sync.
  Future<void> seekUtterance(double fraction) async {
    final double f = fraction.clamp(0.0, 1.0);
    try {
      final Duration? d = await _player.getDuration();
      if (d == null || d.inMilliseconds <= 0) {
        utteranceProgress.value = f;
        return;
      }
      final Duration target = Duration(
        milliseconds: (d.inMilliseconds * f).round(),
      );
      await _player.seek(target);
      _pausedAt = target;
      utteranceProgress.value = f;
    } catch (e) {
      debugPrint('seekUtterance failed: $e');
      utteranceProgress.value = f;
    }
  }

  Future<Source> _sourceForMp3(Uint8List bytes) async {
    if (kIsWeb) {
      return BytesSource(bytes);
    }
    if (_activeMp3Path != null &&
        _activeMp3Bytes != null &&
        identical(_activeMp3Bytes, bytes)) {
      final File existing = File(_activeMp3Path!);
      if (await existing.exists()) {
        return DeviceFileSource(_activeMp3Path!);
      }
    }
    final Directory dir = await getTemporaryDirectory();
    final String path =
        '${dir.path}/tutor_tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await File(path).writeAsBytes(bytes, flush: true);
    _activeMp3Path = path;
    return DeviceFileSource(path);
  }

  /// Wait for MP3 completion without counting soft-pause time toward the timeout.
  Future<void> _awaitMp3Done({
    required Completer<void> done,
    required int generation,
    required int maxMs,
  }) async {
    int activeMs = 0;
    final Stopwatch slice = Stopwatch();
    while (!done.isCompleted && generation == _speakGeneration) {
      if (_playbackPaused) {
        slice.stop();
        await _waitWhilePaused(generation);
        slice
          ..reset()
          ..start();
        continue;
      }
      if (!slice.isRunning) slice.start();
      await Future.any(<Future<void>>[
        done.future,
        Future<void>.delayed(const Duration(milliseconds: 80)),
      ]);
      activeMs += slice.elapsedMilliseconds;
      slice
        ..reset()
        ..start();
      if (activeMs >= maxMs) {
        debugPrint('OpenAI audio: completion timeout after ${maxMs}ms');
        break;
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

  Future<bool> _speakWithDevice(
    String text, {
    double progressBase = 0,
    double progressSpan = 1,
  }) async {
    _speaking = true;
    final double span = progressSpan.clamp(0.0, 1.0);
    final double base = progressBase.clamp(0.0, 1.0);
    utteranceProgress.value = base;
    final int generation = _speakGeneration;
    final int wordCount =
        text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
    // ~130 wpm at 1x — keeps board reveal roughly aligned when MP3 position is unavailable.
    final int totalMs =
        ((wordCount.clamp(1, 5000) / 130.0) * 60000 / _playbackSpeed)
            .round()
            .clamp(800, 300000);
    final Stopwatch clock = Stopwatch()..start();
    final Timer tick = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (generation != _speakGeneration) return;
      if (_playbackPaused) {
        if (clock.isRunning) clock.stop();
        return;
      }
      if (!clock.isRunning) clock.start();
      final double local =
          (clock.elapsedMilliseconds / totalMs).clamp(0.0, 0.99);
      final double mapped = (base + local * span).clamp(0.0, 1.0);
      if ((mapped - utteranceProgress.value).abs() >= 0.008) {
        utteranceProgress.value = mapped;
      }
    });
    try {
      await _tts.stop();
      final dynamic result = await _tts.speak(text);
      if (result is int && result != 1) {
        _lastSpeakError = 'Device voice unavailable (code $result).';
        debugPrint('Device TTS speak returned $result');
        return false;
      }
      if (generation == _speakGeneration) {
        utteranceProgress.value = (base + span).clamp(0.0, 1.0);
      }
      return true;
    } catch (error) {
      _lastSpeakError = error.toString().replaceFirst('Exception: ', '');
      debugPrint('Device TTS speak error: $error');
      return false;
    } finally {
      tick.cancel();
      _speaking = false;
    }
  }

  /// Freeze audio mid-utterance without cancelling the in-flight [speak] Future.
  Future<void> pauseSpeaking() async {
    if (_playbackPaused) return;
    _playbackPaused = true;
    try {
      _pausedAt = await _player.getCurrentPosition();
    } catch (_) {
      _pausedAt = null;
    }
    try {
      await _player.pause();
    } catch (_) {}
    if (_ttsReady) {
      try {
        await _tts.pause();
      } catch (_) {}
    }
  }

  /// Continue after [pauseSpeaking]. Resumes from the paused position when possible.
  Future<void> resumeSpeaking() async {
    if (!_playbackPaused) return;
    _playbackPaused = false;
    final Completer<void>? gate = _resumeGate;
    _resumeGate = null;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
    try {
      final PlayerState state = _player.state;
      if (state == PlayerState.paused) {
        await _applyEffectivePlayerRate();
        await _player.resume();
        return;
      }
      // Some platforms drop pause into "stopped" — restore position then play
      // the same buffer (no network) so unpause stays instant.
      if (state != PlayerState.playing && _activeMp3Bytes != null) {
        final Source source = await _sourceForMp3(_activeMp3Bytes!);
        _ignoreNextMp3Complete = true;
        await _player.play(source);
        final Duration? seekTo = _pausedAt;
        if (seekTo != null && seekTo > Duration.zero) {
          try {
            await _player.seek(seekTo);
          } catch (_) {}
        }
        await _applyEffectivePlayerRate(reinforce: true);
      }
    } catch (e) {
      debugPrint('Resume playback failed: $e');
    }
  }

  Future<void> stopSpeaking() async {
    _speakGeneration++;
    _playbackPaused = false;
    final Completer<void>? gate = _resumeGate;
    _resumeGate = null;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
    await _haltPlayback();
    _activeMp3Bytes = null;
    _activeMp3Text = null;
    final String? path = _activeMp3Path;
    _activeMp3Path = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Future<void> _haltPlayback() async {
    try {
      await _player.stop();
    } catch (_) {}
    if (_ttsReady) {
      try {
        await _tts.stop();
      } catch (_) {}
    }
    final Completer<void>? mp3 = _mp3Done;
    _mp3Done = null;
    if (mp3 != null && !mp3.isCompleted) {
      mp3.complete();
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

    if (kIsWeb && !await ensureMicrophoneAccess()) {
      _lastListenError = _statusMessage ?? 'Microphone access is required.';
      return false;
    }

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

    _lastListenError ??= kIsWeb
        ? 'Speech recognition could not start. Refresh the page, allow Microphone, then try again.'
        : 'Speech recognition could not start. Close other apps using the mic and try again.';
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
    utteranceProgress.dispose();
  }
}
