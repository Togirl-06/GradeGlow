import 'dart:io' show Platform;

bool get isFlutterTestImpl =>
    Platform.environment['FLUTTER_TEST'] == 'true';
