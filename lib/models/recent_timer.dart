class RecentTimer {
  const RecentTimer({
    required this.label,
    required this.totalSeconds,
  });

  final String label;
  final int totalSeconds;

  int get hours => totalSeconds ~/ 3600;
  int get minutes => (totalSeconds % 3600) ~/ 60;
  int get seconds => totalSeconds % 60;

  String get displayTime {
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
