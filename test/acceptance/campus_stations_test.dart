// Acceptance: every learning station in every school building opens its real
// screen inside the full app (all providers, demo sign-in) without throwing.
//
// This is what a student does when they walk up to a station and press Use:
// LifeGame → ActionType.openLab → CampusLabs.byId(id).open(context).
import 'dart:async';

import 'package:ai_study_buddy/life_sim/campus/campus_labs.dart';
import 'package:ai_study_buddy/life_sim/campus/lab_info.dart';
import 'package:ai_study_buddy/main.dart';
import 'package:ai_study_buddy/screens/login_screen.dart';
import 'package:ai_study_buddy/screens/mathematics/mathematics_degree_home_screen.dart';
import 'package:ai_study_buddy/services/appearance_service.dart';
import 'package:ai_study_buddy/services/auth_service.dart';
import 'package:ai_study_buddy/widgets/study_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<BuildContext> signedInContext(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final AppearanceService appearance = AppearanceService();
  await appearance.ensureLoaded();
  await tester.pumpWidget(GradeGlowApp(appearanceService: appearance));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  final AuthService auth = Provider.of<AuthService>(tester.element(find.byType(LoginScreen)), listen: false);
  await auth.signInDemo();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return tester.element(find.byType(StudyBottomNav));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    dotenv.testLoad();
  });

  for (final LabInfo info in kCampusLabs) {
    testWidgets('station ${info.id} (${info.schoolId}) opens ${info.name}', (WidgetTester tester) async {
      final BuildContext ctx = await signedInContext(tester);
      final CampusLab lab = CampusLabs.byId(info.id)!;
      final NavigatorState nav = Navigator.of(ctx);
      unawaited(lab.open(ctx));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      final Object? error = tester.takeException();
      expect(error, isNull, reason: '${info.id} threw: $error');
      // A new screen is on top of the shell.
      expect(nav.canPop(), isTrue, reason: '${info.id} did not open a screen');
      if (info.id == 'math_whiteboard') {
        // Replaces the old "Virtual University → Mathematics" navigation test.
        expect(find.byType(MathematicsDegreeHomeScreen), findsOneWidget);
      }
      nav.popUntil((Route<dynamic> r) => r.isFirst);
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(tester.takeException(), isNull);
      // Let any timers the screen started finish before the test ends.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
