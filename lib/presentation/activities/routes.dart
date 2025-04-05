import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/data/model/activity.dart';

import 'details/screen/activity_details.dart';
import 'list/screen/activities_screen.dart';

const activitiesListPath = '/activities';
const activitiesDetailsPath = 'details';
const activitiesDetailsFullPath = '$activitiesListPath/$activitiesDetailsPath';

class ActivitiesRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
        path: activitiesListPath,
        builder: (context, state) => const ActivitiesScreen(),
        routes: [
          GoRoute(
            path: activitiesDetailsPath,
            builder: (context, state) => ActivityDetailsScreen(
              activityPreview: state.extra as ActivityPreview,
            ),
          )
        ])
  ];
}
