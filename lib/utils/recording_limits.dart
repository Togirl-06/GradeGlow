/// Shared limits and formatting for lecture / summarize recordings.
class RecordingLimits {
  RecordingLimits._();

  static const Duration maxDuration = Duration(hours: 4);
  static const int maxDurationSeconds = 4 * 60 * 60;
}

String formatRecordingDuration(Duration duration) {
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  final int seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
