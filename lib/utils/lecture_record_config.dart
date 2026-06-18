import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
/// Shared microphone recording settings for lecture capture.
  RecordConfig lectureRecordConfig({bool enableAndroidService = !kIsWeb}) {
  return RecordConfig(
    encoder: AudioEncoder.wav,
    bitRate: 128000,
    sampleRate: kIsWeb ? 48000 : 16000,
    numChannels: 1,
    audioInterruption: AudioInterruptionMode.none,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.mic,
      useLegacy: false,
      manageBluetooth: false,
      audioManagerMode: AudioManagerMode.modeNormal,
      service: enableAndroidService
          ? const AndroidService(
              title: 'GradeGlow recording',
              content: 'Recording lecture audio in progress',
            )
          : null,
    ),
    iosConfig: const IosRecordConfig(
      categoryOptions: <IosAudioCategoryOption>[
        IosAudioCategoryOption.defaultToSpeaker,
        IosAudioCategoryOption.allowBluetooth,
        IosAudioCategoryOption.mixWithOthers,
      ],
    ),
  );
}

String lectureRecordingExtension() => 'wav';

/// Sample rate used for [lectureRecordConfig] on this platform.
int lectureRecordingSampleRate() => kIsWeb ? 48000 : 16000;

/// Stream capture — reliable for long lectures (avoids broken WAV headers from file writer).
RecordConfig lectureStreamRecordConfig({bool enableAndroidService = !kIsWeb}) {
  return RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: lectureRecordingSampleRate(),
    numChannels: 1,
    audioInterruption: AudioInterruptionMode.none,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.mic,
      useLegacy: false,
      manageBluetooth: false,
      audioManagerMode: AudioManagerMode.modeNormal,
      service: enableAndroidService
          ? const AndroidService(
              title: 'GradeGlow recording',
              content: 'Recording lecture audio in progress',
            )
          : null,
    ),
    iosConfig: const IosRecordConfig(
      categoryOptions: <IosAudioCategoryOption>[
        IosAudioCategoryOption.defaultToSpeaker,
        IosAudioCategoryOption.allowBluetooth,
        IosAudioCategoryOption.mixWithOthers,
      ],
    ),
  );
}
