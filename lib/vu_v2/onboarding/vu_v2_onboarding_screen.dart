import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
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
  final Set<String> _interests = <String>{};
  String? _majorId;
  String? _majorLabel;
  int _weeklyMinutes = 150;
  String? _error;

  static const List<_GoalOpt> _goalOpts = <_GoalOpt>[
    _GoalOpt('Earn a degree', Icons.school_rounded),
    _GoalOpt('Prepare for a career', Icons.rocket_launch_rounded),
    _GoalOpt('Learn a new subject', Icons.menu_book_rounded),
    _GoalOpt('Prepare for an exam', Icons.track_changes_rounded),
    _GoalOpt('Improve my skills', Icons.psychology_alt_rounded),
    _GoalOpt('Explore careers', Icons.lightbulb_outline_rounded),
  ];

  static const List<_InterestGroup> _interestGroups = <_InterestGroup>[
    _InterestGroup(
      title: 'STEM',
      items: <_InterestOpt>[
        _InterestOpt('Biology', 'biology'),
        _InterestOpt('Chemistry', 'chemistry'),
        _InterestOpt('Physics', 'physics'),
        _InterestOpt('Mathematics', 'mathematics'),
        _InterestOpt('Computer Science', 'computer_science'),
        _InterestOpt('Engineering', 'engineering'),
      ],
    ),
    _InterestGroup(
      title: 'HEALTH SCIENCES',
      items: <_InterestOpt>[
        _InterestOpt('Medicine', 'medicine'),
        _InterestOpt('Nursing', 'nursing'),
        _InterestOpt('Psychology', 'psychology'),
      ],
    ),
    _InterestGroup(
      title: 'BUSINESS',
      items: <_InterestOpt>[
        _InterestOpt('Business Administration', 'business'),
        _InterestOpt('Accounting', 'accounting'),
        _InterestOpt('Finance', 'finance'),
        _InterestOpt('Economics', 'economics'),
        _InterestOpt('Marketing', 'marketing'),
      ],
    ),
    _InterestGroup(
      title: 'LAW',
      items: <_InterestOpt>[
        _InterestOpt('Law', 'law'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  void _restoreDraft() {
    final VuV2Session s = widget.session;
    if (s.displayName.isNotEmpty && s.displayName != 'Student') {
      _name.text = s.displayName;
    }
    _goals
      ..clear()
      ..addAll(s.goals);
    if (s.majorId.isNotEmpty) {
      _majorId = s.majorId;
      _majorLabel = s.majorLabel;
      _interests.add(s.majorLabel);
    }
    _weeklyMinutes = s.weeklyMinutes;
    _index = s.onboardingStep.clamp(0, 4);
    if (_index > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_pages.hasClients) return;
        _pages.jumpToPage(_index);
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _persistDraft({required int nextStep}) async {
    await widget.session.saveOnboardingDraft(
      name: _name.text.trim(),
      goals: _goals.toList(),
      majorId: _majorId,
      majorLabel: _majorLabel,
      weeklyMinutes: _weeklyMinutes,
      step: nextStep,
    );
  }

  void _syncMajorFromInterests() {
    if (_interests.isEmpty) {
      _majorId = null;
      _majorLabel = null;
      return;
    }
    for (final _InterestGroup g in _interestGroups) {
      for (final _InterestOpt o in g.items) {
        if (_interests.contains(o.label)) {
          _majorId = o.subjectId;
          _majorLabel = o.label;
          return;
        }
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_index) {
      case 0:
        break;
      case 1:
        if (_goals.isEmpty) {
          setState(() => _error = 'Select at least one goal to continue.');
          return false;
        }
        break;
      case 2:
        if (_interests.isEmpty) {
          setState(() => _error = 'Select at least one field of interest.');
          return false;
        }
        _syncMajorFromInterests();
        break;
      case 3:
        if (_name.text.trim().isEmpty) {
          setState(() => _error = 'Preferred name is required.');
          return false;
        }
        break;
    }
    setState(() => _error = null);
    return true;
  }

  Future<void> _back() async {
    if (_index <= 0) return;
    final int next = _index - 1;
    await _persistDraft(nextStep: next);
    setState(() => _index = next);
    await _pages.animateToPage(
      _index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    if (!_validateCurrentStep()) return;

    if (_index < 4) {
      final int next = _index + 1;
      await _persistDraft(nextStep: next);
      setState(() => _index = next);
      await _pages.animateToPage(
        _index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _syncMajorFromInterests();
    final AuthService auth = context.read<AuthService>();
    await widget.session.completeOnboarding(
      name: _name.text.trim(),
      majorId: _majorId!,
      majorLabel: _majorLabel!,
      goals: _goals.toList(),
      weeklyMinutes: _weeklyMinutes,
    );
    try {
      await auth.updateDisplayName(_name.text.trim());
    } catch (_) {}
    await widget.progress.enroll(_majorId!);
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
              child: _StepDots(index: _index, total: 5),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  const _WelcomePage(),
                  _GoalsPage(
                    selected: _goals,
                    options: _goalOpts,
                    onToggle: (String g) => setState(() {
                      if (!_goals.add(g)) _goals.remove(g);
                      _error = null;
                    }),
                  ),
                  _FieldsPage(
                    groups: _interestGroups,
                    selected: _interests,
                    onToggle: (String label) => setState(() {
                      if (!_interests.add(label)) {
                        _interests.remove(label);
                      }
                      _syncMajorFromInterests();
                      _error = null;
                    }),
                  ),
                  _PlanPage(
                    nameController: _name,
                    weeklyMinutes: _weeklyMinutes,
                    onNameChanged: (_) => setState(() => _error = null),
                    onMinutesChanged: (int v) =>
                        setState(() => _weeklyMinutes = v),
                  ),
                  _ReadyPage(
                    name: _name.text.trim(),
                    majorLabel: _majorLabel ?? '—',
                    minutes: _weeklyMinutes,
                    goals: _goals.toList(),
                    interests: _interests.toList(),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: VuV2Colors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: _index == 0
                  ? VuV2PrimaryButton(
                      label: 'Start Your Journey',
                      trailingArrow: true,
                      onPressed: _next,
                    )
                  : Row(
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: VuV2Colors.ink,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 160,
                          child: VuV2PrimaryButton(
                            label: _index == 4
                                ? 'Enter campus'
                                : 'Continue',
                            trailingArrow: _index < 4,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (int i) {
        final bool on = i <= index;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: on ? VuV2Colors.mint : VuV2Colors.stroke,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 16),
      children: <Widget>[
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: VuV2Colors.mint,
              borderRadius: BorderRadius.circular(26),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: VuV2Colors.mint.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 44,
              color: Color(0xFF04110C),
            ),
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'Welcome to Your',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontSize: 34,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        ShaderMask(
          shaderCallback: (Rect bounds) => const LinearGradient(
            colors: <Color>[VuV2Colors.mint, VuV2Colors.gold],
          ).createShader(bounds),
          child: const Text(
            'University',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Not a chatbot. A real classroom.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'AI Professors teach · progressive diagrams · labs · '
          'adaptive review when you confuse radius and ulna.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.mute,
            height: 1.45,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'An AI-powered virtual university where you don\'t just study — '
          'you attend AI lectures, run virtual experiments, solve real '
          'professional cases, and build evidence of what you can do.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VuV2Colors.mute, height: 1.5, fontSize: 14),
        ),
      ],
    );
  }
}

class _GoalsPage extends StatelessWidget {
  const _GoalsPage({
    required this.selected,
    required this.options,
    required this.onToggle,
  });

  final Set<String> selected;
  final List<_GoalOpt> options;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      children: <Widget>[
        const Text(
          'What are you here to accomplish?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Choose your primary goal — we\'ll tailor your experience.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 22),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SpacedGridDelegate(),
          itemBuilder: (BuildContext context, int i) {
            final _GoalOpt g = options[i];
            final bool on = selected.contains(g.label);
            return Material(
              color: VuV2Colors.card,
              borderRadius: BorderRadius.circular(VuV2Radii.md),
              child: InkWell(
                onTap: () => onToggle(g.label),
                borderRadius: BorderRadius.circular(VuV2Radii.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(VuV2Radii.md),
                    border: Border.all(
                      color: on ? VuV2Colors.mint : VuV2Colors.stroke,
                      width: on ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(g.icon, color: VuV2Colors.mint, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          g.label,
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SpacedGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const SpacedGridDelegate()
      : super(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.55,
        );
}

class _FieldsPage extends StatelessWidget {
  const _FieldsPage({
    required this.groups,
    required this.selected,
    required this.onToggle,
  });

  final List<_InterestGroup> groups;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      children: <Widget>[
        const Text(
          'Choose your fields of interest',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Select all that appeal to you — you can choose multiple.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 22),
        for (final _InterestGroup group in groups) ...<Widget>[
          Text(
            group.title,
            style: const TextStyle(
              color: VuV2Colors.mint,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.items.map((_InterestOpt item) {
              final bool on = selected.contains(item.label);
              return Material(
                color: on
                    ? VuV2Colors.mint.withValues(alpha: 0.16)
                    : VuV2Colors.card,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onToggle(item.label),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: (MediaQuery.sizeOf(context).width - 64) / 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: on ? VuV2Colors.mint : VuV2Colors.stroke,
                      ),
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: on ? VuV2Colors.mint : VuV2Colors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _PlanPage extends StatelessWidget {
  const _PlanPage({
    required this.nameController,
    required this.weeklyMinutes,
    required this.onNameChanged,
    required this.onMinutesChanged,
  });

  final TextEditingController nameController;
  final int weeklyMinutes;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      children: <Widget>[
        const Text(
          'Set up your profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tell us your name and weekly study goal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VuV2Colors.mute),
        ),
        const SizedBox(height: 24),
        const Text(
          'Preferred name',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: nameController,
          onChanged: onNameChanged,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: VuV2Colors.ink),
          decoration: InputDecoration(
            hintText: 'What should we call you?',
            hintStyle: const TextStyle(color: VuV2Colors.mute),
            filled: true,
            fillColor: VuV2Colors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VuV2Radii.md),
              borderSide: const BorderSide(color: VuV2Colors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VuV2Radii.md),
              borderSide: const BorderSide(color: VuV2Colors.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VuV2Radii.md),
              borderSide: const BorderSide(color: VuV2Colors.mint, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$weeklyMinutes minutes / week',
          style: const TextStyle(
            color: VuV2Colors.mint,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        Slider(
          value: weeklyMinutes.toDouble(),
          min: 60,
          max: 420,
          divisions: 12,
          activeColor: VuV2Colors.mint,
          onChanged: (double v) => onMinutesChanged(v.round()),
        ),
      ],
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
    required this.name,
    required this.majorLabel,
    required this.minutes,
    required this.goals,
    required this.interests,
  });

  final String name;
  final String majorLabel;
  final int minutes;
  final List<String> goals;
  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      children: <Widget>[
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: VuV2Colors.mint,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 36,
              color: Color(0xFF04110C),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Your campus is ready',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Welcome, ${name.isEmpty ? 'scholar' : name}.\n'
          'Starting path: $majorLabel\n'
          'Weekly goal: $minutes minutes\n\n'
          'Your professor will teach the topic you open. Then you apply it in the lab.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VuV2Colors.mute,
            height: 1.55,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _GoalOpt {
  const _GoalOpt(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _InterestOpt {
  const _InterestOpt(this.label, this.subjectId);
  final String label;
  final String subjectId;
}

class _InterestGroup {
  const _InterestGroup({required this.title, required this.items});
  final String title;
  final List<_InterestOpt> items;
}
