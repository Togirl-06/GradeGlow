import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/screens/law/law_program_screen.dart';

void main() {
  testWidgets('LawProgramScreen builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LawProgramScreen()),
    );
    expect(find.text('Loading Law School…'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Law School'), findsOneWidget);
    expect(find.text('Think like a lawyer'), findsOneWidget);
  });
}
