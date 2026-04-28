class UsageEvent {
  final String type; // brain_dump, mood_check, match_view, chat_open
  final DateTime timestamp;
  final Map<String, dynamic> meta;

  const UsageEvent({
    required this.type,
    required this.timestamp,
    this.meta = const {},
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'meta': meta.toString(),
      };
}

class AnalyticsSummary {
  final int brainDumpsTotal;
  final int brainDumpsThisWeek;
  final Map<String, int> moodFrequency; // mood name -> count
  final int matchViews;
  final int chatOpens;
  final int streakDays;

  const AnalyticsSummary({
    this.brainDumpsTotal = 0,
    this.brainDumpsThisWeek = 0,
    this.moodFrequency = const {},
    this.matchViews = 0,
    this.chatOpens = 0,
    this.streakDays = 0,
  });
}
