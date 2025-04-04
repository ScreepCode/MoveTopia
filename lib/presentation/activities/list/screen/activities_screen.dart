import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/utils/health_utils.dart';

import '../view_model/activities_state.dart';
import '../view_model/activities_view_model.dart';

final log = Logger("ActivitiesScreen");

class ActivitiesScreen extends HookConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesViewModelProvider);
    HealthAuthViewModelState authState = ref.read(healthViewModelProvider);
    var scrollController = useScrollController();

    Future<void> fetchHealthData() async {
      await ref.read(activitiesViewModelProvider.notifier).fetchActivities();
    }

    useEffect(() {
      Future(() async {
        if (authState == HealthAuthViewModelState.authorized) {
          await fetchHealthData();

          scrollController.addListener(() {
            if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent) {
              var lastDate = activities.groupedActivities?.keys.last;
              ref
                  .read(activitiesViewModelProvider.notifier)
                  .fetchActivities(endOfData: lastDate);
            }
          });
        }
      });
      return null;
    }, [authState]);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activity_overview),
      ),
      body: activities.isLoading && activities.activities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, activities, fetchHealthData, scrollController),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            context.push("/tracking");
          }),
    );
  }
}

Widget _buildBody(
    BuildContext context,
    ActivitiesState activities,
    Future<void> Function() fetchHealthData,
    ScrollController scrollController) {
  return RefreshIndicator(
    onRefresh: fetchHealthData,
    child: activities.groupedActivities != null &&
            activities.groupedActivities!.isNotEmpty
        ? _buildGroupedActivities(
            context,
            activities.groupedActivities!,
            activities.isLoading,
            scrollController,
          ) //_buildActivityList(context, activities.activities)
        : activities.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Text(AppLocalizations.of(context)!
                    .activity_no_activities_found)),
  );
}

Widget _buildGroupedActivities(
    BuildContext context,
    Map<DateTime, List<ActivityPreview>>? activities,
    bool isLoading,
    ScrollController scrollController) {
  return ListView.builder(
    controller: scrollController,
    physics: const ScrollPhysics(),
    itemCount: activities?.length ?? 0,
    itemBuilder: (context, index) {
      final date = activities?.keys.elementAt(index);
      final activityList = activities?[date]! ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (date != null && activityList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                DateFormat("dd. MMMM yyyy").format(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const Divider(),
          ...activityList.map(
            (activity) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildActivityItem(context, activity),
            ),
          ),
          // Add a loading indicator at the end of the list,
          if (index == activities!.length - 1 && isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            ) // Show loading
          // Show no more entries text if end is reached
          else if (index == activities.length - 1 && !isLoading)
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text("No more entries"),
                )),
        ],
      );
    },
  );
}

Widget _buildActivityItem(BuildContext context, ActivityPreview activity) {
  return ListTile(
      onTap: () {
        context.push("/activities/details", extra: activity);
      },
      isThreeLine: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "${DateFormat("HH:mm").format(activity.start)} - ${DateFormat("HH:mm").format(activity.end)}",
              style: const TextStyle(fontSize: 12, color: Colors.black45)),
          Text(getTranslatedActivityType(context, activity.activityType))
        ],
      ),
      subtitle: activity.distance > 0
          ? Text(AppLocalizations.of(context)!.activity_details(
              activity.distance,
              activity.end.difference(activity.start).inMinutes))
          : Text(AppLocalizations.of(context)!.activity_details_minutes(
              activity.end.difference(activity.start).inMinutes)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Badge(
              alignment: Alignment.bottomRight,
              backgroundColor: Colors.transparent,
              label: activity.icon != null && activity.icon!.isNotEmpty
                  ? Image.memory(activity.icon!, width: 24, height: 24)
                  : null,
              child: Icon(
                getActivityIcon(activity.activityType),
                color: Theme.of(context).colorScheme.onPrimary,
              )),
        )
      ]));
}
