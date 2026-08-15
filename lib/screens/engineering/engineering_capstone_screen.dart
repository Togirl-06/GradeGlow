import 'package:flutter/material.dart';

import '../../models/engineering/engineering_program.dart';
import '../../theme/engineering_theme.dart';

/// Multi-stage capstone checklist — portfolio project, not an exam.
class EngineeringCapstoneScreen extends StatefulWidget {
  const EngineeringCapstoneScreen({
    super.key,
    required this.major,
    required this.course,
  });

  final EngineeringMajor major;
  final EngineeringCourse course;

  @override
  State<EngineeringCapstoneScreen> createState() => _EngineeringCapstoneScreenState();
}

class _EngineeringCapstoneScreenState extends State<EngineeringCapstoneScreen> {
  late final List<bool> _done;

  @override
  void initState() {
    super.initState();
    _done = List<bool>.filled(widget.course.capstoneStages.length, false);
  }

  int get _completed => _done.where((bool d) => d).length;

  @override
  Widget build(BuildContext context) {
    final List<String> stages = widget.course.capstoneStages;
    final double progress = stages.isEmpty ? 0 : _completed / stages.length;

    return Scaffold(
      backgroundColor: EngineeringTheme.background,
      appBar: AppBar(
        backgroundColor: EngineeringTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Capstone Project'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            widget.course.capstoneTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: EngineeringTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.major.name} · ${widget.course.title}',
            style: TextStyle(color: EngineeringTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            'You are building a portfolio piece. Each stage is a real engineering deliverable. '
            'Check a stage only when you could explain it to a non-engineer in 60 seconds '
            'and show at least one number with units.',
            style: TextStyle(color: EngineeringTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: EngineeringTheme.border,
              color: EngineeringTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_completed / ${stages.length} stages',
            style: TextStyle(color: EngineeringTheme.primary, fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(stages.length, (int i) {
            return Card(
              color: EngineeringTheme.surface,
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: EngineeringTheme.border),
              ),
              child: CheckboxListTile(
                value: _done[i],
                onChanged: (bool? v) => setState(() => _done[i] = v ?? false),
                activeColor: EngineeringTheme.primary,
                title: Text(
                  'Stage ${i + 1}: ${stages[i]}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: EngineeringTheme.textPrimary,
                    decoration: _done[i] ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  _stageHint(stages[i]),
                  style: TextStyle(color: EngineeringTheme.textSecondary, fontSize: 12),
                ),
              ),
            );
          }),
          if (_completed == stages.length && stages.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: EngineeringTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EngineeringTheme.success.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Capstone checklist complete. Prepare your presentation: problem, constraints, design, tests, failures, improvements, and final recommendation.',
                style: TextStyle(color: EngineeringTheme.textPrimary, height: 1.45, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _stageHint(String stage) {
    final String s = stage.toLowerCase();
    if (s.contains('research') || s.contains('site') || s.contains('geology') || s.contains('clinical') || s.contains('source')) {
      return 'Gather requirements, constraints, and failure history.';
    }
    if (s.contains('plan') || s.contains('scheme') || s.contains('architecture') || s.contains('flowsheet')) {
      return 'Propose 2+ concepts before locking a direction.';
    }
    if (s.contains('calc') || s.contains('analysis') || s.contains('sizing') || s.contains('mechanics') || s.contains('balance')) {
      return 'Show governing equations and assumptions.';
    }
    if (s.contains('sim') || s.contains('test') || s.contains('prototype') || s.contains('bench')) {
      return 'Run the simulator/lab and capture pass/fail evidence.';
    }
    if (s.contains('safety') || s.contains('hse') || s.contains('regulatory') || s.contains('code')) {
      return 'Document hazards, margins, and mitigations.';
    }
    if (s.contains('cost') || s.contains('econom') || s.contains('roi')) {
      return 'Trade performance vs budget vs sustainability.';
    }
    if (s.contains('present') || s.contains('report') || s.contains('demo') || s.contains('brief')) {
      return 'Explain decisions, failures, and what you would redesign.';
    }
    return 'Document decisions and evidence for your portfolio.';
  }
}
