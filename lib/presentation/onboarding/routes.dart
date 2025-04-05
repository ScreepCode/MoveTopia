import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/onboarding/screen/authorization_problem_screen.dart';
import 'package:movetopia/presentation/onboarding/screen/onboarding_screen.dart';

const onboardingPath = '/onboarding';
const authorizationProblemPath = '/authorizationProblem';

class OnboardingRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: onboardingPath,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: authorizationProblemPath,
      builder: (context, state) => const AuthorizationProblemScreen(),
    )
  ];
}
