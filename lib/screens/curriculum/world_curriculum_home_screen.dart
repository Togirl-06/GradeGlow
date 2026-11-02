import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/world_curriculum_catalog.dart';
import '../../models/world_curriculum_program.dart';
import '../../services/world_curriculum_progress_service.dart';
import '../../widgets/virtual_university/vu_subject_layout.dart';
import 'world_curriculum_course_screen.dart';
import 'world_curriculum_lesson_hub_screen.dart';

/// Economics-style course list for any world-curriculum subject.
class WorldCurriculumHomeScreen extends StatefulWidget {
  const WorldCurriculumHomeScreen({super.key, required this.meta});

  final WorldSubjectMeta meta;

  @override
  State<WorldCurriculumHomeScreen> createState() =>
      _WorldCurriculumHomeScreenState();
}

class _WorldCurriculumHomeScreenState extends State<WorldCurriculumHomeScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<WorldCurriculumProgressService>().load();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WorldSubjectMeta meta = widget.meta;
    final List<WorldCourse> courses =
        WorldCurriculumCatalog.coursesFor(meta.subjectId);
    final List<WorldLessonPath> results =
        WorldCurriculumCatalog.search(meta.subjectId, _query);
    final int totalTopics = WorldCurriculumCatalog.topicCount(meta.subjectId);

    WorldCurriculumProgressService? progress;
    try {
      progress = context.watch<WorldCurriculumProgressService>();
    } catch (_) {
      progress = null;
    }

    return VuSubjectPage(
      title: meta.title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          VuSubjectHero(
            emoji: meta.emoji,
            title: meta.title,
            subtitle: meta.tagline,
            footer: progress == null
                ? '${courses.length} courses · $totalTopics topics worldwide'
                : '${courses.length} courses · $totalTopics topics · ${progress.xp} XP',
          ),
          const SizedBox(height: 16),
          VuSubjectSearchField(
            controller: _search,
            hint: 'Search ${meta.title} courses and topics…',
          ),
          if (_query.trim().isEmpty) ...<Widget>[
            const SizedBox(height: 20),
            const VuSubjectSectionTitle('All Courses'),
            const SizedBox(height: 10),
            ...courses.asMap().entries.map((MapEntry<int, WorldCourse> entry) {
              final int index = entry.key;
              final WorldCourse course = entry.value;
              return VuSubjectListCard(
                title: course.title,
                subtitle: '${course.topics.length} topics',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WorldCurriculumCourseScreen(
                        meta: meta,
                        course: course,
                        courseIndex: index,
                      ),
                    ),
                  );
                },
              );
            }),
          ] else ...<Widget>[
            const SizedBox(height: 20),
            VuSubjectSectionTitle('${results.length} results'),
            const SizedBox(height: 10),
            ...results.map((WorldLessonPath path) {
              return VuSubjectListCard(
                title: path.topic.title,
                subtitle: path.course.title,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WorldCurriculumLessonHubScreen(
                        meta: meta,
                        path: path,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}
