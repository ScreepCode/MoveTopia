import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/presentation/activities/screen/activities_screen.dart';
import 'package:movetopia/presentation/activity_details/screen/activity_details.dart';
import 'package:movetopia/presentation/common/navigator.dart';
import 'package:movetopia/presentation/me/screen/profile_screen.dart';
import 'package:movetopia/presentation/today/screen/today_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _todayTabNavigatorKey = GlobalKey<NavigatorState>();
final _activitiesTabNavigatorKey = GlobalKey<NavigatorState>();
final _meTabNavigatorKey = GlobalKey<NavigatorState>();

final navigationRoutes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/",
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MoveTopiaNavigator(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
              navigatorKey: _todayTabNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                    path: "/",
                    builder: (BuildContext context, GoRouterState state) =>
                        const TodayScreen())
              ]),
          StatefulShellBranch(
              navigatorKey: _activitiesTabNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                    path: "/activities",
                    builder: (BuildContext context, GoRouterState state) =>
                        const ActivitiesScreen(),
                    routes: [
                      GoRoute(
                        path: "details",
                        builder: (context, state) => ActivityDetailsScreen(
                          activityPreview: state.extra as ActivityPreview,
                        ),
                      )
                    ])
              ]),
          StatefulShellBranch(
              navigatorKey: _meTabNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                    path: "/me",
                    builder: (BuildContext context, GoRouterState state) =>
                        const ProfileScreen())
              ])
        ]),
  ],
);
