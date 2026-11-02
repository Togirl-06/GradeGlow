import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parsed_question.dart';
import '../models/search_filters.dart';
import '../services/question_service.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';
import 'question_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  SearchFilters _filters = const SearchFilters();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QuestionService questions = context.watch<QuestionService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Browse', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Search exams, questions, and solutions', style: TextStyle(color: textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search question text…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () => _openFilters(context),
                      ),
                    ),
                    onSubmitted: (String value) {
                      setState(() => _filters = _filters.copyWith(query: value));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ParsedQuestion>>(
            stream: questions.watchQuestions(_filters),
            builder: (BuildContext context, AsyncSnapshot<List<ParsedQuestion>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final List<ParsedQuestion> items = snapshot.data ?? <ParsedQuestion>[];
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No questions yet. Upload an exam to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final ParsedQuestion question = items[index];
                  return StudySurfaceCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuestionDetailScreen(questionId: question.id),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              question.courseCode,
                              style: TextStyle(fontWeight: FontWeight.w800, color: StudyColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${question.professor} · ${question.semester}',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                            ),
                            if (question.hasSolution)
                              const Icon(Icons.check_circle, color: StudyColors.success, size: 18),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(question.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: <Widget>[
                            _Chip(question.examType),
                            _Chip(question.questionType),
                            ...question.topics.take(3).map(_Chip.new),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final _FilterResult? result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => _FilterSheet(filters: _filters),
    );
    if (result != null) {
      setState(() => _filters = result.filters);
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StudyColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _FilterResult {
  const _FilterResult(this.filters);
  final SearchFilters filters;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.filters});
  final SearchFilters filters;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final TextEditingController _course;
  late final TextEditingController _prof;
  late final TextEditingController _semester;
  late final TextEditingController _examType;
  late final TextEditingController _questionType;
  late final TextEditingController _topic;
  bool? _hasSolution;

  @override
  void initState() {
    super.initState();
    _course = TextEditingController(text: widget.filters.courseCode ?? '');
    _prof = TextEditingController(text: widget.filters.professor ?? '');
    _semester = TextEditingController(text: widget.filters.semester ?? '');
    _examType = TextEditingController(text: widget.filters.examType ?? '');
    _questionType = TextEditingController(text: widget.filters.questionType ?? '');
    _topic = TextEditingController(text: widget.filters.topic ?? '');
    _hasSolution = widget.filters.hasSolution;
  }

  @override
  void dispose() {
    _course.dispose();
    _prof.dispose();
    _semester.dispose();
    _examType.dispose();
    _questionType.dispose();
    _topic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _field(_course, 'Course code (CHEM 1211)'),
          _field(_prof, 'Professor'),
          _field(_semester, 'Semester'),
          _field(_examType, 'Exam type (Midterm, Final)'),
          _field(_questionType, 'Question type'),
          _field(_topic, 'Topic'),
          SwitchListTile(
            title: const Text('Has solution only'),
            value: _hasSolution ?? false,
            onChanged: (bool value) => setState(() => _hasSolution = value ? true : null),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, const _FilterResult(SearchFilters())),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _FilterResult(
                        SearchFilters(
                          courseCode: _course.text.trim().isEmpty ? null : _course.text.trim(),
                          professor: _prof.text.trim().isEmpty ? null : _prof.text.trim(),
                          semester: _semester.text.trim().isEmpty ? null : _semester.text.trim(),
                          examType: _examType.text.trim().isEmpty ? null : _examType.text.trim(),
                          questionType:
                              _questionType.text.trim().isEmpty ? null : _questionType.text.trim(),
                          topic: _topic.text.trim().isEmpty ? null : _topic.text.trim(),
                          hasSolution: _hasSolution,
                        ),
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label)),
    );
  }
}
