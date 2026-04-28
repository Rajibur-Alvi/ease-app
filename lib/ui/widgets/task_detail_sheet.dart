import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

Future<void> showTaskDetailSheet(
  BuildContext context, {
  required TaskItem task,
  required AppStateProvider controller,
}) async {
  TaskPriority priority = task.priority;
  final titleController = TextEditingController(text: task.title);
  final tagsController = TextEditingController(text: task.tags.join(', '));
  DateTime? dueAt = task.dueAt;
  DateTime? reminderAt = task.reminderAt;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: EaseTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: EaseSpace.lg,
              right: EaseSpace.lg,
              top: EaseSpace.lg,
              bottom: MediaQuery.of(context).viewInsets.bottom + EaseSpace.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task details', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: EaseSpace.md),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: EaseSpace.sm),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: priority,
                  items: TaskPriority.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => priority = value);
                  },
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: EaseSpace.sm),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                  ),
                ),
                const SizedBox(height: EaseSpace.md),
                Wrap(
                  spacing: EaseSpace.sm,
                  runSpacing: EaseSpace.sm,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDate: dueAt ?? DateTime.now(),
                        );
                        if (date != null) setState(() => dueAt = date);
                      },
                      child: Text(dueAt == null
                          ? 'Set due date'
                          : 'Due: ${dueAt!.month}/${dueAt!.day}'),
                    ),
                    OutlinedButton(
                      onPressed: dueAt == null
                          ? null
                          : () => setState(() => reminderAt = dueAt),
                      child: Text(reminderAt == null
                          ? 'Scaffold reminder'
                          : 'Reminder ready'),
                    ),
                  ],
                ),
                const SizedBox(height: EaseSpace.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final tags = tagsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      await controller.updateTask(
                        task.copyWith(
                          title: titleController.text.trim().isEmpty
                              ? task.title
                              : titleController.text.trim(),
                          dueAt: dueAt,
                          reminderAt: reminderAt,
                          priority: priority,
                          tags: tags,
                        ),
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  titleController.dispose();
  tagsController.dispose();
}
