import 'package:flutter/material.dart';
import '../models/models.dart';
import 'storage_service.dart';
import 'ai_service.dart';

class AppStateProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AiService _aiService = AiService();
  AppState _state = AppState();
  bool _isLoading = true;

  AppStateProvider() {
    _loadInitialState();
  }

  AppState get state => _state;
  bool get isLoading => _isLoading;

  Future<void> _loadInitialState() async {
    _state = await _storageService.loadAppState();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(String content) async {
    final category = _aiService.categorizeThought(content);
    final entry = BrainDumpEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: content,
      createdAt: DateTime.now(),
      categorizedAs: category.name,
    );
    
    // Update main list
    final newEntries = List<BrainDumpEntry>.from(_state.brainDumpEntries)..add(entry);
    
    // Update specific category data
    final newCategories = Map<LifeCategory, CategoryData>.from(_state.categories);
    final catData = newCategories[category] ?? CategoryData(category: category, title: category.name);
    
    final newTasks = List<String>.from(catData.tasks)..add(content);
    newCategories[category] = catData.copyWith(
      tasks: newTasks,
      score: (catData.score - 5).clamp(0, 100), // Adding a task slightly lowers the "Ease" score for that category
    );

    _state = _state.copyWith(
      brainDumpEntries: newEntries,
      categories: newCategories,
      stressorsOffloadedThisWeek: _state.stressorsOffloadedThisWeek + 1,
    );
    
    notifyListeners();
    await _storageService.saveAppState(_state);
  }

  Future<void> updateEaseScore(int newScore) async {
    _state = _state.copyWith(easeScore: newScore);
    notifyListeners();
    await _storageService.saveAppState(_state);
  }

  Future<void> toggleEffects() async {
    _state = _state.copyWith(enableEffects: !_state.enableEffects);
    notifyListeners();
    await _storageService.saveAppState(_state);
  }

  Future<void> updateCategoryData(LifeCategory category, CategoryData data) async {
    final newCategories = Map<LifeCategory, CategoryData>.from(_state.categories);
    newCategories[category] = data;
    _state = _state.copyWith(categories: newCategories);
    notifyListeners();
    await _storageService.saveAppState(_state);
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _state = _state.copyWith(userProfile: profile);
    notifyListeners();
    await _storageService.saveAppState(_state);
  }

  // Method to clear state (for testing/reset)
  Future<void> resetState() async {
    _state = AppState();
    notifyListeners();
    await _storageService.saveAppState(_state);
  }
}
