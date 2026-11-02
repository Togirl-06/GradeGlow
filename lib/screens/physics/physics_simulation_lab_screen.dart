import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/physics/physics_lab_engine.dart';
import '../../data/physics/physics_topic_lab_engine.dart';
import '../../models/physics/physics_lab_models.dart';
import '../../models/physics/physics_program.dart';
import '../../services/openai_service.dart';
import '../../theme/physics_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/physics/physics_simulation_widgets.dart';

/// Immersive 3D physics simulation for one topic.
class PhysicsSimulationLabScreen extends StatefulWidget {
  const PhysicsSimulationLabScreen({
    super.key,
    required this.track,
    required this.course,
    required this.topic,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;

  @override
  State<PhysicsSimulationLabScreen> createState() => _PhysicsSimulationLabScreenState();
}

class _PhysicsSimulationLabScreenState extends State<PhysicsSimulationLabScreen> {
  late final PhysicsTopicLabProfile _profile;
  late final PhysicsSimulationKind _kind;
  late final PhysicsLabMission _mission;
  late final List<PhysicsControlSpec> _controls;
  late final Map<String, double> _sliders;
  late PhysicsLabSnapshot _snapshot;
  bool _launched = false;
  bool _aiLoading = false;
  String? _aiFeedback;

  @override
  void initState() {
    super.initState();
    _profile = PhysicsTopicLabEngine.profileFor(course: widget.course, topic: widget.topic);
    _kind = _profile.simulationKind;
    _mission = _profile.mission;
    _controls = _profile.controls;
    _sliders = <String, double>{
      for (final PhysicsControlSpec c in _controls) c.id: c.initial,
    };
    _snapshot = _evaluate();
  }

  PhysicsLabSnapshot _evaluate() => PhysicsLabEngine.evaluate(
        courseId: widget.course.id,
        topicTitle: widget.topic.title,
        values: _sliders,
        kind: _kind,
        mission: _mission,
      );

  void _onSlider(String id, double value) {
    setState(() {
      _sliders[id] = value;
      _snapshot = _evaluate();
    });
  }

  void _launch() {
    setState(() {
      _launched = true;
      _snapshot = _evaluate();
    });
  }

  void _reset() {
    setState(() {
      _launched = false;
      for (final PhysicsControlSpec c in _controls) {
        _sliders[c.id] = c.initial;
      }
      _snapshot = _evaluate();
      _aiFeedback = null;
    });
  }

  Future<void> _askInstructor() async {
    if (!AppConfig.hasOpenAi) {
      setState(() => _aiFeedback = _snapshot.coachTip);
      return;
    }
    setState(() => _aiLoading = true);
    try {
      final String reply = await context.read<OpenAiService>().physicsLabInstructorFeedback(
            simulationLabel: _kind.label,
            topicTitle: widget.topic.title,
            mission: _mission.prompt,
            metrics: _snapshot.metrics.map((PhysicsMetric m) => '${m.label}: ${m.display} ${m.unit}').join('\n'),
            status: _snapshot.status,
            studentQuestion: 'Evaluate my current setup and tell me what to change.',
          );
      if (!mounted) return;
      setState(() => _aiFeedback = reply);
    } catch (e) {
      if (!mounted) return;
      setState(() => _aiFeedback = _snapshot.coachTip);
      StudyMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PhysicsLabDifficulty diff = PhysicsLabEngine.difficultyFor(widget.track.level.label);

    return Scaffold(
      backgroundColor: PhysicsTheme.consoleBg,
      appBar: AppBar(
        backgroundColor: PhysicsTheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${_profile.simulationEmoji} ${_profile.simulationTitle}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              widget.topic.title,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _buildBody(diff),
    );
  }

  Widget _buildBody(PhysicsLabDifficulty diff) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      children: <Widget>[
        _missionCard(),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _profile.simulationDescription,
            style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 12, height: 1.4),
          ),
        ),
        PhysicsSimulationCanvas(
          kind: _kind,
          snapshot: _snapshot,
          launched: _launched,
          sceneLabel: _profile.simulationTitle,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: _launch,
                style: FilledButton.styleFrom(
                  backgroundColor: PhysicsTheme.consoleGood,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Launch', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: PhysicsTheme.consoleText,
                  side: const BorderSide(color: PhysicsTheme.consoleBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Controls', style: TextStyle(color: PhysicsTheme.consoleText, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ..._controls.map((PhysicsControlSpec c) => _sliderTile(c)),
        const SizedBox(height: 14),
        _resultsPanel(),
        if (_snapshot.graphs.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text('Graphs', style: TextStyle(color: PhysicsTheme.consoleText, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ..._snapshot.graphs.map((PhysicsGraphSeries s) => PhysicsMiniChart(series: s)),
        ],
        const SizedBox(height: 12),
        _instructorPanel(diff),
      ],
    );
  }

  Widget _missionCard() {
    final PhysicsMissionResult? mr = _snapshot.missionResult;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PhysicsTheme.consolePanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mr?.passed == true ? PhysicsTheme.consoleGood : PhysicsTheme.consoleAccent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.flag_outlined, color: PhysicsTheme.consoleAccent, size: 18),
              const SizedBox(width: 8),
              Text('Mission', style: TextStyle(color: PhysicsTheme.consoleText, fontWeight: FontWeight.w800)),
              const Spacer(),
              if (mr != null)
                Text(
                  '${mr.scorePercent}%',
                  style: TextStyle(
                    color: mr.passed ? PhysicsTheme.consoleGood : PhysicsTheme.consoleBad,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_mission.prompt, style: const TextStyle(color: PhysicsTheme.consoleText, height: 1.4)),
          const SizedBox(height: 4),
          Text(_mission.targetDescription, style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 12)),
          if (mr != null && _launched) ...<Widget>[
            const SizedBox(height: 8),
            Text(mr.feedback, style: TextStyle(color: mr.passed ? PhysicsTheme.consoleGood : PhysicsTheme.consoleAccent, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _sliderTile(PhysicsControlSpec c) {
    final double val = _sliders[c.id]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${c.label}: ${val.toStringAsFixed(c.step < 1 ? 2 : 0)} ${c.unit}',
            style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 12),
          ),
          Slider(
            value: val,
            min: c.min,
            max: c.max,
            divisions: ((c.max - c.min) / c.step).round().clamp(1, 200),
            activeColor: PhysicsTheme.consoleAccent,
            onChanged: (double v) => _onSlider(c.id, v),
          ),
        ],
      ),
    );
  }

  Widget _resultsPanel() {
    Color statusColor = PhysicsTheme.consoleAccent;
    if (_snapshot.statusLevel == PhysicsStatusLevel.good) statusColor = PhysicsTheme.consoleGood;
    if (_snapshot.statusLevel == PhysicsStatusLevel.danger) statusColor = PhysicsTheme.consoleBad;

    return Container(
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
          Text('Results', style: TextStyle(color: PhysicsTheme.consoleText, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(_snapshot.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ..._snapshot.metrics.map(
            (PhysicsMetric m) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${m.label}: ${m.display} ${m.unit}',
                style: const TextStyle(color: PhysicsTheme.consoleText, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(_snapshot.plainEnglish, style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 12, height: 1.35)),
        ],
      ),
    );
  }

  Widget _instructorPanel(PhysicsLabDifficulty diff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PhysicsTheme.consoleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.school_outlined, color: PhysicsTheme.consoleAccent, size: 18),
              const SizedBox(width: 8),
              Text('AI Lab Instructor · ${diff.label}', style: const TextStyle(color: PhysicsTheme.consoleText, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _aiFeedback ?? _snapshot.coachTip,
            style: const TextStyle(color: PhysicsTheme.consoleText, height: 1.45, fontSize: 13),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _aiLoading ? null : () => unawaited(_askInstructor()),
            icon: _aiLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.psychology_outlined, size: 18),
            label: Text(_aiLoading ? 'Analyzing…' : 'Get instructor feedback'),
            style: OutlinedButton.styleFrom(foregroundColor: PhysicsTheme.consoleAccent),
          ),
        ],
      ),
    );
  }
}
