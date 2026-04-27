import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../services/app_state_provider.dart';

class PerformanceAwareBlur extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final double? opacity;

  const PerformanceAwareBlur({
    Key? key,
    required this.child,
    this.sigmaX = 20.0,
    this.sigmaY = 20.0,
    this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enableEffects = context.select<AppStateProvider, bool>(
      (provider) => provider.state.enableEffects,
    );

    if (!enableEffects) {
      return Container(
        color: opacity != null ? Colors.white.withOpacity(opacity!) : null,
        child: child,
      );
    }

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: Container(
        color: opacity != null ? Colors.white.withOpacity(opacity!) : Colors.transparent,
        child: child,
      ),
    );
  }
}
