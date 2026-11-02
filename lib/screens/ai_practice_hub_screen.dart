import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ai_practice_catalog.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../services/ai_practice_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';
import '../utils/ai_practice_limits.dart';
import '../screens/membership_screen.dart';
import '../widgets/ai_practice/ai_practice_widgets.dart';
import '../widgets/study_surface.dart';
import 'ai_practice_all_majors_screen.dart';
import 'ai_practice_scenarios_screen.dart';

/// AI Practice Mode hub — major grid, progress, and leaderboard.
class AiPracticeHubScreen extends StatefulWidget {
  const AiPracticeHubScreen({super.key});

  @override
  State<AiPracticeHubScreen> createState() => _AiPracticeHubScreenState();
}

class _AiPracticeHubScreenState extends State<AiPracticeHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _selectedMajorId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiPracticeService>().refreshUsage();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openMajor(PracticeLabCategory major) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AiPracticeScenariosScreen(major: major)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final AiPracticeService service = context.watch<AiPracticeService>();
    final bool isPremium = context.watch<SubscriptionService>().isPremium;
    final AiPracticeUsage? usage = service.usage;
    final List<({PracticeLabCategory major, String label})> featured = AiPracticeCatalog.featuredMajors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Practice Mode'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: 'Practice'),
            Tab(text: 'Progress'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              Text(
                'Practice realistic scenarios for your major through interactive AI roleplay.',
                style: TextStyle(color: textSecondary, height: 1.45),
              ),
              if (!isPremium && usage != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  '${usage.remaining} of ${AiPracticeLimits.freeSessionsPerMonth} free sessions left · Premium = unlimited',
                  style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 20),
              const PracticeStepLabel(step: 1, title: 'Choose Your Major'),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.88,
                children: <Widget>[
                  ...featured.map(
                    (({PracticeLabCategory major, String label}) entry) => MajorGridTile(
                          label: entry.label,
                          icon: entry.major.icon,
                          emoji: entry.major.emoji.isNotEmpty ? entry.major.emoji : null,
                          selected: _selectedMajorId == entry.major.id,
                          onTap: () {
                            setState(() => _selectedMajorId = entry.major.id);
                            _openMajor(entry.major);
                          },
                        ),
                  ),
                  MajorGridTile(
                    label: 'More',
                    icon: Icons.apps_rounded,
                    onTap: () async {
                      final PracticeLabCategory? picked = await Navigator.of(context).push<PracticeLabCategory>(
                        MaterialPageRoute<PracticeLabCategory>(builder: (_) => const AiPracticeAllMajorsScreen()),
                      );
                      if (picked != null && mounted) _openMajor(picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StudySurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.auto_awesome_rounded, color: StudyColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('How it works', style: TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            'Pick a major → choose a scenario → roleplay with AI → get scored feedback.',
                            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const _ProgressTab(),
          const _LeaderboardTab(),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final AiPracticeService service = context.watch<AiPracticeService>();

    return StreamBuilder<List<AiPracticeRecord>>(
      stream: service.watchHistory(),
      builder: (BuildContext context, AsyncSnapshot<List<AiPracticeRecord>> snap) {
        final List<AiPracticeRecord> records = snap.data ?? <AiPracticeRecord>[];
        final List<int> scores = records.map((AiPracticeRecord r) => r.score).toList().reversed.toList();
        final int completed = records.length;
        final int average = completed == 0 ? 0 : (records.fold<int>(0, (int s, AiPracticeRecord r) => s + r.score) / completed).round();
        final int best = completed == 0 ? 0 : records.map((AiPracticeRecord r) => r.score).reduce((int a, int b) => a > b ? a : b);

        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.trending_up_rounded, size: 48, color: textSecondary),
                  const SizedBox(height: 12),
                  const PracticeStepLabel(step: 5, title: 'Progress Tracking'),
                  Text(
                    'Complete practice sessions to track scores, trends, and improvement over time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const PracticeStepLabel(step: 5, title: 'Progress Tracking'),
            StudySurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Your progress', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  PracticeProgressChart(scores: scores.length >= 2 ? scores : <int>[60, ...scores]),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      _StatTile(label: 'Completed', value: '$completed'),
                      _StatTile(label: 'Average', value: '$average%'),
                      _StatTile(label: 'Best', value: '$best%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recent scenarios', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            ...records.take(8).map(
              (AiPracticeRecord record) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StudySurfaceCard(
                  child: Row(
                    children: <Widget>[
                      ScoreBadge(score: record.score),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(record.scenarioTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              '${record.majorName} · ${record.difficulty}',
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(fontSize: 11, color: StudyColors.textSecondary(Theme.of(context).brightness))),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final AiPracticeService service = context.watch<AiPracticeService>();

    return StreamBuilder<List<AiPracticeLeaderboardEntry>>(
      stream: service.watchLeaderboard(),
      builder: (BuildContext context, AsyncSnapshot<List<AiPracticeLeaderboardEntry>> snap) {
        final List<AiPracticeLeaderboardEntry> entries = snap.data ?? <AiPracticeLeaderboardEntry>[];

        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Leaderboard rankings update as students complete practice sessions this month.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, height: 1.5),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('This month\'s top performers', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...entries.asMap().entries.map((MapEntry<int, AiPracticeLeaderboardEntry> entry) {
              final int rank = entry.key + 1;
              final AiPracticeLeaderboardEntry e = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StudySurfaceCard(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 32,
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: rank <= 3 ? StudyColors.accent : textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(e.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              '${e.sessionCount} sessions · avg ${e.averageScore}%',
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text('${e.totalScore} pts', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              );
            }),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
              ),
              child: const Text('Upgrade for unlimited practice'),
            ),
          ],
        );
      },
    );
  }
}
