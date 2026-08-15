import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/screens/physics/physics_program_screen.dart';

void main() {
  testWidgets('PhysicsProgramScreen builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PhysicsProgramScreen()),
    );
    expect(find.text('Loading Physics Faculty…'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Physics Faculty'), findsOneWidget);
    expect(find.text('Choose a Practical'), findsOneWidget);
    expect(find.text('Loading Physics Faculty…'), findsNothing);
  });
}
