import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/app_state_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme.dart';

class OnboardingMvpScreen extends StatefulWidget {
  const OnboardingMvpScreen({super.key});

  @override
  State<OnboardingMvpScreen> createState() => _OnboardingMvpScreenState();
}

class _OnboardingMvpScreenState extends State<OnboardingMvpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1 data
  final _nameController = TextEditingController();

  // Step 2 data
  PersonalityType _personalityType = PersonalityType.introvert;
  double _introvertLevel = 80;

  // Step 3 data
  CommunicationStyle _style = CommunicationStyle.text;
  final List<String> _selectedInterests = [];
  static const _interestOptions = [
    'books', 'music', 'mindfulness', 'fitness',
    'art', 'journaling', 'productivity', 'finance',
    'home', 'nature', 'cooking', 'travel',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    _pageController.nextPage(
      duration: EaseMotion.emphasized,
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: EaseMotion.emphasized,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    await context.read<AppStateProvider>().completeOnboarding(
          name: _nameController.text,
          personalityType: _personalityType,
          introvertLevel: _introvertLevel.round(),
          communicationStyle: _style,
          interests: _selectedInterests,
        );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  EaseSpace.lg, EaseSpace.lg, EaseSpace.lg, 0),
              child: Row(
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: EaseMotion.standard,
                    margin: const EdgeInsets.only(right: EaseSpace.xs),
                    height: 4,
                    width: _currentPage == i ? 28 : 12,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? EaseTheme.primarySage
                          : EaseTheme.surfaceDim,
                      borderRadius: EaseRadius.pill,
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _Step1(nameController: _nameController, onNext: _nextPage),
                  _Step2(
                    personalityType: _personalityType,
                    introvertLevel: _introvertLevel,
                    onPersonalityChanged: (v) =>
                        setState(() => _personalityType = v),
                    onIntrovertChanged: (v) =>
                        setState(() => _introvertLevel = v),
                    onNext: _nextPage,
                    onBack: _prevPage,
                  ),
                  _Step3(
                    style: _style,
                    selectedInterests: _selectedInterests,
                    interestOptions: _interestOptions,
                    onStyleChanged: (v) => setState(() => _style = v),
                    onInterestToggle: (interest) {
                      setState(() {
                        if (_selectedInterests.contains(interest)) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    onFinish: _finish,
                    onBack: _prevPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onNext;

  const _Step1({required this.nameController, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EaseSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: EaseSpace.lg),
          const Icon(LucideIcons.leaf, size: 40, color: EaseTheme.primarySage),
          const SizedBox(height: EaseSpace.md),
          Text(
            'Welcome to Ease',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: EaseSpace.sm),
          Text(
            'A calm space to unload your thoughts, organize your life, and connect gently.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: EaseTheme.secondary,
                ),
          ),
          const SizedBox(height: EaseSpace.xl),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'What should we call you?',
              hintText: 'Your name or nickname',
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final PersonalityType personalityType;
  final double introvertLevel;
  final ValueChanged<PersonalityType> onPersonalityChanged;
  final ValueChanged<double> onIntrovertChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2({
    required this.personalityType,
    required this.introvertLevel,
    required this.onPersonalityChanged,
    required this.onIntrovertChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EaseSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: EaseSpace.lg),
          Text(
            'How do you show up?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: EaseSpace.xs),
          Text(
            'This helps us personalize your experience.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 14, color: EaseTheme.secondary),
          ),
          const SizedBox(height: EaseSpace.lg),
          Text('Personality', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: EaseSpace.xs),
          Wrap(
            spacing: EaseSpace.xs,
            children: PersonalityType.values.map((type) {
              final selected = personalityType == type;
              return ChoiceChip(
                label: Text(_personalityLabel(type)),
                selected: selected,
                onSelected: (_) => onPersonalityChanged(type),
              );
            }).toList(),
          ),
          const SizedBox(height: EaseSpace.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Introvert level',
                  style: Theme.of(context).textTheme.labelSmall),
              Text(
                '${introvertLevel.round()}',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: EaseTheme.primarySage),
              ),
            ],
          ),
          Slider(
            value: introvertLevel,
            min: 0,
            max: 100,
            divisions: 10,
            onChanged: onIntrovertChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Extrovert',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: EaseTheme.secondary)),
              Text('Introvert',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: EaseTheme.secondary)),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: EaseSpace.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _personalityLabel(PersonalityType type) {
    switch (type) {
      case PersonalityType.introvert:
        return 'Introvert';
      case PersonalityType.extrovert:
        return 'Extrovert';
      case PersonalityType.ambivert:
        return 'Ambivert';
    }
  }
}

class _Step3 extends StatelessWidget {
  final CommunicationStyle style;
  final List<String> selectedInterests;
  final List<String> interestOptions;
  final ValueChanged<CommunicationStyle> onStyleChanged;
  final ValueChanged<String> onInterestToggle;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const _Step3({
    required this.style,
    required this.selectedInterests,
    required this.interestOptions,
    required this.onStyleChanged,
    required this.onInterestToggle,
    required this.onFinish,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EaseSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: EaseSpace.lg),
          Text(
            'How do you like to connect?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: EaseSpace.xs),
          Text(
            'We\'ll use this to find the right match for you.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 14, color: EaseTheme.secondary),
          ),
          const SizedBox(height: EaseSpace.lg),
          Text('Communication style',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: EaseSpace.xs),
          Wrap(
            spacing: EaseSpace.xs,
            children: CommunicationStyle.values.map((s) {
              final selected = style == s;
              return ChoiceChip(
                label: Text(_styleLabel(s)),
                selected: selected,
                onSelected: (_) => onStyleChanged(s),
              );
            }).toList(),
          ),
          const SizedBox(height: EaseSpace.lg),
          Text('Interests (pick a few)',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: EaseSpace.xs),
          Wrap(
            spacing: EaseSpace.xs,
            runSpacing: EaseSpace.xs,
            children: interestOptions.map((interest) {
              final selected = selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: selected,
                onSelected: (_) => onInterestToggle(interest),
              );
            }).toList(),
          ),
          const Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: EaseSpace.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onFinish,
                  child: const Text('Start using Ease'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _styleLabel(CommunicationStyle s) {
    switch (s) {
      case CommunicationStyle.text:
        return 'Text';
      case CommunicationStyle.voice:
        return 'Voice';
      case CommunicationStyle.either:
        return 'Either';
    }
  }
}
