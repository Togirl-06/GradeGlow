import 'package:flutter/material.dart';

import '../models/subscription_plan.dart';
import '../screens/membership_screen.dart';
import '../services/subscription_service.dart';
import 'api_error_messages.dart';

/// Premium-only capabilities from the membership catalog.
enum PremiumFeature {
  voiceTutor,
  homeworkHelp,
  studyGuides,
  practiceExams,
  studyPlans,
  advancedAnalytics,
  gradePredictor,
  exportContent,
  unlimitedChat,
}

class PremiumAccess {
  PremiumAccess._();

  static bool isPremium(SubscriptionPlan plan) => plan.isPaid;

  static void requirePremium(SubscriptionPlan plan, {PremiumFeature feature = PremiumFeature.unlimitedChat}) {
    if (plan.isPaid) return;
    throw PremiumRequiredException(forFeature(feature));
  }

  static ApiErrorInfo forFeature(PremiumFeature feature) {
    return switch (feature) {
      PremiumFeature.voiceTutor => voiceTutorRequired,
      PremiumFeature.homeworkHelp => homeworkHelpRequired,
      PremiumFeature.studyGuides => studyGuidesRequired,
      PremiumFeature.practiceExams => practiceExamsRequired,
      PremiumFeature.studyPlans => studyPlansRequired,
      PremiumFeature.advancedAnalytics => advancedAnalyticsRequired,
      PremiumFeature.gradePredictor => gradePredictorRequired,
      PremiumFeature.exportContent => exportRequired,
      PremiumFeature.unlimitedChat => upgradeRequired,
    };
  }

  static const ApiErrorInfo upgradeRequired = ApiErrorInfo(
    title: 'Premium feature',
    message: 'Upgrade to Premium to study without limits.',
    steps: <String>['Open Plans & features and upgrade to Premium'],
  );

  static const ApiErrorInfo voiceTutorRequired = ApiErrorInfo(
    title: 'Live voice is Premium',
    message: 'Hands-free live voice conversations with the AI tutor require Premium.',
    steps: <String>['Upgrade to Premium for live voice mode'],
  );

  static const ApiErrorInfo homeworkHelpRequired = ApiErrorInfo(
    title: 'Exam review is Premium',
    message: 'AI-generated study guides and exam reviews require Premium.',
    steps: <String>['Upgrade to Premium for guided exam reviews'],
  );

  static const ApiErrorInfo studyGuidesRequired = ApiErrorInfo(
    title: 'Study guides are Premium',
    message: 'AI-generated study guides, exam reviews, and regenerating summaries require Premium.',
    steps: <String>['Upgrade to Premium for study guides & exam reviews'],
  );

  static const ApiErrorInfo practiceExamsRequired = ApiErrorInfo(
    title: 'Exam reviews are Premium',
    message: 'AI-generated exam reviews and practice tests require Premium.',
    steps: <String>['Upgrade to Premium for unlimited exam reviews'],
  );

  static const ApiErrorInfo studyPlansRequired = ApiErrorInfo(
    title: 'Personalized study plans are Premium',
    message: 'AI-generated personalized study schedules require Premium.',
    steps: <String>['Upgrade to Premium for personalized study plans'],
  );

  static const ApiErrorInfo advancedAnalyticsRequired = ApiErrorInfo(
    title: 'Advanced analytics are Premium',
    message: 'AI focus topics, grade predictions, and advanced analytics require Premium.',
    steps: <String>['Upgrade to Premium for Grade Predictor & advanced insights'],
  );

  static const ApiErrorInfo gradePredictorRequired = ApiErrorInfo(
    title: 'Grade Predictor is Premium',
    message: 'Grade Predictor and exam score tools require Premium.',
    steps: <String>['Upgrade to Premium to unlock grade predictions'],
  );

  static const ApiErrorInfo exportRequired = ApiErrorInfo(
    title: 'Export is Premium',
    message: 'Downloading and exporting notes, recordings, and study materials requires Premium.',
    steps: <String>['Upgrade to Premium to export your study content'],
  );

  /// Returns true when the user may proceed; otherwise shows an upgrade prompt.
  static Future<bool> checkAndPrompt(
    BuildContext context,
    SubscriptionService subs, {
    PremiumFeature feature = PremiumFeature.unlimitedChat,
  }) async {
    if (subs.isPremium) return true;
    await showUpgradeDialog(context, feature: feature);
    return false;
  }

  static Future<void> showUpgradeDialog(
    BuildContext context, {
    PremiumFeature feature = PremiumFeature.unlimitedChat,
  }) async {
    final ApiErrorInfo info = forFeature(feature);
    final bool? upgrade = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(info.title),
        content: Text(info.message),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Upgrade')),
        ],
      ),
    );
    if (upgrade == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
      );
    }
  }
}

class PremiumRequiredException implements Exception {
  PremiumRequiredException(this.info);

  final ApiErrorInfo info;

  @override
  String toString() => info.message;
}
