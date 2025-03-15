import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/challenges/badgeLists/screen/badge_lists_screen.dart';

const challengesPath = '/challenges';

class ChallengesRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: challengesPath,
      builder: (context, state) => const BadgeListsScreen(),
    )
  ];
}
