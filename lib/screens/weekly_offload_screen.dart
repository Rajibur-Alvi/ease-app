import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import 'dart:ui' as ui;

class WeeklyOffloadScreen extends StatefulWidget {
  const WeeklyOffloadScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyOffloadScreen> createState() => _WeeklyOffloadScreenState();
}

class _WeeklyOffloadScreenState extends State<WeeklyOffloadScreen> {
  int _currentStep = 4;
  final int _totalSteps = 6;
  int _selectedAnswerIndex = -1;

  final List<String> _questions = [
    "", "", "",
    "\"How has your environment been feeling lately? Are you finding enough space for quiet?\"",
    "\"When you think about the upcoming week, what's the one thing that feels heaviest?\"",
    "\"Final thought: If you could delegate one thing today with zero guilt, what would it be?\"",
  ];

  void _onContinue() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
        _selectedAnswerIndex = -1;
      });
    } else {
      context.go('/relief-report');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: Stack(
        children: [
          // Background abstract element
          Center(
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EaseTheme.primaryContainer.withOpacity(0.2),
              ),
              child: const PerformanceAwareBlur(
                sigmaX: 120,
                sigmaY: 120,
                child: SizedBox.expand(),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildProgressBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "STEP $_currentStep OF $_totalSteps",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: EaseTheme.primarySage,
                                letterSpacing: 2.0,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _questions[_currentStep - 1],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                                color: EaseTheme.onSurface,
                                fontFamily: 'Noto Serif',
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 48),
                        _buildAnswerCard(context, 0, "It feels cluttered", LucideIcons.layers),
                        const SizedBox(height: 20),
                        _buildAnswerCard(context, 1, "I'm finding my peace", LucideIcons.checkCircle),
                        const SizedBox(height: 20),
                        _buildAnswerCard(context, 2, "I'm looking for new spaces", LucideIcons.compass),
                      ],
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: EaseTheme.primarySage),
            onPressed: () => context.go('/dashboard'),
          ),
          Text(
            "Mindful Space",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: EaseTheme.primarySage,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: EaseTheme.surfaceDim,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Icon(LucideIcons.user, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _currentStep / _totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: EaseTheme.primaryContainer,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerCard(BuildContext context, int index, String text, IconData icon) {
    final bool isSelected = _selectedAnswerIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswerIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? EaseTheme.primarySage.withOpacity(0.3) : Colors.white.withOpacity(0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: EaseTheme.primarySage.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    color: isSelected ? EaseTheme.primarySage : EaseTheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
            Icon(
              icon,
              color: isSelected ? EaseTheme.primarySage : EaseTheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              if (_currentStep > 1) {
                setState(() {
                  _currentStep--;
                  _selectedAnswerIndex = -1;
                });
              }
            },
            icon: const Icon(LucideIcons.arrowLeft, size: 16),
            label: Text(
              "PREVIOUS",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    color: EaseTheme.onSurfaceVariant,
                  ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: EaseTheme.onSurfaceVariant,
            ),
          ),
          ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: EaseTheme.primaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 4,
              shadowColor: EaseTheme.primaryContainer.withOpacity(0.5),
            ),
            child: Text(
              _currentStep == _totalSteps ? "Finish Session" : "Continue Session",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: _onContinue,
            icon: const Icon(LucideIcons.fastForward, size: 16),
            label: Text(
              "SKIP",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    color: EaseTheme.onSurfaceVariant,
                  ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: EaseTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
