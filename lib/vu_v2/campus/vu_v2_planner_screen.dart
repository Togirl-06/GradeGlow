import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2PlannerScreen extends StatefulWidget {
  const VuV2PlannerScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  State<VuV2PlannerScreen> createState() => _VuV2PlannerScreenState();
}

class _VuV2PlannerScreenState extends State<VuV2PlannerScreen> {
  late final List<String> _slots;

  static const List<String> _defaults = <String>[
    'Mon · 7:00 PM · AI Tutor lesson',
    'Wed · 6:30 PM · Practice quiz',
    'Fri · 5:00 PM · Review session',
    'Sun · 11:00 AM · Weekly review',
  ];

  @override
  void initState() {
    super.initState();
    _slots = List<String>.from(
      widget.progress.plannerSlots.isEmpty
          ? _defaults
          : widget.progress.plannerSlots,
    );
  }

  Future<void> _save() async {
    await widget.progress.setPlannerSlots(_slots);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Study schedule saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int goal = widget.session.weeklyMinutes;
    final int done = widget.progress.studyMinutes.clamp(0, goal * 4);
    final double weekly = (done / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: Text('AI Study Planner')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'STUDY GOAL',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$goal min / week · ${widget.session.majorLabel}',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                VuV2ProgressBar(value: weekly),
                const SizedBox(height: 8),
                Text(
                  'Logged ${widget.progress.studyMinutes} min total · keep your streak alive.',
                  style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const VuV2SectionTitle('This week’s schedule'),
          const SizedBox(height: 8),
          ..._slots.asMap().entries.map((MapEntry<int, String> e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VuV2Surface(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.schedule_rounded, color: VuV2Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Text(
              'AI recommendation: Complete one Notes lesson and one quiz this week. '
              'Focus Module 1 whiteboard lessons before Friday quiz.',
              style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          VuV2PrimaryButton(
            label: 'Save schedule',
            icon: Icons.save_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
