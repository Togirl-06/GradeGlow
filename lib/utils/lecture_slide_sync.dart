import '../models/virtual_lecture.dart';

/// Turns long monologue + dense board lists into short, speech-matched beats
/// while preserving university slide structure (title, process, key points).
class LectureSlideSync {
  const LectureSlideSync._();

  static VirtualLectureScript syncScript(VirtualLectureScript script) {
    if (script.segments.isEmpty) return script;
    return script.copyWith(
      segments: script.segments.map(syncSegment).toList(growable: false),
    );
  }

  static LectureSegment syncSegment(LectureSegment segment) {
    if (segment.beats.isNotEmpty) {
      return _refineBeats(segment);
    }
    if (segment.whiteboard.isWorkedProblem &&
        segment.whiteboard.solutionSteps.isNotEmpty) {
      return _expandWorkedProblem(segment);
    }
    return _expandMonologue(segment);
  }

  static bool _isRichUniversitySlide(LectureWhiteboardFrame board) {
    return board.processSteps.isNotEmpty ||
        board.keyPoints.isNotEmpty ||
        board.dataRows.isNotEmpty ||
        (board.subtitle != null && board.subtitle!.trim().isNotEmpty) ||
        board.slideType != LectureSlideType.concept ||
        (board.interactiveActivity != null &&
            board.interactiveActivity!.trim().isNotEmpty) ||
        (board.diagramId != null && board.diagramId!.trim().isNotEmpty);
  }

  static LectureWhiteboardFrame _copyBoard(
    LectureWhiteboardFrame board, {
    List<String>? lines,
    String? highlight,
  }) {
    return LectureWhiteboardFrame(
      kind: board.kind,
      title: board.title,
      subtitle: board.subtitle,
      slideType: board.slideType,
      lines: lines ?? board.lines,
      keyPoints: board.keyPoints,
      processSteps: board.processSteps,
      dataColumns: board.dataColumns,
      dataRows: board.dataRows,
      equation: board.equation,
      graphFunction: board.graphFunction,
      highlight: highlight,
      graphApproachX: board.graphApproachX,
      graphLimitY: board.graphLimitY,
      problemStatement: board.problemStatement,
      solutionSteps: board.solutionSteps,
      imageUrl: board.imageUrl,
      diagramQuery: board.diagramQuery,
      diagramId: board.diagramId,
      highlightRegionIds: board.highlightRegionIds,
      visibleRegionIds: board.visibleRegionIds,
      diagramInteractive: board.diagramInteractive,
      dimDiagramBackground: board.dimDiagramBackground,
      diagramTeachingMode: board.diagramTeachingMode,
      interactiveActivity: board.interactiveActivity,
      activityRegionIds: board.activityRegionIds,
    );
  }

  /// Keep rich university slides intact; only thin chalk lists get one-focus refinement.
  static LectureSegment _refineBeats(LectureSegment segment) {
    final List<LectureInteractiveBeat> refined = <LectureInteractiveBeat>[];

    for (int i = 0; i < segment.beats.length; i++) {
      final LectureInteractiveBeat beat = segment.beats[i];
      final LectureWhiteboardFrame board = beat.whiteboard;

      if (_isRichUniversitySlide(board) || board.hasVisibleContent) {
        refined.add(
          LectureInteractiveBeat(
            professorSpeech: beat.professorSpeech.trim().isEmpty
                ? (board.title.trim().isEmpty
                    ? _headlineFromSpeech(segment.professorSpeech)
                    : board.title.trim())
                : beat.professorSpeech.trim(),
            caption: beat.caption ??
                '${segment.caption} · ${i + 1}/${segment.beats.length}',
            durationSeconds: beat.durationSeconds > 0
                ? beat.durationSeconds
                : _secondsForSpeech(beat.professorSpeech),
            studentChoice: beat.studentChoice,
            slideNotes: beat.slideNotes ?? segment.slideNotes,
            whiteboard: _copyBoard(board, highlight: null),
          ),
        );
        continue;
      }

      final List<String> lines = board.lines
          .map((String l) => l.trim())
          .where((String l) => l.isNotEmpty)
          .toList();

      final String focus = () {
        if (board.highlight != null && board.highlight!.trim().isNotEmpty) {
          return board.highlight!.trim();
        }
        if (lines.isEmpty) {
          return board.title.trim().isEmpty
              ? _headlineFromSpeech(beat.professorSpeech)
              : board.title.trim();
        }
        return lines.last;
      }();

      refined.add(
        LectureInteractiveBeat(
          professorSpeech: beat.professorSpeech.trim().isEmpty
              ? focus
              : beat.professorSpeech.trim(),
          caption: beat.caption ??
              '${segment.caption} · ${i + 1}/${segment.beats.length}',
          durationSeconds: beat.durationSeconds > 0
              ? beat.durationSeconds
              : _secondsForSpeech(beat.professorSpeech),
          studentChoice: beat.studentChoice,
          slideNotes: beat.slideNotes ?? segment.slideNotes,
          whiteboard: _copyBoard(board, lines: <String>[focus], highlight: null),
        ),
      );
    }

    if (refined.isEmpty) return segment;
    return segment.copyWith(
      professorSpeech: refined.first.professorSpeech,
      caption: segment.caption,
      whiteboard: refined.first.whiteboard,
      slideNotes: segment.slideNotes ?? refined.first.slideNotes,
      durationSeconds: refined.fold<int>(
        0,
        (int n, LectureInteractiveBeat b) => n + b.durationSeconds,
      ),
      beats: refined,
    );
  }

