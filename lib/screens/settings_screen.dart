import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../services/appearance_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../widgets/accent_color_picker_sheet.dart';
import '../widgets/delete_account_flow.dart';
import 'edit_profile_screen.dart';
import 'legal_document_screen.dart';
import 'membership_screen.dart';
import '../utils/study_messenger.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _renameName(BuildContext context, String currentName) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _RenameNameDialog(initialName: currentName),
    );

    if (newName == null || newName.isEmpty || newName == currentName || !context.mounted) return;

    try {
      await context.read<UserService>().updateDisplayName(newName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated')));
    } catch (error) {
      if (!context.mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _openEmailDetails(BuildContext context) async {
    final AuthService auth = context.read<AuthService>();
    final UserService users = context.read<UserService>();
    final bool pendingEduVerify = auth.hasEduEmail && !auth.isEmailVerified;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: StudyColors.border(Theme.of(context).brightness),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(auth.email, style: const TextStyle(fontSize: 15)),
                if (auth.hasEduEmail) ...<Widget>[
                  const SizedBox(height: 16),
                  if (auth.isEmailVerified)
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.verified, color: StudyColors.success),
                      title: Text('.edu email verified'),
                    )
                  else ...<Widget>[
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.mark_email_unread_outlined, color: StudyColors.warning),
                      title: Text('Verify your .edu email'),
                      subtitle: Text('Check your inbox for the verification link.'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await auth.reloadUser();
                          await users.ensureUserDocument();
                          if (!context.mounted) return;
                          if (auth.isEmailVerified) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email verified!')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not verified yet — check your inbox.')),
                            );
                          }
                        } catch (error) {
                          if (!context.mounted) return;
                          StudyMessenger.showError(context, error);
                        }
                      },
                      child: const Text('I verified my email'),
                    ),
                    if (pendingEduVerify)
                      TextButton(
                        onPressed: () async {
                          try {
                            await auth.sendEmailVerification();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Verification email sent.')),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            StudyMessenger.showError(context, error);
                          }
                        },
                        child: const Text('Resend verification email'),
                      ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    await DeleteAccountFlow.run(context);
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthService>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = context.watch<AuthService>();
    final UserService users = context.watch<UserService>();
    final AppearanceService appearance = context.watch<AppearanceService>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final bool isDark = appearance.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StreamBuilder<UserProfile>(
        stream: users.watchProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          final UserProfile profile = snapshot.data ??
              UserProfile.empty(email: auth.email, displayName: auth.displayName);
          final String name = profile.displayName.isNotEmpty ? profile.displayName : auth.displayName;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              const _SectionHeader(title: 'Account'),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: <Widget>[
                  _AccountValueRow(
                    label: 'Name',
                    value: name,
                    onTap: () => _renameName(context, name),
                  ),
                  _AccountValueRow(
                    label: 'Email',
                    value: auth.email,
                    showChevron: true,
                    onTap: () => _openEmailDetails(context),
                  ),
                  _AccountActionRow(
                    label: 'Delete account',
                    action: OutlinedButton(
                      onPressed: () => _confirmDeleteAccount(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StudyColors.danger,
                        side: const BorderSide(color: StudyColors.danger),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: <Widget>[
                  _SettingsNavRow(
                    title: 'Plans & features',
                    subtitle: 'Free vs Premium',
                    icon: Icons.workspace_premium_outlined,
                    iconColor: StudyColors.accent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
                    ),
                  ),
                  _SettingsNavRow(
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    icon: Icons.privacy_tip_outlined,
                    iconColor: StudyColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LegalDocumentScreen(
                          kind: LegalDocumentKind.privacy,
                        ),
                      ),
                    ),
                  ),
                  _SettingsNavRow(
                    title: 'Terms of Service',
                    subtitle: 'Rules for using GradeGlow',
                    icon: Icons.gavel_outlined,
                    iconColor: StudyColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LegalDocumentScreen(
                          kind: LegalDocumentKind.terms,
                        ),
                      ),
                    ),
                  ),
                  _SettingsNavRow(
                    title: 'Edit profile',
                    subtitle: 'School, major, courses',
                    icon: Icons.person_outline_rounded,
                    iconColor: StudyColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _SettingsNavRow(
                    title: 'App color',
                    subtitle: 'Buttons, links & highlights',
                    icon: Icons.palette_outlined,
                    iconColor: appearance.primaryColor,
                    onTap: () => AccentColorPickerSheet.show(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Dark mode'),
                      value: isDark,
                      onChanged: (bool value) =>
                          appearance.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                  _SettingsNavRow(
                    title: 'Sign out',
                    icon: Icons.logout_rounded,
                    iconColor: StudyColors.danger,
                    titleColor: StudyColors.danger,
                    showChevron: false,
                    onTap: () => _signOut(context),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Signed in as ${auth.email}',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RenameNameDialog extends StatefulWidget {
  const _RenameNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameNameDialog> createState() => _RenameNameDialogState();
}

class _RenameNameDialogState extends State<_RenameNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (_) => _save(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: StudyColors.textSecondary(Theme.of(context).brightness),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(children: children),
    );
  }
}

class _AccountValueRow extends StatelessWidget {
  const _AccountValueRow({
    required this.label,
    required this.value,
    this.showChevron = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final Color divider = StudyColors.border(Theme.of(context).brightness);

    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: <Widget>[
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                if (showChevron) ...<Widget>[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                ],
              ],
            ),
          ),
        ),
        Divider(height: 1, color: divider),
      ],
    );
  }
}

class _AccountActionRow extends StatelessWidget {
  const _AccountActionRow({
    required this.label,
    required this.action,
  });

  final String label;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          action,
        ],
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.titleColor,
    this.showChevron = true,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? titleColor;
  final VoidCallback onTap;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final Color divider = StudyColors.border(Theme.of(context).brightness);

    return Column(
      children: <Widget>[
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
          subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: textSecondary, fontSize: 12)),
          trailing: showChevron ? Icon(Icons.chevron_right_rounded, color: textSecondary) : null,
        ),
        if (showDivider) Divider(height: 1, indent: 56, endIndent: 16, color: divider),
      ],
    );
  }
}
