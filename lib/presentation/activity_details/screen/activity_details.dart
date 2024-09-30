import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/presentation/activity_details/widget/detail_stats_card.dart';
import 'package:movetopia/presentation/activity_details/widget/graph_visualization.dart';
import 'package:movetopia/presentation/activity_details/widget/header_details.dart';
import 'package:movetopia/utils/health_utils.dart';

class ActivityDetailsScreen extends HookConsumerWidget {
  const ActivityDetailsScreen({super.key, required this.activityPreview});
  final ActivityPreview activityPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var log = Logger("ActivityDetailsScreen");
    log.info(activityPreview.activityType);
/* 
    useEffect(() async {

    }, [activityPreview]) */

    return SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListView(
          children: [
            HeaderDetails(
                title: getTranslatedActivityType(
                    Localizations.localeOf(context),
                    activityPreview.activityType),
                start: activityPreview.start,
                end: activityPreview.end),
            DetailStatsCard(
                displayName: "Active Time",
                value: activityPreview.getDuration().toString(),
                iconData: Icons.speed),
            const Divider(),
            DetailStatsCard(
              displayName: "Hearth Rate",
              value: "120bpm",
              iconData: Icons.monitor_heart,
              // child: GraphVisualization(),
            )
          ],
        ));
  }
}
