import '../models/models.dart';

class AiService {
  static const Map<LifeCategory, List<String>> _keywords = {
    LifeCategory.health: ['doctor', 'dentist', 'medicine', 'exercise', 'gym', 'appointment', 'stethoscope', 'mental', 'health'],
    LifeCategory.workCareer: ['meeting', 'email', 'project', 'report', 'boss', 'office', 'deadline', 'promotion', 'interview', 'job'],
    LifeCategory.finances: ['pay', 'bill', 'bank', 'credit', 'money', 'tax', 'finance', 'budget', 'invest', 'savings'],
    LifeCategory.family: ['mom', 'dad', 'sister', 'brother', 'family', 'parent', 'kid', 'child', 'cousin'],
    LifeCategory.relationships: ['friend', 'date', 'partner', 'relationship', 'girlfriend', 'boyfriend', 'wife', 'husband', 'social'],
    LifeCategory.homeEnvironment: ['clean', 'groceries', 'fix', 'repair', 'laundry', 'dishes', 'house', 'plumber', 'sink', 'home', 'garden'],
    LifeCategory.personalGrowth: ['read', 'learn', 'skill', 'course', 'hobby', 'meditation', 'growth', 'habit'],
    LifeCategory.timeManagement: ['schedule', 'calendar', 'plan', 'time', 'urgent', 'delay', 'productivity', 'todo'],
  };

  /// Categorizes a text string based on predefined keywords.
  /// This is a simple, free "AI" logic that runs locally.
  LifeCategory categorizeThought(String text) {
    final lowerText = text.toLowerCase();
    
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return LifeCategory.health; // Default category
  }
}
