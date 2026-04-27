import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import '../services/app_state_provider.dart';
import 'dart:ui' as ui;

class EaseScoreScreen extends StatelessWidget {
  const EaseScoreScreen({Key? key}) : super(key: key);

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
                _buildEaseScoreGauge(context, appState.easeScore),
                const SizedBox(height: 48),
                _buildCategoryBreakdown(context),
                const SizedBox(height: 48),
                _buildInsightsSection(context),
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
                        border: Border.all(color: EaseTheme.primaryContainer, width: 2),
                      ),
                      child: const Icon(LucideIcons.user, color: EaseTheme.primaryContainer),
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

  Widget _buildEaseScoreGauge(BuildContext context, int score) {
    String feedback = "GOOD";
    if (score >= 90) feedback = "EXCELLENT";
    else if (score >= 70) feedback = "GREAT";
    else if (score >= 50) feedback = "BALANCED";
    else feedback = "STRESSED";

    return Column(
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
                  value: score / 100.0,
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
                    feedback,
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
          "Your current load",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: EaseTheme.onSurfaceVariant,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          score >= 80 ? "Light as a feather today." : "Take a deep breath.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category Breakdown",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard(
                context,
                "Health",
                "72% BALANCED",
                0.72,
                LucideIcons.heart,
                EaseTheme.primarySage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBreakdownCard(
                context,
                "Relationships",
                "91% BALANCED",
                0.91,
                LucideIcons.users,
                EaseTheme.tertiaryTerracotta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBreakdownCard(
          context,
          "Career",
          "64% BALANCED",
          0.64,
          LucideIcons.briefcase,
          EaseTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(BuildContext context, String title, String status, double progress, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EaseTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: EaseTheme.surfaceDim,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's driving your score?",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _buildInsightItem(
          context,
          LucideIcons.mail,
          EaseTheme.primaryContainer,
          "You've been carrying a lot of logistical weight lately. Taking 15 minutes to clear your inbox might bring that much-needed relief.",
        ),
        const SizedBox(height: 16),
        _buildInsightItem(
          context,
          LucideIcons.smile,
          EaseTheme.tertiaryTerracotta,
          "Your physical recovery is peaking. This is a gentle invitation to move your body through a sunset walk or light stretching.",
        ),
        const SizedBox(height: 16),
        _buildInsightItem(
          context,
          LucideIcons.moon,
          EaseTheme.secondary,
          "Consistent sleep patterns are anchoring your focus. Maintaining this rhythm for two more days will solidify this new baseline.",
        ),
      ],
    );
  }

  Widget _buildInsightItem(BuildContext context, IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EaseTheme.glassDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: EaseTheme.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: EaseTheme.background.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.3)),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, LucideIcons.home, "Home", false, () => context.go('/dashboard')),
              _buildNavItem(context, LucideIcons.barChart2, "Insights", true, () {}),
              _buildNavItem(context, LucideIcons.mic, "Voice", false, () => context.go('/voice-mode')),
              _buildNavItem(context, LucideIcons.bookOpen, "Journal", false, () {}),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: isActive
                ? BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Icon(
              icon,
              color: isActive ? EaseTheme.primarySage : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isActive ? EaseTheme.primarySage : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
