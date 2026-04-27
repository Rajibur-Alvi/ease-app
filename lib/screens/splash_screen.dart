import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate loading, then navigate to onboarding
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: Stack(
        children: [
          // Subtle Radial Background Gradient
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [EaseTheme.primaryContainer, Colors.transparent],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),

          // Floating Glass Blobs
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.1)
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon Container
                SizedBox(
                  width: 128,
                  height: 128 + 20, // Add space for shadow
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Shadow Floor
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: EaseTheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: EaseTheme.primaryContainer.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Main Icon
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              EaseTheme.primaryContainer,
                              EaseTheme.primarySage,
                            ],
                          ),
                          boxShadow: EaseTheme.neumorphicShadows,
                        ),
                        child: Stack(
                          children: [
                            // Inner Border
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                            // Horizon Line
                            Positioned(
                              top: 128 * 0.6,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Center Element
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: const PerformanceAwareBlur(
                                  sigmaX: 4.0,
                                  sigmaY: 4.0,
                                  child: _IconCenter(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Brand Identity
                Text(
                  'ease',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        color: EaseTheme.primaryContainer,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your life, one step ahead.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        color: EaseTheme.secondary,
                      ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: SizedBox(
                width: 48,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: EaseTheme.surfaceDim,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          EaseTheme.primaryContainer.withOpacity(0.4),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCenter extends StatelessWidget {
  const _IconCenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: const Center(
        child: Icon(
          LucideIcons.flower2,
          color: Colors.white70,
          size: 24,
        ),
      ),
    );
  }
}
