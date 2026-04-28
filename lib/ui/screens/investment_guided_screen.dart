import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class InvestmentGuidedScreen extends StatefulWidget {
  const InvestmentGuidedScreen({super.key});

  @override
  State<InvestmentGuidedScreen> createState() => _InvestmentGuidedScreenState();
}

class _InvestmentGuidedScreenState extends State<InvestmentGuidedScreen> {
  _InvestmentGoal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: EaseTheme.background,
        elevation: 0,
        title: const Text('Investment Guidance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(EaseSpace.lg),
        children: [
          Text(
            'What do you want to do?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: EaseSpace.xs),
          Text(
            'Choose a goal and we\'ll show you the right path.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 14, color: EaseTheme.secondary),
          ),
          const SizedBox(height: EaseSpace.md),

          // Goal selector
          Row(
            children: _InvestmentGoal.values.map((goal) {
              final selected = _selectedGoal == goal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: EaseSpace.xs),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGoal = goal),
                    child: AnimatedContainer(
                      duration: EaseMotion.standard,
                      padding: const EdgeInsets.symmetric(
                          vertical: EaseSpace.md, horizontal: EaseSpace.xs),
                      decoration: BoxDecoration(
                        color: selected
                            ? EaseTheme.primarySage
                            : Colors.white.withValues(alpha: 0.78),
                        borderRadius: EaseRadius.md,
                        border: Border.all(
                          color: selected
                              ? EaseTheme.primarySage
                              : EaseTheme.surfaceDim,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _goalIcon(goal),
                            color: selected
                                ? Colors.white
                                : EaseTheme.primarySage,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _goalLabel(goal),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : EaseTheme.onSurface,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedGoal != null) ...[
            const SizedBox(height: EaseSpace.md),
            _GoalTip(goal: _selectedGoal!),
          ],

          const SizedBox(height: EaseSpace.lg),

          Text(
            'VERIFIED INSTITUTIONS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  color: EaseTheme.secondary,
                ),
          ),
          const SizedBox(height: EaseSpace.sm),

          ..._institutions.map(
            (inst) => Padding(
              padding: const EdgeInsets.only(bottom: EaseSpace.sm),
              child: _InstitutionCard(institution: inst),
            ),
          ),

          const SizedBox(height: EaseSpace.xxl),
        ],
      ),
    );
  }

  IconData _goalIcon(_InvestmentGoal goal) {
    switch (goal) {
      case _InvestmentGoal.save:
        return LucideIcons.piggyBank;
      case _InvestmentGoal.invest:
        return LucideIcons.shieldCheck;
      case _InvestmentGoal.grow:
        return LucideIcons.trendingUp;
    }
  }

  String _goalLabel(_InvestmentGoal goal) {
    switch (goal) {
      case _InvestmentGoal.save:
        return 'Save\nmoney';
      case _InvestmentGoal.invest:
        return 'Invest\nsafely';
      case _InvestmentGoal.grow:
        return 'Grow\nwealth';
    }
  }
}

class _GoalTip extends StatelessWidget {
  final _InvestmentGoal goal;

  const _GoalTip({required this.goal});

  @override
  Widget build(BuildContext context) {
    final tip = switch (goal) {
      _InvestmentGoal.save =>
        'Start with a savings account at a regulated bank. Aim to save 10–20% of your income each month.',
      _InvestmentGoal.invest =>
        'Consider government bonds or fixed deposits for low-risk, steady returns.',
      _InvestmentGoal.grow =>
        'Diversify across mutual funds, stocks, and real estate over time. Start small and stay consistent.',
    };
    return Container(
      padding: const EdgeInsets.all(EaseSpace.md),
      decoration: BoxDecoration(
        color: EaseTheme.primarySage.withValues(alpha: 0.08),
        borderRadius: EaseRadius.md,
        border: Border.all(
            color: EaseTheme.primarySage.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lightbulb,
              color: EaseTheme.primarySage, size: 18),
          const SizedBox(width: EaseSpace.sm),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 14, color: EaseTheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  final _Institution institution;

  const _InstitutionCard({required this.institution});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: EaseRadius.md,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: EaseTheme.primarySage.withValues(alpha: 0.1),
            borderRadius: EaseRadius.sm,
          ),
          child: const Icon(LucideIcons.building2,
              color: EaseTheme.primarySage, size: 20),
        ),
        title: Text(
          institution.name,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          institution.description,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: EaseTheme.secondary),
        ),
        trailing: institution.url != null
            ? IconButton(
                icon: const Icon(LucideIcons.externalLink,
                    size: 16, color: EaseTheme.primarySage),
                onPressed: () async {
                  final uri = Uri.parse(institution.url!);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              )
            : null,
      ),
    );
  }
}

enum _InvestmentGoal { save, invest, grow }

class _Institution {
  final String name;
  final String description;
  final String? url;

  const _Institution(
      {required this.name, required this.description, this.url});
}

const _institutions = [
  _Institution(
    name: 'Bangladesh Bank',
    description: 'Central regulatory authority · Government backed',
    url: 'https://www.bb.org.bd',
  ),
  _Institution(
    name: 'Sonali Bank',
    description: 'Largest state-owned commercial bank',
    url: 'https://www.sonalibank.com.bd',
  ),
  _Institution(
    name: 'BRAC Bank',
    description: 'Leading private bank · SME focused',
    url: 'https://www.bracbank.com',
  ),
  _Institution(
    name: 'Islami Bank Bangladesh',
    description: 'Shariah-compliant banking',
    url: 'https://www.islamibankbd.com',
  ),
  _Institution(
    name: 'City Bank',
    description: 'Retail & corporate banking',
    url: 'https://www.thecitybank.com',
  ),
];
