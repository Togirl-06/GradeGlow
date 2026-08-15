import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_buddy/data/chemistry_degree_catalog.dart';
import 'package:ai_study_buddy/models/chemistry_degree.dart';
import 'package:ai_study_buddy/screens/chemistry/chemistry_lesson_hub_screen.dart';
import 'package:ai_study_buddy/services/chemistry_progress_service.dart';
import 'package:ai_study_buddy/services/openai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Chemistry lesson hub opens without crash', (WidgetTester tester) async {
    final ChemistryProgressService progress = ChemistryProgressService();
    final OpenAiService openAi = OpenAiService();
    final ChemistryLessonPath path = ChemistryDegreeCatalog.defaultLesson;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<OpenAiService>.value(value: openAi),
          ChangeNotifierProvider<ChemistryProgressService>.value(value: progress),
        ],
        child: MaterialApp(
          home: ChemistryLessonHubScreen(path: path),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lesson Activities'), findsOneWidget);
    expect(find.text('AI Professor Lecture'), findsOneWidget);
    expect(find.text('Virtual Laboratory'), findsOneWidget);
  });
}
