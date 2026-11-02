import '../models/english_lesson.dart';
import '../services/english_adaptive_service.dart';

/// Builds lesson queues — core questions first, then varied extras.
class EnglishLessonMixer {
  const EnglishLessonMixer({EnglishAdaptiveService? adaptive})
      : _adaptive = adaptive ?? const EnglishAdaptiveService();

  final EnglishAdaptiveService _adaptive;

  List<EnglishActivity> buildQueue(List<EnglishActivity> script) {
    if (script.isEmpty) return <EnglishActivity>[];

    final List<EnglishActivity> intro = <EnglishActivity>[];
    final List<EnglishActivity> core = <EnglishActivity>[];
    final List<EnglishActivity> extras = <EnglishActivity>[];

    for (final EnglishActivity activity in script) {
      if (activity.kind == EnglishActivityKind.microPrompt &&
          intro.isEmpty &&
          core.isEmpty) {
        intro.add(activity);
        continue;
      }
      if (_isCoreLessonStep(activity)) {
        core.add(activity);
      } else {
        extras.add(activity);
      }
    }

    if (core.isEmpty && extras.isEmpty) {
      return List<EnglishActivity>.from(script);
    }

    final List<EnglishActivity> diversifiedExtras =
        _adaptive.diversifyKinds(extras);

    return <EnglishActivity>[
      ...intro,
      ...core,
      ...diversifiedExtras,
    ];
  }

  bool _isCoreLessonStep(EnglishActivity activity) {
    final String id = activity.id;
    return !id.startsWith('bank_') &&
        !id.startsWith('ch_') &&
        !id.contains('_retry');
  }

  EnglishActivityDifficulty resolveDifficulty(EnglishActivity activity) {
    if (activity.kind == EnglishActivityKind.microPrompt) {
      return EnglishActivityDifficulty.easy;
    }
    if (activity.difficulty != null) return activity.difficulty!;
    return EnglishActivityDifficulty.hard;
  }
}
