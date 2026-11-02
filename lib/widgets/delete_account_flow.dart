import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account_deletion_status.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/study_messenger.dart';

/// Settings → Delete account: warning, type DELETE, re-auth, schedule deletion.
class DeleteAccountFlow {
  DeleteAccountFlow._();

  static Future<void> run(BuildContext context) async {
    final AuthService auth = context.read<AuthService>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const _DeleteAccountWarningDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    String? password;
    if (auth.usesEmailPassword) {
      password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const _DeleteAccountPasswordDialog(),
      );
      if (password == null || password.isEmpty || !context.mounted) return;
    }

    try {
      await context.read<UserService>().scheduleAccountDeletion(password: password);
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Account scheduled for deletion'),
          content: Text(
            'Your GradeGlow account will be permanently deleted in '
            '${AccountDeletionConfig.recoveryWindow.inDays} days. '
            'Sign in before then to restore your account.',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;
      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    } catch (error) {
      if (!context.mounted) return;
      StudyMessenger.showError(context, error);
    }
  }
}

class _DeleteAccountWarningDialog extends StatefulWidget {
  const _DeleteAccountWarningDialog();

  @override
  State<_DeleteAccountWarningDialog> createState() => _DeleteAccountWarningDialogState();
}

class _DeleteAccountWarningDialogState extends State<_DeleteAccountWarningDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canDelete =>
      _controller.text.trim().toUpperCase() == AccountDeletionConfig.confirmToken;

  @override
  Widget build(BuildContext context) {
    final AuthService auth = context.read<AuthService>();
    final String reauthHint = auth.usesEmailPassword
        ? 'You will enter your password next.'
        : auth.usesGoogleSignIn
            ? 'You will confirm with Google next.'
            : auth.usesAppleSignIn
                ? 'You will confirm with Apple next.'
                : 'You will confirm your identity next.';

    return AlertDialog(
      title: const Text('Delete account?'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(AccountDeletionConfig.warningMessage),
            const SizedBox(height: 16),
            Text(
              'Deletes: profile, courses, notes, flashcards, quiz history, '
              'uploaded files, AI chats, and study statistics.',
              style: TextStyle(
                color: StudyColors.textSecondary(Theme.of(context).brightness),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reauthHint,
              style: TextStyle(
                color: StudyColors.textSecondary(Theme.of(context).brightness),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Type ${AccountDeletionConfig.confirmToken} to confirm',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: StudyColors.danger,
            disabledBackgroundColor: StudyColors.danger.withValues(alpha: 0.35),
          ),
          onPressed: _canDelete ? () => Navigator.pop(context, true) : null,
          child: const Text('Delete account'),
        ),
      ],
    );
  }
}

class _DeleteAccountPasswordDialog extends StatefulWidget {
  const _DeleteAccountPasswordDialog();

  @override
  State<_DeleteAccountPasswordDialog> createState() => _DeleteAccountPasswordDialogState();
}

class _DeleteAccountPasswordDialogState extends State<_DeleteAccountPasswordDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final String value = _controller.text;
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm your password'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: _obscure,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
        ),
        onSubmitted: (_) => _confirm(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: StudyColors.danger),
          onPressed: _confirm,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
