import 'package:ai_study_buddy/screens/business/business_school_screen.dart';
import 'package:ai_study_buddy/screens/science/science_school_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('school dashboards follow light and dark app themes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final Brightness brightness in Brightness.values) {
      final ThemeData theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const ScienceSchoolScreen()),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        theme.scaffoldBackgroundColor,
      );

      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const BusinessSchoolScreen()),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        theme.scaffoldBackgroundColor,
      );
    }
  });
}
