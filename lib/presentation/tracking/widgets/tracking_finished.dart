import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health/health.dart';
import 'package:movetopia/presentation/activities/details/widget/detail_stats_card.dart';
import 'package:movetopia/presentation/activities/details/widget/header_details.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';
import 'package:movetopia/utils/health_utils.dart';
import 'package:movetopia/utils/tracking_utils.dart';

class TrackingFinished extends StatelessWidget {
  final Activity? activity;
  final int durationMillis;

  const TrackingFinished(
      {Key? key, required this.activity, required this.durationMillis})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListView(children: [
          _buildHeaderDetails(context, activity!),
          _buildActivityDetails(context, activity!, durationMillis)
        ]));
  }

  double getAverageSpeed(Activity activity) {
    if (activity.locations == null) {
      return 0.0;
    }
    if (activity.locations!.isEmpty) {
      return 0.0;
    }

    double totalSpeed = 0.0;
    activity.locations!.forEach((datetime, location) {
      totalSpeed += location.speed;
    });

    return ((totalSpeed / activity.locations!.length) * 10.0).round() / 10.0;
  }

  String getAveragePace(Activity activity) {
    if (activity.locations == null) {
      return "-- min/km";
    }
    if (activity.locations!.isEmpty) {
      return "-- min/km";
    }
    double totalPace = 0.0;
    activity.locations!.forEach((datetime, location) {
      totalPace += location.pace;
    });

    return getPace(
        (totalPace / activity.locations!.length) * 10.0.round() / 10.0);
  }

  Widget _buildHeaderDetails(BuildContext context, Activity activity) {
    return HeaderDetails(
      title: getTranslatedActivityType(
          context,
          HealthWorkoutActivityType.values
              .firstWhere((t) => t.name == activity.activityType?.name)),
      start: DateTime.fromMillisecondsSinceEpoch(activity.startDateTime ?? 0),
      end: DateTime.fromMillisecondsSinceEpoch(activity.endDateTime ?? 0),
      icon: getActivityIcon(HealthWorkoutActivityType.values
          .firstWhere((t) => t.name == activity.activityType?.name)),
    );
  }

  Widget _buildActivityDetails(
      BuildContext context, Activity activity, int duration) {
    final l10n = AppLocalizations.of(context)!;
    return GenericCard(
      title: l10n.activity_details_title,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.activityType != ActivityType.biking)
            DetailStatsCardEntry(
                displayName: l10n.activity_steps, value: "${activity.steps}"),
          DetailStatsCardEntry(
              displayName: l10n.activity_distance,
              value: "${activity.distance} km"),
          DetailStatsCardEntry(
            displayName: l10n.activity_duration,
            value: getDuration(duration),
          ),
          DetailStatsCardEntry(
              displayName: l10n.activity_avg_speed,
              value: "${getAverageSpeed(activity)} km/h"),
          DetailStatsCardEntry(
              displayName: l10n.activity_avg_pace,
              value: getAveragePace(activity).toString()),
        ],
      ),
    );
  }
}
