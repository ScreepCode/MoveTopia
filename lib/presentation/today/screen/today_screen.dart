import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:movetopia/presentation/today/view_model/last_activity_view_model.dart';
import 'package:movetopia/presentation/today/view_model/stats_view_model.dart';
import 'package:movetopia/presentation/today/widgets/last_activity_card.dart';
import 'package:movetopia/presentation/today/widgets/today_overview.dart';

import '../../me/view_model/profile_view_model.dart';
import '../view_model/last_activity_state.dart';
import '../view_model/stats_state.dart';

class TodayScreen extends HookConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastActivityState = ref.watch(lastActivityViewModelProvider);
    final statsState = ref.watch(statsViewModelProvider);
    final healthState = ref.watch(healthViewModelProvider);

    Future<void> fetchHealthData() async {
      await ref
          .read(lastActivityViewModelProvider.notifier)
          .fetchLastTraining();
      await ref.read(statsViewModelProvider.notifier).fetchStats();
    }

    useEffect(() {
      if (healthState == HealthAuthViewModelState.authorized) {
        fetchHealthData();
      }
      return null;
    }, [healthState]);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
      ),
      body: _buildBody(context, ref, healthState, lastActivityState, statsState,
          fetchHealthData),
    );
  }
}

Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    HealthAuthViewModelState state,
    LastActivityState? lastActivityState,
    StatsState statsState,
    Future<void> Function() fetchHealthData) {
  switch (state) {
    case HealthAuthViewModelState.notAuthorized:
      return const Center(child: CircularProgressIndicator());
    case HealthAuthViewModelState.authorizationNotGranted:
    case HealthAuthViewModelState.error:
      return Center(
          child: Text(AppLocalizations.of(context)!.please_allow_access));
    case HealthAuthViewModelState.authorized:
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blue,
        onRefresh: fetchHealthData,
        child: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTodayOverview(context, ref, statsState),
              if (lastActivityState != null)
                _buildLastActivityCard(context, lastActivityState),
            ],
          ),
        ),
      );
    default:
      return const Center(child: CircularProgressIndicator());
  }
}

Widget _buildTodayOverview(
    BuildContext context, WidgetRef ref, StatsState statsState) {
  return TodayOverview(
    steps: statsState.steps,
    sleep: statsState.sleep,
    distance: statsState.distance.toStringAsFixed(2),
    stepGoal: ref.watch(profileProvider).stepGoal,
  );
}

Widget _buildLastActivityCard(
    BuildContext context, LastActivityState lastActivityState) {
  return LastActivityCard(
    lastActivity: lastActivityState.activityPreview,
  );
}
