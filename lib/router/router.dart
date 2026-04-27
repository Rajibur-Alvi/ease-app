import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/category_detail_screen.dart';
import '../screens/brain_dump_screen.dart';
import '../screens/voice_mode_screen.dart';
import '../screens/ease_score_screen.dart';
import '../screens/weekly_offload_screen.dart';
import '../screens/relief_report_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/investment_screen.dart';
import '../screens/connections_screen.dart';
import '../screens/chat_screen.dart';
import '../models/models.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/category-detail',
      builder: (context, state) {
        final categoryStr = state.uri.queryParameters['category'] ?? 'health';
        final category = LifeCategory.values.firstWhere(
          (e) => e.toString().split('.').last == categoryStr,
          orElse: () => LifeCategory.health,
        );
        return CategoryDetailScreen(category: category);
      },
    ),
    GoRoute(
      path: '/brain-dump',
      builder: (context, state) => const BrainDumpScreen(),
    ),
    GoRoute(
      path: '/voice-mode',
      builder: (context, state) => const VoiceModeScreen(),
    ),
    GoRoute(
      path: '/ease-score',
      builder: (context, state) => const EaseScoreScreen(),
    ),
    GoRoute(
      path: '/weekly-offload',
      builder: (context, state) => const WeeklyOffloadScreen(),
    ),
    GoRoute(
      path: '/relief-report',
      builder: (context, state) => const ReliefReportScreen(),
    ),
    GoRoute(
      path: '/investments',
      builder: (context, state) => const InvestmentScreen(),
    ),
    GoRoute(
      path: '/connections',
      builder: (context, state) => const ConnectionsScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final name = state.uri.queryParameters['name'] ?? 'Friend';
        return ChatScreen(partnerName: name);
      },
    ),
  ],
);
