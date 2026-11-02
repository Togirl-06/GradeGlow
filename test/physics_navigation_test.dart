import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_buddy/data/physics_degree_catalog.dart';
import 'package:ai_study_buddy/screens/physics/physics_degree_lesson_hub_screen.dart';
import 'package:ai_study_buddy/services/physics_progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Physics lesson hub opens without crash', (WidgetTester tester) async {
    final PhysicsProgressService progress = PhysicsProgressService();

    await tester.pumpWidget(
      ChangeNotifierProvider<PhysicsProgressService>.value(
        value: progress,
        child: MaterialApp(
          home: PhysicsDegreeLessonHubScreen(path: PhysicsDegreeCatalog.defaultLesson),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lesson Activities'), findsOneWidget);
    expect(find.text('AI Professor'), findsOneWidget);
    expect(find.text('3D Simulation & Lab'), findsOneWidget);
  });
}
