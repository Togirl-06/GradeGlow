import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../utils/api_error_messages.dart';
import '../utils/premium_access.dart';

/// High-contrast snackbars so errors and messages stay readable everywhere.
class StudyMessenger {
  StudyMessenger._();

  static String clean(Object message) {
    if (message is PremiumRequiredException) return message.info.message;
    final String raw = message.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) return 'Something went wrong. Try again.';
    if (raw.startsWith("Instance of '") && raw.endsWith("'")) {
      return 'Something went wrong while building your study set. Try again.';
    }
    if (raw.startsWith('type ') && raw.contains(' is not a subtype of type ')) {
      return 'We could not read the AI response. Try again.';
    }
    return ApiErrorMessages.friendlyNetworkMessage(raw) ?? raw;
  }

  static void showError(
    BuildContext context,
    Object message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      clean(message),
      backgroundColor: StudyColors.danger,
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: StudyColors.success,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF1E293B),
      duration: duration,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Duration duration,
  }) {
    if (message.isEmpty) return;

    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          elevation: 6,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: messenger.hideCurrentSnackBar,
          ),
        ),
      );
  }
}
