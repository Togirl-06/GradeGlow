import 'package:ai_study_buddy/models/study_progress.dart';
import 'package:ai_study_buddy/models/user_profile.dart';
import 'package:ai_study_buddy/utils/gpa_predictor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps percent bands onto a 4.0 letter scale', () {
    expect(GpaPredictor.letterFromPercent(95), 'A');
    expect(GpaPredictor.pointsFromPercent(95), 4.0);
    expect(GpaPredictor.letterFromPercent(90), 'A-');
    expect(GpaPredictor.pointsFromPercent(87), 3.3);
    expect(GpaPredictor.letterFromPercent(72), 'C-');
    expect(GpaPredictor.pointsFromPercent(59), 0.0);
  });

  test('predicts term GPA from quiz average', () {
    final GpaForecast forecast = GpaPredictor.fromPercents(
      percents: <int>[88, 91, 85],
    );
    expect(forecast.averagePercent, 88);
    expect(forecast.letter, 'B+');
    expect(forecast.predictedGpa, 3.3);
    expect(forecast.quizCount, 3);
    expect(forecast.confidence, greaterThan(0));
  });

  test('flags weak courses and a rising trend', () {
    final GpaForecast forecast = GpaPredictor.fromPercents(
      percents: <int>[70, 72, 71, 84, 86, 88],
      byCourse: <String, int>{'BIO-101': 71, 'CHEM-101': 86},
    );
    expect(forecast.trendLabel, 'Rising');
    expect(forecast.courses.first.name, 'BIO-101');
    expect(forecast.nextStep, contains('BIO-101'));
  });

  test('builds a forecast from a user profile', () {
    final UserProfile profile = UserProfile.empty(
      email: 'demo@gradeglow.app',
      displayName: 'Demo',
    ).copyWith(
      gpa: 3.1,
      studyProgress: StudyProgress(
        quizResults: <QuizResult>[
          QuizResult(
            date: DateTime(2026, 1, 10),
            courseCode: 'BIO-101',
            scorePercent: 82,
            correct: 8,
            total: 10,
          ),
          QuizResult(
            date: DateTime(2026, 2, 10),
            courseCode: 'BIO-101',
            scorePercent: 90,
            correct: 9,
            total: 10,
          ),
        ],
      ),
    );
    final GpaForecast forecast = GpaPredictor.fromProfile(profile);
    expect(forecast.hasQuizzes, isTrue);
    expect(forecast.reportedGpa, 3.1);
    expect(forecast.cumulativeOutlook, isNotNull);
    expect(forecast.courses, isNotEmpty);
  });
}
