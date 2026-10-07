import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../services/lecture_recording_service.dart';
import '../services/mic_capture_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/openai_whisper_service.dart';
import '../services/recording_bin_service.dart';
import '../theme/study_theme.dart';
import '../utils/course_summary_actions.dart';
import '../utils/study_messenger.dart';

/// Floating recorder — stays visible while you browse the app.
class LectureRecordingBar extends StatelessWidget {
  const LectureRecordingBar({super.key});

  Future<void> _summarize(BuildContext context) async {
    final LectureRecordingService recording = context.read<LectureRecordingService>();
    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
    final Course? course = recording.course;
    final String? title = recording.title;

    if (course == null || title == null) return;

    final String? path = await recording.validatedFilePath();
    if ((path == null && MicCaptureService.instance.lastWavBytes == null) ||
        !context.mounted) {
      return;
    }

    recording.beginSummarizing();
    try {
      String? transcript;
      if (kIsWeb) {
        final bytes = MicCaptureService.instance.lastWavBytes;
        if (bytes != null && bytes.isNotEmpty) {
          transcript = await OpenAiWhisperService().transcribeBytes(
            bytes,
            fileName: 'lecture.wav',
          );
        }
      }
      final StudySummary summary = await summarizer.summarizeForCourseFromAudio(
        course: course,
        title: title,
        audioFilePath: path ?? 'lecture.wav',
        transcript: transcript,
      );
      recording.complete();
      if (!context.mounted) return;
      await CourseSummaryActions.openGeneratedNote(context, summary);
    } catch (error) {
      if (!context.mounted) return;
      recording.failSummarize(error.toString().replaceFirst('Exception: ', ''));
      StudyMessenger.showError(context, recording.error ?? 'Could not summarize recording.');
    }
  }

  Future<void> _moveToBin(BuildContext context) async {
    final LectureRecordingService recording = context.read<LectureRecordingService>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Move to bin?'),
        content: const Text('This recording will stay in the bin for 30 days so you can restore it.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move to bin')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    if (recording.phase == LectureRecordingPhase.recording) {
      await recording.stop();
    }
    final String? path = await recording.validatedFilePath();
    if (path != null && context.mounted) {
      await context.read<RecordingBinService>().moveToBin(
            sourcePath: path,
            duration: recording.elapsed,
            label: recording.title,
          );
    }
    await recording.cancel();
    if (context.mounted) {
      StudyMessenger.showInfo(context, 'Recording moved to bin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LectureRecordingService recording = context.watch<LectureRecordingService>();
    if (!recording.isActive) return const SizedBox.shrink();

    final Brightness brightness = Theme.of(context).brightness;
    final Color surface = brightness == Brightness.dark ? const Color(0xFF1C1C1E) : const Color(0xFF2C2C2E);
    final Color textSecondary = Colors.white.withValues(alpha: 0.65);
    final bool busy = recording.phase == LectureRecordingPhase.summarizing;

    final String? courseCode = recording.course?.code;
    final String headline = courseCode != null && courseCode.isNotEmpty
        ? '${recording.statusLabel} · $courseCode'
        : recording.statusLabel;

    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (recording.phase == LectureRecordingPhase.recording)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(color: StudyColors.danger, shape: BoxShape.circle),
                  )
                else if (busy)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: StudyColors.accent)),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check_circle_outline, color: StudyColors.accent, size: 20),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        headline,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        recording.phase == LectureRecordingPhase.recording
                            ? 'Recording continues in background'
                            : recording.phase == LectureRecordingPhase.saved
                                ? 'Tap Summarize when ready'
                                : 'Transcribing your lecture…',
                        style: TextStyle(color: textSecondary, fontSize: 11, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  recording.formatElapsed(),
                  style: const TextStyle(color: StudyColors.accent, fontWeight: FontWeight.w800, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                if (recording.phase == LectureRecordingPhase.recording) ...<Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => recording.stop(),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
                      child: const Text('Stop'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Move to bin',
                    onPressed: busy ? null : () => _moveToBin(context),
                    icon: Icon(Icons.delete_outline_rounded, color: textSecondary),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ] else if (recording.phase == LectureRecordingPhase.saved) ...<Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: busy ? null : () => _summarize(context),
                      style: FilledButton.styleFrom(backgroundColor: StudyColors.accent),
                      child: const Text('Summarize', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Move to bin',
                    onPressed: busy ? null : () => _moveToBin(context),
                    icon: Icon(Icons.delete_outline_rounded, color: textSecondary),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
