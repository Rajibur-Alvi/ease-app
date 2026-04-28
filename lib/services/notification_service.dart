import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static NotificationService? _instance;
  NotificationService._();
  factory NotificationService() =>
      _instance ??= NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Schedule a daily Brain Dump reminder at [hour]:[minute].
  Future<void> scheduleDailyBrainDumpReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    await _ensureInit();
    await _plugin.zonedSchedule(
      1,
      'Time to unload 🧠',
      'Take 2 minutes to Brain Dump — your mind will thank you.',
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ease_daily',
          'Daily Reminder',
          channelDescription: 'Gentle daily Brain Dump reminder',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a mood check-in reminder.
  Future<void> scheduleMoodCheckIn({int hour = 9, int minute = 0}) async {
    await _ensureInit();
    await _plugin.zonedSchedule(
      2,
      'How are you feeling? 😌',
      'A quick check-in takes 5 seconds.',
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ease_mood',
          'Mood Check-in',
          channelDescription: 'Morning mood check-in',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _ensureInit();
    await _plugin.cancelAll();
  }

  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
