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
    } catch (_) {
      // Return default state on parse/storage errors.
    }
    return AppState();
  }

  Future<void> saveAppState(AppState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_appStateKey, jsonString);
    } catch (_) {
      // Ignore write errors in scaffolded local persistence.
    }
  }
}
