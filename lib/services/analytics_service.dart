import '../models/analytics_models.dart';
import 'database_service.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  AnalyticsService._();
  factory AnalyticsService() => _instance ??= AnalyticsService._();

  final _db = DatabaseService();

  Future<void> logBrainDump(String category) async {
    await _db.logEvent(UsageEvent(
      type: 'brain_dump',
      timestamp: DateTime.now(),
      meta: {'category': category},
    ));
  }

  Future<void> logMoodCheck(String mood) async {
    await _db.logEvent(UsageEvent(
      type: 'mood_check',
      timestamp: DateTime.now(),
      meta: {'mood': mood},
    ));
  }

  Future<void> logMatchView() async {
    await _db.logEvent(UsageEvent(
      type: 'match_view',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> logChatOpen() async {
    await _db.logEvent(UsageEvent(
      type: 'chat_open',
      timestamp: DateTime.now(),
    ));
  }

  Future<AnalyticsSummary> getSummary() => _db.getAnalytics();
}
