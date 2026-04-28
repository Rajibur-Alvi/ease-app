import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: EaseTheme.surfaceDim,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: EaseTheme.surfaceDim,
          borderRadius: borderRadius ?? EaseRadius.md,
        ),
      ),
    );
  }
}

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EaseSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: EaseSpace.lg),
          SkeletonBox(width: 160, height: 28, borderRadius: EaseRadius.sm),
          const SizedBox(height: EaseSpace.sm),
          SkeletonBox(width: 240, height: 18, borderRadius: EaseRadius.sm),
          const SizedBox(height: EaseSpace.lg),
          // Mood chips
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(right: EaseSpace.xs),
                child: SkeletonBox(
                    width: 80, height: 32, borderRadius: EaseRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: EaseSpace.lg),
          // Brain dump button
          SkeletonBox(
              width: double.infinity,
              height: 120,
              borderRadius: EaseRadius.xl),
          const SizedBox(height: EaseSpace.lg),
          SkeletonBox(width: 100, height: 14, borderRadius: EaseRadius.sm),
          const SizedBox(height: EaseSpace.sm),
          SkeletonBox(
              width: double.infinity,
              height: 80,
              borderRadius: EaseRadius.md),
          const SizedBox(height: EaseSpace.sm),
          SkeletonBox(
              width: double.infinity,
              height: 80,
              borderRadius: EaseRadius.md),
        ],
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: EaseTheme.surfaceDim,
      highlightColor: Colors.white,
      child: Container(
        width: double.infinity,
        height: 88,
        margin: const EdgeInsets.only(bottom: EaseSpace.sm),
        decoration: BoxDecoration(
          color: EaseTheme.surfaceDim,
          borderRadius: EaseRadius.md,
        ),
      ),
    );
  }
}
