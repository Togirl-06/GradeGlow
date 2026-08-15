import 'package:ai_study_buddy/data/health_faculty_catalog.dart';
import 'package:ai_study_buddy/data/practice_lab_university_catalog.dart';
import 'package:ai_study_buddy/data/world_curriculum_topics.dart';
import 'package:ai_study_buddy/models/health_faculty_program.dart';
import 'package:ai_study_buddy/models/virtual_university_lesson_contract.dart';
import 'package:ai_study_buddy/screens/health/health_faculty_home_screen.dart';
import 'package:ai_study_buddy/services/business_school_progress_service.dart';
import 'package:ai_study_buddy/services/health_faculty_progress_service.dart';
import 'package:ai_study_buddy/services/virtual_university_dashboard_service.dart';
import 'package:ai_study_buddy/utils/virtual_university_premium.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('lesson contract has required activities', () {
    expect(VirtualUniversityLessonContract.required.length, 4);
    expect(
      VirtualUniversityLessonContract.visibleFor(hasDiscussion: true).length,
      6,
    );
  });

  test('health catalogs are non-empty with real topics', () {
    for (final HealthFaculty faculty in HealthFaculty.values) {
      final courses = HealthFacultyCatalog.coursesFor(faculty);
      expect(courses, isNotEmpty, reason: faculty.title);
      expect(courses.length, greaterThanOrEqualTo(8), reason: faculty.title);
      expect(courses.first.topics.length, greaterThanOrEqualTo(10));
      expect(courses.first.topics.first.summary.length, greaterThan(40));
    }
  });

  test('world curriculum covers all major subjects', () {
    for (final String id in <String>[
      'nursing',
      'medicine',
      'psychology',
      'english',
      'engineering',
      'law',
      'physics',
      'biology',
      'chemistry',
      'mathematics',
      'computer_science',
      'business',
      'environmental_science',
      'political_science',
    ]) {
      final courses = WorldCurriculumTopics.coursesFor(id);
      expect(courses, isNotEmpty, reason: id);
      final topics = WorldCurriculumTopics.topicsFor(
        subjectId: id,
        courseName: courses.first,
      );
      expect(topics.length, greaterThanOrEqualTo(10), reason: id);
    }
  });

  test('university search returns hits', () {
    final hits = PracticeLabUniversityCatalog.search('biology');
    expect(hits, isNotEmpty);
  });

  test('premium AI limits enforce free cap', () async {
    expect(await VirtualUniversityPremium.canAskAiProfessor(true), isTrue);
    for (
      int i = 0;
      i < VirtualUniversityPremium.freeAiProfessorQuestionsPerDay;
      i++
    ) {
      await VirtualUniversityPremium.recordAiQuestion();
    }
    expect(await VirtualUniversityPremium.canAskAiProfessor(false), isFalse);
  });

  test('all catalog courses are open without Premium', () {
    expect(
      VirtualUniversityPremium.canAccessCourse(
        isPremium: false,
        courseTitle: 'Surgery',
        courseIndex: 0,
      ),
      isTrue,
    );
    expect(
      VirtualUniversityPremium.canAccessCourse(
        isPremium: false,
        courseTitle: 'Anatomy',
        courseIndex: 3,
      ),
      isTrue,
    );
    expect(
      VirtualUniversityPremium.canAccessCourse(
        isPremium: false,
        courseTitle: 'Surgery',
        courseIndex: 3,
      ),
      isTrue,
    );
    expect(VirtualUniversityPremium.canAccessAllCourses(false), isTrue);
  });

  test('intro course detection', () {
    expect(VirtualUniversityPremium.isIntroCourse('Fundamentals'), isTrue);
    expect(VirtualUniversityPremium.isIntroCourse('Anatomy'), isTrue);
    expect(VirtualUniversityPremium.isIntroCourse('Critical Care'), isFalse);
  });

  test('dashboard snapshot aggregates continue learning', () async {
    final BusinessSchoolProgressService business =
        BusinessSchoolProgressService();
    final VirtualUniversityDashboardService dash =
        VirtualUniversityDashboardService(business: business);
    await dash.load();
    await dash.recordContinue(
      subjectId: 'biology',
      subjectName: 'Biology',
      courseTitle: 'General Biology',
      lessonTitle: 'Cell Structure',
      routeHint: 'biology',
      progress: 0.4,
    );
    final snap = await dash.snapshot(welcomeName: 'Alex');
    expect(snap.welcomeName, 'Alex');
    expect(snap.continueItems, isNotEmpty);
    expect(snap.continueItems.first.lessonTitle, 'Cell Structure');
    expect(snap.dailyStudyMinutes, greaterThanOrEqualTo(0));
  });

  testWidgets('nursing faculty home lists courses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<HealthFacultyProgressService>(
        create: (_) => HealthFacultyProgressService(),
        child: const MaterialApp(
          home: HealthFacultyHomeScreen(faculty: HealthFaculty.nursing),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nursing'), findsWidgets);
    expect(find.textContaining('Fundamentals'), findsWidgets);
  });
}
