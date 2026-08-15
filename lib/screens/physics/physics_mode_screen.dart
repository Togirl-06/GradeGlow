import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/physics/physics_lab_engine.dart';
import '../../models/physics/physics_program.dart';
import '../../services/openai_service.dart';
import '../../theme/physics_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/tutor_markdown_body.dart';

/// Interactive workspace for simulators, labs, problems, reports, and more.
class PhysicsModeScreen extends StatefulWidget {
  const PhysicsModeScreen({
    super.key,
    required this.track,
    required this.course,
    required this.topic,
    required this.mode,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;
  final PhysicsLearningMode mode;

  @override
  State<PhysicsModeScreen> createState() => _PhysicsModeScreenState();
}

class _PhysicsModeScreenState extends State<PhysicsModeScreen> {
  final Map<String, double> _sliders = <String, double>{};
  final TextEditingController _input = TextEditingController();
  String _output = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _output = _offlineContent();
    for (final PhysicsControlSpec c in PhysicsLabEngine.controlsFor(widget.course.id)) {
      _sliders[c.id] = c.initial;
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  bool get _isInteractive => widget.mode == PhysicsLearningMode.virtualLab;

  Future<void> _generate() async {
    final String prompt = _input.text.trim();
    if (prompt.isEmpty && !_isInteractive) return;
    if (!AppConfig.hasOpenAi) {
      setState(() => _output = _offlineContent(extra: prompt));
      return;
    }
    setState(() => _loading = true);
    try {
      final String result = await context.read<OpenAiService>().physicsModeActivity(
            modeLabel: widget.mode.label,
            levelLabel: widget.track.level.label,
            courseTitle: widget.course.title,
            topicTitle: widget.topic.title,
            studentInput: prompt.isEmpty ? _snapshotText() : prompt,
          );
      if (!mounted) return;
      setState(() => _output = result);
    } catch (e) {
      if (!mounted) return;
      StudyMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _snapshotText() {
    final PhysicsLabSnapshot snap = PhysicsLabEngine.evaluate(
      courseId: widget.course.id,
      topicTitle: widget.topic.title,
      values: _sliders,
    );
    return snap.plainEnglish;
  }

  String _offlineContent({String extra = ''}) {
    if (_isInteractive) {
      final PhysicsLabSnapshot snap = PhysicsLabEngine.evaluate(
        courseId: widget.course.id,
        topicTitle: widget.topic.title,
        values: _sliders,
      );
      return '## ${widget.mode.label}\n\n'
          '**${widget.topic.title}** · ${widget.course.title}\n\n'
          '### Status: ${snap.status}\n\n'
          '${snap.plainEnglish}\n\n'
          '**Coach tip:** ${snap.coachTip}\n\n'
          '**Try next:** ${snap.whatToTry}';
    }

    return switch (widget.mode) {
      PhysicsLearningMode.experimentReport => '## Experiment Report\n\n'
          '**Title:** Measuring ${widget.topic.title}\n\n'
          'Sections: Abstract · Introduction · Apparatus · Procedure · Data · Analysis · Error · Conclusion\n\n'
          'Include units on every number and propagate uncertainty.',
      PhysicsLearningMode.formulaNotebook => '## Formula Notebook\n\n'
          '${widget.topic.formulas.map((String f) => '- $f').join('\n')}\n\n'
          'For each relation: define symbols, check units, state limiting cases.',
      _ => widget.topic.summary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final PhysicsLabSnapshot? snap = _isInteractive
        ? PhysicsLabEngine.evaluate(
            courseId: widget.course.id,
            topicTitle: widget.topic.title,
            values: _sliders,
          )
        : null;

    return Scaffold(
      backgroundColor: _isInteractive ? PhysicsTheme.consoleBg : PhysicsTheme.background,
      appBar: AppBar(
        backgroundColor: PhysicsTheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.mode.label),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            '${widget.topic.title} · ${widget.course.title}',
            style: TextStyle(
              color: _isInteractive ? PhysicsTheme.consoleText : PhysicsTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (_isInteractive && snap != null) ...<Widget>[
            const SizedBox(height: 16),
            ...PhysicsLabEngine.controlsFor(widget.course.id).map(
              (PhysicsControlSpec c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${c.label} (${_sliders[c.id]!.toStringAsFixed(c.step < 1 ? 2 : 0)} ${c.unit})',
                    style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 12),
                  ),
                  Slider(
                    value: _sliders[c.id]!,
                    min: c.min,
                    max: c.max,
                    divisions: ((c.max - c.min) / c.step).round().clamp(1, 200),
                    activeColor: PhysicsTheme.consoleAccent,
                    onChanged: (double v) => setState(() {
                      _sliders[c.id] = v;
                      _output = _offlineContent();
                    }),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PhysicsTheme.consolePanel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PhysicsTheme.consoleBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    snap.status,
                    style: TextStyle(
                      color: snap.statusLevel == PhysicsStatusLevel.good
                          ? PhysicsTheme.consoleGood
                          : snap.statusLevel == PhysicsStatusLevel.danger
                              ? PhysicsTheme.consoleBad
                              : PhysicsTheme.consoleAccent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...snap.metrics.map(
                    (PhysicsMetric m) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${m.label}: ${m.display} ${m.unit}',
                        style: const TextStyle(color: PhysicsTheme.consoleText, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (!_isInteractive) ...<Widget>[
            TextField(
              controller: _input,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Your design notes, answer, or code…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loading ? null : () => unawaited(_generate()),
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(_loading ? 'Generating…' : 'Generate with AI'),
            ),
            const SizedBox(height: 16),
          ],
          TutorMarkdownBody(
            text: _output,
            textColor: _isInteractive ? PhysicsTheme.consoleText : null,
          ),
        ],
      ),
    );
  }
}
