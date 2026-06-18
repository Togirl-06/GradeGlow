import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';

class WeaknessReviewScreen extends StatelessWidget {
  const WeaknessReviewScreen({super.key, required this.onStartQuiz});

  final VoidCallback onStartQuiz;

  @override
  Widget build(BuildContext context) {
    final UserService users = context.watch<UserService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Review weak topics')),
      body: StreamBuilder<UserProfile>(
        stream: users.watchProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          final UserProfile profile = snapshot.data ?? UserProfile.empty(email: '');
          final List<MapEntry<String, int>> weak = profile.topWeakTopics(limit: 5);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                'Topics you marked wrong in Quiz Mode. Focus here first.',
                style: TextStyle(color: textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              if (weak.isEmpty)
                StudySurfaceCard(
                  child: Text(
                    'No weak topics tracked yet. In Quiz Mode, tap “Got it wrong” after revealing an answer.',
                    style: TextStyle(color: textSecondary, height: 1.4),
                  ),
                )
              else
                ...weak.map(
                  (MapEntry<String, int> entry) => StudySurfaceCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.warning_amber_rounded, color: StudyColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('Missed ${entry.value} time${entry.value == 1 ? '' : 's'}', style: TextStyle(color: textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onStartQuiz,
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Practice in Quiz Mode'),
              ),
            ],
          );
        },
      ),
    );
  }
}
