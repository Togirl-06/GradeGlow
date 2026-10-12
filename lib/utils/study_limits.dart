import '../models/course.dart';
import '../models/study_summary.dart';
import '../services/notes_summarizer_service.dart';
import 'api_error_messages.dart';

/// Free-plan caps for study sets (upload / paste / record).
/// Premium removes per-course caps. Batch sizes are internal only.
class StudyLimits {
  StudyLimits._();

  /// Combined uploads, pastes, and recordings per day on Free.
  static const int freeDailySummarizeActions = 5;

  static const int freeStudySetsPerCourse = 10;
  static const int freeFlashcardsPerCourse = 10;
  static const int freeQuizQuestionsPerCourse = 15;

  /// Internal AI batch size per generation (not a Premium life-time limit).
  static const int premiumFlashcardsPerGeneration = 20;
  static const int premiumQuizQuestionsPerGeneration = 15;

  static const int unlimitedSentinel = 999999;

  static const ApiErrorInfo dailySummarizeLimitReached = ApiErrorInfo(
    title: 'Daily summarize limit reached',
    message:
        'Free accounts can upload, paste, or record up to $freeDailySummarizeActions times per day. Upgrade for unlimited summaries.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
      'Or try again tomorrow',
    ],
  );

  static const ApiErrorInfo studySetLimitReached = ApiErrorInfo(
    title: 'Study set limit reached',
    message:
        'Free accounts can create up to $freeStudySetsPerCourse study set uploads per course. Upgrade for unlimited uploads.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
      'Or remove an older study set for this class',
    ],
  );

  static const ApiErrorInfo flashcardLimitReached = ApiErrorInfo(
    title: 'Flashcard limit reached',
    message:
        'Free accounts can have up to $freeFlashcardsPerCourse flashcards per course across all study sets. Upgrade for unlimited flashcards.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
    ],
  );

  static const ApiErrorInfo quizLimitReached = ApiErrorInfo(
    title: 'Quiz limit reached',
    message:
        'Free accounts can have up to $freeQuizQuestionsPerCourse quiz questions per course across all study sets. Upgrade for unlimited quizzes.',
    steps: <String>[
      'Open Plans & features and upgrade to Premium',
    ],
  );

  static Course courseLookup({required String courseId, required String courseCode}) {
    return Course(
      id: courseId,
      code: courseCode,
      name: courseCode,
      professor: '',
      semester: '',
      school: '',
      createdBy: '',
    );
  }

  static CourseStudyUsage usageForCourse(
    List<StudySummary> allSummaries,
    Course course,
    bool isPremium,
  ) {
    final List<StudySummary> courseSummaries =
        NotesSummarizerService.summariesForCourse(allSummaries, course);
    int quizCount = 0;
    int flashcardCount = 0;
    for (final StudySummary summary in courseSummaries) {
      quizCount += summary.quizQuestions.length;
      flashcardCount += summary.flashcards.length;
    }
    return CourseStudyUsage(
      studySetCount: courseSummaries.length,
      quizCount: quizCount,
      flashcardCount: flashcardCount,
      isPremium: isPremium,
    );
  }

  static bool canCreateStudySet(CourseStudyUsage usage) =>
      usage.isPremium || usage.studySetCount < freeStudySetsPerCourse;

  /// How many cards/questions to request from AI this run.
  static ({int flashcardCount, int quizCount}) generationBudget({
    required CourseStudyUsage usage,
    required bool isPremium,
    int existingFlashcards = 0,
    int existingQuizQuestions = 0,
  }) {
    if (isPremium) {
      return (
        flashcardCount: premiumFlashcardsPerGeneration,
        quizCount: premiumQuizQuestionsPerGeneration,
      );
    }
    final int flashcardCount =
        (freeFlashcardsPerCourse - usage.flashcardCount + existingFlashcards)
            .clamp(0, freeFlashcardsPerCourse);
    final int quizCount =
        (freeQuizQuestionsPerCourse - usage.quizCount + existingQuizQuestions)
            .clamp(0, freeQuizQuestionsPerCourse);
    return (flashcardCount: flashcardCount, quizCount: quizCount);
  }
}

class CourseStudyUsage {
  const CourseStudyUsage({
    required this.studySetCount,
    required this.quizCount,
    required this.flashcardCount,
    required this.isPremium,
  });

  final int studySetCount;
  final int quizCount;
  final int flashcardCount;
  final bool isPremium;

  bool get isAtStudySetLimit =>
      !isPremium && studySetCount >= StudyLimits.freeStudySetsPerCourse;

  int get studySetRemaining => isPremium
      ? StudyLimits.unlimitedSentinel
      : (StudyLimits.freeStudySetsPerCourse - studySetCount)
          .clamp(0, StudyLimits.freeStudySetsPerCourse);

  int get flashcardRemaining => isPremium
      ? StudyLimits.unlimitedSentinel
      : (StudyLimits.freeFlashcardsPerCourse - flashcardCount)
          .clamp(0, StudyLimits.freeFlashcardsPerCourse);

  int get quizRemaining => isPremium
      ? StudyLimits.unlimitedSentinel
      : (StudyLimits.freeQuizQuestionsPerCourse - quizCount)
          .clamp(0, StudyLimits.freeQuizQuestionsPerCourse);

  bool get isAtAnyLimit =>
      isAtStudySetLimit ||
      (!isPremium && flashcardRemaining == 0 && quizRemaining == 0);
}

class SummarizeDailyUsage {
  const SummarizeDailyUsage({
    required this.count,
    required this.limit,
    required this.isPremium,
  });

  final int count;
  final int limit;
  final bool isPremium;

  bool get isAtLimit => !isPremium && count >= limit;
  int get remaining => isPremium ? limit : (limit - count).clamp(0, limit);
  bool canCreate() => isPremium || count < limit;
}
