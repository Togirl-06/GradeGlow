import '../utils/study_limits.dart';

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
  });

  final String name;
  final String tagline;
  final List<PlanFeature> features;
  final String priceAmount;
  final String priceSuffix;
  final String? strikethroughPrice;
  final String? promoLabel;
}

/// Free vs Premium catalog shown on Plans & features.
class MembershipPlans {
  static const String premiumRegularPrice = r'$14.99';
  static const String premiumPromoPrice = r'$7.99';

  static final MembershipPlanDetails free = MembershipPlanDetails(
    name: 'Free',
    tagline: 'Everything you need to get started.',
    priceAmount: '0',
    priceSuffix: '/ month',
    features: <PlanFeature>[
      PlanFeature('AI Tutor Chat'),
      PlanFeature('AI summaries from PDFs, slides, notes, images & recordings'),
      PlanFeature(
        '${StudyLimits.freeDailySummarizeActions} uploads, pastes & recordings per day',
      ),
      PlanFeature('Up to ${StudyLimits.freeStudySetsPerCourse} study sets per course'),
      PlanFeature('Up to ${StudyLimits.freeFlashcardsPerCourse} flashcards per course'),
      PlanFeature('Up to ${StudyLimits.freeQuizQuestionsPerCourse} quiz questions per course'),
      PlanFeature('Study planner & reminders'),
      PlanFeature('Progress tracking'),
      PlanFeature('Daily study streaks'),
      PlanFeature('Basic performance insights'),
    ],
  );

  static final MembershipPlanDetails premium = MembershipPlanDetails(
    name: 'Premium',
    tagline: 'Study without limits.',
    priceAmount: '7.99',
    priceSuffix: '/ month',
    strikethroughPrice: premiumRegularPrice,
    promoLabel: 'LIMITED TIME',
    features: <PlanFeature>[
      PlanFeature('Everything in Free'),
      PlanFeature('Unlimited AI Tutor Chat'),
      PlanFeature('Live voice conversations with AI Tutor'),
      PlanFeature('Unlimited study sets'),
      PlanFeature('Unlimited file, image & recording uploads'),
      PlanFeature(
        'Generate up to ${StudyLimits.premiumFlashcardsPerGeneration} flashcards at once',
      ),
      PlanFeature(
        'Generate up to ${StudyLimits.premiumQuizQuestionsPerGeneration} quiz questions at once',
      ),
      PlanFeature('AI-generated study guides & exam reviews'),
      PlanFeature('Personalized study plans'),
      PlanFeature('Grade Predictor & Exam Score Calculator'),
      PlanFeature('Regenerate summaries, flashcards & quizzes anytime'),
      PlanFeature('Download and export notes, recordings & study materials'),
      PlanFeature('Faster AI responses'),
      PlanFeature('No ads'),
      PlanFeature('Early access to new features'),
    ],
  );
}
