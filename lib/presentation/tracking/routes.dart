import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/tracking/screen/tracking.dart';


const trackingPath = '/tracking';


class TrackingRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
        path: trackingPath,
        builder: (context, state) => TrackingScreen(),

    )
  ];
}