enum MoodState { calm, overwhelmed, lowEnergy }

enum DepartmentStatus { stable, inProgress, needsAttention }

enum TaskPriority { low, medium, high }

enum CommunicationStyle { text, voice, either }

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

class TaskItem {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final bool completed;
  final String source;
  final TaskPriority priority;
  final List<String> tags;
  final LifeCategory? category;

  TaskItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.dueAt,
    this.reminderAt,
    this.completed = false,
    this.source = 'quick_add',
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.category,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? dueAt,
    DateTime? reminderAt,
    bool? completed,
    String? source,
    TaskPriority? priority,
    List<String>? tags,
    LifeCategory? category,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      dueAt: dueAt ?? this.dueAt,
      reminderAt: reminderAt ?? this.reminderAt,
      completed: completed ?? this.completed,
      source: source ?? this.source,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'dueAt': dueAt?.toIso8601String(),
        'reminderAt': reminderAt?.toIso8601String(),
        'completed': completed,
        'source': source,
        'priority': priority.index,
        'tags': tags,
        'category': category?.index,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt'] as String) : null,
        reminderAt: json['reminderAt'] != null ? DateTime.parse(json['reminderAt'] as String) : null,
        completed: json['completed'] as bool? ?? false,
        source: json['source'] as String? ?? 'quick_add',
        priority: TaskPriority.values[json['priority'] as int? ?? TaskPriority.medium.index],
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        category: json['category'] != null ? LifeCategory.values[json['category'] as int] : null,
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
  final int introvertLevel;
  final CommunicationStyle communicationStyle;

  UserProfile({
    this.name = "Stranger",
    this.personalityType = PersonalityType.introvert,
    this.interests = const [],
    this.priorityDepartments = const [],
    this.introvertLevel = 80,
    this.communicationStyle = CommunicationStyle.text,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'personalityType': personalityType.index,
        'interests': interests,
        'priorityDepartments': priorityDepartments.map((e) => e.index).toList(),
        'introvertLevel': introvertLevel,
        'communicationStyle': communicationStyle.index,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? "Stranger",
        personalityType: PersonalityType.values[json['personalityType'] ?? 0],
        interests: List<String>.from(json['interests'] ?? []),
        priorityDepartments: (json['priorityDepartments'] as List?)
                ?.map((e) => LifeCategory.values[e as int])
                .toList() ??
            [],
        introvertLevel: json['introvertLevel'] ?? 80,
        communicationStyle: CommunicationStyle.values[json['communicationStyle'] ?? 0],
      );
}

class CategoryData {
  final LifeCategory category;
  final String title;
  final int score;
  final List<String> tasks;
  final String goal;
  final double progress;
  final DepartmentStatus status;

  CategoryData({
    required this.category,
    required this.title,
    this.score = 100,
    this.tasks = const [],
    this.goal = "Steady progress",
    this.progress = 0.0,
    this.status = DepartmentStatus.inProgress,
  });

  Map<String, dynamic> toJson() => {
        'category': category.index,
        'title': title,
        'score': score,
        'tasks': tasks,
        'goal': goal,
        'progress': progress,
        'status': status.index,
      };

  CategoryData copyWith({
    LifeCategory? category,
    String? title,
    int? score,
    List<String>? tasks,
    String? goal,
    double? progress,
    DepartmentStatus? status,
  }) {
    return CategoryData(
      category: category ?? this.category,
      title: title ?? this.title,
      score: score ?? this.score,
      tasks: tasks ?? this.tasks,
      goal: goal ?? this.goal,
      progress: progress ?? this.progress,
      status: status ?? this.status,
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
      status: DepartmentStatus.values[json['status'] ?? DepartmentStatus.inProgress.index],
    );
  }
}

class ReflectionResult {
  final LifeCategory category;
  final String suggestedAction;
  final bool suggestConnection;
  final String summary;

  const ReflectionResult({
    required this.category,
    required this.suggestedAction,
    required this.suggestConnection,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
        'category': category.index,
        'suggestedAction': suggestedAction,
        'suggestConnection': suggestConnection,
        'summary': summary,
      };

  factory ReflectionResult.fromJson(Map<String, dynamic> json) => ReflectionResult(
        category: LifeCategory.values[json['category'] ?? 0],
        suggestedAction: json['suggestedAction'] ?? '',
        suggestConnection: json['suggestConnection'] ?? false,
        summary: json['summary'] ?? '',
      );
}

class CompanionMatch {
  final String id;
  final String name;
  final List<String> interests;
  final MoodState mood;
  final CommunicationStyle style;
  final int introvertLevel;