  static LectureSegment _expandMonologue(LectureSegment segment) {
    final LectureWhiteboardFrame board = segment.whiteboard;
    final String speech = segment.professorSpeech.trim();
    final List<String> lines = board.lines
        .map((String l) => l.trim())
        .where((String l) => l.isNotEmpty)
        .toList();
    final List<String> sentences = _sentences(speech);

    // Rich university slides stay as one complete slide + spoken lecture.
    if (_isRichUniversitySlide(board)) {
      return segment.copyWith(
        whiteboard: _copyBoard(
          board,
          lines: lines.isEmpty && board.keyPoints.isEmpty
              ? <String>[
                  board.title.trim().isEmpty
                      ? _headlineFromSpeech(speech)
                      : board.title.trim(),
                ]
              : lines,
        ),
      );
    }

    final bool shortEnough =
        sentences.length <= 3 && lines.length <= 1 && speech.length < 420;
    if (shortEnough || speech.isEmpty) {
      return segment.copyWith(
        whiteboard: _copyBoard(
          board,
          lines: lines.isEmpty
              ? <String>[
                  board.title.trim().isEmpty
                      ? _headlineFromSpeech(speech)
                      : board.title.trim(),
                ]
              : lines,
          highlight: null,
        ),
      );
    }

    final int beatCount = () {
      if (lines.length >= 2) return lines.length.clamp(2, 14);
      final int bySentences = (sentences.length / 3).ceil();
      return bySentences.clamp(2, 10);
    }();

    final List<List<String>> groups = _distributeSentences(sentences, beatCount);
    final List<LectureInteractiveBeat> beats = <LectureInteractiveBeat>[];

    for (int i = 0; i < groups.length; i++) {
      final String beatSpeech = groups[i].join(' ').trim();
      if (beatSpeech.isEmpty) continue;

      final String focus = lines.isEmpty
          ? _headlineFromSpeech(beatSpeech)
          : lines[
              ((i / groups.length) * lines.length).floor().clamp(0, lines.length - 1)];

      beats.add(
        LectureInteractiveBeat(
          professorSpeech: beatSpeech,
          caption: '${segment.caption} · ${beats.length + 1}',
          durationSeconds: _secondsForSpeech(beatSpeech),
          slideNotes: segment.slideNotes,
          whiteboard: _copyBoard(board, lines: <String>[focus], highlight: null),
        ),
      );
    }

    if (beats.length < 2) return segment;

    final List<LectureInteractiveBeat> numbered = <LectureInteractiveBeat>[];
    for (int i = 0; i < beats.length; i++) {
      final LectureInteractiveBeat b = beats[i];
      numbered.add(
        LectureInteractiveBeat(
          professorSpeech: b.professorSpeech,
          caption: '${segment.caption} · ${i + 1}/${beats.length}',
          durationSeconds: b.durationSeconds,
          studentChoice: b.studentChoice,
          slideNotes: b.slideNotes,
          whiteboard: b.whiteboard,
        ),
      );
    }

    return segment.copyWith(
      professorSpeech: numbered.first.professorSpeech,
      whiteboard: numbered.first.whiteboard,
      durationSeconds: numbered.fold<int>(
        0,
        (int n, LectureInteractiveBeat b) => n + b.durationSeconds,
      ),
      beats: numbered,
      knowledgeCheck: segment.knowledgeCheck,
      slideNotes: segment.slideNotes,
    );
  }

