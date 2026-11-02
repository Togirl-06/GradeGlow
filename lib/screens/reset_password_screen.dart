import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_branding.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../theme/study_theme.dart';
import '../utils/study_messenger.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController =
      TextEditingController(text: widget.initialEmail ?? '');
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      setState(() => _emailSent = true);
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return Scaffold(
      backgroundColor: StudyColors.background(brightness),
      appBar: AppBar(
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                  decoration: BoxDecoration(
                    color: StudyColors.surface(brightness),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: StudyColors.border(brightness)),
                  ),
                  child: _emailSent ? _buildSuccess(textSecondary) : _buildForm(textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Color textSecondary) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Enter the email for your ${AppBranding.name} account and we\'ll send you a link to reset your password.',
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.45),
          ),
          if (!AppConfig.hasFirebase) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StudyColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Firebase could not start on this device. Password reset is unavailable until it connects.',
                style: TextStyle(height: 1.35, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            autofocus: widget.initialEmail == null || widget.initialEmail!.isEmpty,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: StudyColors.background(Theme.of(context).brightness),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _isLoading || !AppConfig.hasFirebase ? null : _sendResetLink,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Send reset link',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Icon(Icons.mark_email_read_outlined, size: 48, color: StudyColors.success),
        const SizedBox(height: 16),
        const Text(
          'Password reset email sent. Check your inbox.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a link to ${_emailController.text.trim()}. '
          'Check spam or junk if you do not see it within a few minutes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }
}
