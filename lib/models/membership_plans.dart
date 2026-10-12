import '../config/billing_config.dart';
import '../utils/study_limits.dart';
import '../utils/tutor_limits.dart';

class PlanFeature {
  const PlanFeature(this.label);

  final String label;
}

class MembershipPlanDetails {
  const MembershipPlanDetails({
    required this.name,
    required this.tagline,
    required this.features,
    required this.priceAmount,
    required this.priceSuffix,
    this.strikethroughPrice,
    this.promoLabel,
    this.footerNote,
  });

  final String name;
  final String tagline;
  final List<PlanFeature> features;
  final String priceAmount;
  final String priceSuffix;
  final String? strikethroughPrice;
  final String? promoLabel;
  final String? footerNote;
}

/// Free vs Premium catalog shown on Plans & features.
class MembershipPlans {
  static const String premiumRegularPrice = BillingConfig.premiumMonthlyPrice;
  static const String premiumPromoPrice = BillingConfig.premiumMonthlyPrice;

  static MembershipPlanDetails free = MembershipPlanDetails(
    name: 'Free',
    tagline: 'The Virtual University is included.',
    priceAmount: '0',
    priceSuffix: '/ month',
    features: <PlanFeature>[
      const PlanFeature('Full Virtual University campus'),
      const PlanFeature('AI Professor lectures, labs, quizzes & certificates'),
      PlanFeature(
        'AI Tutor Chat — ${TutorLimits.freeDailyMessages} messages/day',
      ),
      PlanFeature(
        '${StudyLimits.freeDailySummarizeActions} uploads, pastes & recordings per day',
      ),
      PlanFeature(
        'Up to ${StudyLimits.freeStudySetsPerCourse} study sets per course',
      ),
      PlanFeature(
        'Up to ${StudyLimits.freeFlashcardsPerCourse} flashcards per course',
      ),
      PlanFeature(
        'Up to ${StudyLimits.freeQuizQuestionsPerCourse} quiz questions per course',
      ),
      const PlanFeature('Study planner, streaks & basic insights'),
    ],
  );

  /// Premium selling points — keep to ~5 grouped benefits.
  static MembershipPlanDetails premiumFor(BillingPlanOption plan) {
    return MembershipPlanDetails(
      name: 'Premium',
      tagline: 'Unlimited study tools for exam season and beyond.',
      priceAmount: plan.priceAmount,
      priceSuffix: plan.suffix,
      promoLabel: BillingConfig.trialLabel,
      footerNote: BillingConfig.trialFooter,
      features: const <PlanFeature>[
        PlanFeature('Everything in Free'),
        PlanFeature(
          'Unlimited AI Tutor, including live voice conversations',
        ),
        PlanFeature('Unlimited study sets, flashcards and quizzes'),
        PlanFeature(
          'Unlimited uploads (files, images, recordings) plus export',
        ),
        PlanFeature(
          'Exam prep tools: study guides, personalized plans, Grade Predictor',
        ),
        PlanFeature('Faster AI, no ads, early access'),
      ],
    );
  }

  /// Default monthly card (compat for older call sites).
  static MembershipPlanDetails get premium =>
      premiumFor(BillingConfig.planFor(BillingInterval.monthly));
}
