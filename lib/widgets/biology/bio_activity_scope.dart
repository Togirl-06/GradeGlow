import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/biology_progress_service.dart';
import '../../services/openai_service.dart';

class BioActivityScope extends StatelessWidget {
  const BioActivityScope({super.key, required this.child});

  final Widget child;

  static Widget wrap(BuildContext context, Widget child) {
    return MultiProvider(
      providers: [
        Provider<OpenAiService>.value(value: context.read<OpenAiService>()),
        ChangeNotifierProvider<BiologyProgressService>.value(
          value: context.read<BiologyProgressService>(),
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => child;
}
