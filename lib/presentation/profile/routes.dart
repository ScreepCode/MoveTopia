import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/profile/screen/log_screen.dart';

import 'screen/debug_settings_screen.dart';
import 'screen/permissions_settings_screen.dart';
import 'screen/profile_screen.dart';

const profilePath = '/profile';
const profilePermissionsPath = 'permissions';
const profileDebugPath = 'debug';
const profileLoggingPath = 'logging';

class ProfileRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: profilePath,
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: profilePermissionsPath,
          builder: (context, state) => const PermissionsSettingsScreen(),
        ),
        GoRoute(
          path: profileDebugPath,
          builder: (context, state) => const DebugSettingsScreen(),
        ),
        GoRoute(
          path: profileLoggingPath,
          builder: (context, state) => const LogScreen(),
        ),
      ],
    )
  ];
}
