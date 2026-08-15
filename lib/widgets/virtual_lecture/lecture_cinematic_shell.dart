import 'package:flutter/material.dart';

import '../../data/virtual_lecture_outline.dart';
import '../../theme/study_theme.dart';

/// Cream academic lecture layout: CONTENTS sidebar, lecture hero, Khan-style video stage.
class LectureCinematicShell extends StatelessWidget {
  const LectureCinematicShell({
    super.key,
    required this.lessonTitle,
    required this.courseTitle,
    required this.moduleTitle,
    required this.faculty,
    required this.preparing,
    required this.chapters,
    required this.activeChapterIndex,
    required this.onSelectChapter,
    required this.onBack,
    required this.onEndLesson,
    required this.elapsedLabel,
    required this.stage,
    required this.controls,
    this.blurb,
    this.prerequisites = const <String>[],
    this.askOverlay,
    this.checkOverlay,
    this.belowStage,
  });

  final String lessonTitle;
  final String courseTitle;
  final String moduleTitle;
  final String faculty;
  final bool preparing;
  final List<LectureOutlineChapter> chapters;
  final int activeChapterIndex;
  final ValueChanged<int> onSelectChapter;
  final VoidCallback onBack;
  final VoidCallback onEndLesson;
  final String elapsedLabel;
  final Widget stage;
  final Widget controls;
  final String? blurb;
  final List<String> prerequisites;
  final Widget? askOverlay;
  final Widget? checkOverlay;
  final Widget? belowStage;

  static const Color cream = Color(0xFFF5F1EA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0F172A);
  static const Color mute = Color(0xFF64748B);
  static const Color stageNavy = Color(0xFF0B1220);
  static const Color line = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final Color accent = StudyColors.primary;
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(
              courseTitle: courseTitle,
              elapsedLabel: elapsedLabel,
              accent: accent,
              onBack: onBack,
              onEnd: onEndLesson,
            ),
            Expanded(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          width: 280,
                          child: _ContentsPane(
                            chapters: chapters,
                            activeIndex: activeChapterIndex,
                            accent: accent,
                            onSelect: onSelectChapter,
                          ),
                        ),
                        Expanded(child: _mainColumn(accent)),
                      ],
                    )
                  : _mainColumn(accent, showContentsInline: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainColumn(Color accent, {bool showContentsInline = false}) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _LectureHero(
                lessonTitle: lessonTitle,
                moduleTitle: moduleTitle,
                accent: accent,
                blurb: blurb ??
                    'This lecture provides a rigorous foundation for $lessonTitle.',
                prerequisites: prerequisites,
                compact: true,
              ),
            ),
            if (showContentsInline)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _ContentsPane(
                  chapters: chapters,
                  activeIndex: activeChapterIndex,
                  accent: accent,
                  onSelect: onSelectChapter,
                  compact: true,
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: const Color(0xFF0B1220),
                    child: preparing ? _PreparingPanel(accent: accent) : stage,
                  ),
                ),
              ),
            ),
            if (!preparing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: <Widget>[
                    controls,
                    if (belowStage != null) ...<Widget>[
                      const SizedBox(height: 8),
                      belowStage!,
                    ],
                  ],
                ),
              ),
          ],
        ),
        ?askOverlay,
        ?checkOverlay,
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.courseTitle,
    required this.elapsedLabel,
    required this.accent,
    required this.onBack,
    required this.onEnd,
  });

  final String courseTitle;
  final String elapsedLabel;
  final Color accent;
  final VoidCallback onBack;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: LectureCinematicShell.ink,
            ),
          ),
          Expanded(
            child: Text(
              courseTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LectureCinematicShell.ink,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            elapsedLabel,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onEnd,
            child: Text(
              'End',
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentsPane extends StatelessWidget {
  const _ContentsPane({
    required this.chapters,
    required this.activeIndex,
    required this.accent,
    required this.onSelect,
    this.compact = false,
  });

  final List<LectureOutlineChapter> chapters;
  final int activeIndex;
  final Color accent;
  final ValueChanged<int> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 0 : 12, 8, compact ? 0 : 0, 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: LectureCinematicShell.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LectureCinematicShell.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'CONTENTS',
            style: TextStyle(
              color: LectureCinematicShell.mute,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          if (compact)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chapters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int i) {
                  final bool active = i == activeIndex;
                  return Material(
                    color: active
                        ? accent.withValues(alpha: 0.14)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onSelect(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? accent.withValues(alpha: 0.55)
                                : LectureCinematicShell.line,
                          ),
                        ),
                        child: Text(
                          '${i + 1}. ${chapters[i].label}',
                          style: TextStyle(
                            color: active
                                ? accent
                                : LectureCinematicShell.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (BuildContext context, int i) {
                  final bool active = i == activeIndex;
                  return Material(
                    color: active
                        ? accent.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 22,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: active
                                      ? accent
                                      : LectureCinematicShell.mute,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                chapters[i].label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: active
                                      ? accent
                                      : LectureCinematicShell.ink,
                                  fontWeight: active
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _LectureHero extends StatelessWidget {
  const _LectureHero({
    required this.lessonTitle,
    required this.moduleTitle,
    required this.accent,
    required this.blurb,
    required this.prerequisites,
    this.compact = false,
  });

  final String lessonTitle;
  final String moduleTitle;
  final Color accent;
  final String blurb;
  final List<String> prerequisites;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        color: LectureCinematicShell.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LectureCinematicShell.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.school_rounded, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                'LECTURE',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  moduleTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LectureCinematicShell.mute,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lessonTitle,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: LectureCinematicShell.ink,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 18 : 26,
              height: 1.15,
              fontFamily: 'Georgia',
            ),
          ),
          if (!compact) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              blurb,
              style: const TextStyle(
                color: LectureCinematicShell.mute,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            if (prerequisites.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              const Text(
                'Prerequisites:',
                style: TextStyle(
                  color: LectureCinematicShell.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prerequisites
                    .map(
                      (String p) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p,
                          style: const TextStyle(
                            color: LectureCinematicShell.mute,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PreparingPanel extends StatelessWidget {
  const _PreparingPanel({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: accent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'The professor is preparing the lecture...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A cinematic lecture takes about 30-60 seconds. Please keep this tab open.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
