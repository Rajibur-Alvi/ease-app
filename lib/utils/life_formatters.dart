import '../models/models.dart';

String categoryLabel(LifeCategory category) {
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
