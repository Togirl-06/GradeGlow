import 'package:flutter/material.dart';

import 'vu_v2_progress_store.dart';
import 'vu_v2_session.dart';

class VuV2Scope extends InheritedWidget {
  const VuV2Scope({
    super.key,
    required this.session,
    required this.progress,
    required super.child,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  static VuV2Scope of(BuildContext context) {
    final VuV2Scope? scope =
        context.dependOnInheritedWidgetOfExactType<VuV2Scope>();
    assert(scope != null, 'VuV2Scope not found');
    return scope!;
  }

  static VuV2Scope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VuV2Scope>();
  }

  @override
  bool updateShouldNotify(covariant VuV2Scope oldWidget) {
    return session != oldWidget.session || progress != oldWidget.progress;
  }
}
