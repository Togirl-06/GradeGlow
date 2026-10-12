import 'api_error_messages.dart';

/// Free-plan AI tutor caps.
class TutorLimits {
  TutorLimits._();

  /// Text chat messages per day on Free (Premium is unlimited).
  static const int freeDailyMessages = 30;

  /// Photos, videos, and file attachments combined per day on Free.
  static const int freeDailyMediaAttachments = 5;

  static int mediaCountInRequest({
    required List<String> imagePaths,
    required String? videoPath,
  }) {
    return imagePaths.length + (videoPath != null && videoPath.isNotEmpty ? 1 : 0);
  }

  static const ApiErrorInfo mediaLimitReached = ApiErrorInfo(
    title: 'Daily attachment limit reached',
    message:
        'Free accounts can send $freeDailyMediaAttachments photos, videos, or files in the tutor per day. Upgrade for unlimited attachments.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
      'Or send text-only messages until tomorrow',
    ],
  );
}

class TutorMediaUsage {
  const TutorMediaUsage({
    required this.count,
    required this.limit,
    required this.isPremium,
  });

  final int count;
  final int limit;
  final bool isPremium;

  bool get isAtLimit => !isPremium && count >= limit;
  int get remaining => isPremium ? limit : (limit - count).clamp(0, limit);

  bool canAdd(int additional) => isPremium || count + additional <= limit;
}

// Back-compat alias for existing UI code.
typedef TutorDailyUsage = TutorMediaUsage;
