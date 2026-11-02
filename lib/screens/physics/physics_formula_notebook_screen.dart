import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/physics/physics_formula_engine.dart';
import '../../models/physics/physics_program.dart';
import '../../services/openai_service.dart';
import '../../theme/physics_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/tutor_markdown_body.dart';

/// Textbook-style formula reference written for each physics topic.
class PhysicsFormulaNotebookScreen extends StatefulWidget {
  const PhysicsFormulaNotebookScreen({
    super.key,
    required this.track,
    required this.course,
    required this.topic,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;

  @override
  State<PhysicsFormulaNotebookScreen> createState() => _PhysicsFormulaNotebookScreenState();
}

class _PhysicsFormulaNotebookScreenState extends State<PhysicsFormulaNotebookScreen> {
  late String _content;
  bool _loading = false;
  bool _expandedWithAi = false;

  @override
  void initState() {
    super.initState();
    _content = PhysicsFormulaEngine.notebookMarkdown(
      course: widget.course,
      topic: widget.topic,
      levelLabel: widget.track.level.label,
    );
  }

  Future<void> _expandWithAi() async {
    if (!AppConfig.hasOpenAi) {
      StudyMessenger.showError(context, 'Connect OpenAI to expand formula notes.');
      return;
    }
    setState(() => _loading = true);
    try {
      final List<PhysicsFormula> formulas = PhysicsFormulaEngine.formulasFor(
        courseId: widget.course.id,
        topic: widget.topic,
      );
      final String formulaList = formulas
          .map((PhysicsFormula f) => '${f.name}: \$${f.latex}\$ — ${f.symbols}')
          .join('\n');

      final String expanded = await context.read<OpenAiService>().physicsFormulaNotebookExpand(
            levelLabel: widget.track.level.label,
            courseTitle: widget.course.title,
            topicTitle: widget.topic.title,
            topicSummary: widget.topic.summary,
            baseFormulas: formulaList,
          );
      if (!mounted) return;
      setState(() {
        _content = expanded;
        _expandedWithAi = true;
      });
    } catch (e) {
      if (!mounted) return;
      StudyMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PhysicsFormula> formulas = PhysicsFormulaEngine.formulasFor(
      courseId: widget.course.id,
      topic: widget.topic,
    );

    return Scaffold(
      backgroundColor: PhysicsTheme.background,
      appBar: AppBar(
        backgroundColor: PhysicsTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Formula Notebook'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            widget.topic.title,
            style: TextStyle(
              color: PhysicsTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.course.title} · ${widget.track.level.label}',
            style: TextStyle(color: PhysicsTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: PhysicsTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PhysicsTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              '${formulas.length} governing relation${formulas.length == 1 ? '' : 's'} for this topic',
              style: TextStyle(color: PhysicsTheme.primary, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          if (AppConfig.hasOpenAi && !_expandedWithAi)
            FilledButton.icon(
              onPressed: _loading ? null : () => unawaited(_expandWithAi()),
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(_loading ? 'Expanding…' : 'Add worked examples (AI)'),
            ),
          if (_expandedWithAi) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Expanded with AI — includes extra examples and applications.',
              style: TextStyle(color: PhysicsTheme.textSecondary, fontSize: 11),
            ),
          ],
          const SizedBox(height: 16),
          TutorMarkdownBody(text: _content),
        ],
      ),
    );
  }
}
