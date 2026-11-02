import 'api_error_messages.dart';

/// Free-plan caps for AI Practice Mode sessions.
class AiPracticeLimits {
  AiPracticeLimits._();

  static const int freeSessionsPerMonth = 5;

  static const ApiErrorInfo monthlyLimitReached = ApiErrorInfo(
    title: 'Practice session limit reached',
    message:
        'Free accounts can run $freeSessionsPerMonth AI Practice Mode sessions per month. '
        'Upgrade to Premium for unlimited practice.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
      'Or wait until next month',
    ],
  );
}

class AiPracticeUsage {
  const AiPracticeUsage({
    required this.count,
    required this.limit,
    required this.isPremium,
  });

  final int count;
  final int limit;
  final bool isPremium;

  bool get isAtLimit => !isPremium && count >= limit;
  int get remaining => isPremium ? limit : (limit - count).clamp(0, limit);
  bool canStart() => isPremium || count < limit;
}
