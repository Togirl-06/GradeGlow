import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/account_deletion_status.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/study_messenger.dart';

/// Shown when a user signs in during the 30-day deletion grace period.
class AccountRecoveryScreen extends StatelessWidget {
  const AccountRecoveryScreen({
    super.key,
    required this.status,
    required this.onRestored,
  });

  final AccountDeletionStatus status;
  final VoidCallback onRestored;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final String deleteDate = DateFormat.yMMMMd().format(status.deleteAt);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              Icon(Icons.hourglass_top_rounded, size: 56, color: StudyColors.warning),
              const SizedBox(height: 20),
              const Text(
                'Account scheduled for deletion',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Your GradeGlow account is hidden and will be permanently deleted on $deleteDate '
                '(${status.daysRemaining} days remaining).',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 12),
              Text(
                'Restore now to keep your courses, notes, flashcards, quizzes, uploads, and AI chats.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14, height: 1.4),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _restore(context),
                child: const Text('Restore my account'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _signOut(context),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context) async {
    try {
      await context.read<UserService>().cancelScheduledDeletion();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account restored. Welcome back!')),
      );
      onRestored();
    } catch (error) {
      if (!context.mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthService>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }
}
