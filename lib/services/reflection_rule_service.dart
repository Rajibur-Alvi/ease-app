import '../models/models.dart';

class ReflectionRuleService {
  const ReflectionRuleService();

  ReflectionResult analyze(String input, MoodState moodState) {
    final text = input.toLowerCase();
    LifeCategory category = LifeCategory.personalGrowth;
    String action = 'Write one sentence about the smallest next step.';
    bool suggestConnection = false;

    if (_containsAny(text, ['stress', 'overwhelmed', 'burnout', 'anxious'])) {
      category = LifeCategory.health;
      action = 'Take 3 deep breaths and do a 5-minute walk.';
      suggestConnection = true;
    } else if (_containsAny(text, ['work', 'job', 'deadline', 'meeting', 'boss'])) {
      category = LifeCategory.workCareer;
      action = 'Pick one task and spend 10 focused minutes on it.';
    } else if (_containsAny(text, ['money', 'finance', 'budget', 'bill', 'bank'])) {
      category = LifeCategory.finances;
      action = 'Review one expense and set one simple money action for today.';
    } else if (_containsAny(text, ['family', 'mom', 'dad', 'child', 'kids'])) {
      category = LifeCategory.family;
      action = 'Send one caring check-in message to a family member.';
      suggestConnection = true;
    } else if (_containsAny(text, ['friend', 'partner', 'relationship', 'lonely'])) {
      category = LifeCategory.relationships;
      action = 'Reach out to one trusted person with a short message.';
      suggestConnection = true;
    } else if (_containsAny(text, ['home', 'clean', 'laundry', 'mess'])) {
      category = LifeCategory.homeEnvironment;
      action = 'Do a 10-minute reset in one area of your home.';
    } else if (_containsAny(text, ['learn', 'study', 'habit', 'read'])) {
      category = LifeCategory.personalGrowth;
      action = 'Complete one 10-minute learning block.';
    } else if (_containsAny(text, ['time', 'schedule', 'calendar', 'late'])) {
      category = LifeCategory.timeManagement;
      action = 'Choose your top 2 priorities for the next 3 hours.';
    }

    if (moodState == MoodState.overwhelmed) {
      suggestConnection = true;
    }

    return ReflectionResult(
      category: category,
      suggestedAction: action,
      suggestConnection: suggestConnection,
      summary: 'We categorized your thought under ${_categoryLabel(category)}.',
    );
  }

  bool _containsAny(String text, List<String> words) {
    for (final word in words) {
      if (text.contains(word)) return true;
    }
    return false;
  }

  String _categoryLabel(LifeCategory category) {
    switch (category) {
      case LifeCategory.health:
        return 'Health';
      case LifeCategory.workCareer:
        return 'Work/Career';
      case LifeCategory.finances:
        return 'Finance';
      case LifeCategory.family:
        return 'Family';
      case LifeCategory.relationships:
        return 'Relationships';
      case LifeCategory.homeEnvironment:
        return 'Home';
      case LifeCategory.personalGrowth:
        return 'Personal Growth';
      case LifeCategory.timeManagement:
        return 'Time Management';
    }
  }
}
