import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityService>().isOnline;
    return AnimatedSlide(
      offset: isOnline ? const Offset(0, -1) : Offset.zero,
      duration: EaseMotion.emphasized,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isOnline ? 0 : 1,
        duration: EaseMotion.emphasized,
        child: Container(
          width: double.infinity,
          color: EaseTheme.tertiaryTerracotta,
          padding: const EdgeInsets.symmetric(
              vertical: EaseSpace.xs, horizontal: EaseSpace.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff,
                  size: 14, color: Colors.white),
              const SizedBox(width: EaseSpace.xs),
              Text(
                'You\'re offline — changes saved locally',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
