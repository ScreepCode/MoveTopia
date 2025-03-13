import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/challenges/screen/challenges_screen.dart';

const challengesPath = '/challenges';

class ChallengesRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: challengesPath,
      builder: (context, state) => const ChallengesScreen(),
    )
  ];
}
