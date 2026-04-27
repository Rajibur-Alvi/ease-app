import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/app_state_provider.dart';
import '../models/models.dart';
import '../theme/performance_helper.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>().state;

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
          "Categories",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: appState.categories.values.map((cat) => _buildCategoryTile(context, cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, CategoryData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: EaseTheme.glassDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: EaseTheme.surfaceDim,
            shape: BoxShape.circle,
          ),
          child: Icon(_getIconForCategory(data.category), color: EaseTheme.primarySage),
        ),
        title: Text(
          data.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        subtitle: Text(
          "${data.tasks.length} active items",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EaseTheme.secondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: data.score > 80 ? const Color(0xFFE1F5E2) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${data.score}",
            style: TextStyle(
              color: data.score > 80 ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => context.go('/category-detail?category=${data.category.name}'),
      ),
    );
  }

  IconData _getIconForCategory(LifeCategory cat) {
    switch (cat) {
      case LifeCategory.health: return LucideIcons.heart;
      case LifeCategory.workCareer: return LucideIcons.briefcase;
      case LifeCategory.finances: return LucideIcons.banknote;
      case LifeCategory.family: return LucideIcons.users;
      case LifeCategory.relationships: return LucideIcons.heartHandshake;
      case LifeCategory.homeEnvironment: return LucideIcons.home;
      case LifeCategory.personalGrowth: return LucideIcons.trendingUp;
      case LifeCategory.timeManagement: return LucideIcons.clock;
    }
  }
}
