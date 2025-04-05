import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/onboarding/screen/onboarding_screen.dart';

const onboardingPath = '/onboarding';

class OnboardingRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: onboardingPath,
      builder: (context, state) => const OnboardingScreen(),
    )
  ];
}
