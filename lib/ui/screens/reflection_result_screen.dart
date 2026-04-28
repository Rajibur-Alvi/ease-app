import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class ReflectionResultScreen extends StatefulWidget {
  const ReflectionResultScreen({super.key});

  @override
  State<ReflectionResultScreen> createState() => _ReflectionResultScreenState();
}

class _ReflectionResultScreenState extends State<ReflectionResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));
    _enterController.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reflection = context.watch<AppStateProvider>().state.lastReflection;

    if (reflection == null) {
      return Scaffold(
        backgroundColor: EaseTheme.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.brainCircuit,
                  size: 48, color: EaseTheme.primarySage),
              const SizedBox(height: EaseSpace.md),
              Text(
                'Nothing to reflect on yet.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: EaseSpace.lg),
              FilledButton(
                onPressed: () => context.go('/brain-dump'),
                child: const Text('Start Brain Dump'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: EaseTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Your Reflection'),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideIn,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(EaseSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(EaseSpace.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [EaseTheme.primarySage, EaseTheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: EaseRadius.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We heard you',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 1.2),
                        ),
                        const SizedBox(height: EaseSpace.xs),
                        Text(
                          reflection.summary,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: EaseSpace.md),

                  // Category
                  _InfoCard(
                    icon: LucideIcons.tag,
                    title: 'Categorized under',
                    body: _categoryLabel(reflection.category),
                    iconColor: EaseTheme.primarySage,
                  ),

                  const SizedBox(height: EaseSpace.sm),

                  // Suggested action
                  _InfoCard(
                    icon: LucideIcons.zap,
                    title: 'One small step',
                    body: reflection.suggestedAction,
                    iconColor: EaseTheme.tertiaryTerracotta,
                  ),

                  const Spacer(),

                  // Connection CTA
                  if (reflection.suggestConnection) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/connect'),
                        icon: const Icon(LucideIcons.messageCircle),
                        label: const Text('Talk to someone who understands'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: EaseTheme.primarySage),
                          foregroundColor: EaseTheme.primarySage,
                        ),
                      ),
                    ),
                    const SizedBox(height: EaseSpace.sm),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Return to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _categoryLabel(LifeCategory category) {
    switch (category) {
      case LifeCategory.health:
        return '🌿 Health';
      case LifeCategory.workCareer:
        return '💼 Work / Career';
      case LifeCategory.finances:
        return '💰 Finance';
      case LifeCategory.family:
        return '🏠 Family';
      case LifeCategory.relationships:
        return '🤝 Relationships';
      case LifeCategory.homeEnvironment:
        return '🏡 Home';
      case LifeCategory.personalGrowth:
        return '🌱 Personal Growth';
      case LifeCategory.timeManagement:
        return '⏰ Time Management';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EaseSpace.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(EaseSpace.xs),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: EaseRadius.sm,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: EaseSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: EaseTheme.secondary)),
                const SizedBox(height: 4),
                Text(body,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
