import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screen/profile_screen.dart';

const profilePath = '/profile';

class ProfileRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: profilePath,
      builder: (context, state) => const ProfileScreen(),
    )
  ];
}