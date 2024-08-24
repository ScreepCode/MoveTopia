import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hackathon/core/health_authorized_view_model.dart';
import 'package:hackathon/presentation/today/view_model/last_activity_view_model.dart';
import 'package:hackathon/presentation/today/view_model/stats_view_model.dart';
import 'package:hackathon/presentation/today/widgets/last_activity_card.dart';
import 'package:hackathon/presentation/today/widgets/today_overview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../me/view_model/profile_view_model.dart';

class TodayScreen extends HookConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastActivityState = ref.watch(lastActivityViewModelProvider);
    final statsViewModel = ref.watch(statsViewModelProvider);
    HealthAuthViewModelState state = ref.watch(healthViewModelProvider);

    Future<void> fetchHealthData() async {
      await ref
          .read(lastActivityViewModelProvider.notifier)
          .fetchLastTraining();
      await ref.read(statsViewModelProvider.notifier).fetchStats();
    }

    useEffect(() {
      // Use a future to ensure fetching is done before UI updates
      Future(() async {
        HealthAuthViewModelState state = ref.watch(healthViewModelProvider);
        if (state == HealthAuthViewModelState.authorized) {
          await fetchHealthData();
        }
      });
      return null;
    }, [state]);

    switch (state) {
      case HealthAuthViewModelState.notAuthorized:
        return const Center(child: CircularProgressIndicator());
      case HealthAuthViewModelState.authorizationNotGranted ||
            HealthAuthViewModelState.error:
        return const Center(child: Text('Please allow access to health data'));
      case HealthAuthViewModelState.authorized:
        return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.blue,
            onRefresh: fetchHealthData,
            child: SafeArea(
                minimum: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TodayOverview(
                      steps: statsViewModel.steps,
                      sleep: statsViewModel.sleep,
                      distance: statsViewModel.distance.toStringAsFixed(2),
                      stepGoal: ref.watch(profileProvider).stepGoal,
                    ),
                    LastActivityCard(
                      lastActivity: lastActivityState.activityPreview,
                    ),
                  ],
                )));
    }
  }
}
