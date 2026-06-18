import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ai_study_buddy/main.dart';
import 'package:ai_study_buddy/services/appearance_service.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad();
  });

  testWidgets('app shows splash then login', (WidgetTester tester) async {
    final AppearanceService appearance = AppearanceService();
    await appearance.ensureLoaded();
    await tester.pumpWidget(GradeGlowApp(appearanceService: appearance));
    await tester.pump();

    expect(find.text('Learn brighter every day'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('demo sign in shows home', (WidgetTester tester) async {
    final AppearanceService appearance = AppearanceService();
    await appearance.ensureLoaded();
    await tester.pumpWidget(GradeGlowApp(appearanceService: appearance));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Browse'), findsWidgets);
  });
}
