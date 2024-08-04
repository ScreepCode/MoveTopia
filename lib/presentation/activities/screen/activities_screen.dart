import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/health_authorized_view_model.dart';
import 'package:hackathon/presentation/activities/view_model/activities_view_model.dart';
import 'package:hackathon/utils/health_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final log = Logger("ActivitiesScreen");

class ActivitiesScreen extends HookConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = Logger("TrainingsScreen");
    final activities = ref.watch(activitiesViewModelProvider);
    HealthAuthViewModelState state = ref.watch(healthViewModelProvider);

    Future<void> fetchHealthData() async {
      await ref.read(activitiesViewModelProvider.notifier).fetchActivities();
    }

    useEffect(() {
      Future(() async {
        HealthAuthViewModelState state = ref.watch(healthViewModelProvider);
        if (state == HealthAuthViewModelState.authorized) {
          await fetchHealthData();
        }
        log.info(activities);
      });
      return null;
    }, [state]);

    return RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blue,
        onRefresh: fetchHealthData,
        child: activities.activities.isNotEmpty
            ? ListView.builder(
                itemCount: activities.activities.length,
                itemBuilder: (context, index) {
                  final activity = activities.activities[index];
                  return ListTile(
                      onTap: () {
                        context.push("/activities/details", extra: activity);
                      },
                      isThreeLine: true,
                      title: Text(getTranslatedActivityType(
                          Localizations.localeOf(context),
                          activity.activityType)),
                      subtitle: Text(
                          '${activity.distance}km in ${activity.end.difference(activity.start).inMinutes} Minuten'),
                      trailing: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(getActivityIcon(activity.activityType),
                            color: Theme.of(context).colorScheme.onPrimary),
                      ));
                },
              )
            : const Text(""));
  }
}
