import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:movetopia/presentation/activities/view_model/activities_view_model.dart';
import 'package:movetopia/utils/health_utils.dart';

import '../../../data/model/activity.dart';
import '../view_model/activities_state.dart';

final log = Logger("ActivitiesScreen");

class ActivitiesScreen extends HookConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesViewModelProvider);
    HealthAuthViewModelState authState = ref.read(healthViewModelProvider);

    Future<void> fetchHealthData() async {
      await ref.read(activitiesViewModelProvider.notifier).fetchActivities();
    }

    useEffect(() {
      Future(() async {
        if (authState == HealthAuthViewModelState.authorized) {
          await fetchHealthData();
        }
        log.info(activities);
      });
      return null;
    }, [authState]);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activity_overview),
      ),
      body: activities.isLoading && activities.activities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, activities, fetchHealthData),
    );
  }
}

Widget _buildBody(BuildContext context, ActivitiesState activities,
    Future<void> Function() fetchHealthData) {
  return RefreshIndicator(
    color: Colors.white,
    backgroundColor: Colors.blue,
    onRefresh: fetchHealthData,
    child: activities.activities.isNotEmpty
        ? _buildActivityList(context, activities.activities)
        : activities.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Text(AppLocalizations.of(context)!.no_activities_found)),
  );
}

Widget _buildActivityList(
    BuildContext context, List<ActivityPreview> activities) {
  return ListView.builder(
    itemCount: activities.length,
    itemBuilder: (context, index) {
      final activity = activities[index];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _buildActivityItem(context, activity),
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
    title: Text(getTranslatedActivityType(
        Localizations.localeOf(context), activity.activityType)),
    subtitle: Text(AppLocalizations.of(context)!.activity_details(
        activity.distance, activity.end.difference(activity.start).inMinutes)),
    trailing: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(getActivityIcon(activity.activityType),
          color: Theme.of(context).colorScheme.onPrimary),
    ),
  );
}
