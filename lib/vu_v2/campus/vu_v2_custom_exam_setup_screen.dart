import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_mixed_quiz.dart';
import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_semester_exam_screen.dart';

/// After picking a course: choose topics → start quiz or timed exam.
class VuV2CustomExamSetupScreen extends StatefulWidget {
  const VuV2CustomExamSetupScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;

  @override
  State<VuV2CustomExamSetupScreen> createState() =>
      _VuV2CustomExamSetupScreenState();
}

class _VuV2CustomExamSetupScreenState extends State<VuV2CustomExamSetupScreen> {
  final Set<String> _selected = <String>{};
  bool _examMode = true;

  List<VuV2RoadmapLesson> get _lessons => widget.course.allLessons;

  @override
  void initState() {
    super.initState();
    // Pre-select first 5 topics so users can start quickly.
    for (final VuV2RoadmapLesson l in _lessons.take(5)) {
      _selected.add(l.id);
    }
  }

  void _toggle(String id) {
    setState(() {
      if (!_selected.add(id)) _selected.remove(id);
    });
  }

  void _selectAll() {
    setState(() {
      _selected
        ..clear()
        ..addAll(_lessons.map((VuV2RoadmapLesson l) => l.id));
    });
  }

  void _clear() => setState(_selected.clear);

  List<String> get _selectedTitles => _lessons
      .where((VuV2RoadmapLesson l) => _selected.contains(l.id))
      .map((VuV2RoadmapLesson l) => l.title)
      .toList();

  Future<void> _start() async {
    final List<String> titles = _selectedTitles;
    if (titles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one topic.')),
      );
      return;
    }

    final List<VuV2Mcq> questions;
    if (_examMode) {
      final VuV2ExamPackage pack = VuV2TopicContent.courseExam(
        subjectId: widget.subjectId,
        facultyTitle: widget.facultyTitle,
        courseTitle: widget.course.title,
        lessonTitles: titles,
        count: (titles.length * 3).clamp(10, 24),
      );
      questions = VuV2MixedQuiz.enrich(pack.questions);
    } else {
      final List<VuV2Mcq> built = <VuV2Mcq>[];
      for (final String topic in titles.take(8)) {
        built.addAll(
          VuV2TopicContent.topicQuiz(
            subjectId: widget.subjectId,
            facultyTitle: widget.facultyTitle,
            courseTitle: widget.course.title,
            topicTitle: topic,
            count: 3,
          ),
        );
      }
      questions = VuV2MixedQuiz.enrich(built.take(16).toList());
    }

    if (!mounted) return;

    if (_examMode) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => VuV2SemesterExamScreen(
            progress: widget.progress,
            title: '${widget.course.title} exam',
            subtitle:
                '${titles.length} topics · timed · pass ≥70%',
            questions: questions,
            studentName: widget.session.displayName,
            courseId: '${widget.subjectId}_${widget.course.id}_custom',
            courseTitle: widget.course.title,
            minutes: (questions.length * 0.9).ceil().clamp(10, 30),
          ),
        ),
      );
    } else {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => VuV2SemesterExamScreen(
            progress: widget.progress,
            title: '${widget.course.title} quiz',
            subtitle: '${titles.length} topics · practice',
            questions: questions,
            studentName: widget.session.displayName,
            courseId: '${widget.subjectId}_${widget.course.id}_quiz',
            courseTitle: widget.course.title,
            minutes: (questions.length * 0.7).ceil().clamp(8, 20),
            passPercent: 60,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        title: Text(widget.course.title),
        backgroundColor: VuV2Colors.navy,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: <Widget>[
                Text(
                  '${widget.facultyEmoji} ${widget.facultyTitle}',
                  style: const TextStyle(
                    color: VuV2Colors.mute,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select topics',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your exam questions are generated from the topics you check.',
                  style: TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    TextButton(onPressed: _selectAll, child: const Text('Select all')),
                    TextButton(onPressed: _clear, child: const Text('Clear')),
                    const Spacer(),
                    Text(
                      '${_selected.length} / ${_lessons.length}',
                      style: TextStyle(
                        color: VuV2Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._lessons.map((VuV2RoadmapLesson l) {
                  final bool on = _selected.contains(l.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: VuV2Colors.navyElevated,
                      borderRadius: BorderRadius.circular(VuV2Radii.md),
                      child: CheckboxListTile(
                        value: on,
                        onChanged: (_) => _toggle(l.id),
                        activeColor: VuV2Colors.orange,
                        checkColor: Colors.black,
                        title: Text(
                          l.title,
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: l.subtitle == null
                            ? null
                            : Text(
                                l.subtitle!,
                                style: const TextStyle(
                                  color: VuV2Colors.mute,
                                  fontSize: 12,
                                ),
                              ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  'Mode',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ModeChip(
                        label: 'Practice quiz',
                        selected: !_examMode,
                        onTap: () => setState(() => _examMode = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(
                        label: 'Timed exam',
                        selected: _examMode,
                        onTap: () => setState(() => _examMode = true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: VuV2PrimaryButton(
                label: _examMode ? 'Start exam' : 'Start quiz',
                icon: Icons.play_arrow_rounded,
                onPressed: _selected.isEmpty ? null : _start,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? VuV2Colors.orange.withValues(alpha: 0.18)
          : VuV2Colors.navyElevated,
      borderRadius: BorderRadius.circular(VuV2Radii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VuV2Radii.md),
            border: Border.all(
              color: selected ? VuV2Colors.orange : VuV2Colors.stroke,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? VuV2Colors.orange : VuV2Colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
