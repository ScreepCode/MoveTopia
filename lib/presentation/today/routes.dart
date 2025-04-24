import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/today/screen/survey_webview_screen.dart';
import 'package:movetopia/presentation/today/screen/today_screen.dart';

const todayPath = '/today';

const String surveyWebViewPath = 'survey-webview';
const String fullSurveyWebViewPath = '$todayPath/$surveyWebViewPath';

class TodayRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static List<RouteBase> routes = [
    GoRoute(
      path: todayPath,
      builder: (context, state) => const TodayScreen(),
      routes: [
        GoRoute(
          path: surveyWebViewPath,
          builder: (context, state) => SurveyWebViewScreen(
            surveyUrl: state.extra as String,
          ),
        ),
      ],
    ),
  ];
}
