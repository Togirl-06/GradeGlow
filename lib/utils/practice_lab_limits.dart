import 'api_error_messages.dart';

/// Free-plan caps for Practice Lab simulations.
class PracticeLabLimits {
  PracticeLabLimits._();

  static const int freeSimulationsPerMonth = 3;

  static const ApiErrorInfo monthlyLimitReached = ApiErrorInfo(
    title: 'Simulation limit reached',
    message:
        'Free accounts can run $freeSimulationsPerMonth Practice Lab simulations per month. '
        'Upgrade to Premium for unlimited simulations.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
      'Or wait until next month',
    ],
  );
}

class PracticeLabUsage {
  const PracticeLabUsage({
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
