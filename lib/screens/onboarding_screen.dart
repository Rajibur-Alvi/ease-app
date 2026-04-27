import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';
import '../models/models.dart';
import '../services/app_state_provider.dart';
import 'dart:ui' as ui;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  PersonalityType _selectedPersonality = PersonalityType.introvert;
  final List<LifeCategory> _selectedPriorities = [];
  final TextEditingController _nameController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    final profile = UserProfile(
      name: _nameController.text.isEmpty ? "Friend" : _nameController.text,
      personalityType: _selectedPersonality,
      priorityDepartments: _selectedPriorities,
    );
    context.read<AppStateProvider>().updateUserProfile(profile);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: Stack(
        children: [
          _buildBackgroundBlobs(),
          _buildStepContent(),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        Positioned(top: -50, right: -50, child: _buildBlob(const Color(0xFFE9B384), 300)),
        Positioned(top: MediaQuery.of(context).size.height * 0.2, left: -100, child: _buildBlob(const Color(0xFF6A9E6F), 400)),
        Positioned(bottom: MediaQuery.of(context).size.height * 0.4, right: 40, child: _buildBlob(const Color(0xFFC77C90), 250)),
      ],
    );
  }

  Widget _buildStepContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, -20))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 32),
            if (_currentStep == 0) _buildWelcomeStep(),
            if (_currentStep == 1) _buildPersonalityStep(),
            if (_currentStep == 2) _buildPrioritiesStep(),
            const SizedBox(height: 40),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => _buildDot(index == _currentStep)),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? EaseTheme.primaryContainer : EaseTheme.surfaceDim,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        Text(
          "Welcome to Ease",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: EaseTheme.primaryContainer),
        ),
        const SizedBox(height: 16),
        Text(
          "A calm space for introverts to connect and manage life without the pressure.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: EaseTheme.secondary),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "What should we call you?",
            filled: true,
            fillColor: EaseTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityStep() {
    return Column(
      children: [
        Text(
          "Tell us about yourself",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, color: EaseTheme.primaryContainer),
        ),
        const SizedBox(height: 16),
        Text(
          "This helps us suggest the right connections for you.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: EaseTheme.secondary),
        ),
        const SizedBox(height: 32),
        _buildPersonalityOption(PersonalityType.introvert, "Introvert", "I recharge by being alone.", LucideIcons.moon),
        const SizedBox(height: 16),
        _buildPersonalityOption(PersonalityType.extrovert, "Extrovert", "I get energy from socializing.", LucideIcons.sun),
      ],
    );
  }

  Widget _buildPersonalityOption(PersonalityType type, String title, String subtitle, IconData icon) {
    bool isSelected = _selectedPersonality == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedPersonality = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? EaseTheme.primarySage.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? EaseTheme.primarySage : EaseTheme.surfaceDim, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? EaseTheme.primarySage : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(subtitle, style: TextStyle(color: EaseTheme.secondary, fontSize: 14)),
                ],
              ),
            ),
            if (isSelected) const Icon(LucideIcons.checkCircle, color: EaseTheme.primarySage),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritiesStep() {
    return Column(
      children: [
        Text(
          "What matters most?",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, color: EaseTheme.primaryContainer),
        ),
        const SizedBox(height: 16),
        Text(
          "Select the life departments you want to focus on.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: EaseTheme.secondary),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: LifeCategory.values.map((cat) => _buildPriorityChip(cat)).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(LifeCategory category) {
    bool isSelected = _selectedPriorities.contains(category);
    String label = category.name[0].toUpperCase() + category.name.substring(1).replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedPriorities.add(category);
          } else {
            _selectedPriorities.remove(category);
          }
        });
      },
      selectedColor: EaseTheme.primarySage.withOpacity(0.2),
      checkmarkColor: EaseTheme.primarySage,
      labelStyle: TextStyle(color: isSelected ? EaseTheme.primarySage : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      backgroundColor: EaseTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? EaseTheme.primarySage : EaseTheme.surfaceDim)),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: EaseTheme.primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(_currentStep == 2 ? "START MY JOURNEY" : "CONTINUE", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color.withOpacity(0.4), shape: BoxShape.circle), child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(color: Colors.transparent)));
  }
}
