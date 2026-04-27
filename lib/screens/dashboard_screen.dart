import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import '../services/app_state_provider.dart';
import 'dart:ui' as ui;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>().state;

    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlob(const Color(0xFF6A9E6F).withOpacity(0.3), 300),
          ),
          
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeSection(context, appState.userProfile.name),
                      const SizedBox(height: 32),
                      _buildEaseScoreModule(context, appState.easeScore, appState.stressorsOffloadedThisWeek),
                      const SizedBox(height: 32),
                      _buildBentoGrid(context),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Brain Dump Button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () {
                  context.go('/voice-mode'); 
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [EaseTheme.primaryContainer, Color(0xFF8DBA91)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EaseTheme.primaryContainer.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.mic, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        "BRAIN DUMP",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNav(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const PerformanceAwareBlur(
        sigmaX: 80,
        sigmaY: 80,
        child: SizedBox.expand(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: EaseTheme.background.withOpacity(0.6),
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
                        color: EaseTheme.surfaceDim,
                        border: Border.all(color: Colors.white, width: 2),
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
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EaseTheme.surface,
                    boxShadow: EaseTheme.neumorphicShadows,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.zap, color: Colors.grey),
                    tooltip: "Toggle Performance Mode",
                    onPressed: () {
                      context.read<AppStateProvider>().toggleEffects();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good morning, $name",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Your mind feels lighter today.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EaseTheme.secondary,
                fontSize: 14,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(context, "Connections", LucideIcons.users, () => context.go('/connections')),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAction(context, "Investments", LucideIcons.landmark, () => context.go('/investments')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: EaseTheme.surfaceDim),
        ),
        child: Column(
          children: [
            Icon(icon, color: EaseTheme.primarySage, size: 24),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEaseScoreModule(BuildContext context, int score, int stressorsCount) {
    return _GlassCard(
      onTap: () => context.go('/ease-score'),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EASE SCORE",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EaseTheme.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$score",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            color: EaseTheme.primaryContainer,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(LucideIcons.arrowDown,
                            size: 14, color: EaseTheme.tertiaryTerracotta),
                        const SizedBox(width: 4),
                        Text(
                          "stable this week",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: EaseTheme.tertiaryTerracotta,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "You've successfully offloaded $stressorsCount items this week.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: EaseTheme.secondary.withOpacity(0.8),
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 8,
                    backgroundColor: EaseTheme.surfaceDim,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        EaseTheme.primaryContainer),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Icon(
                  LucideIcons.leaf,
                  color: EaseTheme.primaryContainer,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _BentoCard(
                accentColor: EaseTheme.primaryContainer,
                icon: LucideIcons.heart,
                title: "Health",
                subtitle: "Your mental vitality",
                status: "IN PROGRESS",
                progress: 0.75,
                onTap: () => context.go('/category-detail?category=health'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _BentoCard(
                accentColor: const Color(0xFFC77C90),
                icon: LucideIcons.briefcase,
                title: "Work",
                subtitle: "Career growth",
                onTap: () => context.go('/category-detail?category=workCareer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _BentoCard(
                accentColor: const Color(0xFFE9B384),
                icon: LucideIcons.banknote,
                title: "Finances",
                subtitle: "Stress level: low",
                onTap: () => context.go('/category-detail?category=finances'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _BentoCard(
                accentColor: EaseTheme.primarySage.withOpacity(0.4),
                icon: LucideIcons.users,
                title: "Family",
                subtitle: "Stay connected",
                status: "STABLE",
                statusColor: const Color(0xFFE1F5E2),
                statusTextColor: const Color(0xFF1E5029),
                onTap: () => context.go('/category-detail?category=family'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _BentoCard(
                accentColor: const Color(0xFF9E84E9),
                icon: LucideIcons.heartHandshake,
                title: "Relationships",
                subtitle: "Meaningful bonds",
                onTap: () => context.go('/category-detail?category=relationships'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _BentoCard(
                accentColor: const Color(0xFF6A9E6F),
                icon: LucideIcons.home,
                title: "Home",
                subtitle: "Your sanctuary",
                onTap: () => context.go('/category-detail?category=homeEnvironment'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => context.go('/categories'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("VIEW ALL CATEGORIES", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EaseTheme.primarySage, letterSpacing: 2.0)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, size: 16, color: EaseTheme.primarySage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 16, left: 32, right: 32),
      decoration: BoxDecoration(
        color: EaseTheme.background.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: ClipRRect(
        child: PerformanceAwareBlur(
          sigmaX: 20,
          sigmaY: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, LucideIcons.home, "Home", true, () {}),
              _buildNavItem(context, LucideIcons.layoutGrid, "Categories", false, () => context.go('/categories')),
              _buildNavItem(context, LucideIcons.barChart2, "Insights", false, () => context.go('/ease-score')),
              _buildNavItem(context, LucideIcons.user, "Profile", false, () => context.go('/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: isActive
                ? BoxDecoration(
                    color: EaseTheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: EaseTheme.neumorphicShadows,
                  )
                : const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isActive ? EaseTheme.primaryContainer : Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const _GlassCard({
    required this.child,
    required this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: EaseTheme.glassDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: child,
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? status;
  final Color? statusColor;
  final Color? statusTextColor;
  final double? progress;
  final VoidCallback? onTap;

  const _BentoCard({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.statusColor,
    this.statusTextColor,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: -20,
            bottom: -20,
            width: 4,
            child: Container(color: accentColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: accentColor, size: 28),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor ?? EaseTheme.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: statusTextColor ?? EaseTheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EaseTheme.secondary.withOpacity(0.6),
                    ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: accentColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
