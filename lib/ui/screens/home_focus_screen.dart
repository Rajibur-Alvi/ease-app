import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';
import '../widgets/skeleton_loader.dart';

class HomeFocusScreen extends StatefulWidget {
  const HomeFocusScreen({super.key});

  @override
  State<HomeFocusScreen> createState() => _HomeFocusScreenState();
}

class _HomeFocusScreenState extends State<HomeFocusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: EaseTheme.background,
        body: SafeArea(child: HomeScreenSkeleton()),
      );
    }
    final appState = provider.state;
    final priorityCards = appState.categories.values
        .where((c) => c.status == DepartmentStatus.needsAttention)
        .take(2)
        .toList();
    final fallbackCards = appState.categories.values.take(2).toList();
    final displayCards = priorityCards.isNotEmpty ? priorityCards : fallbackCards;

    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    EaseSpace.lg, EaseSpace.lg, EaseSpace.lg, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: EaseTheme.secondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appState.userProfile.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                    _AvatarBadge(name: appState.userProfile.name),
                  ],
                ),
              ),
            ),

            // Mood check-in
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    EaseSpace.lg, EaseSpace.lg, EaseSpace.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: EaseTheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: EaseSpace.sm),
                    Row(
                      children: MoodState.values.map((mood) {
                        final selected = appState.moodState == mood;
                        return Padding(
                          padding: const EdgeInsets.only(right: EaseSpace.xs),
                          child: _MoodChip(
                            mood: mood,
                            selected: selected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context
                                  .read<AppStateProvider>()
                                  .setMoodState(mood);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Brain Dump CTA — primary action
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(EaseSpace.lg),
                child: _BrainDumpButton(pulseAnimation: _pulseAnimation),
              ),
            ),

            // Priority cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: EaseSpace.lg),
                child: Text(
                  'FOCUS AREAS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: EaseTheme.secondary,
                      ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: EaseSpace.sm)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: EaseSpace.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < displayCards.length) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: EaseSpace.sm),
                        child: _PriorityCard(category: displayCards[index]),
                      );
                    }
                    return null;
                  },
                  childCount: displayCards.length,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EaseSpace.lg, vertical: EaseSpace.xs),
                child: TextButton.icon(
                  onPressed: () => context.go('/life'),
                  icon: const Icon(LucideIcons.layoutGrid, size: 16),
                  label: const Text('See all life departments'),
                ),
              ),
            ),

            // Recent brain dump
            if (appState.brainDumpEntries.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      EaseSpace.lg, EaseSpace.md, EaseSpace.lg, EaseSpace.sm),
                  child: Text(
                    'RECENT REFLECTION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.4,
                          color: EaseTheme.secondary,
                        ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: EaseSpace.lg),
                  child: _RecentEntryCard(
                      entry: appState.brainDumpEntries.first),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _MoodChip extends StatelessWidget {
  final MoodState mood;
  final bool selected;
  final VoidCallback onTap;

  const _MoodChip(
      {required this.mood, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = _label(mood);
    final emoji = _emoji(mood);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: EaseMotion.standard,
        padding: const EdgeInsets.symmetric(
            horizontal: EaseSpace.sm, vertical: EaseSpace.xs),
        decoration: BoxDecoration(
          color: selected
              ? EaseTheme.primarySage
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: EaseRadius.pill,
          border: Border.all(
            color: selected ? EaseTheme.primarySage : EaseTheme.surfaceDim,
          ),
        ),
        child: Text(
          '$emoji $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : EaseTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  String _label(MoodState m) {
    switch (m) {
      case MoodState.calm:
        return 'Calm';
      case MoodState.overwhelmed:
        return 'Overwhelmed';
      case MoodState.lowEnergy:
        return 'Low Energy';
    }
  }

  String _emoji(MoodState m) {
    switch (m) {
      case MoodState.calm:
        return '😌';
      case MoodState.overwhelmed:
        return '😤';
      case MoodState.lowEnergy:
        return '😴';
    }
  }
}

class _BrainDumpButton extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const _BrainDumpButton({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push('/brain-dump');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              vertical: EaseSpace.xl, horizontal: EaseSpace.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [EaseTheme.primarySage, EaseTheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: EaseRadius.xl,
            boxShadow: [
              BoxShadow(
                color: EaseTheme.primarySage.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(LucideIcons.brainCircuit,
                  color: Colors.white, size: 36),
              const SizedBox(height: EaseSpace.sm),
              Text(
                'Brain Dump',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: EaseSpace.xs),
              Text(
                'Unload what\'s on your mind',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final CategoryData category;

  const _PriorityCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EaseSpace.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 16),
              ),
              _StatusBadge(status: category.status),
            ],
          ),
          const SizedBox(height: EaseSpace.xs),
          ClipRRect(
            borderRadius: EaseRadius.pill,
            child: LinearProgressIndicator(
              value: category.progress,
              minHeight: 6,
              backgroundColor: EaseTheme.surfaceDim,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progressColor(category.status),
              ),
            ),
          ),
          const SizedBox(height: EaseSpace.xs),
          Text(
            '${(category.progress * 100).round()}% · ${category.goal}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: EaseTheme.secondary),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(
          horizontal: EaseSpace.xs, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: EaseRadius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _RecentEntryCard extends StatelessWidget {
  final BrainDumpEntry entry;

  const _RecentEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EaseSpace.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.text.length > 120
                ? '${entry.text.substring(0, 120)}...'
                : entry.text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 14, color: EaseTheme.secondary),
          ),
          if (entry.categorizedAs != null) ...[
            const SizedBox(height: EaseSpace.xs),
            Text(
              '→ ${entry.categorizedAs}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EaseTheme.primarySage,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String name;

  const _AvatarBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: EaseTheme.primaryContainer.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'E',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: EaseTheme.primarySage,
        ),
      ),
    );
  }
}
