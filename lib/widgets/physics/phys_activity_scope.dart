import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/physics_progress_service.dart';

class PhysActivityScope extends StatelessWidget {
  const PhysActivityScope({super.key, required this.child});

  final Widget child;

  static Widget wrap(BuildContext context, Widget child) {
    return ChangeNotifierProvider<PhysicsProgressService>.value(
      value: context.read<PhysicsProgressService>(),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => child;
}
