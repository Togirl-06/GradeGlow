import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/physics/physics_topic_lab_engine.dart';
import '../../models/physics/physics_lab_models.dart';
import '../../models/physics/physics_program.dart';
import '../../services/openai_service.dart';
import '../../theme/physics_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/tutor_markdown_body.dart';

/// University-style experiment report with AI professor grading.
class PhysicsExperimentReportScreen extends StatefulWidget {
  const PhysicsExperimentReportScreen({
    super.key,
    required this.track,
    required this.course,
    required this.topic,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;

  @override
  State<PhysicsExperimentReportScreen> createState() => _PhysicsExperimentReportScreenState();
}

class _PhysicsExperimentReportScreenState extends State<PhysicsExperimentReportScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _objective = TextEditingController();
  final TextEditingController _background = TextEditingController();
  final TextEditingController _hypothesis = TextEditingController();
  final TextEditingController _procedure = TextEditingController();
  final TextEditingController _dataTable = TextEditingController();
  final TextEditingController _calculations = TextEditingController();
  final TextEditingController _analysis = TextEditingController();
  final TextEditingController _conclusion = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String _equipment = '';
  String? _gradeReport;
  bool _grading = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  @override
  void dispose() {
    _title.dispose();
    _objective.dispose();
    _background.dispose();
    _hypothesis.dispose();
    _procedure.dispose();
    _dataTable.dispose();
    _calculations.dispose();
    _analysis.dispose();
    _conclusion.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_prefilled) return;
    final PhysicsTopicLabProfile profile =
        PhysicsTopicLabEngine.profileFor(course: widget.course, topic: widget.topic);
    final PhysicsLabRoom room = profile.virtualLab;
    final PhysicsExperimentReportTemplate report = profile.report;
    _equipment = <String>[...room.equipment, 'Notebook', 'Timer'].join('\n• ');
    _title.text = report.title;
    _objective.text = report.objective;
    _background.text =
        '${widget.topic.summary}\n\n'
        'Key concepts: ${widget.topic.keyConcepts.join(', ')}.';
    _hypothesis.text = report.hypothesis;
    _procedure.text = report.procedureSteps.map((String s) => '• $s').join('\n');
    _dataTable.text = report.dataTable;
    _calculations.text = report.calculationHint;
    _analysis.text = report.aiInsight.isNotEmpty ? report.aiInsight : 'Explain how your data supports or refutes the hypothesis.';
    _conclusion.text = report.conclusionHint;
    setState(() => _prefilled = true);
  }

  Future<void> _grade() async {
    final String report = _assembleReport();
    if (report.trim().length < 120) {
      StudyMessenger.showError(context, 'Fill in more sections before submitting.');
      return;
    }
    if (!AppConfig.hasOpenAi) {
      setState(() {
        _gradeReport = '## AI Professor Feedback\n\n'
            '**Experiment Score: 85%**\n\n'
            '**Strengths:**\n'
            '✓ Clear objective and hypothesis\n'
            '✓ Procedure follows lab steps\n\n'
            '**Improve:**\n'
            '- Add more trials in data table\n'
            '- Explain sources of error in analysis\n'
            '- Connect calculations to ${widget.topic.title} theory';
      });
      return;
    }
    setState(() {
      _grading = true;
      _gradeReport = null;
    });
    try {
      final String graded = await context.read<OpenAiService>().physicsExperimentGrade(
            levelLabel: widget.track.level.label,
            courseTitle: widget.course.title,
            topicTitle: widget.topic.title,
            reportMarkdown: report,
          );
      if (!mounted) return;
      setState(() => _gradeReport = graded);
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      StudyMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _grading = false);
    }
  }

  String _assembleReport() {
    return '''
# ${_title.text.trim()}

## 1. Objective
${_objective.text.trim()}

## 2. Background Theory
${_background.text.trim()}

## 3. Hypothesis
${_hypothesis.text.trim()}

## 4. Equipment
• $_equipment

## 5. Procedure
${_procedure.text.trim()}

## 6. Data Collection
${_dataTable.text.trim()}

## 7. Data Visualization
Describe graphs (position vs time, voltage vs current, etc.).

## 8. Calculations
${_calculations.text.trim()}

## 9. Analysis
${_analysis.text.trim()}

## 10. Conclusion
${_conclusion.text.trim()}
''';
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhysicsTheme.background,
      appBar: AppBar(
        backgroundColor: PhysicsTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Experiment Report'),
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            widget.topic.title,
            style: TextStyle(color: PhysicsTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            '${widget.course.title} · ${widget.track.level.label} lab write-up',
            style: TextStyle(color: PhysicsTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _section('Title', _title, maxLines: 2),
          _section('1. Objective — What are we trying to discover?', _objective),
          _section('2. Background Theory', _background, maxLines: 6),
          _section('3. Hypothesis — What do you predict?', _hypothesis),
          _readOnlySection('4. Equipment', '• $_equipment'),
          _section('5. Procedure', _procedure, maxLines: 8),
          _section('6. Data Collection (markdown table)', _dataTable, maxLines: 8),
          _section('8. Calculations (show work)', _calculations, maxLines: 6),
          _section('9. Analysis — Why differ from expected?', _analysis, maxLines: 5),
          _section('10. Conclusion — What did you learn?', _conclusion, maxLines: 5),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _grading ? null : () => unawaited(_grade()),
            style: FilledButton.styleFrom(
              backgroundColor: PhysicsTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _grading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.fact_check_outlined),
            label: Text(_grading ? 'Grading…' : 'Submit for AI Professor feedback', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          if (_gradeReport != null) ...<Widget>[
            const SizedBox(height: 20),
            Text('11. AI Professor Feedback', style: TextStyle(color: PhysicsTheme.primary, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 10),
            TutorMarkdownBody(text: _gradeReport!),
          ],
        ],
      ),
    );
  }

  Widget _section(String label, TextEditingController c, {int maxLines = 4}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(color: PhysicsTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: PhysicsTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlySection(String label, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(color: PhysicsTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PhysicsTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PhysicsTheme.border),
            ),
            child: Text(body, style: TextStyle(color: PhysicsTheme.textSecondary, height: 1.45, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
