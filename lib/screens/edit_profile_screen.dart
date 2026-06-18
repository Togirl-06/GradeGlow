import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import 'my_courses_screen.dart';
import '../utils/study_messenger.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  bool _anonymousDefault = false;
  bool _loaded = false;

  static const List<String> _yearOptions = <String>[
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate',
  ];

  @override
  void dispose() {
    _schoolController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _load(UserProfile profile) {
    if (_loaded) return;
    _schoolController.text = profile.school;
    _majorController.text = profile.major;
    _yearController.text = profile.year;
    _anonymousDefault = profile.anonymousByDefault;
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final UserService users = context.watch<UserService>();
    final AuthService auth = context.watch<AuthService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: StreamBuilder<UserProfile>(
        stream: users.watchProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          final UserProfile profile = snapshot.data ?? UserProfile.empty(email: auth.email);
          _load(profile);
          final bool pendingEduVerify = auth.hasEduEmail && !auth.isEmailVerified;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              if (profile.isEduVerified)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.verified, color: StudyColors.success),
                  title: Text('.edu email verified'),
                )
              else if (pendingEduVerify) ...<Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mark_email_unread_outlined, color: StudyColors.warning),
                  title: const Text('Verify your .edu email'),
                  subtitle: Text(
                    'We sent a link to ${auth.email}. Tap below after you confirm.',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
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
                const SizedBox(height: 8),
              ],
              const Text('School info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(controller: _schoolController, decoration: const InputDecoration(labelText: 'School')),
              const SizedBox(height: 10),
              TextField(controller: _majorController, decoration: const InputDecoration(labelText: 'Major')),
              const SizedBox(height: 10),
              TextField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _yearOptions
                    .map(
                      (String year) => ActionChip(
                        label: Text(year),
                        onPressed: () => setState(() => _yearController.text = year),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Anonymous uploads by default'),
                value: _anonymousDefault,
                onChanged: (bool v) => setState(() => _anonymousDefault = v),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const MyCoursesScreen()),
                  );
                },
                icon: const Icon(Icons.school_outlined),
                label: const Text('Manage my courses'),
              ),
              const SizedBox(height: 8),
              Text(
                'Add semesters, classes per term (Spring 2026, Fall 2025), and more.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await users.updateProfile(
                    school: _schoolController.text,
                    major: _majorController.text,
                    year: _yearController.text,
                    anonymousByDefault: _anonymousDefault,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Save profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}
