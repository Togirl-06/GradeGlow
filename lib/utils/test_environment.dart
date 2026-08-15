import 'test_environment_stub.dart'
    if (dart.library.io) 'test_environment_io.dart' as impl;

/// True when running under `flutter test`.
/// Safe on web (never reads `dart:io` Platform).
bool get isFlutterTest => impl.isFlutterTestImpl;
