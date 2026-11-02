import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/health_lesson_content.dart';
import '../../data/practice_lab_scenarios.dart';
import '../../data/practice_lab_university_catalog.dart';
import '../../data/visual_learning_catalog.dart';
import '../../models/ai_practice_mode.dart';
import '../../models/health_faculty_program.dart';
import '../../models/practice_lab.dart';
import '../../models/practice_lab_subject.dart';
import '../../models/virtual_university_lesson_contract.dart';
import '../../models/visual_learning_lab.dart';
import '../../services/health_faculty_progress_service.dart';
import '../../services/vu_notes_service.dart';
import '../../widgets/virtual_university/vu_lesson_hub_shell.dart';
import '../virtual_hospital_hub_screen.dart';
import 'health_ai_professor_screen.dart';

class HealthLessonHubScreen extends StatelessWidget {
  const HealthLessonHubScreen({super.key, required this.path});

  final HealthLessonPath path;

  static final List<VuActivitySpec> _activities =
      VirtualUniversityLessonContract.visibleFor(
        hasInteractive: true,
        hasDiscussion: true,
      );

  @override
  Widget build(BuildContext context) {
    HealthFacultyProgressService? progress;
    try {
      progress = context.watch<HealthFacultyProgressService>();
    } catch (_) {
      progress = null;
    }

    final Set<String> done =
        progress?.completedActivityNames(path.topic.id) ?? const <String>{};
    final bool certified = progress?.hasCertificate(path.topic.id) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          path.topic.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: VuLessonHubShell(
        title: path.topic.title,
        subtitle: path.breadcrumb,
        accent: Theme.of(context).colorScheme.primary,
        activities: _activities,
        completedActivityNames: done,
        certificateBadge: certified
            ? Icon(
                Icons.workspace_premium,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              )
            : null,
        onOpen: (VuCanonicalActivity activity) {
          if (activity == VuCanonicalActivity.aiProfessor) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HealthAiProfessorScreen(path: path),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  _HealthActivityWorkspace(path: path, activity: activity),
            ),
          );
        },
      ),
    );
  }
}

class _HealthActivityWorkspace extends StatelessWidget {
  const _HealthActivityWorkspace({required this.path, required this.activity});

  final HealthLessonPath path;
  final VuCanonicalActivity activity;

  String get _title => switch (activity) {
    VuCanonicalActivity.aiProfessor => 'AI Professor',
    VuCanonicalActivity.textbookNotes => 'Textbook Notes',
    VuCanonicalActivity.interactiveOrVideo => 'Interactive / Video',
    VuCanonicalActivity.practiceOrHomework => 'Practice / Homework',
    VuCanonicalActivity.quizOrExam => 'Quiz / Exam',
    VuCanonicalActivity.discussionOrSummary => 'Discussion / Summary',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: switch (activity) {
        VuCanonicalActivity.aiProfessor => const SizedBox.shrink(),
        VuCanonicalActivity.textbookNotes => _LectureNotesBody(path: path),
        VuCanonicalActivity.interactiveOrVideo => _InteractiveBody(path: path),
        VuCanonicalActivity.practiceOrHomework => _PracticeQuizBody(
          path: path,
          timedFeel: false,
        ),
        VuCanonicalActivity.quizOrExam => _PracticeQuizBody(
          path: path,
          timedFeel: true,
        ),
        VuCanonicalActivity.discussionOrSummary => _SummaryBody(path: path),
      },
    );
  }
}

class _LectureNotesBody extends StatefulWidget {
  const _LectureNotesBody({required this.path});

  final HealthLessonPath path;

  @override
  State<_LectureNotesBody> createState() => _LectureNotesBodyState();
}

