import '../models/models.dart';

class ReminderService {
  final List<String> _scheduledReminders = [];

  Future<void> scheduleTaskReminder(TaskItem task) async {
    if (task.reminderAt == null) return;
    final record = '${task.id}|${task.reminderAt!.toIso8601String()}';
    if (!_scheduledReminders.contains(record)) {
      _scheduledReminders.add(record);
    }
  }

  List<String> get scheduledReminders => List.unmodifiable(_scheduledReminders);
}
