import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/mathematics_progress_service.dart';
import '../../services/openai_service.dart';

/// Ensures math activity routes always have required providers.
class MathActivityScope extends StatelessWidget {
  const MathActivityScope({super.key, required this.child});

  final Widget child;

  static Widget wrap(BuildContext context, Widget child) {
    return MultiProvider(
      providers: [
        Provider<OpenAiService>.value(value: context.read<OpenAiService>()),
        ChangeNotifierProvider<MathematicsProgressService>.value(
          value: context.read<MathematicsProgressService>(),
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => child;
}
