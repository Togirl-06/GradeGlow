import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/virtual_lecture.dart';
import '../../services/lecture_diagram_service.dart';
import '../../theme/mathematics_degree_theme.dart';
import 'khan_lecture_colors.dart';
import 'lecture_math_view.dart';
import 'lecture_worked_problem_view.dart';

/// Animated digital whiteboard — strokes, graphs, and equations appear as the professor teaches.
class LectureWhiteboard extends StatefulWidget {
  const LectureWhiteboard({
    super.key,
    required this.frame,
    this.animate = true,
    this.speechProgress = 0,
    this.isSpeaking = false,
    this.khanStyle = false,
  });

  final LectureWhiteboardFrame frame;
  final bool animate;
  final double speechProgress;
  final bool isSpeaking;
  /// Yellow/white chalk on dark board (video-lecture look).
  final bool khanStyle;

  @override
  State<LectureWhiteboard> createState() => _LectureWhiteboardState();
}

class _LectureWhiteboardState extends State<LectureWhiteboard> {
  @override
  Widget build(BuildContext context) {
    final bool khan = widget.khanStyle;
    // Dark board uses fixed chalk colors — avoid Theme.of so teardown cannot
    // leave InheritedWidget dependents behind during route pops.
    final Color chalk = khan
        ? KhanLectureColors.chalkYellow
        : MathematicsDegreeTheme.of(context).primary;
    final Color ink = khan
        ? KhanLectureColors.chalkWhite
        : MathematicsDegreeTheme.of(context).textPrimary;
    final Color mute = khan
        ? KhanLectureColors.chalkMute
        : MathematicsDegreeTheme.of(context).textSecondary;
    final Color border = khan
        ? KhanLectureColors.chalkWhite.withValues(alpha: 0.22)
        : MathematicsDegreeTheme.of(context).border;

    return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: khan
                  ? const <Color>[
                      KhanLectureColors.board,
                      KhanLectureColors.boardDeep,
                    ]
                  : Theme.of(context).brightness == Brightness.dark
                      ? const <Color>[Color(0xFF1A2332), Color(0xFF0F1623)]
                      : const <Color>[Color(0xFFF8FAFC), Color(0xFFEEF2F7)],
            ),
          ),
          child: Stack(
            children: <Widget>[
              // Soft chalk wash — no grid (felt empty / unfinished).
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.2),
                      radius: 1.15,
                      colors: <Color>[
                        Colors.white.withValues(alpha: khan ? 0.035 : 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, khan ? 22 : 56, 18, khan ? 88 : 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (khan) ...<Widget>[
                      Text(
                        widget.frame.title.trim().isEmpty
                            ? 'Lecture board'
                            : widget.frame.title.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: chalk.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.2,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 1.5,
                        width: 72,
                        color: chalk.withValues(alpha: 0.45),
                      ),
                      const SizedBox(height: 14),
                    ] else ...<Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.draw_rounded, color: chalk, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.frame.title,
                              style: TextStyle(
                                color: chalk,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    Expanded(
                      child: _buildContent(
                        chalk: chalk,
                        ink: ink,
                        mute: mute,
                        border: border,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSpeaking && _drawProgress < 0.98)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment(
                      -0.85 + 1.7 * _drawProgress,
                      0.2 + 0.35 * math.sin(_drawProgress * math.pi),
                    ),
                    child: Transform.rotate(
                      angle: -0.35,
                      child: Icon(
                        Icons.edit_rounded,
                        color: chalk.withValues(alpha: 0.9),
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  double get _drawProgress {
    // Board follows voice exactly — no intro floor that races ahead of speech.
    return widget.speechProgress.clamp(0.0, 1.0);
  }

  Widget _buildContent({
    required Color chalk,
    required Color ink,
    required Color mute,
    required Color border,
  }) {
    if (widget.frame.isWorkedProblem) {
      return LectureWorkedProblemView(
        problem: widget.frame.problemStatement ?? '',
        steps: widget.frame.solutionSteps,
        progress: _drawProgress,
        answer: widget.frame.highlight,
        accent: chalk,
        textColor: ink,
      );
    }
    switch (widget.frame.kind) {
      case WhiteboardKind.diagram:
      case WhiteboardKind.graph:
      case WhiteboardKind.geometry:
        return _LectureDiagramBoard(
          frame: widget.frame,
          chalk: chalk,
          ink: ink,
          mute: mute,
          progress: _drawProgress,
        );
      case WhiteboardKind.equation:
        return _AnimatedEquation(
          equation: widget.frame.equation ?? '',
          lines: widget.frame.lines,
          color: chalk,
          textColor: ink,
          progress: _drawProgress,
          highlightTerm: widget.frame.highlight,
        );
      case WhiteboardKind.matrix:
        return _MatrixGrid(lines: widget.frame.lines, color: ink, progress: _drawProgress);
      case WhiteboardKind.table:
        return _AnimatedTable(
          lines: widget.frame.lines,
          color: ink,
          accent: chalk,
          progress: _drawProgress,
        );
      case WhiteboardKind.workedProblem:
        return const SizedBox.shrink();
      case WhiteboardKind.text:
      case WhiteboardKind.vector:
      case WhiteboardKind.probability:
        return _AnimatedLines(
          lines: widget.frame.lines,
          color: ink,
          accent: chalk,
          progress: _drawProgress,
          highlight: widget.frame.highlight,
        );
    }
  }
}

class _AnimatedEquation extends StatelessWidget {
  const _AnimatedEquation({
    required this.equation,
    required this.lines,
    required this.color,
    required this.textColor,
    required this.progress,
    this.highlightTerm,
  });

  final String equation;
  final List<String> lines;
  final Color color;
  final Color textColor;
  final double progress;
  final String? highlightTerm;

  @override
  Widget build(BuildContext context) {
    final int visibleLines = (lines.length * progress).ceil().clamp(0, lines.length);
    final bool showHighlight = highlightTerm != null &&
        highlightTerm!.isNotEmpty &&
        progress > 0.55;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: showHighlight ? color : color.withValues(alpha: 0.35),
                width: showHighlight ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: showHighlight ? 0.12 : 0.06),
            ),
            child: LectureMathDisplay(
              expression: equation,
              color: color,
              highlight: showHighlight ? highlightTerm : null,
              fontSize: 22,
              compact: true,
              progress: progress,
            ),
          ),
          ...List<Widget>.generate(visibleLines, (int i) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.arrow_forward_rounded, size: 14, color: color.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: LectureMathText(
                      text: lines[i],
                      color: textColor,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnimatedTable extends StatelessWidget {
  const _AnimatedTable({
    required this.lines,
    required this.color,
    required this.accent,
    required this.progress,
  });

  final List<String> lines;
  final Color color;
  final Color accent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final int visible = (lines.length * progress).ceil().clamp(0, lines.length);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(visible, (int i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: LectureMathText(
                  text: lines[i],
                  color: color,
                  fontSize: 14,
                  fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w500,
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLines extends StatelessWidget {
  const _AnimatedLines({
    required this.lines,
    required this.color,
    required this.accent,
    required this.progress,
    this.highlight,
  });

  final List<String> lines;
  final Color color;
  final Color accent;
  final double progress;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Center(
        child: Text(
          'Board notes appear as the professor teaches…',
          style: TextStyle(color: color.withValues(alpha: 0.55), fontSize: 14),
        ),
      );
    }

    // Progress drives the active slide. [highlight] only accents the focused line —
    // it must never freeze the board while the professor keeps talking.
    final int focus = () {
      if (progress < 0.02) return 0;
      final int byProgress =
          (lines.length * progress.clamp(0.0, 1.0)).ceil().clamp(1, lines.length) -
              1;
      return byProgress;
    }();

    final String current = lines[focus.clamp(0, lines.length - 1)];
    final String? kind = _noteKind(current);
    final bool highlightActive =
        highlight != null && highlight!.trim() == current.trim();
    // Writing reveal: chalk appears as the voice reaches this slide.
    final double writeIn = () {
      if (lines.length <= 1) return progress.clamp(0.0, 1.0);
      final double slot = 1.0 / lines.length;
      final double start = focus * slot;
      final double local = ((progress - start) / slot).clamp(0.0, 1.0);
      return Curves.easeOutCubic.transform(local);
    }();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Slide ${focus + 1} of ${lines.length}',
              style: TextStyle(
                color: accent.withValues(alpha: 0.85),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
            if (kind != null) ...<Widget>[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Text(
                  kind,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Align(
              key: ValueKey<String>('$focus|$current'),
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: writeIn.clamp(0.15, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - writeIn)),
                  child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: highlightActive ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: highlightActive ? 0.55 : 0.4),
                    width: 1.4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.28),
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            '${focus + 1}',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            current,
                            style: TextStyle(
                              color: color,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (focus > 0) ...<Widget>[
                      const SizedBox(height: 16),
                      Text(
                        'Already on the board',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...lines.take(focus).map(
                        (String prior) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '·  ',
                                style: TextStyle(
                                  color: color.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  prior,
                                  style: TextStyle(
                                    color: color.withValues(alpha: 0.55),
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String? _noteKind(String note) {
    final String n = note.toLowerCase();
    if (n.startsWith('how') || n.contains('step ') || n.startsWith('1.') || n.contains('first ')) {
      return 'HOW';
    }
    if (n.contains('example') || n.startsWith('e.g.') || n.contains('scenario') || n.contains('case:')) {
      return 'EXAMPLE';
    }
    if (n.contains('why') || n.contains('because') || n.contains('matters')) {
      return 'WHY';
    }
    if (n.contains('define') || n.contains('means') || n.contains('definition')) {
      return 'DEFINE';
    }
    return null;
  }
}

class _MatrixGrid extends StatelessWidget {
  const _MatrixGrid({
    required this.lines,
    required this.color,
    required this.progress,
  });

  final List<String> lines;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final int visible = (lines.length * progress).ceil().clamp(0, lines.length);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Opacity(
          opacity: progress.clamp(0.3, 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: lines
                .take(visible)
                .map(
                  (String row) => LectureMathText(
                    text: row,
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _LectureDiagramBoard extends StatefulWidget {
  const _LectureDiagramBoard({
    required this.frame,
    required this.chalk,
    required this.ink,
    required this.mute,
    required this.progress,
  });

  final LectureWhiteboardFrame frame;
  final Color chalk;
  final Color ink;
  final Color mute;
  final double progress;

  @override
  State<_LectureDiagramBoard> createState() => _LectureDiagramBoardState();
}

class _LectureDiagramBoardState extends State<_LectureDiagramBoard> {
  LectureDiagramRef? _ref;
  bool _loading = true;
  String? _error;
  Object? _requestKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LectureDiagramBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frame.title != widget.frame.title ||
        oldWidget.frame.imageUrl != widget.frame.imageUrl ||
        oldWidget.frame.diagramQuery != widget.frame.diagramQuery ||
        oldWidget.frame.diagramId != widget.frame.diagramId ||
        oldWidget.frame.lines.join('|') != widget.frame.lines.join('|')) {
      _load();
    }
  }

  Future<void> _load() async {
    final Object key = Object();
    _requestKey = key;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final LectureDiagramRef? ref = await LectureDiagramService.instance.resolve(
        imageUrl: widget.frame.imageUrl,
        diagramId: widget.frame.diagramId,
        diagramQuery: widget.frame.diagramQuery,
        title: widget.frame.title,
        lines: widget.frame.lines,
      );
      if (!mounted || !identical(_requestKey, key)) return;
      setState(() {
        _ref = ref;
        _loading = false;
        _error = ref == null ? 'No diagram found' : null;
      });
    } catch (e) {
      if (!mounted || !identical(_requestKey, key)) return;
      setState(() {
        _loading = false;
        _error = 'Could not load diagram';
        _ref = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.progress.clamp(0.25, 1.0),
      duration: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.frame.lines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Labels',
                      style: TextStyle(
                        color: widget.chalk,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: () {
                        final List<String> labels = widget.frame.lines;
                        final int visible = labels.isEmpty
                            ? 0
                            : (labels.length * widget.progress.clamp(0.08, 1.0))
                                .ceil()
                                .clamp(1, labels.length);
                        return labels.take(visible).map(
                          (String line) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: widget.chalk.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              line.replaceFirst(RegExp(r'^•\s*'), ''),
                              style: TextStyle(
                                color: widget.ink,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).toList();
                      }(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.chalk.withValues(alpha: 0.28)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.chalk,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Loading diagram…',
              style: TextStyle(color: widget.mute, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final LectureDiagramRef? ref = _ref;
    if (ref == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error ?? 'Diagram unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.mute, fontSize: 13),
          ),
        ),
      );
    }

    if (ref.isNetwork) {
      final String url = ref.networkUrl!;
      if (ref.isSvg) {
        return SvgPicture.network(
          url,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Center(
            child: CircularProgressIndicator(color: widget.chalk, strokeWidth: 2),
          ),
        );
      }
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(color: widget.chalk, strokeWidth: 2),
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            Center(
          child: Text(
            'Diagram failed to load',
            style: TextStyle(color: widget.mute),
          ),
        ),
      );
    }

    final String asset = ref.assetPath!;
    if (ref.isSvg || asset.endsWith('.svg')) {
      return SvgPicture.asset(asset, fit: BoxFit.contain);
    }
    return Image.asset(asset, fit: BoxFit.contain);
  }
}
