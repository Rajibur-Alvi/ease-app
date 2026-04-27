import 'dart:convert';

class BrainDumpEntry {
  final String id;
  final String text;
  final DateTime createdAt;
  final String? categorizedAs;

  BrainDumpEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    this.categorizedAs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'categorizedAs': categorizedAs,
      };

  factory BrainDumpEntry.fromJson(Map<String, dynamic> json) => BrainDumpEntry(
        id: json['id'],
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
        categorizedAs: json['categorizedAs'],
      );
}

enum LifeCategory {
  health,
  workCareer,
  finances,
  family,
  relationships,
  homeEnvironment,
  personalGrowth,
  timeManagement,
}

enum PersonalityType {
  introvert,
  extrovert,
  ambivert,
}

class UserProfile {
  final String name;
  final PersonalityType personalityType;
  final List<String> interests;
  final List<LifeCategory> priorityDepartments;

  UserProfile({
    this.name = "Stranger",
    this.personalityType = PersonalityType.introvert,
    this.interests = const [],
    this.priorityDepartments = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'personalityType': personalityType.index,
        'interests': interests,
        'priorityDepartments': priorityDepartments.map((e) => e.index).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? "Stranger",
        personalityType: PersonalityType.values[json['personalityType'] ?? 0],
        interests: List<String>.from(json['interests'] ?? []),
        priorityDepartments: (json['priorityDepartments'] as List?)
                ?.map((e) => LifeCategory.values[e as int])
                .toList() ??
            [],
      );
}

class CategoryData {
  final LifeCategory category;
  final String title;
  final int score;
  final List<String> tasks;
  final String goal;
  final double progress;

  CategoryData({
    required this.category,
    required this.title,
    this.score = 100,
    this.tasks = const [],
    this.goal = "Steady progress",
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'category': category.index,
        'title': title,
        'score': score,
        'tasks': tasks,
        'goal': goal,
        'progress': progress,
      };

  CategoryData copyWith({
    LifeCategory? category,
    String? title,
    int? score,
    List<String>? tasks,
    String? goal,
    double? progress,
  }) {
    return CategoryData(
      category: category ?? this.category,
      title: title ?? this.title,
      score: score ?? this.score,
      tasks: tasks ?? this.tasks,
      goal: goal ?? this.goal,
      progress: progress ?? this.progress,
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      category: LifeCategory.values[json['category'] ?? 0],
      title: json['title'] ?? "",
      score: json['score'] ?? 100,
      tasks: List<String>.from(json['tasks'] ?? []),
      goal: json['goal'] ?? "",
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }
}

class AppState {
  final int easeScore;
  final int stressorsOffloadedThisWeek;
  final List<BrainDumpEntry> brainDumpEntries;
  final Map<LifeCategory, CategoryData> categories;
  final UserProfile userProfile;
  final bool enableEffects;

  AppState({
    this.easeScore = 84,
    this.stressorsOffloadedThisWeek = 0,
    this.brainDumpEntries = const [],
    Map<LifeCategory, CategoryData>? categories,
    UserProfile? userProfile,
    this.enableEffects = true,
  })  : categories = categories ?? _defaultCategories(),
        userProfile = userProfile ?? UserProfile();

  static Map<LifeCategory, CategoryData> _defaultCategories() {
    return {
      LifeCategory.health: CategoryData(category: LifeCategory.health, title: "Health", score: 85, goal: "Morning walk daily"),
      LifeCategory.workCareer: CategoryData(category: LifeCategory.workCareer, title: "Work & Career", score: 72, goal: "Complete project X"),
      LifeCategory.finances: CategoryData(category: LifeCategory.finances, title: "Finances", score: 64, goal: "Save \$500 this month"),
      LifeCategory.family: CategoryData(category: LifeCategory.family, title: "Family", score: 90, goal: "Weekly dinner"),
      LifeCategory.relationships: CategoryData(category: LifeCategory.relationships, title: "Relationships", score: 78, goal: "Deep conversation"),
      LifeCategory.homeEnvironment: CategoryData(category: LifeCategory.homeEnvironment, title: "Home & Environment", score: 82, goal: "Declutter kitchen"),
      LifeCategory.personalGrowth: CategoryData(category: LifeCategory.personalGrowth, title: "Personal Growth", score: 75, goal: "Read 2 books"),
      LifeCategory.timeManagement: CategoryData(category: LifeCategory.timeManagement, title: "Time Management", score: 60, goal: "Audit daily schedule"),
    };
  }

  AppState copyWith({
    int? easeScore,
    int? stressorsOffloadedThisWeek,
    List<BrainDumpEntry>? brainDumpEntries,
    Map<LifeCategory, CategoryData>? categories,
    UserProfile? userProfile,
    bool? enableEffects,
  }) {
    return AppState(
      easeScore: easeScore ?? this.easeScore,
      stressorsOffloadedThisWeek: stressorsOffloadedThisWeek ?? this.stressorsOffloadedThisWeek,
      brainDumpEntries: brainDumpEntries ?? this.brainDumpEntries,
      categories: categories ?? this.categories,
      userProfile: userProfile ?? this.userProfile,
      enableEffects: enableEffects ?? this.enableEffects,
    );
  }

  Map<String, dynamic> toJson() => {
        'easeScore': easeScore,
        'stressorsOffloadedThisWeek': stressorsOffloadedThisWeek,
        'brainDumpEntries': brainDumpEntries.map((e) => e.toJson()).toList(),
        'categories': categories.map((k, v) => MapEntry(k.index.toString(), v.toJson())),
        'userProfile': userProfile.toJson(),
        'enableEffects': enableEffects,
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      easeScore: json['easeScore'] ?? 84,
      stressorsOffloadedThisWeek: json['stressorsOffloadedThisWeek'] ?? 0,
      brainDumpEntries: (json['brainDumpEntries'] as List?)
              ?.map((e) => BrainDumpEntry.fromJson(e))
              .toList() ??
          [],
      categories: (json['categories'] as Map?)?.map(
        (k, v) => MapEntry(
          LifeCategory.values[int.parse(k as String)],
          CategoryData.fromJson(v as Map<String, dynamic>),
        ),
      ) ?? _defaultCategories(),
      userProfile: json['userProfile'] != null 
          ? UserProfile.fromJson(json['userProfile']) 
          : UserProfile(),
      enableEffects: json['enableEffects'] ?? true,
    );
  }
}
