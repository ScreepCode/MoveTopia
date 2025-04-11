import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screen/settings_screen.dart';

const settingsPath = '/settings';

class SettingsRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: settingsPath,
      builder: (context, state) => const SettingsScreen(),
    )
  ];
}
