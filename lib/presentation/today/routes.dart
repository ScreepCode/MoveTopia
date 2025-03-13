import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/today/screen/today_screen.dart';

const todayPath = '/today';

class TodayRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: todayPath,
      builder: (context, state) => const TodayScreen(),
    )
  ];
}
