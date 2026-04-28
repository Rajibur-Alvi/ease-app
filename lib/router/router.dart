import 'package:go_router/go_router.dart';
import '../services/app_state_provider.dart';
import '../ui/screens/onboarding_mvp_screen.dart';
import '../ui/screens/home_focus_screen.dart';
import '../ui/screens/life_departments_screen.dart';
import '../ui/screens/connect_mvp_screen.dart';
import '../ui/screens/profile_mvp_screen.dart';
import '../ui/screens/brain_dump_input_screen.dart';
import '../ui/screens/reflection_result_screen.dart';
import '../ui/screens/investment_guided_screen.dart';
import '../ui/widgets/mvp_shell.dart';

GoRouter createAppRouter(AppStateProvider controller) {
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: controller,
    redirect: (context, state) {
      final location = state.uri.toString();
      final onboardingDone = controller.state.onboardingComplete;

      if (!onboardingDone && location != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingDone && location == '/onboarding') {
        return '/home';
      }
      if (location == '/reflect' && controller.state.lastReflection == null) {
        return '/brain-dump';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingMvpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MvpShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeFocusScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/life',
                builder: (context, state) => const LifeDepartmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/connect',
                builder: (context, state) => const ConnectMvpScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileMvpScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/brain-dump',
        builder: (context, state) => const BrainDumpInputScreen(),
      ),
      GoRoute(
        path: '/reflect',
        builder: (context, state) => const ReflectionResultScreen(),
      ),
      GoRoute(
        path: '/investments',
        builder: (context, state) => const InvestmentGuidedScreen(),
      ),
    ],
  );
}
