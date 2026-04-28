import '../models/models.dart';

class MatchingService {
  const MatchingService();

  int score({
    required UserProfile me,
    required CompanionMatch candidate,
    required MoodState currentMood,
  }) {
    final myInterests = me.interests.map((e) => e.toLowerCase()).toSet();
    final candidateInterests =
        candidate.interests.map((e) => e.toLowerCase()).toSet();
    final sharedInterests = myInterests.intersection(candidateInterests).length;
    final moodCompatibility = candidate.mood == currentMood ? 2 : 0;
    final styleCompatibility =
        me.communicationStyle == candidate.style ||
                me.communicationStyle == CommunicationStyle.either
            ? 1
            : 0;
    final introvertGap = (me.introvertLevel - candidate.introvertLevel).abs();
    final introvertScore = introvertGap <= 20 ? 1 : 0;
    return sharedInterests + moodCompatibility + styleCompatibility + introvertScore;
  }
}
