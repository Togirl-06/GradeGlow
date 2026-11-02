import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/health_faculty_catalog.dart';
import '../../models/health_faculty_program.dart';
import '../../services/health_faculty_progress_service.dart';
import '../../widgets/virtual_university/vu_subject_layout.dart';
import 'health_course_screen.dart';
import 'health_lesson_hub_screen.dart';

/// Faculty hub for Nursing, Medicine, or Psychology.
class HealthFacultyHomeScreen extends StatefulWidget {
  const HealthFacultyHomeScreen({super.key, required this.faculty});

  final HealthFaculty faculty;

  @override
  State<HealthFacultyHomeScreen> createState() =>
      _HealthFacultyHomeScreenState();
}

class _HealthFacultyHomeScreenState extends State<HealthFacultyHomeScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<HealthFacultyProgressService>().load();
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
    final HealthFaculty faculty = widget.faculty;
    final List<HealthCourse> courses = HealthFacultyCatalog.coursesFor(faculty);
    final List<HealthLessonPath> results = HealthFacultyCatalog.search(
      faculty,
      _query,
    );
    final int topicCount = courses.fold<int>(
      0,
      (int n, HealthCourse c) => n + c.topics.length,
    );

    HealthFacultyProgressService? progress;
    try {
      progress = context.watch<HealthFacultyProgressService>();
    } catch (_) {
      progress = null;
    }

    return VuSubjectPage(
      title: faculty.title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          VuSubjectHero(
            emoji: faculty.emoji,
            title: faculty.title,
            subtitle: faculty.tagline,
            footer: progress == null
                ? '${courses.length} courses · $topicCount topics'
                : '${courses.length} courses · $topicCount topics · ${progress.xp} XP',
          ),
          const SizedBox(height: 16),
          VuSubjectSearchField(
            controller: _search,
            hint: 'Search ${faculty.title} courses and topics…',
          ),
          if (_query.trim().isEmpty) ...<Widget>[
            const SizedBox(height: 20),
            const VuSubjectSectionTitle('All Courses'),
            const SizedBox(height: 10),
            ...courses.asMap().entries.map((MapEntry<int, HealthCourse> entry) {
              final int index = entry.key;
              final HealthCourse course = entry.value;
              return VuSubjectListCard(
                title: course.title,
                subtitle: '${course.topics.length} topics',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HealthCourseScreen(
                        faculty: faculty,
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
            ...results.map((HealthLessonPath path) {
              return VuSubjectListCard(
                title: path.topic.title,
                subtitle: path.course.title,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HealthLessonHubScreen(path: path),
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
