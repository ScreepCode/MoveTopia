import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/model/badge.dart';
import 'badgeLists/screen/badge_lists_screen.dart';
import 'dashboard/screen/challange_dashboard_screen.dart';

const challengesPath = '/challenges';

const badgeListsPath = 'badges';
const fullBadgeListsPath = '$challengesPath/$badgeListsPath';

class ChallengesRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: challengesPath,
      builder: (context, state) => const ChallengeDashboardScreen(),
      routes: [
        GoRoute(
          path: badgeListsPath,
          builder: (context, state) {
            final category = state.extra as AchievementBadgeCategory?;
            return BadgeListsScreen(initialCategory: category);
          },
        ),
      ],
    ),
  ];
}
