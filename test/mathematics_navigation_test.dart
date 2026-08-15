import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_buddy/main.dart';
import 'package:ai_study_buddy/screens/login_screen.dart';
import 'package:ai_study_buddy/screens/mathematics/mathematics_degree_home_screen.dart';
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

  testWidgets('Virtual University → Mathematics opens hub', (WidgetTester tester) async {
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

    final Object? error = tester.takeException();
    if (error != null) {
      fail('Crash opening Mathematics: $error');
    }

    expect(find.byType(MathematicsDegreeHomeScreen), findsOneWidget);
    expect(find.text('Continue →'), findsOneWidget);
  });
}