  static LectureSegment _expandWorkedProblem(LectureSegment segment) {
    final List<LectureProblemStep> steps = segment.whiteboard.solutionSteps;
    final List<String> sentences = _sentences(segment.professorSpeech);
    if (steps.isEmpty || sentences.length < 2) return segment;

    final int beatCount = (1 + steps.length).clamp(2, 12);
    final List<List<String>> groups = _distributeSentences(sentences, beatCount);
    final List<LectureInteractiveBeat> beats = <LectureInteractiveBeat>[];

    for (int i = 0; i < groups.length; i++) {
      final String beatSpeech = groups[i].join(' ').trim();
      if (beatSpeech.isEmpty) continue;
      final int revealedSteps = (i - 1).clamp(0, steps.length);
      beats.add(
        LectureInteractiveBeat(
          professorSpeech: beatSpeech,
          caption: i == 0 ? 'Problem' : 'Step $revealedSteps of ${steps.length}',
          durationSeconds: _secondsForSpeech(beatSpeech),
          slideNotes: segment.slideNotes,
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.workedProblem,
            title: segment.whiteboard.title,
            subtitle: segment.whiteboard.subtitle,
            slideType: segment.whiteboard.slideType,
            lines: segment.whiteboard.lines,
            keyPoints: segment.whiteboard.keyPoints,
            equation: segment.whiteboard.equation,
            highlight: i >= beatCount - 1 ? segment.whiteboard.highlight : null,
            problemStatement: segment.whiteboard.problemStatement,
            solutionSteps: steps.take(revealedSteps.clamp(0, steps.length)).toList(),
            diagramId: segment.whiteboard.diagramId,
            highlightRegionIds: segment.whiteboard.highlightRegionIds,
            visibleRegionIds: segment.whiteboard.visibleRegionIds,
            interactiveActivity: segment.whiteboard.interactiveActivity,
            activityRegionIds: segment.whiteboard.activityRegionIds,
          ),
        ),
      );
    }

    if (beats.length < 2) return segment;
    return segment.copyWith(
      professorSpeech: beats.first.professorSpeech,
      whiteboard: beats.first.whiteboard,
      durationSeconds: beats.fold<int>(
        0,
        (int n, LectureInteractiveBeat b) => n + b.durationSeconds,
      ),
      beats: beats,
    );
  }

  static List<String> _sentences(String speech) {
    final String plain = speech.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.isEmpty) return const <String>[];
    final List<String> parts = plain
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? <String>[plain] : parts;
  }

  static List<List<String>> _distributeSentences(
    List<String> sentences,
    int count,
  ) {
    if (sentences.isEmpty) {
      return List<List<String>>.generate(count, (_) => <String>[]);
    }
    if (count <= 1) return <List<String>>[List<String>.from(sentences)];

    final int n = count.clamp(1, sentences.length);
    final int totalChars =
        sentences.fold<int>(0, (int a, String s) => a + s.length).clamp(1, 1 << 30);
    final double target = totalChars / n;

    final List<List<String>> groups = <List<String>>[];
    List<String> current = <String>[];
    int currentChars = 0;

    for (int i = 0; i < sentences.length; i++) {
      final String s = sentences[i];
      current.add(s);
      currentChars += s.length;
      final int remainingSentences = sentences.length - i - 1;
      final int remainingGroups = n - groups.length - 1;
      final bool filled = currentChars >= target * 0.85;
      final bool mustLeaveRoom = remainingSentences <= remainingGroups;
      if ((filled || mustLeaveRoom) && groups.length < n - 1) {
        groups.add(current);
        current = <String>[];
        currentChars = 0;
      }
    }
    if (current.isNotEmpty) groups.add(current);
    while (groups.length < n) {
      groups.add(<String>[]);
    }
    while (groups.length > 1 && groups.last.isEmpty) {
      groups.removeLast();
    }
    return groups;
  }

  static String _headlineFromSpeech(String speech) {
    final String plain = speech.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.isEmpty) return 'Key idea';
    final String first = plain.split(RegExp(r'(?<=[.!?])\s+')).first.trim();
    if (first.length <= 110) return first;
    return '${first.substring(0, 107).trimRight()}…';
  }

  static int _secondsForSpeech(String speech) {
    final int words = speech
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .length;
    return (words / 2.1).round().clamp(12, 180);
  }
}
