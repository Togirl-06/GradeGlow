import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../../models/cs_curriculum.dart';
import '../../services/cs_curriculum_progress_service.dart';
import '../../theme/cs_hybrid_theme.dart';
import 'cs_professor_lecture_screen.dart';

/// One language track: beginner → intermediate → advanced lessons.
class CsLanguageTrackScreen extends StatefulWidget {
  const CsLanguageTrackScreen({super.key, required this.languageId});

  final String languageId;

  @override
  State<CsLanguageTrackScreen> createState() => _CsLanguageTrackScreenState();
}

class _CsLanguageTrackScreenState extends State<CsLanguageTrackScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CsCurriculumProgressService>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlgorithms = widget.languageId == 'algorithms';
    final CsCurriculumLanguage? lang = CsCurriculumCatalog.languageById(widget.languageId);
    final String title = isAlgorithms ? 'Problem Solving & Algorithms' : (lang?.label ?? 'Track');
    final CsCurriculumProgressService progress = context.watch<CsCurriculumProgressService>();

    if (!isAlgorithms && lang == null) {
      return Scaffold(appBar: AppBar(title: const Text('Track')), body: const Center(child: Text('Track not found')));
    }

    final List<CsCurriculumTopic> topics = isAlgorithms
        ? CsCurriculumCatalog.algorithmsTopics
            .map(
              (CsAlgorithmsTopic t) => CsCurriculumTopic(
                id: t.id,
                languageId: 'algorithms',
                title: t.title,
                order: t.order,
                level: t.level,
              ),
            )
            .toList()
        : CsCurriculumCatalog.topicsForLanguage(widget.languageId);

    return Scaffold(
      backgroundColor: CsHybridTheme.background,
      appBar: AppBar(
        backgroundColor: CsHybridTheme.primary,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          for (final CsCurriculumLevel level in CsCurriculumLevel.values)
            _LevelSection(
              level: level,
              topics: topics.where((CsCurriculumTopic t) => t.level == level).toList(),
              progress: progress,
              languageId: widget.languageId,
              courseName: title,
            ),
        ],
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.level,
    required this.topics,
    required this.progress,
    required this.languageId,
    required this.courseName,
  });

  final CsCurriculumLevel level;
  final List<CsCurriculumTopic> topics;
  final CsCurriculumProgressService progress;
  final String languageId;
  final String courseName;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            level.label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary, letterSpacing: 0.6),
          ),
          const SizedBox(height: 8),
          for (final CsCurriculumTopic topic in topics)
            _TopicRow(
              topic: topic,
              completed: progress.isCompleted(topic.id),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CsProfessorLectureScreen(
                    topicTitle: topic.title,
                    courseName: courseName,
                    curriculumTopicId: topic.id,
                    curriculumLanguageId: languageId,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.completed,
    required this.onTap,
  });

  final CsCurriculumTopic topic;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CsHybridTheme.surface,
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: CsHybridTheme.border)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: completed
              ? CsHybridTheme.primary.withValues(alpha: 0.15)
              : CsHybridTheme.background,
          child: Icon(
            completed ? Icons.check_rounded : Icons.school_outlined,
            size: 18,
            color: CsHybridTheme.primary,
          ),
        ),
        title: Text(
          topic.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: CsHybridTheme.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: CsHybridTheme.textSecondary),
      ),
    );
  }
}
