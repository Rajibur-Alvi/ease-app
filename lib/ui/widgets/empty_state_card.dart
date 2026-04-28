import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final String ctaLabel;
  final VoidCallback onTap;
  final IconData? icon;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    required this.ctaLabel,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EaseSpace.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: EaseRadius.lg,
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon ?? LucideIcons.brainCircuit,
            size: 36,
            color: EaseTheme.primarySage.withValues(alpha: 0.5),
          ),
          const SizedBox(height: EaseSpace.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: EaseSpace.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  color: EaseTheme.secondary,
                ),
          ),
          const SizedBox(height: EaseSpace.lg),
          FilledButton(onPressed: onTap, child: Text(ctaLabel)),
        ],
      ),
    );
  }
}
