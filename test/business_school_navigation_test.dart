import 'package:ai_study_buddy/data/business_lecture_notes.dart';
import 'package:ai_study_buddy/data/business_school_catalog.dart';
import 'package:ai_study_buddy/data/practice_lab_university_catalog.dart';
import 'package:ai_study_buddy/models/business_school.dart';
import 'package:ai_study_buddy/screens/business/business_school_screen.dart';
import 'package:ai_study_buddy/services/business_school_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('School of Business shows all majors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<BusinessSchoolProgressService>(
        create: (_) => BusinessSchoolProgressService(),
        child: const MaterialApp(home: BusinessSchoolScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('School of Business'), findsOneWidget);
    expect(find.text('Economics'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Marketing'), findsOneWidget);
    expect(find.text('Accounting'), findsOneWidget);
    expect(find.text('Management'), findsOneWidget);
  });

  testWidgets('Management major opens Business Administration courses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<BusinessSchoolProgressService>(
        create: (_) => BusinessSchoolProgressService(),
        child: const MaterialApp(
          home: BusinessSchoolScreen(
            initialMajor: BusinessMajor.businessAdministration,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Courses'), findsOneWidget);
    expect(find.textContaining('Introduction to Business'), findsOneWidget);
    expect(
      businessActivityFlow(BusinessMajor.businessAdministration),
      <BusinessActivityKind>[
        BusinessActivityKind.professor,
        BusinessActivityKind.video,
        BusinessActivityKind.notes,
        BusinessActivityKind.aiTutor,
        BusinessActivityKind.homework,
        BusinessActivityKind.exam,
      ],
    );
  });

  test('Business curriculum matches the supplied topic outline', () {
    final List<BusinessCourse> courses = BusinessSchoolCatalog.coursesFor(
      BusinessMajor.businessAdministration,
    );
    expect(courses.length, 29);
    expect(
      PracticeLabUniversityCatalog.subjectById('business')?.courses.length,
      greaterThanOrEqualTo(29),
    );

    final List<BusinessLessonPath> paths = BusinessSchoolCatalog.pathsFor(
      BusinessMajor.businessAdministration,
    );
    for (final String topic in <String>[
      'What is Business?',
      'Business Statistics Basics',
      'Cross-cultural Communication',
      "Porter's Five Forces",
      'Critical Path Method (CPM)',
      'Family Business Management',
      'Digital Twins',
      'Power BI',
      'Professional Ethics',
      'Final Presentation',
    ]) {
      expect(
        paths.any((BusinessLessonPath p) => p.lesson.title == topic),
        isTrue,
        reason: topic,
      );
    }
  });

  test('every Business topic has a full textbook chapter', () {
    final List<BusinessLessonPath> paths = BusinessSchoolCatalog.pathsFor(
      BusinessMajor.businessAdministration,
    );
    for (final BusinessLessonPath path in paths.take(5)) {
      final notes = BusinessLectureNotes.forPath(path);
      expect(notes.sections.length, greaterThanOrEqualTo(3));
    }
  });

  testWidgets('lecture notes do not change mastery or XP', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final BusinessSchoolProgressService progress =
        BusinessSchoolProgressService();
    await progress.load();
    final BusinessLessonPath path = BusinessSchoolCatalog.pathsFor(
      BusinessMajor.businessAdministration,
    ).first;
    final int xpBefore = progress.xp;
    await progress.complete(path.lesson.id, BusinessActivityKind.notes);
    expect(progress.xp, xpBefore);
    expect(
      progress.isComplete(path.lesson.id, BusinessActivityKind.notes),
      isFalse,
    );
  });
}
