import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import '../services/app_state_provider.dart';
import 'dart:ui' as ui;

class ReliefReportScreen extends StatelessWidget {
  const ReliefReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>().state;

    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroSection(context),
                const SizedBox(height: 48),
                _buildEaseScoreSection(context, appState.easeScore, appState.stressorsOffloadedThisWeek),
                const SizedBox(height: 48),
                _buildBentoRecommendations(context),
                const SizedBox(height: 48),
                _buildInsightStream(context),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
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
                        color: EaseTheme.surfaceDim,
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: const Icon(LucideIcons.user, color: Colors.grey, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Mindful Space",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: EaseTheme.primarySage,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            fontSize: 18,
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

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "You cleared a lot.",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                color: EaseTheme.primarySage,
                fontFamily: 'Lora',
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Here's your weekly relief report.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: EaseTheme.secondary,
                fontFamily: 'Noto Serif',
              ),
        ),
      ],
    );
  }

  Widget _buildEaseScoreSection(BuildContext context, int score, int offloaded) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: EaseTheme.glassDecoration,
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: EaseTheme.surfaceDim,
                    valueColor: const AlwaysStoppedAnimation<Color>(EaseTheme.primaryContainer),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$score",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                    Text(
                      "EASE SCORE",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            letterSpacing: 2.0,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "\"Your mental sky is clearing. You've offloaded $offloaded thoughts this week.\"",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: EaseTheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoRecommendations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Just for you",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: EaseTheme.primarySage,
                  ),
            ),
            Text(
              "LOCAL DISCOVERY",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EaseTheme.secondary,
                    letterSpacing: 2.0,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Simplified Bento Grid for Flutter
        _buildMainBentoCard(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSideBentoCard(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildSurpriseMeCard(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildMainBentoCard(BuildContext context) {
    return Container(
      decoration: EaseTheme.glassDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            color: EaseTheme.primarySage.withOpacity(0.3),
            child: const Center(child: Icon(LucideIcons.image, size: 48, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8F0BB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "HEALTH",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1E5029),
                          fontSize: 10,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sunset Meditation at Park West",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.banknote, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("\$", style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 16),
                        const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("0.8 mi", style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const Icon(LucideIcons.chevronRight, color: EaseTheme.primarySage),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBentoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EaseTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EaseTheme.tertiaryTerracotta.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.gamepad2, color: EaseTheme.tertiaryTerracotta),
          ),
          const SizedBox(height: 16),
          Text(
            "SOCIAL",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EaseTheme.tertiaryTerracotta,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Retro Gaming Night",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 16),
          Text("Free Entry", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Text("1.2 mi", style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSurpriseMeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EaseTheme.primarySage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: EaseTheme.primarySage.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(LucideIcons.sparkles, color: EaseTheme.primarySage),
          ),
          const SizedBox(height: 16),
          Text(
            "Feeling adventurous?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  color: EaseTheme.primarySage,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: EaseTheme.primarySage,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Text(
              "GENERATE RELIEF",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightStream(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Insight Stream",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: EaseTheme.primarySage,
              ),
        ),
        const SizedBox(height: 16),
        _buildInsightRow(
          context,
          EaseTheme.primarySage,
          "Peak Relief Day",
          "Wednesday was your most intentional day this week.",
          "11:00 AM",
        ),
        const SizedBox(height: 16),
        _buildInsightRow(
          context,
          EaseTheme.tertiaryTerracotta,
          "Cognitive Weight",
          "Work-related stress reduced by 15% since Monday.",
          "TREND UP",
        ),
      ],
    );
  }

  Widget _buildInsightRow(BuildContext context, Color color, String title, String subtitle, String trailing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EaseTheme.glassDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: EaseTheme.secondary,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            trailing,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EaseTheme.secondary,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: EaseTheme.background.withOpacity(0.8),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        child: PerformanceAwareBlur(
          sigmaX: 20,
          sigmaY: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, LucideIcons.mic, "Offload", false, () => context.go('/voice-mode')),
              _buildNavItem(context, LucideIcons.barChart2, "Relief", true, () {}),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: isActive
                ? BoxDecoration(
                    color: EaseTheme.primarySage,
                    borderRadius: BorderRadius.circular(24),
                  )
                : null,
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isActive ? EaseTheme.primarySage : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