class _LectureNotesBodyState extends State<_LectureNotesBody> {
  Future<void> _markComplete() async {
    try {
      await context.read<HealthFacultyProgressService>().complete(
        widget.path.topic.id,
        VuCanonicalActivity.textbookNotes.name,
      );
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notes marked complete')));
    Navigator.of(context).pop();
  }

  Future<void> _bookmark() async {
    try {
      await VuNotesService.instance.addBookmark(
        title: '${widget.path.topic.title} · Notes',
        lessonId: widget.path.topic.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmarked to campus notes')),
      );
    } catch (_) {}
  }

  Future<void> _highlightSelection(String text) async {
    final String trimmed = text.trim();
    if (trimmed.length < 8) return;
    try {
      await VuNotesService.instance.addHighlight(
        text: trimmed,
        lessonId: widget.path.topic.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Highlight saved')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final String text = HealthLessonContent.lecture(widget.path);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _bookmark,
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: const Text('Bookmark'),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SelectableText(
              text,
              style: const TextStyle(height: 1.45, fontSize: 15),
              contextMenuBuilder:
                  (BuildContext context, EditableTextState state) {
                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: state.contextMenuAnchors,
                      buttonItems: <ContextMenuButtonItem>[
                        ...state.contextMenuButtonItems,
                        ContextMenuButtonItem(
                          onPressed: () {
                            final TextSelection sel =
                                state.textEditingValue.selection;
                            final String selected = sel.textInside(
                              state.textEditingValue.text,
                            );
                            state.hideToolbar();
                            unawaited(_highlightSelection(selected));
                          },
                          label: 'Save highlight',
                        ),
                      ],
                    );
                  },
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed: _markComplete,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Finish notes review'),
            ),
          ),
        ),
      ],
    );
  }
}

class _InteractiveBody extends StatefulWidget {
  const _InteractiveBody({required this.path});

  final HealthLessonPath path;

  @override
  State<_InteractiveBody> createState() => _InteractiveBodyState();
}

class _InteractiveBodyState extends State<_InteractiveBody> {
  late final List<_ChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    final String topic = widget.path.topic.title;
    _items = <_ChecklistItem>[
      _ChecklistItem('Review the clinical goal for $topic'),
      _ChecklistItem('Complete a focused assessment checklist'),
      _ChecklistItem('Choose a first-line action and rationale'),
      _ChecklistItem('Identify one safety / escalation cue'),
      _ChecklistItem('Document a one-line handoff summary'),
    ];
  }

  bool get _allDone => _items.every((_ChecklistItem i) => i.done);

  Future<void> _openHospital() async {
    final HealthFaculty faculty = widget.path.faculty;
    if (faculty == HealthFaculty.psychology) return;

    final String subjectId = faculty.name;
    final PracticeLabSubject? subject =
        PracticeLabUniversityCatalog.subjectById(subjectId);
    final VisualLabActivity? activity = VisualLearningCatalog.activityById(
      faculty == HealthFaculty.medicine
          ? 'med_teaching_hospital'
          : 'nurse_virtual_hospital',
    );
    if (subject == null || activity == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Virtual Hospital unavailable — use the checklist'),
        ),
      );
      return;
    }

    final List<PracticeLabType> labs = PracticeLabScenarios.forMajor(
      subjectId,
      groupId: subject.groupId,
      majorName: subject.name,
    );
    final PracticeLabType lab = labs.isNotEmpty
        ? labs.first
        : PracticeLabType(
            id: '${subjectId}_vu_hospital',
            title: 'Virtual Hospital',
            subtitle: 'Clinical decision-making practice',
            style: SimulationStyle.erEmergency,
          );
    final PracticeLabCategory category = subject.toCategory();

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VirtualHospitalHubScreen(
          subject: subject,
          category: category,
          lab: lab,
          activity: activity,
          difficulty: PracticeDifficulty.intermediate,
          teachingHospital: faculty == HealthFaculty.medicine,
        ),
      ),
    );
  }

  Future<void> _finish() async {
    try {
      await context.read<HealthFacultyProgressService>().complete(
        widget.path.topic.id,
        VuCanonicalActivity.interactiveOrVideo.name,
      );
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool clinical = widget.path.faculty != HealthFaculty.psychology;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: <Widget>[
        Text(
          'Interactive skills checklist for ${widget.path.topic.title}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          widget.path.topic.summary,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (clinical) ...<Widget>[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openHospital,
            icon: const Icon(Icons.local_hospital_outlined),
            label: Text(
              widget.path.faculty == HealthFaculty.medicine
                  ? 'Open Teaching Hospital'
                  : 'Open Virtual Hospital',
            ),
          ),
        ],
        const SizedBox(height: 16),
        ..._items.map((_ChecklistItem item) {
          return CheckboxListTile(
            value: item.done,
            onChanged: (bool? v) => setState(() => item.done = v ?? false),
            title: Text(item.label),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _allDone ? _finish : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Complete interactive activity'),
        ),
      ],
    );
  }
}

