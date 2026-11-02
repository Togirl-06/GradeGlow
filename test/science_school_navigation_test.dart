import 'package:ai_study_buddy/data/practice_lab_university_catalog.dart';
import 'package:ai_study_buddy/screens/science/science_school_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('School of Sciences exposes its three degree programs', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: ScienceSchoolScreen()));
    await tester.pumpAndSettle();

    expect(find.text('School of Sciences'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Why study science with us?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Continue Learning'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Continue Learning'), findsOneWidget);

    final science = PracticeLabUniversityCatalog.subjectById('sciences');
    expect(science, isNotNull);
    expect(science!.courses.map((course) => course.name), <String>[
      'Biology',
      'Chemistry',
      'Physics',
    ]);
  });
}
