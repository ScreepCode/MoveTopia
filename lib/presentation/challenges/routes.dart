import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/challenges/streak/screen/streak_details_screen.dart';

import '../../data/model/badge.dart';
import 'badgeLists/screen/badge_lists_screen.dart';
import 'dashboard/screen/challenge_dashboard_screen.dart';

const challengesPath = '/challenges';

// Path für die Badge-Listen
const badgeListsPath = 'badge-lists';
const fullBadgeListsPath = '$challengesPath/$badgeListsPath';

// Path für die Streak-Details
const streakDetailsPath = 'streak-details';
const fullStreakDetailsPath = '$challengesPath/$streakDetailsPath';

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
        GoRoute(
          path: streakDetailsPath,
          builder: (context, state) => const StreakDetailsScreen(),
        ),
      ],
    ),
  ];
}
