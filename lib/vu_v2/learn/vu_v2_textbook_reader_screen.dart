import 'package:flutter/material.dart';

import '../../data/university_learning_engine.dart';
import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_rich_text.dart';
import '../design/vu_v2_theme.dart';
import '../labs/engine/laboratory_engine.dart';

/// Full textbook chapter reader — long-form notes, not slide cards.
class VuV2TextbookReaderScreen extends StatefulWidget {
  const VuV2TextbookReaderScreen({
    super.key,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.courseTitle,
    required this.topicTitle,
    this.topicSubtitle,
  });

  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final String courseTitle;
  final String topicTitle;
  final String? topicSubtitle;

  @override
  State<VuV2TextbookReaderScreen> createState() =>
      _VuV2TextbookReaderScreenState();
}

class _VuV2TextbookReaderScreenState extends State<VuV2TextbookReaderScreen> {
  VuV2TopicPackage? _pack;
  bool _loading = true;
  String? _error;
  int? _jumpIndex;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final VuV2TopicPackage pack = VuV2TopicContent.forLesson(
        subjectId: widget.subjectId,
        facultyTitle: widget.facultyTitle,
        facultyEmoji: widget.facultyEmoji,
        trackTitle: widget.trackTitle,
        courseTitle: widget.courseTitle,
        topicTitle: widget.topicTitle,
        topicSubtitle: widget.topicSubtitle,
        interactive: false,
      );
      if (!mounted) return;
      setState(() {
        _pack = pack;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  void _showToc(VuV2TopicPackage pack) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VuV2Colors.navyElevated,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pack.sections.length,
            itemBuilder: (BuildContext context, int i) {
              return ListTile(
                leading: Text(
                  '${i + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    color: VuV2Colors.mint,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                title: Text(
                  pack.sections[i].title,
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _jumpIndex = i);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Textbook chapter')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(color: VuV2Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Opening textbook chapter…',
                style: TextStyle(color: VuV2Colors.mute),
              ),
            ],
          ),
        ),
      );
    }

    final VuV2TopicPackage? pack = _pack;
    if (pack == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Textbook chapter')),
        body: VuV2EmptyState(
          title: 'Chapter unavailable',
          subtitle: _error ?? 'Try this lesson again.',
          actionLabel: 'Close',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final List<VuV2TextbookSection> sections = pack.sections;
    final int highlight = _jumpIndex ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1018),
      appBar: AppBar(
        title: const Text('Textbook chapter'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Table of contents',
            onPressed: () => _showToc(pack),
            icon: const Icon(Icons.list_alt_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: sections.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _Cover(
              emoji: widget.facultyEmoji,
              faculty: pack.facultyTitle,
              course: pack.courseTitle,
              track: pack.trackTitle,
              title: pack.topicTitle,
              subtitle: widget.topicSubtitle,
              readingTime: pack.readingTimeLabel,
              chapterCount: sections.length,
            );
          }
          if (index == sections.length + 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: <Widget>[
                  VuV2PrimaryButton(
                    label: 'Apply this chapter in the laboratory',
                    icon: Icons.science_outlined,
                    onPressed: () {
                      final UniversityLabLink link = UniversityLearningEngine.labForLesson(
                            subjectId: widget.subjectId,
                            lessonTitle: widget.topicTitle,
                            moduleTitle: widget.courseTitle,
                          ) ??
                          UniversityLabLink(
                            labId: widget.subjectId,
                            stationId: 'engine',
                            title: widget.topicTitle,
                            purpose: 'Apply the chapter on the interactive workspace.',
                            objectives: const <String>['Perform the work'],
                          );
                      LaboratoryEngine.open(
                        context: context,
                        link: link,
                        subjectId: widget.subjectId,
                        courseTitle: widget.courseTitle,
                        topicTitle: widget.topicTitle,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  VuV2PrimaryButton(
                    label: 'Mark chapter complete',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
          }
          final int i = index - 1;
          final VuV2TextbookSection section = sections[i];
          return _ChapterSection(
            number: i + 1,
            section: section,
            highlighted: i == highlight,
          );
        },
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.emoji,
    required this.faculty,
    required this.course,
    required this.track,
    required this.title,
    required this.readingTime,
    required this.chapterCount,
    this.subtitle,
  });

  final String emoji;
  final String faculty;
  final String course;
  final String track;
  final String title;
  final String? subtitle;
  final String readingTime;
  final int chapterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VuV2Radii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF122033),
            Color(0xFF0E3A32),
            Color(0xFF1A2744),
          ],
        ),
        border: Border.all(color: VuV2Colors.mint.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$emoji  $faculty',
            style: TextStyle(
              color: VuV2Colors.mint,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.toUpperCase(),
            style: TextStyle(
              color: VuV2Colors.mute,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.2,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(color: VuV2Colors.mute, height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaChip(icon: Icons.menu_book_rounded, label: '$chapterCount sections'),
              _MetaChip(icon: Icons.schedule_rounded, label: readingTime),
              _MetaChip(icon: Icons.account_balance_rounded, label: track),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Read this like a required textbook chapter: definitions, mechanisms, '
            'worked examples, then retrieval. Do not skim the headings.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.45, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: VuV2Colors.mint),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.number,
    required this.section,
    required this.highlighted,
  });

  final int number;
  final VuV2TextbookSection section;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141C28),
        borderRadius: BorderRadius.circular(VuV2Radii.lg),
        border: Border.all(
          color: highlighted
              ? VuV2Colors.mint.withValues(alpha: 0.55)
              : VuV2Colors.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '§$number',
            style: TextStyle(
              color: VuV2Colors.mint,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.title,
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          VuV2RichTeachBody(
            text: section.body,
            accent: VuV2Colors.mint,
            fontSize: 16,
            height: 1.65,
          ),
        ],
      ),
    );
  }
}
