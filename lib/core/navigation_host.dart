import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/common/navigator.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';
import 'package:movetopia/presentation/onboarding/routes.dart';
import 'package:movetopia/presentation/onboarding/screen/onboarding_screen.dart';
import 'package:movetopia/presentation/tracking/routes.dart';

import '../presentation/activities/routes.dart';
import '../presentation/challenges/routes.dart';
import '../presentation/profile/routes.dart';
import '../presentation/today/routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final navigationRoutesProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboardingAsync = ref.watch(hasCompletedOnboardingProvider);

  String initialLocation = onboardingPath;

  if (hasCompletedOnboardingAsync is AsyncData) {
    final bool isCompleted = hasCompletedOnboardingAsync.value == true;
    initialLocation = isCompleted ? todayPath : onboardingPath;
  }

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: <RouteBase>[
      // Onboarding route (außerhalb der Shell-Navigation)
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Haupt-Navigation mit StatefulShell
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MoveTopiaNavigator(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: TodayRoutes.navigatorKey,
            routes: TodayRoutes.routes,
          ),
          StatefulShellBranch(
            navigatorKey: ActivitiesRoutes.navigatorKey,
            routes: ActivitiesRoutes.routes,
          ),
          StatefulShellBranch(
            navigatorKey: ChallengesRoutes.navigatorKey,
            routes: ChallengesRoutes.routes,
          ),
          StatefulShellBranch(
            navigatorKey: ProfileRoutes.navigatorKey,
            routes: ProfileRoutes.routes,
          ),
          StatefulShellBranch(
              navigatorKey: TrackingRoutes.navigatorKey,
              routes: TrackingRoutes.routes)
        ],
      ),
    ],
  );
});
