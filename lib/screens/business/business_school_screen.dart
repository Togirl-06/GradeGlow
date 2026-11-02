import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/business_lecture_notes.dart';
import '../../data/business_school_catalog.dart';
import '../../models/business_school.dart';
import '../../services/business_school_progress_service.dart';
import '../ai_tutor_screen.dart';

class BusinessSchoolScreen extends StatelessWidget {
  const BusinessSchoolScreen({super.key, this.initialMajor});

  final BusinessMajor? initialMajor;

  @override
  Widget build(BuildContext context) {
    if (initialMajor != null) {
      return BusinessMajorHomeScreen(major: initialMajor!);
    }
    return const BusinessSchoolMajorsScreen();
  }
}

/// School of Business — pick Economics, Finance, Marketing, Accounting, or Management.
class BusinessSchoolMajorsScreen extends StatelessWidget {
  const BusinessSchoolMajorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'School of Business',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            'Choose your major',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Each major has university courses, AI lectures, notes, homework, and exams.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ...BusinessMajor.values.map((BusinessMajor major) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BusinessMajorHomeScreen(major: major),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(major.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                major.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                major.tagline,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class BusinessMajorHomeScreen extends StatefulWidget {
  const BusinessMajorHomeScreen({super.key, required this.major});

  final BusinessMajor major;

  @override
  State<BusinessMajorHomeScreen> createState() =>
      _BusinessMajorHomeScreenState();
}

class _BusinessMajorHomeScreenState extends State<BusinessMajorHomeScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BusinessSchoolProgressService>().load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BusinessMajor major = widget.major;
    final BusinessSchoolProgressService progress = context
        .watch<BusinessSchoolProgressService>();
    final List<BusinessCourse> courses = BusinessSchoolCatalog.coursesFor(
      major,
    );
    final List<BusinessLessonPath> results = BusinessSchoolCatalog.search(
      major,
      _query,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: <Widget>[
          _MajorHero(major: major, xp: progress.xp),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              hintText: 'Search Business courses and topics…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          if (_query.trim().isEmpty) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              'All Courses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '${courses.length} courses · open any topic in any order',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ...courses.map(
              (BusinessCourse course) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CourseCard(
                  major: major,
                  course: course,
                  progress: progress.courseProgress(course, major),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          BusinessCourseScreen(major: major, course: course),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 18),
            Text(
              'Search Results',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...results.map(
              (BusinessLessonPath path) => ListTile(
                leading: Text(path.course.emoji),
                title: Text(path.lesson.title),
                subtitle: Text(path.breadcrumb),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openLesson(context, path),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BusinessCourseScreen extends StatelessWidget {
  const BusinessCourseScreen({
    super.key,
    required this.major,
    required this.course,
  });

  final BusinessMajor major;
  final BusinessCourse course;

  @override
  Widget build(BuildContext context) {
    final BusinessSchoolProgressService progress = context
        .watch<BusinessSchoolProgressService>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${course.code} · ${course.title}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _card(context, Theme.of(context).colorScheme.primary),
            child: Row(
              children: <Widget>[
                Text(course.emoji, style: const TextStyle(fontSize: 42)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        major.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress.courseProgress(course, major),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress.courseProgress(course, major) * 100).round()}% mastery',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Modules & Lessons',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...course.lessons.asMap().entries.map((
            MapEntry<int, BusinessLesson> entry,
          ) {
            final BusinessLesson lesson = entry.value;
            final double mastery = progress.lessonProgress(lesson.id, major);
            final BusinessLessonPath path = BusinessLessonPath(
              major: major,
              course: course,
              lesson: lesson,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openLesson(context, path),
                  child: Ink(
                    padding: const EdgeInsets.all(15),
                    decoration: _card(context),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: mastery,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class BusinessLessonHubScreen extends StatelessWidget {
  const BusinessLessonHubScreen({super.key, required this.path});

  final BusinessLessonPath path;

  @override
  Widget build(BuildContext context) {
    final BusinessSchoolProgressService progress = context
        .watch<BusinessSchoolProgressService>();
    final double mastery = progress.lessonProgress(path.lesson.id, path.major);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          path.lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _card(context, Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  path.breadcrumb,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By the end of this lesson, you will:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                ...path.lesson.outcomes.map(
                  (String outcome) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $outcome'),
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: mastery,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  mastery >= 1
                      ? 'Topic complete · certificate unlocked'
                      : '${(mastery * 100).round()}% mastery · Lecture + Video + Homework + Exam',
                  style: TextStyle(
                    color: mastery >= 1 ? Colors.green : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (mastery >= 1) ...<Widget>[
            const SizedBox(height: 14),
            _TopicCertificateCard(path: path, progress: progress),
          ],
          const SizedBox(height: 18),
          Text(
            'Learning Workspaces',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lecture and Whiteboard Video teach the topic. Textbook Notes and AI Tutor are supplemental. Homework and Exam finish mastery and unlock your certificate.',
          ),
          const SizedBox(height: 12),
          ...businessActivityFlow(path.major).map((BusinessActivityKind kind) {
            final bool supplemental = businessActivityIsSupplemental(kind);
            final bool done =
                !supplemental && progress.isComplete(path.lesson.id, kind);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final bool? finished = await Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) =>
                                BusinessWorkspaceScreen(path: path, kind: kind),
                          ),
                        );
                    if (finished == true && !supplemental && context.mounted) {
                      await context
                          .read<BusinessSchoolProgressService>()
                          .complete(path.lesson.id, kind);
                    }
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(15),
                    decoration: _card(
                      context,
                      done ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(kind.emoji, style: const TextStyle(fontSize: 27)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                kind.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                supplemental
                                    ? (kind == BusinessActivityKind.notes
                                          ? 'Full textbook chapter · study anytime'
                                          : 'Optional coaching · no mastery credit')
                                    : kind.subtitle,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          supplemental
                              ? 'Study'
                              : done
                              ? '✓ Done'
                              : '+${kind.xp} XP',
                          style: TextStyle(
                            color: done ? Colors.green : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class BusinessWorkspaceScreen extends StatelessWidget {
  const BusinessWorkspaceScreen({
    super.key,
    required this.path,
    required this.kind,
  });

  final BusinessLessonPath path;
  final BusinessActivityKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == BusinessActivityKind.aiTutor) {
      return AiTutorScreen(
        initialPrompt:
            'Help me understand ${path.lesson.title} from ${path.course.title}. '
            'Teach it step by step, use a practical business example, and check my understanding.',
        requireEngagedSession: true,
      );
    }
    final Widget body = switch (kind) {
      BusinessActivityKind.professor => _ProfessorWorkspace(path: path),
      BusinessActivityKind.aiTutor => throw StateError('Handled above'),
      BusinessActivityKind.notes => _NotesWorkspace(path: path),
      BusinessActivityKind.video => _VideoWorkspace(path: path),
      BusinessActivityKind.interactive ||
      BusinessActivityKind.simulation ||
      BusinessActivityKind.dashboard => _MajorLabWorkspace(
        path: path,
        kind: kind,
      ),
      BusinessActivityKind.ceoMentor => _CeoMentorWorkspace(path: path),
      BusinessActivityKind.companySimulator => _CompanySimulatorWorkspace(
        path: path,
      ),
      BusinessActivityKind.management => _ManagementWorkspace(path: path),
      BusinessActivityKind.entrepreneurship ||
      BusinessActivityKind.operations ||
      BusinessActivityKind.leadership ||
      BusinessActivityKind.negotiation => _ExecutiveLabWorkspace(
        path: path,
        kind: kind,
      ),
      BusinessActivityKind.caseStudy => _CaseWorkspace(path: path),
      BusinessActivityKind.homework ||
      BusinessActivityKind.exam => _AssessmentWorkspace(
        path: path,
        exam: kind == BusinessActivityKind.exam,
      ),
      BusinessActivityKind.project || BusinessActivityKind.internship =>
        _DeliverableWorkspace(path: path, kind: kind),
      BusinessActivityKind.capstone =>
        path.major == BusinessMajor.businessAdministration
            ? _CompanySimulatorWorkspace(path: path)
            : _DeliverableWorkspace(path: path, kind: kind),
    };
    final bool supplemental = businessActivityIsSupplemental(kind);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${kind.emoji} ${kind.title}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: body,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(!supplemental),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              supplemental
                  ? 'Back to lesson'
                  : 'Complete ${kind.title} · +${kind.xp} XP',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfessorWorkspace extends StatefulWidget {
  const _ProfessorWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_ProfessorWorkspace> createState() => _ProfessorWorkspaceState();
}

class _ProfessorWorkspaceState extends State<_ProfessorWorkspace> {
  int _section = 0;
  bool _speaking = true;
  final TextEditingController _question = TextEditingController();
  String? _answer;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  List<String> _lectureSections(BusinessLessonPath path) {
    final BusinessLectureNote note = BusinessLectureNotes.forPath(path);
    return <String>[
      'Welcome. Today\'s AI Professor lecture is ${path.lesson.title} '
          'from ${path.course.title}. I will teach this as a full textbook '
          'chapter with voice narration. Listen for definitions, mechanisms, '
          'and decision rules.\n\n${note.overview}',
      if (note.definitions.isNotEmpty)
        'Vocabulary for this lecture:\n\n${note.definitions.take(8).map((String d) => '• $d').join('\n')}',
      ...note.sections.map(
        (BusinessTextbookSection s) => '${s.title}\n\n${s.body}',
      ),
      'Formulas and frameworks:\n\n${note.formulas.map((String f) => '• $f').join('\n')}',
      'Worked example with narration:\n\n${note.workedExample}',
      'Professional application:\n\n${note.application}',
      'Closing checkpoint:\n\n${note.summary}\n\n'
          'Before you leave, answer one review question aloud, then complete '
          'the Whiteboard Video and Textbook Notes if you need reinforcement.',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final BusinessLessonPath path = widget.path;
    final List<String> sections = _lectureSections(path);
    final int index = _section.clamp(0, sections.length - 1);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                const Color(0xFF111827),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _speaking ? Icons.record_voice_over : Icons.voice_over_off,
                  size: 72,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  _speaking ? 'Voice narration on' : 'Voice narration paused',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Icon(Icons.school, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'AI Professor lecture',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text('${index + 1}/${sections.length}'),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _card(context, Theme.of(context).colorScheme.primary),
          child: Text(sections[index], style: const TextStyle(height: 1.55)),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: index > 0
                  ? () => setState(() => _section = index - 1)
                  : null,
              icon: const Icon(Icons.skip_previous),
            ),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => setState(() {
                  _speaking = !_speaking;
                  if (index < sections.length - 1 && _speaking) {
                    _section = index + 1;
                  }
                }),
                icon: Icon(_speaking ? Icons.pause : Icons.play_arrow),
                label: Text(_speaking ? 'Pause narration' : 'Continue lecture'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              onPressed: index < sections.length - 1
                  ? () => setState(() => _section = index + 1)
                  : null,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _question,
          decoration: const InputDecoration(
            labelText: 'Ask the professor',
            hintText: 'Explain a formula, assumption, or implication…',
          ),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _answer = _question.text.trim().isEmpty
                ? 'Ask a specific question about ${path.lesson.title}.'
                : 'Professor: In ${path.lesson.title}, start from the definition, '
                      'state the mechanism, show one calculation, and test what '
                      'would falsify your conclusion. Then reconnect to the '
                      'learning outcomes for ${path.course.title}.';
          }),
          icon: const Icon(Icons.smart_toy),
          label: const Text('Ask'),
        ),
        if (_answer != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_answer!, style: const TextStyle(height: 1.45)),
          ),
      ],
    );
  }
}

class _NotesWorkspace extends StatelessWidget {
  const _NotesWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  Widget build(BuildContext context) {
    final BusinessLectureNote note = BusinessLectureNotes.forPath(path);
    var sectionNo = 1;
    String next(String title) {
      final String labeled = '$sectionNo · $title';
      sectionNo += 1;
      return labeled;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          path.lesson.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          '${path.course.code} · Full textbook chapter · 60–90 min study',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Divider(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _card(context, Theme.of(context).colorScheme.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Chapter learning objectives',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const SizedBox(height: 10),
              ...path.lesson.outcomes.map(
                (String outcome) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text(
                    '• $outcome',
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _NoteSection(title: next('Chapter overview'), body: note.overview),
        _NoteListSection(
          title: next('Definitions and vocabulary'),
          items: note.definitions,
          accent: Theme.of(context).colorScheme.primary,
        ),
        _NoteListSection(
          title: next('Core theory and key concepts'),
          items: note.keyConcepts,
          accent: Theme.of(context).colorScheme.primary,
        ),
        ...note.sections.map(
          (BusinessTextbookSection section) =>
              _NoteSection(title: next(section.title), body: section.body),
        ),
        _NoteListSection(
          title: next('Formulas, identities, and frameworks'),
          items: note.formulas,
          accent: Theme.of(context).colorScheme.primary,
          callout: true,
        ),
        _NoteSection(
          title: next('Fully worked example'),
          body: note.workedExample,
        ),
        _NoteSection(
          title: next('Professional application lab'),
          body: note.application,
        ),
        _NoteListSection(
          title: next('Common mistakes and how to avoid them'),
          items: note.commonMistakes,
          accent: Theme.of(context).colorScheme.primary,
        ),
        _NoteListSection(
          title: next('Practice problems'),
          items: note.practiceProblems,
          accent: Theme.of(context).colorScheme.primary,
        ),
        _NoteSection(title: next('Chapter summary'), body: note.summary),
        _NoteListSection(
          title: next('Review and research questions'),
          items: note.reviewQuestions,
          accent: Theme.of(context).colorScheme.primary,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _card(context, Theme.of(context).colorScheme.primary),
          child: const Text(
            'How to study this textbook chapter\n\n'
            '1. Read the overview and definitions first; rewrite every term in your own words.\n'
            '2. Study each theory section in order — later sections depend on earlier ones.\n'
            '3. Cover the worked example and reproduce every step from memory.\n'
            '4. Complete the practice problems before looking at review questions.\n'
            '5. Answer review questions with evidence, assumptions, and a clear recommendation.\n'
            '6. Only then open Homework and Exam to test mastery.',
            style: TextStyle(height: 1.55),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _VideoWorkspace extends StatefulWidget {
  const _VideoWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_VideoWorkspace> createState() => _VideoWorkspaceState();
}

class _VideoWorkspaceState extends State<_VideoWorkspace> {
  bool _playing = false;
  double _position = 0.12;
  double _speed = 1;
  int _chapter = 0;

  @override
  Widget build(BuildContext context) {
    final BusinessLessonPath path = widget.path;
    final BusinessLectureNote note = BusinessLectureNotes.forPath(path);
    final List<({String stamp, String title, String board})>
    chapters = <({String stamp, String title, String board})>[
      (
        stamp: '00:00',
        title: 'Learning objectives & setup',
        board:
            'Animated whiteboard opens with the title ${path.lesson.title}. '
            'Objectives appear one by one. The instructor circles the decision '
            'question and underlines key vocabulary.',
      ),
      (
        stamp: '06:20',
        title: 'Core model on the board',
        board:
            'The instructor draws the governing framework for ${path.lesson.title}, '
            'labels each variable, and animates arrows that show the mechanism. '
            'Assumptions are written in a side column.',
      ),
      (
        stamp: '16:40',
        title: 'Formula walkthrough',
        board: note.formulas.take(3).map((String f) => '• $f').join('\n'),
      ),
      (
        stamp: '24:10',
        title: 'Worked example animation',
        board:
            'Numbers appear step by step on the whiteboard while the narrator '
            'explains each transformation for ${path.lesson.title}.',
      ),
      (
        stamp: '34:50',
        title: 'Professional application',
        board:
            'A realistic ${path.major.title.toLowerCase()} scenario is sketched: '
            'options, trade-offs, and a final recommendation box.',
      ),
      (
        stamp: '42:30',
        title: 'Checkpoint & recap',
        board:
            'Three review prompts appear. Students pause, answer, then resume '
            'for the closing summary of ${path.lesson.title}.',
      ),
    ];
    final ({String stamp, String title, String board}) current =
        chapters[_chapter.clamp(0, chapters.length - 1)];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.brush, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Animated whiteboard · ${path.lesson.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _playing = !_playing),
                      icon: Icon(
                        _playing ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        current.board,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Slider(
          value: _position,
          onChanged: (double value) => setState(() {
            _position = value;
            _chapter = (value * (chapters.length - 1)).round();
          }),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        Row(
          children: <Widget>[
            Text('${(_position * 48).round()}:00 / 48:00'),
            const Spacer(),
            DropdownButton<double>(
              value: _speed,
              items: const <DropdownMenuItem<double>>[
                DropdownMenuItem(value: 0.75, child: Text('0.75×')),
                DropdownMenuItem(value: 1, child: Text('1×')),
                DropdownMenuItem(value: 1.25, child: Text('1.25×')),
                DropdownMenuItem(value: 1.5, child: Text('1.5×')),
              ],
              onChanged: (double? value) => setState(() => _speed = value ?? 1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Whiteboard chapters',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 8),
        ...chapters.asMap().entries.map((
          MapEntry<int, ({String stamp, String title, String board})> e,
        ) {
          final bool selected = e.key == _chapter;
          return ListTile(
            selected: selected,
            leading: Icon(
              Icons.play_arrow,
              color: selected ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text('${e.value.stamp} · ${e.value.title}'),
            onTap: () => setState(() {
              _chapter = e.key;
              _position = e.key / (chapters.length - 1);
              _playing = true;
            }),
          );
        }),
      ],
    );
  }
}

class _CeoMentorWorkspace extends StatefulWidget {
  const _CeoMentorWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_CeoMentorWorkspace> createState() => _CeoMentorWorkspaceState();
}

class _CeoMentorWorkspaceState extends State<_CeoMentorWorkspace> {
  int _scenario = 0;
  int? _choice;
  String? _consequence;
  double _revenue = 100;
  double _morale = 72;
  double _marketShare = 18;

  static const List<
    ({String problem, List<String> choices, List<String> consequences})
  >
  _scenarios = <({String problem, List<String> choices, List<String> consequences})>[
    (
      problem:
          'Sales in Europe have declined 16% for two quarters while customer satisfaction remains high.',
      choices: <String>[
        'Cut prices across Europe immediately',
        'Diagnose segments, channels, and competitor moves before a targeted response',
        'Exit Europe and redirect all capital',
      ],
      consequences: <String>[
        'Volume improves, but margin falls sharply and the price cut is hard to reverse.',
        'You discover one channel caused most of the decline. A targeted fix restores growth while protecting margin.',
        'Cash improves briefly, but you surrender a valuable market and damage partner trust.',
      ],
    ),
    (
      problem:
          'A competitor lowered price by 20% and is advertising heavily. Your product has stronger retention.',
      choices: <String>[
        'Match the price cut',
        'Reinforce differentiated value and selectively defend price-sensitive accounts',
        'Ignore the competitor entirely',
      ],
      consequences: <String>[
        'Churn slows, but industry profitability deteriorates and your premium positioning weakens.',
        'You protect high-value customers, preserve economics, and learn where differentiation matters.',
        'Margins stay intact, but preventable churn accelerates in exposed segments.',
      ],
    ),
    (
      problem:
          'Employee engagement fell to 54%. Managers report burnout and unclear priorities.',
      choices: <String>[
        'Offer a one-time bonus without changing workloads',
        'Reset priorities, train managers, rebalance workloads, and publish follow-up metrics',
        'Replace the lowest-scoring team immediately',
      ],
      consequences: <String>[
        'The bonus creates a short lift, but burnout and role ambiguity persist.',
        'Productivity dips during the reset, then improves as trust and focus recover.',
        'Fear increases turnover and important institutional knowledge leaves the company.',
      ],
    ),
    (
      problem:
          'Production costs rose 20% after a supplier shock. Customer orders are still growing.',
      choices: <String>[
        'Cut quality controls to preserve margin',
        'Negotiate, qualify a second supplier, redesign high-cost inputs, and phase pricing',
        'Raise every price by 25% tomorrow',
      ],
      consequences: <String>[
        'Short-term margin holds, but defects, returns, and brand damage compound.',
        'Margin recovers gradually while resilience improves and customers receive clear notice.',
        'Margin improves per unit, but demand and trust fall faster than expected.',
      ],
    ),
  ];

  void _decide(int index) {
    final int quality = index == 1 ? 1 : -1;
    setState(() {
      _choice = index;
      _consequence = _scenarios[_scenario].consequences[index];
      _revenue += quality * 4;
      _morale = (_morale + quality * 5).clamp(0, 100);
      _marketShare = (_marketShare + quality * 1.2).clamp(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenarios[_scenario];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'AI CEO Mentor',
          subtitle: 'Executive coaching session · Boardroom',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Revenue index',
                value: _revenue.toStringAsFixed(0),
                trend: _revenue - 100,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Employee happiness',
                value: '${_morale.round()}%',
                trend: _morale - 65,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Market share',
                value: '${_marketShare.toStringAsFixed(1)}%',
                trend: _marketShare - 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _card(context, Theme.of(context).colorScheme.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: const Text('CEO'),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Executive challenge',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Text('${_scenario + 1}/${_scenarios.length}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(scenario.problem, style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(
          scenario.choices.length,
          (int i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: _consequence == null ? () => _decide(i) : null,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(14),
                side: BorderSide(
                  color: _choice == i
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: _choice == i ? 2 : 1,
                ),
              ),
              child: Text(scenario.choices[i]),
            ),
          ),
        ),
        if (_consequence != null) ...<Widget>[
          _ConsequenceCard(
            text:
                'CEO mentor: $_consequence\n\nExecutive lesson: avoid false binaries. Diagnose the mechanism, protect strategic options, define leading indicators, and set a review trigger.',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => setState(() {
              _scenario = (_scenario + 1) % _scenarios.length;
              _choice = null;
              _consequence = null;
            }),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next executive challenge'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompanySimulatorWorkspace extends StatefulWidget {
  const _CompanySimulatorWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_CompanySimulatorWorkspace> createState() =>
      _CompanySimulatorWorkspaceState();
}

class _CompanySimulatorWorkspaceState
    extends State<_CompanySimulatorWorkspace> {
  String _industry = 'Technology';
  String _businessModel = 'Subscription';
  String _product = 'Team productivity platform';
  String _location = 'New York';
  String _supplier = 'Balanced supplier';
  double _price = 49;
  double _employees = 12;
  double _marketing = 18;
  double _training = 6;
  double _inventory = 55;
  int _quarter = 1;
  double _cash = 500000;
  double _revenue = 130000;
  double _profit = 18000;
  double _happiness = 74;
  double _customers = 1200;
  double _marketShare = 2.4;
  String _event = 'Company incorporated. Configure the operating model.';
  final List<double> _revenueHistory = <double>[80, 95, 110, 130];

  void _advanceQuarter() {
    final double demand = (80 + _marketing * 2.2 - (_price - 55).abs() * 0.7)
        .clamp(10, 180);
    final double peopleCapacity =
        _employees * (0.8 + _training / 35) * (_happiness / 75);
    final double supplyCapacity = _supplier == 'Low-cost supplier'
        ? 0.9
        : _supplier == 'Premium supplier'
        ? 1.15
        : 1;
    final double served = math.min(demand, peopleCapacity * supplyCapacity);
    final double quarterlyRevenue =
        served * _price * (_businessModel == 'Subscription' ? 62 : 48);
    final double payroll = _employees * 7200;
    final double marketingCost = _marketing * 2500;
    final double trainingCost = _training * 1200;
    final double locationCost = _location == 'Remote-first'
        ? 18000
        : _location == 'London'
        ? 62000
        : 48000;
    final double supplierCost =
        quarterlyRevenue *
        (_supplier == 'Premium supplier'
            ? 0.31
            : _supplier == 'Low-cost supplier'
            ? 0.18
            : 0.24);
    final double quarterlyProfit =
        quarterlyRevenue -
        payroll -
        marketingCost -
        trainingCost -
        locationCost -
        supplierCost;
    final int nextQuarter = _quarter + 1;
    final bool downturn = nextQuarter % 8 == 0;
    final bool competitorLaunch = nextQuarter % 5 == 0;
    final double shock = downturn
        ? 0.82
        : competitorLaunch
        ? 0.92
        : 1;

    setState(() {
      _quarter = nextQuarter;
      _revenue = quarterlyRevenue * shock;
      _profit = quarterlyProfit * shock;
      _cash += _profit;
      _customers = (_customers + served * 12 - math.max(0, 72 - _happiness) * 4)
          .clamp(0, 1000000);
      _marketShare =
          (_marketShare + served / 220 - (competitorLaunch ? 0.45 : 0)).clamp(
            0,
            80,
          );
      _happiness =
          (_happiness +
                  _training * 0.3 -
                  math.max(0, demand - peopleCapacity) * 0.12 -
                  (_employees < 8 ? 3 : 0))
              .clamp(15, 98);
      _inventory = (_inventory + 8 - served / 10).clamp(0, 100);
      _revenueHistory.add(_revenue / 1000);
      if (_revenueHistory.length > 12) _revenueHistory.removeAt(0);
      _event = downturn
          ? 'Economic downturn: demand fell 18%. Protect liquidity and employee trust.'
          : competitorLaunch
          ? 'AI competitor launched a lower-priced product. Differentiate or defend priority segments.'
          : _happiness < 55
          ? 'Employee burnout is reducing capacity. Workload and management systems need attention.'
          : _inventory < 20
          ? 'Inventory risk: customer orders may be delayed next quarter.'
          : 'Quarter closed. The board wants a clear explanation of performance drivers.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final int year = ((_quarter - 1) ~/ 4) + 1;
    final int q = ((_quarter - 1) % 4) + 1;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Company Simulator · Year $year Q$q',
          subtitle: 'Build, operate, and scale against AI competitors',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _card(context, Colors.orange),
          child: Row(
            children: <Widget>[
              const Icon(Icons.notifications_active, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(_event)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Revenue',
                value: '\$${(_revenue / 1000).toStringAsFixed(0)}K',
                trend: _revenue - 130000,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _Kpi(
                label: 'Profit',
                value: '\$${(_profit / 1000).toStringAsFixed(0)}K',
                trend: _profit,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _Kpi(
                label: 'Cash',
                value: '\$${(_cash / 1000).toStringAsFixed(0)}K',
                trend: _cash - 500000,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Customers',
                value: _customers.toStringAsFixed(0),
                trend: _customers - 1200,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _Kpi(
                label: 'Happiness',
                value: '${_happiness.round()}%',
                trend: _happiness - 70,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _Kpi(
                label: 'Market share',
                value: '${_marketShare.toStringAsFixed(1)}%',
                trend: _marketShare - 2.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          child: CustomPaint(
            painter: _BusinessChartPainter(
              values: _revenueHistory,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const Text(
          'Revenue history · \$000',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const Divider(height: 28),
        const Text(
          'Company design',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 8),
        _companyDropdown('Industry', _industry, const <String>[
          'Technology',
          'Retail',
          'Manufacturing',
          'Food & Beverage',
          'Professional Services',
        ], (String value) => setState(() => _industry = value)),
        _companyDropdown(
          'Business model',
          _businessModel,
          const <String>[
            'Subscription',
            'Direct sales',
            'Marketplace',
            'Franchise',
            'Usage-based',
          ],
          (String value) => setState(() => _businessModel = value),
        ),
        TextFormField(
          initialValue: _product,
          decoration: const InputDecoration(labelText: 'Product'),
          onChanged: (String value) => _product = value,
        ),
        const SizedBox(height: 8),
        _companyDropdown(
          'Headquarters',
          _location,
          const <String>[
            'New York',
            'London',
            'Lagos',
            'Singapore',
            'Remote-first',
          ],
          (String value) => setState(() => _location = value),
        ),
        _companyDropdown(
          'Supplier strategy',
          _supplier,
          const <String>[
            'Low-cost supplier',
            'Balanced supplier',
            'Premium supplier',
          ],
          (String value) => setState(() => _supplier = value),
        ),
        _companySlider(
          'Price',
          _price,
          15,
          150,
          '\$',
          (double v) => setState(() => _price = v),
        ),
        _companySlider(
          'Employees',
          _employees,
          4,
          80,
          '',
          (double v) => setState(() => _employees = v),
        ),
        _companySlider(
          'Marketing budget',
          _marketing,
          2,
          60,
          'K',
          (double v) => setState(() => _marketing = v),
        ),
        _companySlider(
          'Training budget',
          _training,
          0,
          25,
          'K',
          (double v) => setState(() => _training = v),
        ),
        _companySlider(
          'Inventory / capacity',
          _inventory,
          0,
          100,
          '%',
          (double v) => setState(() => _inventory = v),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _advanceQuarter,
          icon: const Icon(Icons.fast_forward),
          label: const Text('Make decisions & advance quarter'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        _ConsequenceCard(
          text:
              'Board AI: Revenue alone is not success. Maintain cash, profitability, customer value, employee health, and strategic position across multiple virtual years.',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _companyDropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> changed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: values
            .map(
              (String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: (String? next) {
          if (next != null) changed(next);
        },
      ),
    );
  }

  Widget _companySlider(
    String label,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> changed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label · ${unit == '\$' ? unit : ''}${value.round()}${unit == '\$' ? '' : unit}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Slider(value: value, min: min, max: max, onChanged: changed),
      ],
    );
  }
}

class _ManagementWorkspace extends StatefulWidget {
  const _ManagementWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_ManagementWorkspace> createState() => _ManagementWorkspaceState();
}

class _ManagementWorkspaceState extends State<_ManagementWorkspace> {
  String _role = 'CEO';
  double _salary = 62;
  double _training = 35;
  int _headcount = 18;
  double _happiness = 68;
  double _productivity = 74;
  String _message = 'Select a role and manage the team.';

  void _act(String action) {
    setState(() {
      switch (action) {
        case 'Hire':
          _headcount += 1;
          _productivity = (_productivity + 2).clamp(0, 100);
          _message =
              'A new employee joins. Productivity will improve after onboarding.';
        case 'Promote':
          _happiness = (_happiness + 5).clamp(0, 100);
          _salary += 1;
          _message =
              'Internal promotion improves trust. Ensure the process was fair and role expectations are clear.';
        case 'Train':
          _training = (_training + 5).clamp(0, 100);
          _productivity = (_productivity + 4).clamp(0, 100);
          _message =
              'Training costs time now but improves capability and retention.';
        case 'Resolve conflict':
          _happiness = (_happiness + 4).clamp(0, 100);
          _message =
              'You facilitated a structured conversation, clarified facts, and agreed on behavior and follow-up.';
        case 'Fire':
          _headcount = math.max(1, _headcount - 1);
          _happiness = (_happiness - 8).clamp(0, 100);
          _message =
              'Termination reduces cost but affects trust. Document performance, fairness, transition, and team communication.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Management Simulator',
          subtitle: 'People, priorities, performance, and workplace decisions',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              const <String>[
                'CEO',
                'Operations Manager',
                'Project Manager',
                'Store Manager',
                'HR Manager',
              ].map((String role) {
                return ChoiceChip(
                  label: Text(role),
                  selected: _role == role,
                  onSelected: (_) => setState(() {
                    _role = role;
                    _message =
                        '$role selected. Your metrics and challenges now reflect this role.';
                  }),
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Employees',
                value: '$_headcount',
                trend: _headcount - 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Happiness',
                value: '${_happiness.round()}%',
                trend: _happiness - 65,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Productivity',
                value: '${_productivity.round()}%',
                trend: _productivity - 70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Average salary · \$${_salary.round()}K',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _salary,
          min: 35,
          max: 120,
          onChanged: (double v) => setState(() {
            _salary = v;
            _happiness = (45 + v * 0.4).clamp(0, 95);
          }),
        ),
        Text(
          'Training coverage · ${_training.round()}%',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _training,
          min: 0,
          max: 100,
          onChanged: (double v) => setState(() => _training = v),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              <String>[
                'Hire',
                'Promote',
                'Train',
                'Resolve conflict',
                'Fire',
              ].map((String action) {
                return ActionChip(
                  label: Text(action),
                  onPressed: () => _act(action),
                );
              }).toList(),
        ),
        _ConsequenceCard(text: _message, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

class _ExecutiveLabWorkspace extends StatefulWidget {
  const _ExecutiveLabWorkspace({required this.path, required this.kind});

  final BusinessLessonPath path;
  final BusinessActivityKind kind;

  @override
  State<_ExecutiveLabWorkspace> createState() => _ExecutiveLabWorkspaceState();
}

class _ExecutiveLabWorkspaceState extends State<_ExecutiveLabWorkspace> {
  final TextEditingController _entry = TextEditingController();
  double _primary = 55;
  double _secondary = 45;
  int _round = 1;
  String? _feedback;

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.kind) {
      BusinessActivityKind.entrepreneurship => _entrepreneurship(context),
      BusinessActivityKind.operations => _operations(context),
      BusinessActivityKind.leadership => _leadership(context),
      BusinessActivityKind.negotiation => _negotiation(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _entrepreneurship(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Entrepreneurship Lab',
          subtitle: 'From problem to investor-ready venture',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        ...const <String>[
          'Business idea / customer problem',
          'Value proposition',
          'Customer segments',
          'Business model and revenue',
          'Marketing plan',
          'Financial plan',
          'Investor pitch',
          'Growth strategy',
        ].map(
          (String section) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              decoration: InputDecoration(labelText: section),
              minLines: 1,
              maxLines: 3,
            ),
          ),
        ),
        TextField(
          controller: _entry,
          decoration: const InputDecoration(
            labelText: 'One-minute founder pitch',
          ),
          minLines: 4,
          maxLines: 7,
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => setState(() {
            _feedback = _entry.text.trim().length < 80
                ? 'AI venture mentor: Specify the customer, urgent problem, differentiated solution, evidence, economics, and funding use.'
                : 'AI venture mentor: The narrative is clear. Strengthen customer evidence, acquisition economics, defensibility, and milestones before pitching investors.';
          }),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Pitch to AI investor'),
        ),
        if (_feedback != null)
          _ConsequenceCard(text: _feedback!, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }

  Widget _operations(BuildContext context) {
    final double orders = 70 + _secondary * 0.7;
    final double capacity = 35 + _primary;
    final double onTime = (92 - math.max(0, orders - capacity) * 0.8).clamp(
      20,
      99,
    );
    final double cost = 42 + _primary * 0.35 + _secondary * 0.18;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Operations Control Center',
          subtitle: 'Factory · inventory · suppliers · logistics · orders',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Orders',
                value: orders.round().toString(),
                trend: orders - 80,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'On time',
                value: '${onTime.round()}%',
                trend: onTime - 85,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Cost index',
                value: cost.round().toString(),
                trend: 60 - cost,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Inventory / production capacity · ${_primary.round()}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _primary,
          min: 10,
          max: 100,
          onChanged: (double v) => setState(() => _primary = v),
        ),
        Text(
          'Service and demand commitment · ${_secondary.round()}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _secondary,
          min: 10,
          max: 100,
          onChanged: (double v) => setState(() => _secondary = v),
        ),
        _ConsequenceCard(
          text: onTime < 75
              ? 'Operations AI: Orders exceed practical capacity. Delays and unhappy customers are increasing. Re-plan production, supplier lead times, and customer promises.'
              : 'Operations AI: Service is stable. Now reduce working capital without weakening resilience or delivery.',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _leadership(BuildContext context) {
    const List<String> crises = <String>[
      'Two high-performing employees are arguing publicly.',
      'A respected manager resigned during a critical project.',
      'A cyberattack disrupted customer operations.',
      'The product launch is six weeks behind schedule.',
    ];
    final String crisis = crises[(_round - 1) % crises.length];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Leadership Situation Room',
          subtitle:
              'Crisis $_round · Lead with clarity, fairness, and accountability',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _card(context, Colors.red),
          child: Text(
            crisis,
            style: const TextStyle(fontSize: 17, height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _entry,
          decoration: const InputDecoration(
            labelText: 'Your leadership response',
            hintText:
                'Immediate action · communication · owners · employee/customer care · follow-up',
          ),
          minLines: 5,
          maxLines: 8,
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => setState(() {
            _feedback = _entry.text.trim().length < 90
                ? 'Leadership coach: Add immediate containment, stakeholder communication, accountable owners, timing, and a learning review.'
                : 'Leadership coach: Good structure. Make trade-offs explicit, protect psychological safety, and define what evidence will show recovery.';
          }),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Evaluate leadership'),
        ),
        if (_feedback != null) ...<Widget>[
          _ConsequenceCard(text: _feedback!, color: Theme.of(context).colorScheme.primary),
          OutlinedButton(
            onPressed: () => setState(() {
              _round += 1;
              _entry.clear();
              _feedback = null;
            }),
            child: const Text('Next situation'),
          ),
        ],
      ],
    );
  }

  Widget _negotiation(BuildContext context) {
    final double offer = _primary;
    final double relationship = _secondary;
    final double acceptance =
        (40 + relationship * 0.45 - (offer - 52).abs() * 0.7).clamp(0, 100);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Adaptive Negotiation',
          subtitle: 'Round $_round · Supplier contract renewal',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        const Text(
          'AI supplier: “Our input costs increased. We need an 18% price increase and a two-year commitment.”',
          style: TextStyle(fontWeight: FontWeight.w800, height: 1.45),
        ),
        const SizedBox(height: 12),
        Text(
          'Economic offer · ${offer.round()}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _primary,
          min: 10,
          max: 100,
          onChanged: (double v) => setState(() => _primary = v),
        ),
        Text(
          'Relationship / value creation · ${relationship.round()}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _secondary,
          min: 0,
          max: 100,
          onChanged: (double v) => setState(() => _secondary = v),
        ),
        TextField(
          controller: _entry,
          decoration: const InputDecoration(
            labelText: 'Your message to the supplier',
            hintText:
                'Interests · evidence · package proposal · contingencies · next step',
          ),
          minLines: 4,
          maxLines: 7,
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => setState(() {
            _round += 1;
            _feedback = acceptance > 65
                ? 'AI supplier: “The volume guarantee and joint cost program create value. We can reduce the increase if service levels are measurable.”'
                : 'AI supplier: “This does not address our economics. Improve the package or we will prioritize other customers.”';
          }),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Send offer'),
        ),
        if (_feedback != null)
          _ConsequenceCard(
            text:
                '$_feedback\n\nNegotiation coach: Prepare BATNA, reservation point, interests, objective criteria, and packages—not just one number.',
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }
}

class _MajorLabWorkspace extends StatelessWidget {
  const _MajorLabWorkspace({required this.path, required this.kind});

  final BusinessLessonPath path;
  final BusinessActivityKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (path.major) {
      BusinessMajor.businessAdministration =>
        kind == BusinessActivityKind.dashboard
            ? _BusinessAnalyticsWorkspace(path: path)
            : _CompanySimulatorWorkspace(path: path),
      BusinessMajor.economics => _EconomyLab(path: path),
      BusinessMajor.finance => _FinanceLab(path: path),
      BusinessMajor.marketing => _MarketingLab(path: path),
      BusinessMajor.accounting => _AccountingLab(path: path),
    };
  }
}

class _BusinessAnalyticsWorkspace extends StatefulWidget {
  const _BusinessAnalyticsWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_BusinessAnalyticsWorkspace> createState() =>
      _BusinessAnalyticsWorkspaceState();
}

class _BusinessAnalyticsWorkspaceState
    extends State<_BusinessAnalyticsWorkspace> {
  final TextEditingController _analysis = TextEditingController();
  String? _feedback;

  @override
  void dispose() {
    _analysis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Business Analytics Command Center',
          subtitle: 'Sales · customers · employees · finance · production',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        const Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(label: 'Sales', value: '+14%', trend: 14),
            ),
            SizedBox(width: 7),
            Expanded(
              child: _Kpi(label: 'Profit', value: '−6%', trend: -6),
            ),
            SizedBox(width: 7),
            Expanded(
              child: _Kpi(label: 'Returns', value: '+31%', trend: -31),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(label: 'Overtime', value: '+22%', trend: -22),
            ),
            SizedBox(width: 7),
            Expanded(
              child: _Kpi(label: 'On-time delivery', value: '71%', trend: -14),
            ),
            SizedBox(width: 7),
            Expanded(
              child: _Kpi(label: 'Satisfaction', value: '3.6/5', trend: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _BusinessChartPainter(
              values: const <double>[48, 55, 62, 75, 84, 91, 104],
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Why did profit decrease despite higher sales?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 6),
        const Text(
          'Use at least three metrics, explain the operating mechanism, and distinguish correlation from a supported causal claim.',
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _analysis,
          minLines: 5,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Your analysis',
            hintText:
                'Claim · evidence · mechanism · alternative explanation · recommendation',
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => setState(() {
            final String text = _analysis.text.toLowerCase();
            final int evidence = <String>[
              'return',
              'overtime',
              'delivery',
              'cost',
              'margin',
              'satisfaction',
            ].where(text.contains).length;
            _feedback = evidence >= 3
                ? 'Analytics mentor: Strong triangulation. Higher volume appears to have created overtime, fulfillment failures, and returns that compressed margin. Quantify each contribution before claiming causality.'
                : 'Analytics mentor: Cite at least three dashboard metrics and connect them through an operating mechanism. Higher sales do not guarantee higher profit when variable cost, overtime, returns, or discounting rise.';
          }),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Submit analysis'),
        ),
        if (_feedback != null)
          _ConsequenceCard(text: _feedback!, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

class _EconomyLab extends StatefulWidget {
  const _EconomyLab({required this.path});
  final BusinessLessonPath path;

  @override
  State<_EconomyLab> createState() => _EconomyLabState();
}

class _EconomyLabState extends State<_EconomyLab> {
  double _rate = 4.5;
  double _tax = 24;
  double _spending = 32;
  double _tariff = 5;

  double get _gdp =>
      (3.6 + _spending * 0.08 - _tax * 0.06 - _rate * 0.22).clamp(-8, 10);
  double get _inflation =>
      (2.2 + _spending * 0.05 - _tax * 0.025 - _rate * 0.27 + _tariff * 0.04)
          .clamp(-2, 15);
  double get _unemployment => (6.1 - _gdp * 0.35).clamp(2, 20);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'National Economy Control Room',
          subtitle:
              'Role: President · Central Bank Governor · Finance Minister',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'GDP growth',
                value: '${_gdp.toStringAsFixed(1)}%',
                trend: _gdp,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Inflation',
                value: '${_inflation.toStringAsFixed(1)}%',
                trend: 2 - _inflation,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Unemployment',
                value: '${_unemployment.toStringAsFixed(1)}%',
                trend: 5 - _unemployment,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: CustomPaint(
            painter: _BusinessChartPainter(
              values: <double>[
                _gdp + 6,
                _inflation + 2,
                12 - _unemployment,
                8 - _rate,
              ],
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        _control(
          'Interest rate',
          _rate,
          0,
          15,
          '%',
          (double v) => setState(() => _rate = v),
        ),
        _control(
          'Tax rate',
          _tax,
          5,
          50,
          '%',
          (double v) => setState(() => _tax = v),
        ),
        _control(
          'Government spending',
          _spending,
          5,
          60,
          '% GDP',
          (double v) => setState(() => _spending = v),
        ),
        _control(
          'Tariff',
          _tariff,
          0,
          40,
          '%',
          (double v) => setState(() => _tariff = v),
        ),
        _ConsequenceCard(
          text:
              'AI policy brief: ${_rate > 7 ? 'Tight monetary policy is cooling prices but raising unemployment.' : 'Credit remains supportive.'} '
              '${_spending > 40 ? 'Fiscal stimulus lifts output but adds inflation pressure.' : 'Spending is contained.'} '
              'Explain the trade-off before submitting.',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _control(
    String label,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label · ${value.toStringAsFixed(1)}$unit',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _FinanceLab extends StatefulWidget {
  const _FinanceLab({required this.path});
  final BusinessLessonPath path;

  @override
  State<_FinanceLab> createState() => _FinanceLabState();
}

class _FinanceLabState extends State<_FinanceLab> {
  double _stocks = 45;
  double _bonds = 25;
  double _etfs = 20;
  double _cash = 10;
  int _day = 1;

  double get _risk => (_stocks * 0.16 + _etfs * 0.1 + _bonds * 0.035) / 10;
  double get _value {
    final double cycle = math.sin(_day / 4) * 0.025;
    return 100000 * (1 + cycle + (_stocks + _etfs) / 100 * 0.018);
  }

  @override
  Widget build(BuildContext context) {
    final double total = _stocks + _bonds + _etfs + _cash;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Wall Street Terminal',
          subtitle: 'Virtual capital · \$100,000',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Portfolio',
                value: '\$${_value.toStringAsFixed(0)}',
                trend: _value - 100000,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Risk',
                value: _risk.toStringAsFixed(1),
                trend: 7 - _risk,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Cash',
                value: '${_cash.round()}%',
                trend: _cash - 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: CustomPaint(
            painter: _BusinessChartPainter(
              values: List<double>.generate(
                12,
                (int i) => 50 + math.sin((i + _day) / 2) * 18 + i * 2,
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        _allocation(
          'Stocks',
          _stocks,
          (double v) => setState(() => _stocks = v),
        ),
        _allocation('ETFs', _etfs, (double v) => setState(() => _etfs = v)),
        _allocation('Bonds', _bonds, (double v) => setState(() => _bonds = v)),
        _allocation('Cash', _cash, (double v) => setState(() => _cash = v)),
        Text(
          'Allocation total: ${total.round()}%',
          style: TextStyle(
            color: (total - 100).abs() < 1 ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => setState(() => _day += 1),
          icon: const Icon(Icons.candlestick_chart),
          label: Text('Advance market · Day $_day'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        _ConsequenceCard(
          text:
              'Investment committee: Your portfolio is ${_risk > 8 ? 'aggressive' : 'moderate'}. '
              'Defend the allocation using return objective, volatility, liquidity, and time horizon.',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _allocation(String label, double value, ValueChanged<double> change) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Slider(value: value, min: 0, max: 80, onChanged: change),
        ),
        SizedBox(width: 38, child: Text('${value.round()}%')),
      ],
    );
  }
}

class _MarketingLab extends StatefulWidget {
  const _MarketingLab({required this.path});
  final BusinessLessonPath path;

  @override
  State<_MarketingLab> createState() => _MarketingLabState();
}

class _MarketingLabState extends State<_MarketingLab> {
  double _search = 30;
  double _social = 35;
  double _creator = 20;
  double _email = 15;
  double _price = 79;

  double get _reach => _search * 850 + _social * 1200 + _creator * 1600;
  double get _conversion =>
      (1.2 + _email * 0.08 + _creator * 0.025 - (_price - 70).abs() * 0.012)
          .clamp(0.4, 8);
  double get _roas => (_conversion * _price / 42).clamp(0.2, 8);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Global Product Launch',
          subtitle: 'Campaign budget · \$100,000',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Reach',
                value: '${(_reach / 1000).round()}K',
                trend: _reach,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Conversion',
                value: '${_conversion.toStringAsFixed(1)}%',
                trend: _conversion - 2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'ROAS',
                value: '${_roas.toStringAsFixed(1)}×',
                trend: _roas - 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _budget(
          'Search ads',
          _search,
          (double v) => setState(() => _search = v),
        ),
        _budget(
          'Social ads',
          _social,
          (double v) => setState(() => _social = v),
        ),
        _budget(
          'Creators',
          _creator,
          (double v) => setState(() => _creator = v),
        ),
        _budget(
          'Email / CRM',
          _email,
          (double v) => setState(() => _email = v),
        ),
        Text(
          'Launch price · \$${_price.round()}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _price,
          min: 29,
          max: 149,
          onChanged: (double v) => setState(() => _price = v),
        ),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _BusinessChartPainter(
              values: <double>[100, 68, 42, _conversion * 10, _roas * 7],
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const Text('Impressions → clicks → leads → purchases → retained value'),
        _ConsequenceCard(
          text:
              'CMO review: ${_social > 45 ? 'Social creates awareness, but monitor conversion quality.' : 'The mix is reasonably diversified.'} '
              'Your recommendation must connect audience, creative, channel economics, and retention.',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _budget(String label, double value, ValueChanged<double> change) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Slider(value: value, min: 0, max: 60, onChanged: change),
        ),
        SizedBox(width: 36, child: Text('${value.round()}%')),
      ],
    );
  }
}

class _AccountingLab extends StatefulWidget {
  const _AccountingLab({required this.path});
  final BusinessLessonPath path;

  @override
  State<_AccountingLab> createState() => _AccountingLabState();
}

class _AccountingLabState extends State<_AccountingLab> {
  final List<_JournalLine> _lines = <_JournalLine>[];
  String _account = 'Cash';
  bool _debit = true;
  double _amount = 1250;

  double get _debits => _lines
      .where((_JournalLine l) => l.debit)
      .fold(0, (double a, _JournalLine l) => a + l.amount);
  double get _credits => _lines
      .where((_JournalLine l) => !l.debit)
      .fold(0, (double a, _JournalLine l) => a + l.amount);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Audit & General Ledger Workbench',
          subtitle: 'Engagement: Northstar Manufacturing',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Kpi(
                label: 'Debits',
                value: '\$${_debits.toStringAsFixed(0)}',
                trend: _debits - _credits,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Credits',
                value: '\$${_credits.toStringAsFixed(0)}',
                trend: _credits - _debits,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Kpi(
                label: 'Difference',
                value: '\$${(_debits - _credits).abs().toStringAsFixed(0)}',
                trend: -(_debits - _credits).abs(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _account,
          decoration: const InputDecoration(labelText: 'Account'),
          items:
              const <String>[
                    'Cash',
                    'Accounts Receivable',
                    'Inventory',
                    'Equipment',
                    'Accounts Payable',
                    'Revenue',
                    'Expense',
                    'Equity',
                  ]
                  .map((String a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
          onChanged: (String? value) =>
              setState(() => _account = value ?? 'Cash'),
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment(value: true, label: Text('Debit')),
            ButtonSegment(value: false, label: Text('Credit')),
          ],
          selected: <bool>{_debit},
          onSelectionChanged: (Set<bool> s) => setState(() => _debit = s.first),
        ),
        const SizedBox(height: 8),
        Text(
          'Amount · \$${_amount.round()}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _amount,
          min: 50,
          max: 10000,
          divisions: 199,
          onChanged: (double v) => setState(() => _amount = v),
        ),
        FilledButton.icon(
          onPressed: () => setState(() {
            _lines.add(_JournalLine(_account, _debit, _amount));
          }),
          icon: const Icon(Icons.add),
          label: const Text('Post journal line'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Journal',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        ..._lines.map(
          (_JournalLine line) => ListTile(
            dense: true,
            title: Text(line.account),
            subtitle: Text(line.debit ? 'Debit' : 'Credit'),
            trailing: Text('\$${line.amount.toStringAsFixed(0)}'),
          ),
        ),
        if (_lines.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Post a balanced transaction. AI checks every entry.'),
          ),
        _ConsequenceCard(
          text: (_debits - _credits).abs() < 1 && _lines.isNotEmpty
              ? 'AI audit check: Entry balances. Now verify source evidence, period, and account classification.'
              : 'AI audit check: Debits must equal credits. Add the offsetting line and explain the business event.',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _JournalLine {
  const _JournalLine(this.account, this.debit, this.amount);
  final String account;
  final bool debit;
  final double amount;
}

class _CaseWorkspace extends StatefulWidget {
  const _CaseWorkspace({required this.path});
  final BusinessLessonPath path;

  @override
  State<_CaseWorkspace> createState() => _CaseWorkspaceState();
}

class _CaseWorkspaceState extends State<_CaseWorkspace> {
  final TextEditingController _response = TextEditingController();
  String? _feedback;

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: 'Executive Decision Case',
          subtitle: widget.path.lesson.title,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _card(context, Theme.of(context).colorScheme.primary),
          child: const Text(
            'Revenue is down 18%, customer acquisition costs increased 27%, and leadership has one quarter to restore confidence. The data includes conflicting signals: demand remains strong in one segment, liquidity is tightening, and a competitor has cut price.',
            style: TextStyle(height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Evidence packet',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        ...const <String>[
          'Exhibit A · Three-year KPI trend',
          'Exhibit B · Customer / market segmentation',
          'Exhibit C · Financial and operating statements',
          'Exhibit D · Management interview notes',
        ].map(
          (String e) => ListTile(
            leading: const Icon(Icons.description),
            title: Text(e),
            trailing: const Icon(Icons.open_in_new),
          ),
        ),
        TextField(
          controller: _response,
          minLines: 5,
          maxLines: 9,
          decoration: const InputDecoration(
            labelText: 'What would you do?',
            hintText:
                'Recommendation · evidence · alternatives · risks · implementation metrics',
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => setState(() {
            final String text = _response.text.trim();
            _feedback = text.length < 80
                ? 'AI case coach: Expand the reasoning. State a clear recommendation, cite at least two exhibits, compare an alternative, and define measurable next steps.'
                : 'AI case coach: Your recommendation is directionally defensible. Strengthen it by quantifying the expected impact, naming the largest assumption, and specifying a trigger that would cause management to change course.';
          }),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Submit for AI reasoning review'),
        ),
        if (_feedback != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _ConsequenceCard(
              text: _feedback!,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _AssessmentWorkspace extends StatefulWidget {
  const _AssessmentWorkspace({required this.path, required this.exam});
  final BusinessLessonPath path;
  final bool exam;

  @override
  State<_AssessmentWorkspace> createState() => _AssessmentWorkspaceState();
}

class _AssessmentWorkspaceState extends State<_AssessmentWorkspace> {
  int? _choice;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    const List<String> choices = <String>[
      'Accept the headline metric without testing assumptions',
      'Define the decision, model drivers, test scenarios, and recommend with risks',
      'Choose the option with the largest short-term number',
      'Delay the decision until uncertainty disappears',
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          widget.exam
              ? 'Comprehensive Assessment'
              : 'Homework · Applied Analysis',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Question 1 of ${widget.exam ? 20 : 8}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Which approach produces the most defensible professional recommendation?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(
          choices.length,
          (int i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _feedback == null
                    ? () => setState(() => _choice = i)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _choice == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      width: _choice == i ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        _choice == i
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _choice == i
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(choices[i])),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        FilledButton(
          onPressed: _choice == null
              ? null
              : () => setState(() {
                  _feedback = _choice == 1
                      ? 'Correct. Professional analysis is explicit about model, evidence, alternatives, assumptions, risks, and implementation.'
                      : 'Not yet. A strong answer must test assumptions and connect evidence to a decision—not rely on one headline metric.';
                }),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Check with detailed explanation'),
        ),
        if (_feedback != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_feedback!, style: const TextStyle(height: 1.45)),
          ),
      ],
    );
  }
}

class _DeliverableWorkspace extends StatefulWidget {
  const _DeliverableWorkspace({required this.path, required this.kind});
  final BusinessLessonPath path;
  final BusinessActivityKind kind;

  @override
  State<_DeliverableWorkspace> createState() => _DeliverableWorkspaceState();
}

class _DeliverableWorkspaceState extends State<_DeliverableWorkspace> {
  final TextEditingController _memo = TextEditingController();
  String? _review;
  String _placement = 'Startup Founder';

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String company = switch (widget.path.major) {
      BusinessMajor.businessAdministration =>
        'Executive Rotation · Startup / Amazon / Apple / Starbucks',
      BusinessMajor.economics => 'IMF / World Bank Policy Unit',
      BusinessMajor.finance => 'Global Investment Bank',
      BusinessMajor.marketing => 'Global Consumer Brand',
      BusinessMajor.accounting => 'Big Four Advisory',
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _LabHeader(
          title: widget.kind == BusinessActivityKind.internship
              ? 'Internship · $company'
              : widget.kind == BusinessActivityKind.capstone
              ? 'Final Capstone Boardroom'
              : 'Applied Professional Project',
          subtitle: widget.path.lesson.title,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 14),
        if (widget.kind == BusinessActivityKind.internship &&
            widget.path.major ==
                BusinessMajor.businessAdministration) ...<Widget>[
          DropdownButtonFormField<String>(
            initialValue: _placement,
            decoration: const InputDecoration(
              labelText: 'Internship placement',
            ),
            items:
                const <String>[
                      'Startup Founder',
                      'Amazon Operations Manager',
                      'Apple Product Manager',
                      'Starbucks Store Manager',
                      'Manufacturing Plant Manager',
                      'Consulting Analyst',
                      'Business Development Associate',
                    ]
                    .map(
                      (String role) => DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      ),
                    )
                    .toList(),
            onChanged: (String? value) =>
                setState(() => _placement = value ?? _placement),
          ),
          const SizedBox(height: 10),
          _ConsequenceCard(
            text:
                'AI internship manager: You are the $_placement. Your assignment is adapted to this role, and your work will be reviewed for analysis, communication, execution, and professional judgment.',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
        ],
        const Text(
          'Your brief',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 6),
        Text(
          'Analyze the situation using course models. Produce an executive-ready recommendation with quantified impact, alternatives, risks, and a 90-day implementation plan.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        ...<String>[
          'Build the relevant model / dashboard',
          'Identify the three most important drivers',
          'Compare at least two alternatives',
          'Recommend and quantify expected impact',
          'Define risks, controls, and success metrics',
        ].map(
          (String task) => CheckboxListTile(
            value: false,
            onChanged: (_) {},
            title: Text(task),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        TextField(
          controller: _memo,
          minLines: 7,
          maxLines: 12,
          decoration: const InputDecoration(
            labelText: 'Executive memo / report',
            hintText:
                'To · From · Subject · Recommendation · Analysis · Risks · Next steps',
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => setState(() {
            _review = _memo.text.trim().length < 120
                ? 'Mentor review: The deliverable is not yet board-ready. Add quantified evidence, an alternative considered, execution owners, timing, and measurable outcomes.'
                : 'Mentor review: Solid executive structure. Before final submission, stress-test your central assumption and make the first 30 days operationally specific.';
          }),
          icon: const Icon(Icons.rate_review),
          label: const Text('Submit to AI executive mentor'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (_review != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _ConsequenceCard(
              text: _review!,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _TopicCertificateCard extends StatelessWidget {
  const _TopicCertificateCard({required this.path, required this.progress});

  final BusinessLessonPath path;
  final BusinessSchoolProgressService progress;

  @override
  Widget build(BuildContext context) {
    final List<String> badges = progress.badgesForLesson(path.lesson.id);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Theme.of(context).colorScheme.primary, const Color(0xFF111827)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Topic Certificate Unlocked',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Virtual University certifies completion of ${path.lesson.title} '
            'in ${path.course.title} (${path.major.title}).',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              const Chip(
                avatar: Icon(Icons.verified, size: 16),
                label: Text('Certificate'),
                backgroundColor: Colors.white24,
                labelStyle: TextStyle(color: Colors.white),
              ),
              ...badges.map(
                (String badge) => Chip(
                  avatar: const Icon(Icons.emoji_events, size: 16),
                  label: Text(_badgeLabel(badge)),
                  backgroundColor: Colors.white24,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _badgeLabel(String id) => switch (id) {
    'lecture_complete' => 'Lecture badge',
    'whiteboard_complete' => 'Whiteboard badge',
    'homework_complete' => 'Homework badge',
    'exam_complete' => 'Exam badge',
    'topic_master' => 'Topic Master badge',
    _ => id,
  };
}

class _MajorHero extends StatelessWidget {
  const _MajorHero({required this.major, required this.xp});
  final BusinessMajor major;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Theme.of(context).colorScheme.primary, const Color(0xFF111827)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Text(major.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  major.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  major.tagline,
                  style: const TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
          Text(
            '$xp XP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.major,
    required this.course,
    required this.progress,
    required this.onTap,
  });
  final BusinessMajor major;
  final BusinessCourse course;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(15),
        decoration: _card(context),
        child: Row(
          children: <Widget>[
            Text(course.emoji, style: const TextStyle(fontSize: 31)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    course.code,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${(progress * 100).round()}%'),
          ],
        ),
      ),
    ),
  );
}

class _LabHeader extends StatelessWidget {
  const _LabHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: <Color>[color, const Color(0xFF111827)]),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.trend});
  final String label;
  final String value;
  final double trend;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: _card(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        Text(
          trend >= 0 ? '▲ ${trend.abs()}' : '▼ ${trend.abs()}',
          style: TextStyle(
            color: trend >= 0 ? Colors.green : Colors.redAccent,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _ConsequenceCard extends StatelessWidget {
  const _ConsequenceCard({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(15),
    decoration: _card(context, color),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.smart_toy, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
      ],
    ),
  );
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(height: 1.55)),
      ],
    ),
  );
}

class _NoteListSection extends StatelessWidget {
  const _NoteListSection({
    required this.title,
    required this.items,
    required this.accent,
    this.callout = false,
  });

  final String title;
  final List<String> items;
  final Color accent;
  final bool callout;

  @override
  Widget build(BuildContext context) {
    final Widget list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    callout ? 'ƒ' : '•',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.45)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 8),
          if (callout)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: list,
            )
          else
            list,
        ],
      ),
    );
  }
}

class _BusinessChartPainter extends CustomPainter {
  _BusinessChartPainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.length < 2) return;
    final double minV = values.reduce(math.min);
    final double maxV = values.reduce(math.max);
    final double range = math.max(1, maxV - minV);
    final Path path = Path();
    for (var i = 0; i < values.length; i++) {
      final double x = size.width * i / (values.length - 1);
      final double y =
          size.height - ((values[i] - minV) / range) * size.height * 0.85 - 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BusinessChartPainter oldDelegate) => true;
}

BoxDecoration _card(BuildContext context, [Color? border]) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: (border ?? Theme.of(context).colorScheme.outline).withValues(
      alpha: 0.35,
    ),
  ),
);

void _openLesson(BuildContext context, BusinessLessonPath path) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BusinessLessonHubScreen(path: path),
    ),
  );
}
