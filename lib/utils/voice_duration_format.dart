String formatVoiceDuration(int totalSeconds) {
  final int seconds = totalSeconds.clamp(0, 5999);
  final int minutes = seconds ~/ 60;
  final int secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
