import 'package:flutter/material.dart';

import '../data/vu_v2_degree_catalog.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2OnboardingScreen extends StatefulWidget {
  const VuV2OnboardingScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.onDone,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final VoidCallback onDone;

  @override
  State<VuV2OnboardingScreen> createState() => _VuV2OnboardingScreenState();
}

class _VuV2OnboardingScreenState extends State<VuV2OnboardingScreen> {
  final PageController _pages = PageController();
  final TextEditingController _name = TextEditingController();
  int _index = 0;
  final Set<String> _goals = <String>{};
  String _majorId = 'computer_science';
  String _majorLabel = 'Computer Science';
  int _weeklyMinutes = 150;

  static final List<({String id, String label, String emoji})> _majors =
      VuV2DegreeCatalog.degrees
          .map(
            (VuV2DegreeDef d) => (
              id: d.roadmapSubjectId,
              label: d.title,
              emoji: d.emoji,
            ),
          )
          .toList(growable: false);

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < 4) {
      setState(() => _index += 1);
      await _pages.animateToPage(
        _index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await widget.session.completeOnboarding(
      name: _name.text,
      majorId: _majorId,
      majorLabel: _majorLabel,
      goals: _goals.toList(),
      weeklyMinutes: _weeklyMinutes,
    );
    await widget.progress.enroll(_majorId);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: VuV2ProgressBar(value: (_index + 1) / 5),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _WelcomePage(nameController: _name),
                  _GoalsPage(
                    selected: _goals,
                    onToggle: (String g) => setState(() {
                      if (!_goals.add(g)) _goals.remove(g);
                    }),
                  ),
                  _MajorPage(
                    majors: _majors,
                    selectedId: _majorId,
                    onSelect: (String id, String label) => setState(() {
                      _majorId = id;
                      _majorLabel = label;
                    }),
                  ),
                  _PlanPage(
                    weeklyMinutes: _weeklyMinutes,
                    onChanged: (int v) => setState(() => _weeklyMinutes = v),
                  ),
                  _ReadyPage(majorLabel: _majorLabel, minutes: _weeklyMinutes),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: VuV2PrimaryButton(
                label: _index == 4 ? 'Enter campus' : 'Continue',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.nameController});
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 16),
      children: <Widget>[
        Text(
          'VIRTUAL UNIVERSITY',
          style: TextStyle(
            color: VuV2Colors.orange,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'A university\nwithout tuition.',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontSize: 34,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'GradeGlow is for people who cannot afford university, work full-time, or want a second chance. '
          'Your AI Professor teaches full lectures — not chatbot answers. Tell us your name to begin.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.45, fontSize: 15),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: nameController,
          style: const TextStyle(color: VuV2Colors.ink),
          decoration: InputDecoration(
            labelText: 'Preferred name',
            labelStyle: const TextStyle(color: VuV2Colors.mute),
            filled: true,
            fillColor: VuV2Colors.navyElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VuV2Radii.md),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalsPage extends StatelessWidget {
  const _GoalsPage({required this.selected, required this.onToggle});
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const List<String> _options = <String>[
    'Ace exams',
    'Career readiness',
    'Catch up on gaps',
    'Learn for curiosity',
    'Build a portfolio',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      children: <Widget>[
        const VuV2SectionTitle('What are you here for?'),
        const SizedBox(height: 8),
        const Text(
          'Pick all that apply. Your AI study plan will adapt.',
          style: TextStyle(color: VuV2Colors.mute),
        ),
        const SizedBox(height: 18),
        ..._options.map((String g) {
          final bool on = selected.contains(g);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: on
                  ? VuV2Colors.orange.withValues(alpha: 0.18)
                  : VuV2Colors.navyElevated,
              borderRadius: BorderRadius.circular(VuV2Radii.md),
              child: InkWell(
                onTap: () => onToggle(g),
                borderRadius: BorderRadius.circular(VuV2Radii.md),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(VuV2Radii.md),
                    border: Border.all(
                      color: on ? VuV2Colors.orange : VuV2Colors.stroke,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        on ? Icons.check_circle : Icons.circle_outlined,
                        color: on ? VuV2Colors.orange : VuV2Colors.mute,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MajorPage extends StatelessWidget {
  const _MajorPage({
    required this.majors,
    required this.selectedId,
    required this.onSelect,
  });

  final List<({String id, String label, String emoji})> majors;
  final String selectedId;
  final void Function(String id, String label) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      children: <Widget>[
        const VuV2SectionTitle('Choose your starting faculty'),
        const SizedBox(height: 8),
        Text(
          'You can explore every school later. This sets your first path.',
          style: TextStyle(color: VuV2Colors.mute),
        ),
        const SizedBox(height: 16),
        ...majors.map((m) {
          final bool on = m.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => onSelect(m.id, m.label),
              tileColor: VuV2Colors.navyElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VuV2Radii.md),
                side: BorderSide(color: on ? VuV2Colors.orange : VuV2Colors.stroke),
              ),
              leading: Text(m.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(
                m.label,
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: Icon(
                on ? Icons.radio_button_checked : Icons.radio_button_off,
                color: on ? VuV2Colors.orange : VuV2Colors.mute,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PlanPage extends StatelessWidget {
  const _PlanPage({required this.weeklyMinutes, required this.onChanged});
  final int weeklyMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      children: <Widget>[
        const VuV2SectionTitle('Set your weekly pace'),
        const SizedBox(height: 8),
        Text(
          '$weeklyMinutes minutes / week',
          style: TextStyle(
            color: VuV2Colors.orange,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        Slider(
          value: weeklyMinutes.toDouble(),
          min: 60,
          max: 420,
          divisions: 12,
          activeColor: VuV2Colors.orange,
          onChanged: (double v) => onChanged(v.round()),
        ),
        const Text(
          'Consistency beats cramming. Your campus will nudge you gently — never block learning.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
      ],
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({required this.majorLabel, required this.minutes});
  final String majorLabel;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 16),
      children: <Widget>[
        const Text('🎓', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 16),
        const VuV2SectionTitle('Your campus is ready'),
        const SizedBox(height: 10),
        Text(
          'Faculty: $majorLabel\nWeekly goal: $minutes minutes\nNext: meet your AI Professor in Orientation.',
          style: const TextStyle(color: VuV2Colors.mute, height: 1.5, fontSize: 15),
        ),
      ],
    );
  }
}
