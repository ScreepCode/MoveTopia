import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/common/navigator.dart';
import 'package:movetopia/presentation/tracking/routes.dart';

import '../presentation/activities/routes.dart';
import '../presentation/challenges/routes.dart';
import '../presentation/profile/routes.dart';
import '../presentation/today/routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final navigationRoutes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: todayPath,
  routes: <RouteBase>[
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
