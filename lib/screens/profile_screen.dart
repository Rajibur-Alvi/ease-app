import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/app_state_provider.dart';
import '../theme/performance_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateProvider = context.watch<AppStateProvider>();
    final appState = appStateProvider.state;

    return Scaffold(
      backgroundColor: EaseTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: EaseTheme.onSurface),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context, appState.userProfile.name),
            const SizedBox(height: 40),
            _buildStatsSection(context, appState.easeScore, appState.stressorsOffloadedThisWeek),
            const SizedBox(height: 40),
            _buildSettingsSection(context, appStateProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EaseTheme.surfaceDim,
            border: Border.all(color: EaseTheme.primarySage, width: 2),
          ),
          child: const Icon(LucideIcons.user, size: 50, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        Text(
          "Journey to Mental Clarity",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: EaseTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, int score, int offloaded) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, "Global Ease", "$score", LucideIcons.leaf)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, "Offloaded", "$offloaded", LucideIcons.checkCircle)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EaseTheme.glassDecoration,
      child: Column(
        children: [
          Icon(icon, color: EaseTheme.primarySage),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EaseTheme.secondary)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AppStateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SETTINGS", style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2)),
        const SizedBox(height: 16),
        _buildSettingToggle(
          context, 
          "High Performance Mode", 
          "Disables heavy blurs for smoother experience", 
          !provider.state.enableEffects,
          (val) => provider.toggleEffects(),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(context, "Notifications", LucideIcons.bell, () {
          _showSimpleDialog(context, "Notifications", "Notification settings are managed by your device. We will notify you for your weekly offload.");
        }),
        const SizedBox(height: 16),
        _buildSettingItem(context, "Privacy & Data", LucideIcons.lock, () {
          _showSimpleDialog(context, "Privacy & Data", "Your data is stored locally on this device. We do not upload your personal brain dumps to any external servers.");
        }),
        const SizedBox(height: 16),
        _buildSettingItem(context, "About Ease", LucideIcons.info, () {
          _showSimpleDialog(context, "About Ease", "Ease v1.0.0\nBuilt for introverts to manage mental load and find meaningful connections.");
        }),
      ],
    );
  }

  Widget _buildSettingToggle(BuildContext context, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EaseTheme.glassDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12, color: EaseTheme.secondary)),
              ],
            ),
          ),
          Switch(
            value: value, 
            onChanged: onChanged,
            activeColor: EaseTheme.primarySage,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: EaseTheme.glassDecoration,
      child: ListTile(
        leading: Icon(icon, color: EaseTheme.primarySage),
        title: Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showSimpleDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
        ],
      ),
    );
  }
}
