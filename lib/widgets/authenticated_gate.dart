import 'package:flutter/material.dart';

import '../models/account_deletion_status.dart';
import '../screens/account_recovery_screen.dart';
import '../screens/app_shell.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Routes authenticated users to the app, recovery screen, or final deletion.
class AuthenticatedGate extends StatefulWidget {
  const AuthenticatedGate({
    super.key,
    required this.userService,
    required this.authService,
  });

  final UserService userService;
  final AuthService authService;

  @override
  State<AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<AuthenticatedGate> {
  bool _checking = true;
  AccountDeletionStatus? _scheduled;
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    _evaluateAccount();
  }

  Future<void> _evaluateAccount() async {
    setState(() {
      _checking = true;
      _scheduled = null;
      _restored = false;
    });

    try {
      final bool deleted = await widget.userService.finalizeDeletionIfDue();
      if (!mounted) return;
      if (deleted) return;

      final AccountDeletionStatus? status = await widget.userService.fetchDeletionStatus();
      if (!mounted) return;
      setState(() {
        _scheduled = status;
        _checking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_scheduled != null && !_restored) {
      return AccountRecoveryScreen(
        status: _scheduled!,
        onRestored: () => setState(() {
          _scheduled = null;
          _restored = true;
        }),
      );
    }

    return const AppShell();
  }
}
