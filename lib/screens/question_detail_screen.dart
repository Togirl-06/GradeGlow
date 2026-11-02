import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parsed_question.dart';
import '../models/solution.dart';
import '../models/search_filters.dart';
import '../services/question_service.dart';
import '../services/solution_service.dart';
import '../services/tutor_context_service.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';
import 'ai_tutor_screen.dart';
import '../utils/study_messenger.dart';

class QuestionDetailScreen extends StatefulWidget {
  const QuestionDetailScreen({super.key, required this.questionId});

  final String questionId;

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  bool _showAddSolution = false;

  @override
  void dispose() {
    _stepsController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QuestionService questions = context.read<QuestionService>();
    final SolutionService solutions = context.watch<SolutionService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: FutureBuilder<ParsedQuestion?>(
        future: questions.getQuestion(widget.questionId),
        builder: (BuildContext context, AsyncSnapshot<ParsedQuestion?> snapshot) {
          final ParsedQuestion? question = snapshot.data;
          if (question == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(question.courseCode, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(
                '${question.professor} · ${question.semester} · ${question.examType}',
                style: TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 12),
              StudySurfaceCard(child: Text(question.text, style: const TextStyle(height: 1.45, fontSize: 16))),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final QuestionService questionService = context.read<QuestionService>();
                  final TutorContextService tutorContext = context.read<TutorContextService>();
                  final List<ParsedQuestion> all =
                      await questionService.watchQuestions(const SearchFilters()).first;
                  final List<ParsedQuestion> examQs = all
                      .where((ParsedQuestion q) => q.materialId == question.materialId)
                      .toList()
                    ..sort((ParsedQuestion a, ParsedQuestion b) => a.orderIndex.compareTo(b.orderIndex));
                  final int idx = examQs.indexWhere((ParsedQuestion q) => q.id == question.id);
                  tutorContext.setFromQuestion(question, examQs);
                  if (!context.mounted) return;
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => AiTutorScreen(
                        initialPrompt: idx >= 0
                            ? "Explain Q${idx + 1} like I'm 10"
                            : "Explain this question like I'm 10",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.smart_toy_outlined),
                label: const Text('Ask AI Tutor'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Solutions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => setState(() => _showAddSolution = !_showAddSolution),
                    child: Text(_showAddSolution ? 'Cancel' : 'Add solution'),
                  ),
                ],
              ),
              if (_showAddSolution) ...<Widget>[
                TextField(
                  controller: _stepsController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Step-by-step (Markdown/LaTeX ok)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(labelText: 'Final answer'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    try {
                      await solutions.submitSolution(
                        questionId: question.id,
                        stepByStep: _stepsController.text,
                        finalAnswer: _answerController.text,
                      );
                      if (!context.mounted) return;
                      setState(() => _showAddSolution = false);
                      _stepsController.clear();
                      _answerController.clear();
                    } catch (error) {
                      if (!context.mounted) return;
                      StudyMessenger.showError(context, error);
                    }
                  },
                  child: const Text('Post solution'),
                ),
                const SizedBox(height: 12),
              ],
              StreamBuilder<List<QuestionSolution>>(
                stream: solutions.watchSolutions(question.id),
                builder: (BuildContext context, AsyncSnapshot<List<QuestionSolution>> snap) {
                  final List<QuestionSolution> items = snap.data ?? <QuestionSolution>[];
                  if (items.isEmpty) {
                    return StudySurfaceCard(
                      child: Text('No solutions yet. Be the first to help!', style: TextStyle(color: textSecondary)),
                    );
                  }
                  return Column(
                    children: items.map((QuestionSolution solution) {
                      return StudySurfaceCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(solution.authorName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                if (solution.verified) ...<Widget>[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: StudyColors.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: StudyColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Steps', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                            Text(solution.stepByStep, style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 8),
                            Text('Answer', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                            Text(solution.finalAnswer, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () => solutions.vote(solution.id, upvote: true),
                                  icon: const Icon(Icons.thumb_up_outlined),
                                ),
                                Text('${solution.upvotes}'),
                                IconButton(
                                  onPressed: () => solutions.vote(solution.id, upvote: false),
                                  icon: const Icon(Icons.thumb_down_outlined),
                                ),
                                Text('${solution.downvotes}'),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