class _ChecklistItem {
  _ChecklistItem(this.label);

  final String label;
  bool done = false;
}

class _PracticeQuizBody extends StatefulWidget {
  const _PracticeQuizBody({required this.path, required this.timedFeel});

  final HealthLessonPath path;
  final bool timedFeel;

  @override
  State<_PracticeQuizBody> createState() => _PracticeQuizBodyState();
}

class _PracticeQuizBodyState extends State<_PracticeQuizBody> {
  late final List<HealthMcq> _questions;
  final Map<int, int> _answers = <int, int>{};
  bool _submitted = false;
  late DateTime _started;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _questions = HealthLessonContent.quizFor(widget.path);
    _started = DateTime.now();
    if (widget.timedFeel) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _submitted) return;
        setState(() => _elapsed = DateTime.now().difference(_started));
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _score {
    var n = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) n += 1;
    }
    return n;
  }

  bool get _passed => _score >= 4;

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _elapsed = DateTime.now().difference(_started);
    });
    _ticker?.cancel();
    final String activityName = widget.timedFeel
        ? VuCanonicalActivity.quizOrExam.name
        : VuCanonicalActivity.practiceOrHomework.name;

    if (widget.timedFeel && !_passed) return;

    try {
      await context.read<HealthFacultyProgressService>().complete(
        widget.path.topic.id,
        activityName,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: <Widget>[
        if (widget.timedFeel)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.primary.withValues(alpha: 0.1),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
            ),
            child: Text(
              _submitted
                  ? 'Time ${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')} · Score $_score/${_questions.length}${_passed ? ' · Passed' : ' · Need 4/5 to pass'}'
                  : 'Timed quiz · ${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')} · Pass with 4/5',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ...List<Widget>.generate(_questions.length, (int i) {
          final HealthMcq q = _questions[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Q${i + 1}. ${q.prompt}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  ...List<Widget>.generate(q.choices.length, (int c) {
                    final bool selected = _answers[i] == c;
                    final bool showResult = _submitted;
                    final bool correct = c == q.correctIndex;
                    Color? tileColor;
                    if (showResult && correct) {
                      tileColor = Colors.green.withValues(alpha: 0.15);
                    } else if (showResult && selected && !correct) {
                      tileColor = Colors.red.withValues(alpha: 0.12);
                    }
                    return ListTile(
                      onTap: _submitted
                          ? null
                          : () => setState(() => _answers[i] = c),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: scheme.primary,
                      ),
                      title: Text(q.choices[c]),
                      tileColor: tileColor,
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                  if (_submitted && q.explanation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        q.explanation,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        FilledButton(
          onPressed: _submitted || _answers.length < _questions.length
              ? null
              : _submit,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(
            _submitted
                ? 'Submitted ($_score/${_questions.length})'
                : 'Submit',
          ),
        ),
        if (_submitted) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to lesson'),
          ),
        ],
      ],
    );
  }
}

class _SummaryBody extends StatefulWidget {
  const _SummaryBody({required this.path});

  final HealthLessonPath path;

  @override
  State<_SummaryBody> createState() => _SummaryBodyState();
}

class _SummaryBodyState extends State<_SummaryBody> {
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final String body = _notes.text.trim();
    HealthFacultyProgressService? progress;
    try {
      progress = context.read<HealthFacultyProgressService>();
    } catch (_) {}
    if (body.isNotEmpty) {
      try {
        await VuNotesService.instance.addNote(
          title: '${widget.path.topic.title} summary',
          body: body,
          lessonId: widget.path.topic.id,
        );
      } catch (_) {}
    }
    try {
      await progress?.complete(
        widget.path.topic.id,
        VuCanonicalActivity.discussionOrSummary.name,
      );
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: <Widget>[
        Text(
          'Discussion / summary for ${widget.path.topic.title}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Write a peer-ready summary: definition, one assessment priority, '
          'one action, and one safety cue.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notes,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Your summary…',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _finish,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Save summary & complete'),
        ),
      ],
    );
  }
}
