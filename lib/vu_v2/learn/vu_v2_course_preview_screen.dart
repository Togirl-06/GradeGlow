import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/practice_lab_subject.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../services/openai_service.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// V2 course home preview — new classroom chrome for a catalog subject.
class VuV2CoursePreviewScreen extends StatefulWidget {
  const VuV2CoursePreviewScreen({
    super.key,
    required this.session,
    required this.subject,
  });

  final VuV2Session session;
  final PracticeLabSubject subject;

  @override
  State<VuV2CoursePreviewScreen> createState() =>
      _VuV2CoursePreviewScreenState();
}

class _VuV2CoursePreviewScreenState extends State<VuV2CoursePreviewScreen> {
  int _tab = 0;

  PracticeLabSubject get subject => widget.subject;

  @override
  Widget build(BuildContext context) {
    final String courseTitle = subject.courses.isNotEmpty
        ? subject.courses.first.name
        : subject.name;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: <Widget>[
          _CourseHome(
            subject: subject,
            courseTitle: courseTitle,
            session: widget.session,
          ),
          _ModulesPane(subject: subject, courseTitle: courseTitle),
          const _SimplePane(
            title: 'Progress',
            body:
                'Mastery, XP, and weak topics will live here as you complete lessons.',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (int i) => setState(() => _tab = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_module_outlined),
            selectedIcon: Icon(Icons.view_module_rounded),
            label: 'Modules',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

class _CourseHome extends StatelessWidget {
  const _CourseHome({
    required this.subject,
    required this.courseTitle,
    required this.session,
  });

  final PracticeLabSubject subject;
  final String courseTitle;
  final VuV2Session session;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              courseTitle,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    VuV2Colors.orange.withValues(alpha: 0.9),
                    VuV2Colors.navy,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(subject.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Professor · ${subject.name}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Text(
                'Welcome to your digital classroom. Lessons include AI lecture, practice, and checks — not passive reading.',
                style: TextStyle(color: VuV2Colors.mute, height: 1.45),
              ),
              const SizedBox(height: 16),
              VuV2Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '8% Complete',
                      style: TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const VuV2ProgressBar(value: 0.08),
                    const SizedBox(height: 10),
                    Text(
                      'Module 1 of ${subject.courses.length.clamp(1, 12)} · Grade —',
                      style: const TextStyle(color: VuV2Colors.mute),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              VuV2PrimaryButton(
                label: 'Start AI Professor lecture',
                icon: Icons.school_rounded,
                onPressed: () async {
                  await session.setContinue(
                    title: 'AI Professor · $courseTitle',
                    subtitle: subject.name,
                    progress: 0.15,
                  );
                  if (!context.mounted) return;
                  final OpenAiService openAi = context.read<OpenAiService>();
                  await Navigator.of(context).push(
                    MaterialPageRoute<bool>(
                      builder: (_) => AiProfessorClassroomScreen(
                        openAi: openAi,
                        lessonId: '${subject.id}_preview',
                        lessonTitle: courseTitle,
                        courseId: subject.id,
                        courseTitle: courseTitle,
                        moduleTitle: 'Orientation',
                        faculty: subject.id,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const VuV2SectionTitle('Upcoming'),
              const SizedBox(height: 8),
              const _Line(
                title: 'Knowledge check',
                subtitle: 'After orientation lecture',
              ),
              const _Line(
                title: 'Practice lab',
                subtitle: 'This week',
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ModulesPane extends StatelessWidget {
  const _ModulesPane({required this.subject, required this.courseTitle});

  final PracticeLabSubject subject;
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    final List<String> modules = subject.courses.isEmpty
        ? <String>['Module 1 · Foundations']
        : subject.courses
              .take(6)
              .map((c) => c.name)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Modules')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: modules.length,
        itemBuilder: (BuildContext context, int i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: VuV2Surface(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: VuV2Colors.orange.withValues(alpha: 0.2),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: VuV2Colors.orange,
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
                          modules[i],
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          i == 0 ? 'In progress' : 'Locked until Module $i complete',
                          style: const TextStyle(
                            color: VuV2Colors.mute,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SimplePane extends StatelessWidget {
  const _SimplePane({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: VuV2EmptyState(title: title, subtitle: body),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.event_outlined, color: VuV2Colors.orange),
      title: Text(
        title,
        style: const TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: VuV2Colors.mute)),
    );
  }
}

class _LessonStage extends StatelessWidget {
  const _LessonStage({
    required this.subjectName,
    required this.courseTitle,
    required this.emoji,
  });

  final String subjectName;
  final String courseTitle;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(courseTitle)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: VuV2Colors.orange,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: VuV2Colors.navyElevated,
            showDragHandle: true,
            builder: (_) => const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Text(
                'Ask AI Tutor\n\n“Explain again”, “Give an example”, or “Quiz me” — full tutoring wires in the next slice. Context: this lesson is already attached.',
                style: TextStyle(color: VuV2Colors.ink, height: 1.45),
              ),
            ),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI Tutor'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: <Widget>[
          VuV2Surface(
            child: Row(
              children: <Widget>[
                Text(emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'AI Professor',
                        style: TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subjectName,
                        style: const TextStyle(color: VuV2Colors.mute),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const VuV2SectionTitle('Learning goals'),
          const SizedBox(height: 8),
          const Text(
            '1. Understand the core idea for this orientation lesson.\n'
            '2. See a worked example.\n'
            '3. Pass a short knowledge check.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
          const SizedBox(height: 16),
          const VuV2SectionTitle('Lecture'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Text(
              'Welcome to $courseTitle in the GradeGlow Virtual University.\n\n'
              'In this classroom you learn by doing: listen to your AI Professor, '
              'practice with interactive work, then prove mastery on a check.\n\n'
              'This is the new V2 lesson stage — live streaming lectures and '
              'faculty simulations connect in the next build slices.',
              style: const TextStyle(color: VuV2Colors.ink, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          VuV2PrimaryButton(
            label: 'Mark orientation complete',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
