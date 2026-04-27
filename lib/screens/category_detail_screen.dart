import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import '../services/app_state_provider.dart';
import 'dart:ui' as ui;
import '../models/models.dart';

class CategoryDetailScreen extends StatelessWidget {
  final LifeCategory category;

  const CategoryDetailScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>().state;
    final categoryData = appState.categories[category] ?? 
        CategoryData(category: category, title: "Category");

    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroSection(context, categoryData),
                const SizedBox(height: 48),
                _buildSafeStepsSection(context, categoryData),
                const SizedBox(height: 48),
                _buildTrustedGatewaysSection(context),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
      // Simplified bottom navigation for detail view
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: EaseTheme.background.withOpacity(0.8),
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
        ),
        child: ClipRRect(
          child: PerformanceAwareBlur(
            sigmaX: 20,
            sigmaY: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: EaseTheme.primaryContainer,
                      ),
                      child: const Icon(LucideIcons.user, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Ease",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: EaseTheme.primaryContainer,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.zap, color: Colors.grey),
                  onPressed: () {
                    context.read<AppStateProvider>().toggleEffects();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, CategoryData categoryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left part
        Container(
          padding: const EdgeInsets.all(32),
          decoration: EaseTheme.glassDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "YOUR ${categoryData.title.toUpperCase()} HORIZON",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EaseTheme.primarySage,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                categoryData.goal,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      color: EaseTheme.onSurface,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      Text(
                        "Progress toward stability",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14,
                              color: EaseTheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    "${(categoryData.progress * 100).toInt()}%",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          color: EaseTheme.primarySage,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: categoryData.progress,
                  minHeight: 16,
                  backgroundColor: EaseTheme.surfaceDim,
                  valueColor: const AlwaysStoppedAnimation<Color>(EaseTheme.primaryContainer),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "\"You're building a safety net that breathes with you.\"",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: EaseTheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Right part / Score breakdown
        Container(
          padding: const EdgeInsets.all(32),
          decoration: EaseTheme.glassDecoration,
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9DD4A0), width: 4),
                ),
                child: Center(
                  child: Text(
                    "${categoryData.score}",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          color: EaseTheme.primarySage,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${categoryData.title} Score",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryData.score > 80 ? "Stress is low. You are in the safe zone." : "Moderate attention required.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            color: EaseTheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafeStepsSection(BuildContext context, CategoryData categoryData) {
    final tasks = categoryData.tasks;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Safe Steps",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "${tasks.length} STEPS REMAINING",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF9DD4A0),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: EaseTheme.glassDecoration,
            child: Center(
              child: Text(
                "No tasks yet. Use the Brain Dump to add thoughts to this category.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EaseTheme.secondary,
                    ),
              ),
            ),
          )
        else
          ...tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildStepItem(context, LucideIcons.circle, task, "Identified by AI", false),
              )),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, IconData icon, String title, String subtitle, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isCompleted ? 0.4 : 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: isCompleted ? [] : EaseTheme.neumorphicShadows,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? EaseTheme.primarySage : EaseTheme.background,
              boxShadow: isCompleted ? [] : EaseTheme.neumorphicShadows,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : EaseTheme.primarySage,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 16,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? EaseTheme.secondary : EaseTheme.onSurface,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        color: EaseTheme.secondary,
                      ),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            const Icon(LucideIcons.chevronRight, color: EaseTheme.outline),
        ],
      ),
    );
  }

  Widget _buildTrustedGatewaysSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trusted Gateways",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          "Verified financial partners with low-risk profiles.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EaseTheme.secondary,
                fontSize: 14,
              ),
        ),
        const SizedBox(height: 24),
        // Large Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: EaseTheme.glassDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: EaseTheme.primarySage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EaseTheme.primarySage.withOpacity(0.2)),
                ),
                child: Text(
                  "BANK-REGULATED",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EaseTheme.primarySage,
                        fontSize: 10,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "City Bank",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      color: EaseTheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "High-Interest Savings for the mindful saver. No hidden fees, just growth.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EaseTheme.secondary,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "7.5% APY",
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                              color: EaseTheme.primarySage,
                            ),
                      ),
                      Text(
                        "Compounded Annually",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 12,
                              color: EaseTheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EaseTheme.surface,
                      foregroundColor: EaseTheme.primarySage,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text(
                      "Open Account",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: EaseTheme.primarySage,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.home, color: Colors.grey),
                onPressed: () => context.go('/dashboard'),
              ),
              IconButton(
                icon: const Icon(LucideIcons.layoutGrid, color: Colors.grey),
                onPressed: () {},
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EaseTheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-4, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.banknote, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(LucideIcons.user, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
