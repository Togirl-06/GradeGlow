import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_buddy/main.dart';
import 'package:ai_study_buddy/screens/login_screen.dart';
import 'package:ai_study_buddy/screens/mathematics/mathematics_lecture_screen.dart';
import 'package:ai_study_buddy/services/appearance_service.dart';
import 'package:ai_study_buddy/services/auth_service.dart';

Future<void> _pumpPastSplash(WidgetTester tester, GradeGlowApp app) async {
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    dotenv.testLoad();
  });

  testWidgets('full flow: lecture mode opens without crash', (WidgetTester tester) async {
    final AppearanceService appearance = AppearanceService();
    await appearance.ensureLoaded();
    await _pumpPastSplash(tester, GradeGlowApp(appearanceService: appearance));

    final AuthService auth = Provider.of<AuthService>(
      tester.element(find.byType(LoginScreen)),
      listen: false,
    );
    await auth.signInDemo();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.text('Virtual University'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Mathematics'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Continue →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Lecture'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Object? error = tester.takeException();
    if (error != null) fail('Crash opening lecture: $error');

    await tester.pump(const Duration(milliseconds: 500));

    error = tester.takeException();
    if (error != null) fail('Crash loading lecture: $error');

    expect(find.byType(MathematicsLectureScreen), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final Object? frameError = tester.takeException();
      if (frameError != null) fail('Crash during lecture playback: $frameError');
    }

    await tester.tap(find.text('Restart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });
}
