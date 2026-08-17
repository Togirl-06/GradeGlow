import '../models/subscription_plan.dart';
import 'practice_lab_limits.dart';
import 'study_limits.dart';
import 'tutor_limits.dart';

/// Free vs Premium entitlements — matches [MembershipPlans] catalog.
class PlanFeatures {
  PlanFeatures._();

  static bool isPremium(SubscriptionPlan plan) => plan.isPaid;

  // --- Free tier ---
  static bool aiTutorChat(SubscriptionPlan plan) => true;
  static bool aiSummaries(SubscriptionPlan plan) => true;
  static bool studyPlannerReminders(SubscriptionPlan plan) => true;
  static bool progressTracking(SubscriptionPlan plan) => true;
  static bool dailyStreaks(SubscriptionPlan plan) => true;
  static bool basicPerformanceInsights(SubscriptionPlan plan) => true;
  static bool flashcardsAndQuiz(SubscriptionPlan plan) => true;
  /// Campus labs, lectures, and simulations are free for every student.
  static bool unlimitedPracticeLabs(SubscriptionPlan plan) => true;
  static bool unlimitedAiPracticeMode(SubscriptionPlan plan) => isPremium(plan);

  static int practiceLabMonthlyLimit(SubscriptionPlan plan) =>
      unlimitedPracticeLabs(plan) ? 999999 : PracticeLabLimits.freeSimulationsPerMonth;

  // --- Premium tier ---
  static bool unlimitedSummarize(SubscriptionPlan plan) => isPremium(plan);
  static bool unlimitedStudySets(SubscriptionPlan plan) => isPremium(plan);
  static bool unlimitedTutorMedia(SubscriptionPlan plan) => isPremium(plan);
  static bool liveVoiceTutor(SubscriptionPlan plan) => isPremium(plan);
  static bool studyGuidesExamReviews(SubscriptionPlan plan) => isPremium(plan);
  static bool personalizedStudyPlans(SubscriptionPlan plan) => isPremium(plan);
  static bool gradePredictor(SubscriptionPlan plan) => isPremium(plan);
  static bool regenerateStudySets(SubscriptionPlan plan) => isPremium(plan);
  static bool exportContent(SubscriptionPlan plan) => isPremium(plan);
  static bool advancedAnalytics(SubscriptionPlan plan) => isPremium(plan);
  static bool practiceExams(SubscriptionPlan plan) => isPremium(plan);
  static bool fasterAi(SubscriptionPlan plan) => isPremium(plan);
  static bool noAds(SubscriptionPlan plan) => isPremium(plan);
  static bool earlyAccess(SubscriptionPlan plan) => isPremium(plan);

  static int dailySummarizeLimit(SubscriptionPlan plan) =>
      unlimitedSummarize(plan) ? 999999 : StudyLimits.freeDailySummarizeActions;

  static int studySetsPerCourseLimit(SubscriptionPlan plan) =>
      unlimitedStudySets(plan) ? 999999 : StudyLimits.freeStudySetsPerCourse;

  static int flashcardsPerCourseLimit(SubscriptionPlan plan) =>
      isPremium(plan) ? StudyLimits.premiumFlashcardsPerGeneration : StudyLimits.freeFlashcardsPerCourse;

  static int quizQuestionsPerCourseLimit(SubscriptionPlan plan) =>
      isPremium(plan)
          ? StudyLimits.premiumQuizQuestionsPerGeneration
          : StudyLimits.freeQuizQuestionsPerCourse;

  static int tutorMediaDailyLimit(SubscriptionPlan plan) =>
      unlimitedTutorMedia(plan) ? 999999 : TutorLimits.freeDailyMediaAttachments;
}