  const CompanionMatch({
    required this.id,
    required this.name,
    required this.interests,
    required this.mood,
    required this.style,
    required this.introvertLevel,
  });
}

class AppState {
  final int easeScore;
  final int stressorsOffloadedThisWeek;
  final List<BrainDumpEntry> brainDumpEntries;
  final Map<LifeCategory, CategoryData> categories;
  final UserProfile userProfile;
  final bool enableEffects;
  final List<TaskItem> tasks;
  final MoodState moodState;
  final bool onboardingComplete;
  final ReflectionResult? lastReflection;

  AppState({
    this.easeScore = 84,
    this.stressorsOffloadedThisWeek = 0,
    this.brainDumpEntries = const [],
    Map<LifeCategory, CategoryData>? categories,
    UserProfile? userProfile,
    this.enableEffects = true,
    this.tasks = const [],
    this.moodState = MoodState.calm,
    this.onboardingComplete = false,
    this.lastReflection,
  })  : categories = categories ?? _defaultCategories(),
        userProfile = userProfile ?? UserProfile();

  static Map<LifeCategory, CategoryData> _defaultCategories() {
    return {
      LifeCategory.health: CategoryData(category: LifeCategory.health, title: "Health", score: 85, goal: "Morning walk daily"),
      LifeCategory.workCareer: CategoryData(category: LifeCategory.workCareer, title: "Work & Career", score: 72, goal: "Complete project X", status: DepartmentStatus.needsAttention),
      LifeCategory.finances: CategoryData(category: LifeCategory.finances, title: "Finances", score: 64, goal: "Save \$500 this month", status: DepartmentStatus.needsAttention),
      LifeCategory.family: CategoryData(category: LifeCategory.family, title: "Family", score: 90, goal: "Weekly dinner", status: DepartmentStatus.stable),
      LifeCategory.relationships: CategoryData(category: LifeCategory.relationships, title: "Relationships", score: 78, goal: "Deep conversation", status: DepartmentStatus.inProgress),
      LifeCategory.homeEnvironment: CategoryData(category: LifeCategory.homeEnvironment, title: "Home", score: 82, goal: "Declutter kitchen", status: DepartmentStatus.inProgress),
      LifeCategory.personalGrowth: CategoryData(category: LifeCategory.personalGrowth, title: "Personal Growth", score: 75, goal: "Read 2 books", status: DepartmentStatus.inProgress),
      LifeCategory.timeManagement: CategoryData(category: LifeCategory.timeManagement, title: "Time Management", score: 60, goal: "Audit daily schedule", status: DepartmentStatus.needsAttention),
    };
  }

  AppState copyWith({
    int? easeScore,
    int? stressorsOffloadedThisWeek,
    List<BrainDumpEntry>? brainDumpEntries,
    Map<LifeCategory, CategoryData>? categories,
    UserProfile? userProfile,
    bool? enableEffects,
    List<TaskItem>? tasks,
    MoodState? moodState,
    bool? onboardingComplete,
    ReflectionResult? lastReflection,
  }) {
    return AppState(
      easeScore: easeScore ?? this.easeScore,
      stressorsOffloadedThisWeek: stressorsOffloadedThisWeek ?? this.stressorsOffloadedThisWeek,
      brainDumpEntries: brainDumpEntries ?? this.brainDumpEntries,
      categories: categories ?? this.categories,
      userProfile: userProfile ?? this.userProfile,
      enableEffects: enableEffects ?? this.enableEffects,
      tasks: tasks ?? this.tasks,
      moodState: moodState ?? this.moodState,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lastReflection: lastReflection ?? this.lastReflection,
    );
  }

  Map<String, dynamic> toJson() => {
        'easeScore': easeScore,
        'stressorsOffloadedThisWeek': stressorsOffloadedThisWeek,
        'brainDumpEntries': brainDumpEntries.map((e) => e.toJson()).toList(),
        'categories': categories.map((k, v) => MapEntry(k.index.toString(), v.toJson())),
        'userProfile': userProfile.toJson(),
        'enableEffects': enableEffects,
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'moodState': moodState.index,
        'onboardingComplete': onboardingComplete,
        'lastReflection': lastReflection?.toJson(),
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
      moodState: MoodState.values[json['moodState'] ?? MoodState.calm.index],
      onboardingComplete: json['onboardingComplete'] ?? false,
      lastReflection: json['lastReflection'] != null
          ? ReflectionResult.fromJson(json['lastReflection'] as Map<String, dynamic>)
          : null,
      tasks: (json['tasks'] as List?)
              ?.map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
