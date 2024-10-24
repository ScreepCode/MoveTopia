import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/presentation/activity_details/view_model/activity_detail_view_model.dart';
import 'package:movetopia/presentation/activity_details/widget/detail_stats_card.dart';
import 'package:movetopia/presentation/activity_details/widget/header_details.dart';
import 'package:movetopia/utils/health_utils.dart';

class ActivityDetailsScreen extends HookConsumerWidget {
  const ActivityDetailsScreen({super.key, required this.activityPreview});
  final ActivityPreview activityPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var log = Logger("ActivityDetailsScreen");
    final activityState = ref.watch(activityDetailedViewModelProvider);
    HealthAuthViewModelState state = ref.watch(healthViewModelProvider);

    Future<void> fetchDetailedActivity() async {
      await ref
          .read(activityDetailedViewModelProvider.notifier)
          .fetchActivityDetailed(activityPreview);
    }

    useEffect(() {
      Future(
        () async {
          ref.read(activityDetailedViewModelProvider.notifier).setLoading(true);
          HealthAuthViewModelState state = ref.watch(healthViewModelProvider);
          if (state == HealthAuthViewModelState.authorized) {
            await fetchDetailedActivity();
          }
          ref
              .read(activityDetailedViewModelProvider.notifier)
              .setLoading(false);
          return null;
        },
      );
      return;
    }, [state]);
    return activityState.isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: Theme.of(context).progressIndicatorTheme.circularTrackColor,
            backgroundColor:
                Theme.of(context).progressIndicatorTheme.circularTrackColor,
            strokeWidth: 4,
          ))
        : SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ListView(
              children: [
                HeaderDetails(
                  title: getTranslatedActivityType(
                      Localizations.localeOf(context),
                      activityState.activity.activityType),
                  start: activityState.activity.start,
                  end: activityState.activity.end,
                  icon: getActivityIcon(activityPreview.activityType),
                ),
                DetailStatsCard(
                    displayName: "Active Time",
                    value: activityPreview.getDuration().toString(),
                    iconData: Icons.speed),
                const Divider(),
                DetailStatsCard(
                  displayName: "Hearth Rate",
                  value: '${activityState.getAverageHeartBeat()} bpm',
                  iconData: Icons.monitor_heart,
                )
              ],
            ));
  }
}
