import 'package:flutter/material.dart';
import '../models/models.dart';
import 'storage_service.dart';
import 'reflection_rule_service.dart';
import 'matching_service.dart';
import 'reminder_service.dart';
import 'auth_service.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

class AppStateProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ReflectionRuleService _reflectionRuleService =
      const ReflectionRuleService();
  final MatchingService _matchingService = const MatchingService();
  final ReminderService _reminderService = ReminderService();
  final AuthService _authService = AuthService();
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notifications = NotificationService();

  AppState _state = AppState();
  bool _isLoading = true;
  List<CompanionMatch> _lastMatches = const [];
  String? _error;

  AppStateProvider() {
    _bootstrap();
  }

  AppState get state => _state;
  bool get isLoading => _isLoading;
  List<CompanionMatch> get lastMatches => _lastMatches;
  String? get error => _error;
  AuthService get auth => _authService;
  ReminderService get reminderService => _reminderService;

  // ── Bootstrap ──────────────────────────────────────────────────────────────

  Future<void> _bootstrap() async {
    try {
      await _notifications.init();
      _state = await _storageService.loadAppState();
      _ensureConsistentCategoryStatus();
      // Restore auth session
      final user = await _authService.restoreSession();
      if (user != null && _state.userProfile.name == 'Stranger') {
        _state = _state.copyWith(
          userProfile: _state.userProfile.copyWith(name: user.displayName),
        );
      }
    } catch (e) {
      _error = 'Failed to load data. Please restart the app.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Onboarding ─────────────────────────────────────────────────────────────

  Future<void> completeOnboarding({
    required String name,
    required PersonalityType personalityType,
    required int introvertLevel,
    required CommunicationStyle communicationStyle,
    required List<String> interests,
  }) async {
    final displayName = name.trim().isEmpty ? 'Friend' : name.trim();
    // Create local auth session
    await _authService.signInAnonymously(displayName: displayName);

    final profile = UserProfile(
      name: displayName,
      personalityType: personalityType,
      introvertLevel: introvertLevel,
      communicationStyle: communicationStyle,
      interests: interests,
      priorityDepartments: _state.userProfile.priorityDepartments,
    );
    _state = _state.copyWith(
      onboardingComplete: true,
      userProfile: profile,
    );
    notifyListeners();
    await _persist();
    // Schedule gentle daily reminders
    await _notifications.scheduleDailyBrainDumpReminder();
    await _notifications.scheduleMoodCheckIn();
  }

  // ── Mood ───────────────────────────────────────────────────────────────────

  Future<void> setMoodState(MoodState moodState) async {
    _state = _state.copyWith(moodState: moodState);
    notifyListeners();
    await _persist();
    await _analytics.logMoodCheck(moodState.name);
  }

  // ── Brain Dump ─────────────────────────────────────────────────────────────

  Future<ReflectionResult> processBrainDump(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return const ReflectionResult(
        category: LifeCategory.personalGrowth,
        suggestedAction:
            'Write one line about what feels most important right now.',
        suggestConnection: false,
        summary: 'Please add more detail to your thought.',
      );
    }

    final result =
        _reflectionRuleService.analyze(trimmed, _state.moodState);
    final entry = BrainDumpEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      createdAt: DateTime.now(),
      categorizedAs: result.category.name,
    );

    final updatedEntries =
        List<BrainDumpEntry>.from(_state.brainDumpEntries)..insert(0, entry);
    final updatedCategories =
        Map<LifeCategory, CategoryData>.from(_state.categories);
    final category = updatedCategories[result.category] ??
        CategoryData(
            category: result.category,
            title: _categoryLabel(result.category));
    final updatedCategoryTasks =
        List<String>.from(category.tasks)..add(result.suggestedAction);

    updatedCategories[result.category] = category.copyWith(
      tasks: updatedCategoryTasks,
      progress: _progressFromTasks(updatedCategoryTasks.length),
      status: _statusFromProgress(
          _progressFromTasks(updatedCategoryTasks.length)),
    );

    _state = _state.copyWith(
      brainDumpEntries: updatedEntries,
      categories: updatedCategories,
      stressorsOffloadedThisWeek: _state.stressorsOffloadedThisWeek + 1,
      lastReflection: result,
    );
    _ensureConsistentCategoryStatus();
    notifyListeners();
    await _persist();
    await _analytics.logBrainDump(result.category.name);
    return result;
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> updateUserProfile(UserProfile profile) async {
    _state = _state.copyWith(userProfile: profile);
    notifyListeners();
    await _persist();
    await _authService.updateProfile(displayName: profile.name);
  }

  // ── Tasks ──────────────────────────────────────────────────────────────────

  Future<void> addTask(
    String title, {
    DateTime? dueAt,
    DateTime? reminderAt,
    String source = 'quick_add',
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    LifeCategory? category,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final task = TaskItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: trimmed,
      createdAt: now,
      dueAt: dueAt,
      reminderAt: reminderAt,
      source: source,
      priority: priority,
      tags: tags,
      category: category,
    );

    final updatedTasks =
        List<TaskItem>.from(_state.tasks)..insert(0, task);
    final updatedCategories =
        Map<LifeCategory, CategoryData>.from(_state.categories);
    if (category != null) {
      final cat = updatedCategories[category] ??
          CategoryData(
              category: category, title: _categoryLabel(category));
      final newCatTasks = List<String>.from(cat.tasks)..add(trimmed);
      final nextProgress = _progressFromTasks(newCatTasks.length);
      updatedCategories[category] = cat.copyWith(
        tasks: newCatTasks,
        progress: nextProgress,
        status: _statusFromProgress(nextProgress),
      );
    }
    _state =
        _state.copyWith(tasks: updatedTasks, categories: updatedCategories);
    if (task.reminderAt != null) {
      await _reminderService.scheduleTaskReminder(task);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> updateTask(TaskItem updatedTask) async {
    final tasks = _state.tasks
        .map((t) => t.id == updatedTask.id ? updatedTask : t)
        .toList();
    _state = _state.copyWith(tasks: tasks);
    if (updatedTask.reminderAt != null) {
      await _reminderService.scheduleTaskReminder(updatedTask);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final updatedTasks = _state.tasks
        .map((t) =>
            t.id == taskId ? t.copyWith(completed: !t.completed) : t)
        .toList();
    _state = _state.copyWith(tasks: updatedTasks);
    _ensureConsistentCategoryStatus();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTask(String taskId) async {
    final updatedTasks =
        _state.tasks.where((t) => t.id != taskId).toList();
    _state = _state.copyWith(tasks: updatedTasks);
    _ensureConsistentCategoryStatus();
    notifyListeners();
    await _persist();
  }

  TaskItem? taskById(String id) {
    for (final task in _state.tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  // ── Matching ───────────────────────────────────────────────────────────────

  /// Expanded pool — in production this would be fetched from Firestore.
  static const _matchPool = <CompanionMatch>[
    CompanionMatch(
      id: 'm1',
      name: 'Ari',
      interests: ['books', 'mindfulness', 'music'],
      mood: MoodState.overwhelmed,
      style: CommunicationStyle.text,
      introvertLevel: 85,
    ),
    CompanionMatch(
      id: 'm2',
      name: 'Sam',
      interests: ['productivity', 'fitness', 'finance'],
      mood: MoodState.calm,
      style: CommunicationStyle.either,
      introvertLevel: 60,
    ),
    CompanionMatch(
      id: 'm3',
      name: 'Noor',
      interests: ['journaling', 'art', 'home'],
      mood: MoodState.lowEnergy,
      style: CommunicationStyle.voice,
      introvertLevel: 75,
    ),
    CompanionMatch(
      id: 'm4',
      name: 'Lena',
      interests: ['cooking', 'nature', 'mindfulness'],
      mood: MoodState.calm,
      style: CommunicationStyle.text,
      introvertLevel: 90,
    ),
    CompanionMatch(
      id: 'm5',
      name: 'Rafi',
      interests: ['music', 'travel', 'books'],
      mood: MoodState.lowEnergy,
      style: CommunicationStyle.either,
      introvertLevel: 70,
    ),
  ];

  final Set<String> _skippedMatchIds = {};

  Future<void> buildMatches() async {
    final available = _matchPool
        .where((m) => !_skippedMatchIds.contains(m.id))
        .toList();
    available.sort((a, b) {
      final bScore = _matchingService.score(
        me: _state.userProfile,
        candidate: b,
        currentMood: _state.moodState,
      );
      final aScore = _matchingService.score(
        me: _state.userProfile,
        candidate: a,
        currentMood: _state.moodState,
      );
      return bScore.compareTo(aScore);
    });
    _lastMatches = available;
    notifyListeners();
    await _analytics.logMatchView();
  }

  void skipMatch(String matchId) {
    _skippedMatchIds.add(matchId);
    _lastMatches =
        _lastMatches.where((m) => m.id != matchId).toList();
    notifyListeners();
  }

  // ── Misc ───────────────────────────────────────────────────────────────────

  Future<void> updateEaseScore(int newScore) async {
    _state = _state.copyWith(easeScore: newScore);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleEffects() async {
    _state = _state.copyWith(enableEffects: !_state.enableEffects);
    notifyListeners();
    await _persist();
  }

  Future<void> updateCategoryData(
      LifeCategory category, CategoryData data) async {
    final newCategories =
        Map<LifeCategory, CategoryData>.from(_state.categories);
    newCategories[category] = data;
    _state = _state.copyWith(categories: newCategories);
    _ensureConsistentCategoryStatus();
    notifyListeners();
    await _persist();
  }

  Future<void> resetState() async {
    await _authService.signOut();
    await _notifications.cancelAll();
    _state = AppState();
    _lastMatches = const [];
    _skippedMatchIds.clear();
    notifyListeners();
    await _persist();
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    try {
      await _storageService.saveAppState(_state);
    } catch (_) {}
  }

  double _progressFromTasks(int count) {
    if (count <= 0) return 0;
    if (count >= 8) return 1;
    return (count / 8).clamp(0.0, 1.0);
  }

  DepartmentStatus _statusFromProgress(double progress) {
    if (progress >= 0.7) return DepartmentStatus.stable;
    if (progress >= 0.35) return DepartmentStatus.inProgress;
    return DepartmentStatus.needsAttention;
  }

  void _ensureConsistentCategoryStatus() {
    final updated =
        Map<LifeCategory, CategoryData>.from(_state.categories);
    for (final entry in updated.entries) {
      final progress = _progressFromTasks(entry.value.tasks.length);
      updated[entry.key] = entry.value.copyWith(
        progress: progress,
        status: _statusFromProgress(progress),
      );
    }
    _state = _state.copyWith(categories: updated);
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
