import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../../theme/theme.dart';
import '../../theme/design_tokens.dart';
import 'offline_banner.dart';

class MvpShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MvpShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _BrainDumpFab(),
      bottomNavigationBar: _BottomBar(navigationShell: navigationShell),
    );
  }
}

class _BrainDumpFab extends StatefulWidget {
  @override
  State<_BrainDumpFab> createState() => _BrainDumpFabState();
}

class _BrainDumpFabState extends State<_BrainDumpFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/brain-dump');
        },
        backgroundColor: EaseTheme.primarySage,
        elevation: 4,
        icon: const Icon(LucideIcons.brainCircuit, color: Colors.white, size: 20),
        label: const Text(
          'Brain Dump',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _BottomBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white.withValues(alpha: 0.95),
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: LucideIcons.home,
            label: 'Home',
            selected: navigationShell.currentIndex == 0,
            onTap: () => navigationShell.goBranch(0,
                initialLocation: navigationShell.currentIndex == 0),
          ),
          _NavItem(
            icon: LucideIcons.layoutGrid,
            label: 'Life',
            selected: navigationShell.currentIndex == 1,
            onTap: () => navigationShell.goBranch(1,
                initialLocation: navigationShell.currentIndex == 1),
          ),
          // Center gap for FAB
          const SizedBox(width: 64),
          _NavItem(
            icon: LucideIcons.messageCircle,
            label: 'Connect',
            selected: navigationShell.currentIndex == 2,
            onTap: () => navigationShell.goBranch(2,
                initialLocation: navigationShell.currentIndex == 2),
          ),
          _NavItem(
            icon: LucideIcons.userCircle2,
            label: 'Profile',
            selected: navigationShell.currentIndex == 3,
            onTap: () => navigationShell.goBranch(3,
                initialLocation: navigationShell.currentIndex == 3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: EaseSpace.sm, vertical: EaseSpace.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: EaseMotion.standard,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? EaseTheme.primarySage.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: EaseRadius.sm,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? EaseTheme.primarySage : EaseTheme.secondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? EaseTheme.primarySage : EaseTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarActionAvatar extends StatelessWidget {
  const AppBarActionAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppStateProvider>().state.userProfile;
    return CircleAvatar(
      radius: 18,
      backgroundColor: EaseTheme.primaryContainer.withValues(alpha: 0.2),
      child: Text(
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'E',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: EaseTheme.primarySage,
          fontSize: 14,
        ),
      ),
    );
  }
}
