import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/chemistry_progress_service.dart';
import '../../services/openai_service.dart';

/// Ensures chemistry activity routes always have required providers.
class ChemActivityScope extends StatelessWidget {
  const ChemActivityScope({super.key, required this.child});

  final Widget child;

  static Widget wrap(BuildContext context, Widget child) {
    return MultiProvider(
      providers: [
        Provider<OpenAiService>.value(value: context.read<OpenAiService>()),
        ChangeNotifierProvider<ChemistryProgressService>.value(
          value: context.read<ChemistryProgressService>(),
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => child;
}
