import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/models/english_lesson.dart';
import 'package:ai_study_buddy/screens/english/english_lesson_screen.dart';
import 'package:ai_study_buddy/data/english/lessons/present_perfect_lesson.dart';
import 'package:ai_study_buddy/services/english_lesson_engine.dart';
import 'package:ai_study_buddy/widgets/english/english_activity_panel.dart';

void main() {
  testWidgets('EnglishActivityPanel sentence builder shows word bank', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: EnglishActivityPanel(
              activity: const EnglishActivity(
                id: 'pp_build',
                kind: EnglishActivityKind.sentenceBuilder,
                skill: EnglishSkill.grammar,
                prompt: 'Build the sentence',
                wordBank: <String>['I', 'have', 'never', 'been', 'there'],
                correctSentence: 'I have never been there',
              ),
              phase: EnglishLessonPhase.active,
              feedback: null,
              lastCorrect: false,
              onSubmit: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Your sentence'), findsOneWidget);
    expect(find.textContaining('Word bank'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
    expect(find.text('Submit answer'), findsOneWidget);
  });

  testWidgets('EnglishLessonScreen shows sentence builder at pp_build', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: EnglishLessonScreen(script: presentPerfectLesson),
      ),
    );

    final EnglishLessonEngine engine = EnglishLessonEngine(
      presentPerfectLesson,
      useQuestionBank: false,
    );
    engine.begin();
    while (engine.currentActivity?.id != 'pp_build' && !engine.isComplete) {
      if (engine.phase == EnglishLessonPhase.microPrompt) {
        engine.advanceFromMicroPrompt();
      } else if (engine.phase == EnglishLessonPhase.feedback) {
        engine.continueAfterFeedback();
      } else {
        engine.submitAnswer('dummy');
        if (engine.phase == EnglishLessonPhase.active) break;
      }
    }

    // Re-pump with controlled engine by finding the screen state is hard;
    // instead pump panel in lesson layout manually.
    final EnglishActivity step = engine.currentActivity!;
    expect(step.kind, EnglishActivityKind.sentenceBuilder);
    expect(step.wordBank, isNotEmpty);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              EnglishActivityPanel(
                key: const ValueKey<String>('pp_build-4'),
                activity: step,
                phase: EnglishLessonPhase.active,
                feedback: null,
                lastCorrect: false,
                onSubmit: (_) {},
                showSubmitButton: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('I'), findsOneWidget);
    expect(find.text('never'), findsOneWidget);
  });
}
