import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/utils/health_utils.dart';

import '../view_model/activity_detail_state.dart';
import '../view_model/activity_detail_view_model.dart';
import '../widget/header_details.dart';
import '../widget/workout_details.dart';

class ActivityDetailsScreen extends HookConsumerWidget {
  const ActivityDetailsScreen({super.key, required this.activityPreview});

  final ActivityPreview activityPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var log = Logger("ActivityDetailsScreen");
    ActivityDetailState activityState =
        ref.watch(activityDetailedViewModelProvider);
    HealthAuthViewModelState authState = ref.read(healthViewModelProvider);

    Future<void> fetchDetailedActivity() async {
      await ref
          .read(activityDetailedViewModelProvider.notifier)
          .fetchActivityDetailed(activityPreview);
    }

    useEffect(() {
      Future(
        () async {
          var activityDetailNotifier =
              ref.read(activityDetailedViewModelProvider.notifier);
          activityDetailNotifier.setLoading(true);
          if (authState == HealthAuthViewModelState.authorized) {
            await fetchDetailedActivity();
          }

          activityDetailNotifier.setLoading(false);
          return null;
        },
      );
      return;
    }, [authState]);

    return Scaffold(
      appBar: AppBar(),
      body: activityState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, ref, activityState),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ActivityDetailState activityState) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ListView(
        children: [
          _buildHeaderDetails(context, activityState),
          _buildWorkoutDetails(activityState),
        ],
      ),
    );
  }

  Widget _buildHeaderDetails(
      BuildContext context, ActivityDetailState activityState) {
    return HeaderDetails(
      platformIcon: activityState.activity.icon,
      title: getTranslatedActivityType(
          context, activityState.activity.activityType),
      start: activityState.activity.start,
      end: activityState.activity.end,
      icon: getActivityIcon(activityPreview.activityType),
    );
  }

  Widget _buildWorkoutDetails(ActivityDetailState activityState) {
    return WorkoutDetails(
      averageHeartBeat: activityState.getAverageHeartBeat(),
      duration: activityPreview.getDuration(),
      caloriesBurnt: activityPreview.caloriesBurnt,
      steps: 0, // TODO: Add steps from workout
    );
  }
}
