import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_buddy/data/mathematics_degree_catalog.dart';
import 'package:ai_study_buddy/screens/mathematics/mathematics_lecture_screen.dart';
import 'package:ai_study_buddy/services/mathematics_progress_service.dart';
import 'package:ai_study_buddy/services/openai_service.dart';
import 'package:ai_study_buddy/theme/study_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    dotenv.testLoad();
  });

  Future<void> pumpLecture(WidgetTester tester) async {
    final OpenAiService openAi = OpenAiService();
    final MathematicsProgressService progress = MathematicsProgressService();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildStudyTheme(Brightness.light),
        home: MultiProvider(
          providers: [
            Provider<OpenAiService>.value(value: openAi),
            ChangeNotifierProvider<MathematicsProgressService>.value(value: progress),
          ],
          child: MathematicsLectureScreen(
            path: MathematicsDegreeCatalog.defaultLesson,
            openAi: openAi,
            progress: progress,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  void assertNoCrash(WidgetTester tester, String step) {
    final Object? error = tester.takeException();
    if (error != null) {
      fail('Crash at $step: $error');
    }
  }

  testWidgets('lecture mode picker and controls do not throw', (WidgetTester tester) async {
    await pumpLecture(tester);
    assertNoCrash(tester, 'initial pump');

    await tester.pump(const Duration(milliseconds: 500));
    assertNoCrash(tester, 'lecture load');

    for (final String label in <String>['Notes']) {
      final Finder control = find.text(label);
      if (control.evaluate().isEmpty) continue;
      await tester.tap(control.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      assertNoCrash(tester, 'tap $label');
      if (find.byType(ModalBarrier).evaluate().isNotEmpty) {
        await tester.tapAt(const Offset(20, 20));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (find.text('Raise Hand').evaluate().isNotEmpty) {
      await tester.tap(find.text('Raise Hand'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      assertNoCrash(tester, 'tap Raise Hand open');
      if (find.byIcon(Icons.close_rounded).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }
      assertNoCrash(tester, 'dismiss Raise Hand');
    }

    if (find.byIcon(Icons.pause_rounded).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      assertNoCrash(tester, 'pause');
    } else if (find.byIcon(Icons.play_arrow_rounded).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      assertNoCrash(tester, 'play');
    }
  });
}
