import 'package:flutter/material.dart';

import '../data/vu_v2_degree_catalog.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';
import '../learn/vu_v2_lesson_learn_hub_screen.dart';

class VuV2SearchScreen extends StatefulWidget {
  const VuV2SearchScreen({
    super.key,
    required this.session,
    this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore? progress;

  @override
  State<VuV2SearchScreen> createState() => _VuV2SearchScreenState();
}

class _VuV2SearchScreenState extends State<VuV2SearchScreen> {
  String _query = '';

  List<_Hit> get _hits {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <_Hit>[];
    final List<_Hit> out = <_Hit>[];

    for (final VuV2DegreeDef d in VuV2DegreeCatalog.degrees) {
      if (d.title.toLowerCase().contains(q) || d.blurb.toLowerCase().contains(q)) {
        out.add(_Hit(
          kind: 'Degree',
          title: d.title,
          subtitle: d.blurb,
          onOpen: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => VuV2DegreeRoadmapScreen(
                  session: widget.session,
                  subjectId: d.roadmapSubjectId,
                  progress: widget.progress,
                ),
              ),
            );
          },
        ));
      }
    }

    for (final VuV2DegreeRoadmap roadmap in VuV2RoadmapSync.allFaculties()) {
      for (final VuV2RoadmapTrack track in roadmap.tracks) {
        for (final VuV2RoadmapCourse course in track.courses) {
          if (course.title.toLowerCase().contains(q)) {
            out.add(_Hit(
              kind: 'Course',
              title: course.title,
              subtitle: '${roadmap.title} · ${track.title}',
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VuV2DegreeRoadmapScreen(
                      session: widget.session,
                      subjectId: roadmap.subjectId,
                      progress: widget.progress,
                    ),
                  ),
                );
              },
            ));
          }
          for (final VuV2RoadmapLesson lesson in course.allLessons) {
            if (lesson.title.toLowerCase().contains(q) ||
                (lesson.subtitle?.toLowerCase().contains(q) ?? false)) {
              out.add(_Hit(
                kind: 'Lesson',
                title: lesson.title,
                subtitle: '${roadmap.title} · ${course.title}',
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VuV2LessonLearnHubScreen(
                        session: widget.session,
                        progress: widget.progress,
                        subjectId: roadmap.subjectId,
                        facultyTitle: roadmap.title,
                        facultyEmoji: roadmap.emoji,
                        trackTitle: track.title,
                        courseTitle: course.title,
                        lesson: lesson,
                      ),
                    ),
                  );
                },
              ));
            }
          }
        }
      }
    }

    return out.take(40).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<_Hit> hits = _hits;
    return Scaffold(
      appBar: AppBar(title: const Text('Search campus')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              style: TextStyle(color: VuV2Colors.ink),
              decoration: InputDecoration(
                hintText: 'Degrees, courses, lessons, notes…',
                hintStyle: TextStyle(color: VuV2Colors.mute),
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (String v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? const VuV2EmptyState(
                    title: 'Search the university',
                    subtitle:
                        'Find degrees, courses, lessons, and note topics instantly.',
                  )
                : hits.isEmpty
                    ? const VuV2EmptyState(
                        title: 'No matches',
                        subtitle: 'Try another keyword.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        itemCount: hits.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int i) {
                          final _Hit h = hits[i];
                          return Material(
                            color: VuV2Colors.navyElevated,
                            borderRadius: BorderRadius.circular(VuV2Radii.lg),
                            child: ListTile(
                              title: Text(
                                h.title,
                                style: TextStyle(
                                  color: VuV2Colors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                '${h.kind} · ${h.subtitle}',
                                style: TextStyle(color: VuV2Colors.mute),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: h.onOpen,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Hit {
  const _Hit({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  final String kind;
  final String title;
  final String subtitle;
  final VoidCallback onOpen;
}
