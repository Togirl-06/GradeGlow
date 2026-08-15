import 'package:flutter/material.dart';

import '../../data/physics/physics_practical_lab_catalog.dart';
import '../../models/physics/physics_program.dart';
import '../../theme/physics_theme.dart';
import 'physics_routes.dart';

/// Full Practical Lab hub — PhysicLab-style grid with college-physics resource framing.
class PhysicsPracticalLabHubScreen extends StatefulWidget {
  const PhysicsPracticalLabHubScreen({super.key});

  @override
  State<PhysicsPracticalLabHubScreen> createState() => _PhysicsPracticalLabHubScreenState();
}

class _PhysicsPracticalLabHubScreenState extends State<PhysicsPracticalLabHubScreen> {
  bool _darkMode = true;
  String _filter = 'All';

  void _openPractical(PhysicsPracticalLab practical) {
    final PhysicsTrack? track = practical.track;
    final PhysicsCourse? course = practical.course;
    final PhysicsTopic? topic = practical.topic;
    if (track == null || course == null || topic == null) return;
    PhysicsRoutes.openSimulation(context, track: track, course: course, topic: topic);
  }

  List<PhysicsPracticalLab> get _filtered {
    if (_filter == 'All') return PhysicsPracticalLabCatalog.all;
    return PhysicsPracticalLabCatalog.forCategory(_filter);
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _darkMode ? PhysicsTheme.consoleBg : PhysicsTheme.background;
    final Color surface = _darkMode ? PhysicsTheme.consolePanel : PhysicsTheme.surface;
    final Color text = _darkMode ? PhysicsTheme.consoleText : PhysicsTheme.textPrimary;
    final Color muted = _darkMode ? PhysicsTheme.consoleMuted : PhysicsTheme.textSecondary;
    final Color border = _darkMode ? PhysicsTheme.consoleBorder : PhysicsTheme.border;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _darkMode
                  ? <Color>[PhysicsTheme.consoleBg, PhysicsTheme.consolePanel]
                  : <Color>[PhysicsTheme.primaryDark, PhysicsTheme.primary],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Practical Lab', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            Text('Virtual experiments & simulations', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: _darkMode ? 'Light mode' : 'Dark mode',
            onPressed: () => setState(() => _darkMode = !_darkMode),
            icon: Icon(_darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _darkMode
                    ? <Color>[PhysicsTheme.primary.withValues(alpha: 0.35), PhysicsTheme.consolePanel]
                    : <Color>[PhysicsTheme.primary.withValues(alpha: 0.12), PhysicsTheme.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'College Intro Physics — For Students',
                  style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Master every topic with interactive simulators, real-time data, and built-in theory — '
                  'then reinforce with AI Professor chapters, quizzes, and experiment reports.',
                  style: TextStyle(color: muted, height: 1.45, fontSize: 14),
                ),
                const SizedBox(height: 14),
                ...<String>[
                  '📹 Step-by-step simulations with live formulas',
                  '📊 Real-time graphs and comparison modes',
                  '📚 Theory, applications, and AI Professor support',
                  '✅ Practice problems tied to each practical',
                ].map(
                  (String line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(line, style: TextStyle(color: text, fontSize: 13, height: 1.35)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '🎓 CHOOSE A PRACTICAL',
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click any topic below to start exploring real-world physics through simulation:',
            style: TextStyle(color: muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <String>['All', ...PhysicsPracticalLabCatalog.categories].map((String cat) {
                final bool selected = _filter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = cat),
                    selectedColor: PhysicsTheme.primary.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: selected ? PhysicsTheme.primary : muted,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemCount: _filtered.length,
            itemBuilder: (BuildContext context, int i) {
              final PhysicsPracticalLab p = _filtered[i];
              return _HubPracticalCard(
                practical: p,
                surface: surface,
                text: text,
                muted: muted,
                border: border,
                dark: _darkMode,
                onTap: () => _openPractical(p),
              );
            },
          ),
          const SizedBox(height: 16),
          _ComingSoonCard(surface: surface, text: text, muted: muted, border: border),
        ],
      ),
    );
  }
}

class _HubPracticalCard extends StatelessWidget {
  const _HubPracticalCard({
    required this.practical,
    required this.surface,
    required this.text,
    required this.muted,
    required this.border,
    required this.dark,
    required this.onTap,
  });

  final PhysicsPracticalLab practical;
  final Color surface;
  final Color text;
  final Color muted;
  final Color border;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      elevation: dark ? 0 : 2,
      shadowColor: PhysicsTheme.primary.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            gradient: dark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[surface, PhysicsTheme.primary.withValues(alpha: 0.15)],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(practical.emoji, style: const TextStyle(fontSize: 32)),
                const Spacer(),
                Text(
                  practical.title,
                  style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 14, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  practical.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 11, height: 1.35),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(Icons.play_circle_fill_rounded, color: PhysicsTheme.primary, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      'Start simulation',
                      style: TextStyle(color: PhysicsTheme.primary, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({
    required this.surface,
    required this.text,
    required this.muted,
    required this.border,
  });

  final Color surface;
  final Color text;
  final Color muted;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, style: BorderStyle.solid),
      ),
      child: Row(
        children: <Widget>[
          const Text('🚀', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Exciting Simulators Ahead', style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  'Wave interference, magnetic fields, and quantum demos are on the way.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
