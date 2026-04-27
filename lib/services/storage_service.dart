import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _appStateKey = 'ease_app_state_v1';

  Future<AppState> loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_appStateKey);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return AppState.fromJson(jsonMap);
      }
    } catch (e) {
      // Return default state on error
      print("Error loading state: \$e");
    }
    return AppState();
  }

  Future<void> saveAppState(AppState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_appStateKey, jsonString);
    } catch (e) {
      print("Error saving state: \$e");
    }
  }
}
