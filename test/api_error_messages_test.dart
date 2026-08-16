import 'package:ai_study_buddy/utils/api_error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hides Dart null-check crashes from the tutor banner', () {
    final ApiErrorInfo info = ApiErrorMessages.fromException(
      StateError('Null check operator used on a null value'),
    );
    expect(info.title, 'Something went wrong');
    expect(info.message, isNot(contains('Null check operator')));
  });
}
