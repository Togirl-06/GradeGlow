import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/cs_curriculum/cs_curriculum_workspace_builder.dart';
import '../../models/cs_w3s_topic.dart';
import '../../models/leetcode_problem.dart';
import '../../services/cs_curriculum_progress_service.dart';
import '../../theme/cs_hybrid_theme.dart';
import '../../theme/study_theme.dart';
import '../../widgets/cs/cs_hybrid_panels.dart';

/// W3Schools-style practice: multiple-choice exercises from the lecture topic.
class CsW3sPracticeScreen extends StatefulWidget {
  const CsW3sPracticeScreen({
    super.key,
    required this.topicId,
    this.curriculumLanguageId,
    required this.topicTitle,
  });

  final String topicId;
  final String? curriculumLanguageId;
  final String topicTitle;

  @override
  State<CsW3sPracticeScreen> createState() => _CsW3sPracticeScreenState();
}

class _CsW3sPracticeScreenState extends State<CsW3sPracticeScreen> {
  late CsW3sTopic _topic;
  int _quizIndex = 0;
  int? _picked;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _topic = CsCurriculumWorkspaceBuilder.resolveTopic(widget.topicId) ?? _fallbackTopic();
  }

  CsW3sTopic _fallbackTopic() {
    return CsW3sTopic(
      id: widget.topicId,
      title: widget.topicTitle,
      track: 'Practice',
      lesson: const CsW3sLesson(whatItDoes: '', whenToUse: '', keyIdea: ''),
      example: const CsW3sExample(input: '', output: '', steps: ''),
      tryIt: const CsW3sTryIt(task: ''),
      easy: _placeholder,
      medium: _placeholder,
      hard: _placeholder,
    );
  }

  static const LeetcodeProblem _placeholder = LeetcodeProblem(
    id: '_practice_placeholder',
    title: 'Placeholder',
    slug: 'placeholder',
    difficulty: 'Easy',
    description: '',
    functionName: 'solve',
    examples: <LeetcodeExample>[],
    constraints: <String>[],
    tags: <String>[],
  );

  List<CsW3sQuiz> get _quizzes => _topic.quizzes;

  CsW3sQuiz get _activeQuiz => _quizzes[_quizIndex % _quizzes.length];

  void _pick(int index) {
    if (_revealed || _quizzes.isEmpty) return;
    final bool correct = index == _activeQuiz.correctIndex;
    setState(() {
      _picked = index;
      _revealed = true;
    });
    if (_quizIndex + 1 >= _quizzes.length && correct) {
      unawaited(_markComplete());
    }
  }

  Future<void> _markComplete() async {
    await context.read<CsCurriculumProgressService>().recordProblemSolved(
          topicId: widget.topicId,
          tier: 'Easy',
          accepted: true,
        );
  }

  void _nextQuiz() {
    if (_quizzes.isEmpty) return;
    setState(() {
      if (_quizIndex + 1 >= _quizzes.length) {
        _quizIndex = 0;
      } else {
        _quizIndex++;
      }
      _picked = null;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CsHybridTheme.background,
      appBar: AppBar(
        backgroundColor: StudyColors.primary,
        foregroundColor: Colors.white,
        title: Text('Practice: ${widget.topicTitle}'),
      ),
      body: CsW3sPracticePanel(
        quizzes: _quizzes,
        quizIndex: _quizIndex,
        picked: _picked,
        revealed: _revealed,
        onPick: _pick,
        onNext: _nextQuiz,
        topicTitle: _topic.title,
      ),
    );
  }
}
