import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../services/app_state_provider.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final List<Map<String, dynamic>> _potentialMatches = [
    {"name": "Sarah", "type": PersonalityType.introvert, "interests": ["Reading", "Coffee", "Gardening"], "bio": "Looking for someone to share quiet moments and book recommendations."},
    {"name": "Alex", "type": PersonalityType.extrovert, "interests": ["Hiking", "Photography", "Travel"], "bio": "I love exploring! Happy to be the one who does the talking."},
    {"name": "Jamie", "type": PersonalityType.introvert, "interests": ["Gaming", "Coding", "Anime"], "bio": "Introvert who loves deep conversations over small talk."},
    {"name": "Maya", "type": PersonalityType.ambivert, "interests": ["Music", "Cooking", "Yoga"], "bio": "A bit of both. Let's find some middle ground."},
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AppStateProvider>().state.userProfile;

    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              Expanded(
                child: _currentIndex < _potentialMatches.length 
                  ? _buildMatchCard(userProfile, _potentialMatches[_currentIndex])
                  : _buildEmptyState(),
              ),
              const SizedBox(height: 32),
              if (_currentIndex < _potentialMatches.length) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Discover", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: EaseTheme.primaryContainer)),
            Text("Find your relief partner", style: TextStyle(color: EaseTheme.secondary)),
          ],
        ),
        IconButton(
          icon: const Icon(LucideIcons.sliders, color: EaseTheme.primarySage),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMatchCard(UserProfile user, Map<String, dynamic> match) {
    double compatibility = _calculateCompatibility(user.personalityType, match['type']);
    
    return Container(
      decoration: EaseTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: EaseTheme.primarySage.withOpacity(0.1),
              child: const Center(child: Icon(LucideIcons.user, size: 80, color: EaseTheme.primarySage)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(match['name'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: EaseTheme.primarySage.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text("${(compatibility * 100).toInt()}% Match", style: const TextStyle(color: EaseTheme.primarySage, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(match['type'].name.toUpperCase(), style: TextStyle(color: EaseTheme.secondary, letterSpacing: 1.2, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(match['bio'], style: TextStyle(color: Colors.black87, height: 1.5)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: (match['interests'] as List<String>).map((interest) => Chip(
                    label: Text(interest, style: const TextStyle(fontSize: 10)),
                    backgroundColor: EaseTheme.background,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCompatibility(PersonalityType userType, PersonalityType matchType) {
    if (userType == PersonalityType.introvert) {
      if (matchType == PersonalityType.introvert) return 0.95; // Perfect understanding
      if (matchType == PersonalityType.ambivert) return 0.85;
      return 0.70; // Complementary growth
    }
    return 0.80; // Default
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(LucideIcons.x, Colors.redAccent, () => setState(() => _currentIndex++)),
        const SizedBox(width: 40),
        _buildCircleButton(LucideIcons.messageCircle, EaseTheme.primarySage, () {
          final name = _potentialMatches[_currentIndex]['name'];
          context.go('/chat?name=$name');
          setState(() {
            _currentIndex++;
          });
        }),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text("No more matches found", style: TextStyle(color: EaseTheme.secondary, fontSize: 18)),
          const SizedBox(height: 8),
          Text("Try expanding your preferences", style: TextStyle(color: EaseTheme.secondary.withOpacity(0.6))),
          const SizedBox(height: 24),
          TextButton(onPressed: () => setState(() => _currentIndex = 0), child: const Text("REFRESH")),
        ],
      ),
    );
  }
}
