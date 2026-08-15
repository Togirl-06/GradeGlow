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
  /// Yellow/white chalk on dark board (Khan Academy video look).
  final bool khanStyle;

  @override
  State<LectureWhiteboard> createState() => _LectureWhiteboardState();
}

class _LectureWhiteboardState extends State<LectureWhiteboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _introProgress;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _introProgress = CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic);
    _startIntro();
  }

  @override
  void didUpdateWidget(LectureWhiteboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frame.title != widget.frame.title ||
        oldWidget.frame.kind != widget.frame.kind ||
        oldWidget.frame.problemStatement != widget.frame.problemStatement ||
        oldWidget.frame.solutionSteps.length != widget.frame.solutionSteps.length) {
      _startIntro();
    }
  }

  void _startIntro() {
    _introController.reset();
    if (widget.animate) {
      _introController.forward();
    } else {
      _introController.value = 1;
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  double get _drawProgress {
    final double speech = widget.speechProgress.clamp(0, 1);
    final double intro = _introProgress.value;
    if (!widget.isSpeaking && speech > 0.05) return speech;
    return math.max(speech * 0.85 + intro * 0.15, intro * 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final bool khan = widget.khanStyle;
    // Khan board uses fixed chalk colors — avoid Theme.of so teardown cannot
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

    return AnimatedBuilder(
      animation: _introController,
      builder: (BuildContext context, Widget? child) {
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
              CustomPaint(
                painter: _BoardGridPainter(
                  color: chalk.withValues(alpha: khan ? 0.06 : 0.08),
                ),
                child: const SizedBox.expand(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, khan ? 28 : 56, 18, khan ? 88 : 100),
                child: khan
                    ? _buildContent(
                        chalk: chalk,
                        ink: ink,
                        mute: mute,
                        border: border,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                              if (widget.frame.highlight != null &&
                                  !widget.frame.isWorkedProblem)
                                Flexible(
                                  child: _HighlightChip(
                                    label: widget.frame.highlight!,
                                    color: chalk,
                                    visible: _drawProgress > 0.55,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
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
      },
    );
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
        );
    }
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({
    required this.label,
    required this.color,
    required this.visible,
  });

  final String label;
  final Color color;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ),
    );
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
  });

  final List<String> lines;
  final Color color;
  final Color accent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final int visible = (lines.length * progress).ceil().clamp(0, lines.length);
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: visible,
      itemBuilder: (BuildContext context, int index) {
        final double lineProgress = ((progress * lines.length) - index).clamp(0.0, 1.0);
        return Opacity(
          opacity: lineProgress.clamp(0.3, 1),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LectureMathText(
                    text: lines[index],
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

class _BoardGridPainter extends CustomPainter {
  _BoardGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = color
      ..strokeWidth = 1;
    const double step = 28;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardGridPainter old) => old.color != color;
}

/// Loads a real educational diagram (asset or internet) — never freehand shapes.
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
                child: Text(
                  widget.frame.lines.take(2).join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
