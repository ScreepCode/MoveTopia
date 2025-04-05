import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/common/app_assets.dart';
import 'package:movetopia/presentation/onboarding/routes.dart';
import 'package:movetopia/presentation/today/view_model/last_activity_view_model.dart';
import 'package:movetopia/presentation/today/view_model/stats_view_model.dart';
import 'package:movetopia/presentation/today/widgets/last_activity_card.dart';
import 'package:movetopia/presentation/today/widgets/today_overview.dart';
import 'package:movetopia/presentation/today/widgets/tracking_active.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';

import '../../../core/health_authorized_view_model.dart';
import '../../challenges/widgets/streak_card.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/last_activity_state.dart';
import '../view_model/stats_state.dart';

class TodayScreen extends HookConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastActivityState = ref.watch(lastActivityViewModelProvider);
    final statsState = ref.watch(statsViewModelProvider);
    final authState = ref.watch(healthViewModelProvider);
    final trackingState = ref.watch(trackingViewModelProvider);
    final previousAuthState = useRef<HealthAuthViewModelState?>(null);

    // Halte den Ladezustand
    final isLoading = useState(false);
    final refreshIndicatorKey = useRef(GlobalKey<RefreshIndicatorState>());

    Future<void> fetchHealthData() async {
      try {
        isLoading.value = true;
        await ref
            .read(lastActivityViewModelProvider.notifier)
            .fetchLastTraining();
        await ref.read(statsViewModelProvider.notifier).fetchStats();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> pauseTracking() async {
      await ref.read(trackingViewModelProvider.notifier).pauseTracking();
      context.push("/tracking");
    }

    Future<void> stopTracking() async {
      await ref.read(trackingViewModelProvider.notifier).stopTracking();
      context.push("/tracking");
    }

    // Zeige den RefreshIndicator manuell an, wenn wir laden
    useEffect(() {
      if (isLoading.value) {
        // Füge einen Frame-Callback hinzu, um sicherzustellen, dass der Indikator erst angezeigt wird,
        // nachdem das Widget vollständig gerendert wurde
        WidgetsBinding.instance.addPostFrameCallback((_) {
          refreshIndicatorKey.value.currentState?.show();
        });
      }
      return null;
    }, [isLoading.value]);

    useEffect(() {
      if (authState == HealthAuthViewModelState.authorizationNotGranted ||
          authState == HealthAuthViewModelState.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(authorizationProblemPath);
        });
      }
      return null;
    }, [authState]);

    useEffect(() {
      if (authState == HealthAuthViewModelState.authorized) {
        if (previousAuthState.value != HealthAuthViewModelState.authorized) {
          fetchHealthData();
        }
      }

      previousAuthState.value = authState;

      return null;
    }, [authState]);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Row(
            children: [
              const Image(
                  image: AssetImage(AppAssets.appIcon), width: 40, height: 40),
              Text(AppLocalizations.of(context)!.app_name)
            ],
          ),
          actions: [
            IconButton(onPressed: () => (), icon: const Icon(Icons.settings))
          ],
        ),
        body: _buildBody(
            context,
            ref,
            lastActivityState,
            statsState,
            trackingState,
            fetchHealthData,
            stopTracking,
            pauseTracking,
            refreshIndicatorKey.value),
        floatingActionButton: trackingState?.isRecording == false
            ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  context.push("/tracking");
                })
            : null);
  }
}

Widget _buildBody(
  BuildContext context,
  WidgetRef ref,
  LastActivityState? lastActivityState,
  StatsState statsState,
  TrackingState? trackingState,
  Future<void> Function() fetchHealthData,
  Future<void> Function() stopTracking,
  Future<void> Function() pauseTracking,
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
) {
  return Stack(children: [
    RefreshIndicator(
      key: refreshIndicatorKey,
      color: Colors.white,
      backgroundColor: Colors.blue,
      onRefresh: fetchHealthData,
      child: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTodayOverview(context, ref, statsState),
            const StreakCard(isCompact: true),
            if (lastActivityState != null)
              _buildLastActivityCard(context, lastActivityState),
          ],
        ),
      ),
    ),
    if (trackingState != null && trackingState.isRecording)
      _buildCurrentTracking(
          context, ref, trackingState, stopTracking, pauseTracking),
  ]);
}

void _onCardClick(BuildContext context) {
  print("Card clicked");
  context.push("/tracking");
}

Widget _buildCurrentTracking(
    BuildContext context,
    WidgetRef ref,
    TrackingState state,
    Future<void> Function() stopTracking,
    Future<void> Function() pauseTracking) {
  return ActiveTracking(
    activity: state.activity,
    duration: state.duration,
    onCardClick: () => _onCardClick(context),
    onPause: pauseTracking,
    onStop: stopTracking,
  );
}

Widget _buildTodayOverview(
    BuildContext context, WidgetRef ref, StatsState statsState) {
  return TodayOverview(
    steps: statsState.steps,
    sleep: statsState.sleep,
    distance: statsState.distance.toStringAsFixed(2),
    stepGoal: ref.read(profileProvider).stepGoal,
  );
}

Widget _buildLastActivityCard(
    BuildContext context, LastActivityState lastActivityState) {
  return LastActivityCard(
    lastActivity: lastActivityState.activityPreview,
  );
}
