import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/task_detail_sheet.dart';

class LifeDepartmentsScreen extends StatelessWidget {
  const LifeDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>().state;
    final controller = context.read<AppStateProvider>();
    final departments = appState.categories.values.toList();

    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: EaseTheme.background,
        elevation: 0,
        title: const Text('Life Departments'),
      ),
      body: departments.isEmpty
          ? Center(
              child: EmptyStateCard(
                title: 'No departments yet',
                message: 'Start by using Brain Dump to clear your mind.',
                ctaLabel: 'Brain Dump',
                onTap: () => context.push('/brain-dump'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(EaseSpace.lg),
              itemCount: departments.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: EaseSpace.sm),
              itemBuilder: (context, index) => _DepartmentCard(
                category: departments[index],
                tasks: appState.tasks,
                controller: controller,
              ),
            ),
    );
  }
}

class _DepartmentCard extends StatefulWidget {
  final CategoryData category;
  final List<TaskItem> tasks;
  final AppStateProvider controller;

  const _DepartmentCard({
    required this.category,
    required this.tasks,
    required this.controller,
  });

  @override
  State<_DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<_DepartmentCard> {
  bool _expanded = false;
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryTasks = widget.tasks
        .where((t) => t.category == widget.category.category)
        .toList();
    final visibleTasks =
        _expanded ? categoryTasks : categoryTasks.take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            borderRadius: EaseRadius.md,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(EaseSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _categoryEmoji(widget.category.category),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: EaseSpace.xs),
                      Expanded(
                        child: Text(
                          widget.category.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 17),
                        ),
                      ),
                      _StatusBadge(status: widget.category.status),
                      const SizedBox(width: EaseSpace.xs),
                      Icon(
                        _expanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 18,
                        color: EaseTheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: EaseSpace.xs),
                  ClipRRect(
                    borderRadius: EaseRadius.pill,
                    child: LinearProgressIndicator(
                      value: widget.category.progress,
                      minHeight: 5,
                      backgroundColor: EaseTheme.surfaceDim,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressColor(widget.category.status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(widget.category.progress * 100).round()}% · ${widget.category.goal}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: EaseTheme.secondary),
                  ),
                ],
              ),
            ),
          ),

          // Tasks
          if (_expanded) ...[
            const Divider(height: 1, color: EaseTheme.surfaceDim),
            if (visibleTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(EaseSpace.md),
                child: Text(
                  'No tasks yet. Add one below.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 13, color: EaseTheme.secondary),
                ),
              )
            else
              ...visibleTasks.map(
                (task) => _TaskRow(
                  task: task,
                  controller: widget.controller,
                ),
              ),
            if (categoryTasks.length > 2 && !_expanded)
              TextButton(
                onPressed: () => setState(() => _expanded = true),
                child: Text(
                    'Show ${categoryTasks.length - 2} more'),
              ),

            // Add micro-task
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  EaseSpace.md, 0, EaseSpace.md, EaseSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Add a micro-task...',
                        isDense: true,
                      ),
                      onSubmitted: _addTask,
                    ),
                  ),
                  const SizedBox(width: EaseSpace.xs),
                  IconButton(
                    onPressed: () => _addTask(_inputController.text),
                    icon: const Icon(LucideIcons.plus, size: 20),
                    color: EaseTheme.primarySage,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addTask(String value) {
    if (value.trim().isEmpty) return;
    HapticFeedback.selectionClick();
    widget.controller.addTask(
      value,
      category: widget.category.category,
      source: 'life_department',
    );
    _inputController.clear();
  }

  String _categoryEmoji(LifeCategory cat) {
    switch (cat) {
      case LifeCategory.health:
        return '🌿';
      case LifeCategory.workCareer:
        return '💼';
      case LifeCategory.finances:
        return '💰';
      case LifeCategory.family:
        return '🏠';
      case LifeCategory.relationships:
        return '🤝';
      case LifeCategory.homeEnvironment:
        return '🏡';
      case LifeCategory.personalGrowth:
        return '🌱';
      case LifeCategory.timeManagement:
        return '⏰';
    }
  }

  Color _progressColor(DepartmentStatus status) {
    switch (status) {
      case DepartmentStatus.stable:
        return EaseTheme.primarySage;
      case DepartmentStatus.inProgress:
        return EaseTheme.primaryContainer;
      case DepartmentStatus.needsAttention:
        return EaseTheme.tertiaryTerracotta;
    }
  }
}

class _TaskRow extends StatelessWidget {
  final TaskItem task;
  final AppStateProvider controller;

  const _TaskRow({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: EaseSpace.md, vertical: 0),
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.toggleTaskCompletion(task.id);
        },
        child: AnimatedContainer(
          duration: EaseMotion.standard,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: task.completed
                ? EaseTheme.primarySage
                : Colors.transparent,
            borderRadius: EaseRadius.sm,
            border: Border.all(
              color: task.completed
                  ? EaseTheme.primarySage
                  : EaseTheme.surfaceDim,
              width: 1.5,
            ),
          ),
          child: task.completed
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
      ),
      title: Text(
        task.title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              decoration:
                  task.completed ? TextDecoration.lineThrough : null,
              color: task.completed ? EaseTheme.secondary : EaseTheme.onSurface,
            ),
      ),
      trailing: IconButton(
        icon: const Icon(LucideIcons.moreHorizontal, size: 16),
        onPressed: () => showTaskDetailSheet(
          context,
          task: task,
          controller: controller,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DepartmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      DepartmentStatus.stable => 'Stable',
      DepartmentStatus.inProgress => 'In Progress',
      DepartmentStatus.needsAttention => 'Needs Attention',
    };
    final color = switch (status) {
      DepartmentStatus.stable => EaseTheme.primarySage,
      DepartmentStatus.inProgress => EaseTheme.primaryContainer,
      DepartmentStatus.needsAttention => EaseTheme.tertiaryTerracotta,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: EaseSpace.xs, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: EaseRadius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
