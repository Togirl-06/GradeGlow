import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_buddy/data/biology_degree_catalog.dart';
import 'package:ai_study_buddy/models/biology_degree.dart';
import 'package:ai_study_buddy/screens/biology/biology_lesson_hub_screen.dart';
import 'package:ai_study_buddy/services/biology_progress_service.dart';
import 'package:ai_study_buddy/services/openai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Biology lesson hub shows active-learning pipeline', (WidgetTester tester) async {
    final BiologyProgressService progress = BiologyProgressService();
    final OpenAiService openAi = OpenAiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<OpenAiService>.value(value: openAi),
          ChangeNotifierProvider<BiologyProgressService>.value(value: progress),
        ],
        child: MaterialApp(
          home: BiologyLessonHubScreen(path: BiologyDegreeCatalog.defaultLesson),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lesson Workspaces'), findsOneWidget);
    expect(find.text('AI Professor Lecture'), findsOneWidget);
    expect(find.text('Interactive Activity'), findsOneWidget);

    // Workspace cards are taller — scroll to bring later titles on-screen.
    for (final String title in <String>[
      '3D Exploration',
      'Virtual Experiment',
      'Practice Exercises',
      'Case Study',
      'AI Discussion',
      'Assessment',
      'Reflection & Notes',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    }

    expect(BioLessonActivityKind.activeLessonFlow.length, 9);
  });
}
