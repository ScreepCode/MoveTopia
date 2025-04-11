import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/presentation/challenges/provider/badge_repository_provider.dart';
import 'package:movetopia/presentation/challenges/widgets/badge_detail_dialog.dart';
import 'package:movetopia/presentation/common/app_assets.dart';
import 'package:movetopia/presentation/onboarding/routes.dart';
import 'package:movetopia/presentation/today/view_model/last_activity_view_model.dart';
import 'package:movetopia/presentation/today/view_model/stats_view_model.dart';
import 'package:movetopia/presentation/today/widgets/achievement_preview_card.dart';
import 'package:movetopia/presentation/today/widgets/exercise_minutes_card.dart';
import 'package:movetopia/presentation/today/widgets/last_activity_card.dart';
import 'package:movetopia/presentation/today/widgets/steps_streak_card.dart';
import 'package:movetopia/presentation/today/widgets/tracking_active.dart';
import 'package:movetopia/presentation/today/widgets/weekly_steps_chart.dart';
import 'package:movetopia/presentation/tracking/routes.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';

import '../../../core/health_authorized_view_model.dart';
import '../../challenges/routes.dart';
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

    // Hold loading state
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
      await ref.read(trackingViewModelProvider.notifier).togglePauseTracking();
      context.push(trackingPath);
    }

    Future<void> stopTracking() async {
      await ref.read(trackingViewModelProvider.notifier).stopTracking();
      context.push(trackingPath);
    }

    void navigateToBadges() {
      // Navigate to badges screen
      context.push(fullBadgeListsPath);
    }

    // Show RefreshIndicator manually when we are loading
    useEffect(() {
      if (isLoading.value) {
        // Add a frame callback to ensure the indicator is only shown
        // after the widget has been fully rendered
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
      if (authState == HealthAuthViewModelState.authorized ||
          authState ==
              HealthAuthViewModelState.authorizedWithHistoricalAccess) {
        if (previousAuthState.value != authState) {
          fetchHealthData();
        }
      }

      previousAuthState.value = authState;

      return null;
    }, [authState]);

    // Initial data loading when screen builds the first time
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchHealthData();
      });
      return null;
    }, const []);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Row(
            children: [
              const Image(
                  image: AssetImage(AppAssets.appIcon), width: 40, height: 40),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.app_name)
            ],
          ),
          actions: [
            IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
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
            navigateToBadges,
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
  void Function() navigateToBadges,
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  return Stack(children: [
    RefreshIndicator(
      key: refreshIndicatorKey,
      color: theme.colorScheme.onPrimary,
      backgroundColor: theme.colorScheme.primary,
      onRefresh: fetchHealthData,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // Today's Section
            _buildSectionHeader(context, l10n.navigation_today, theme),
            const SizedBox(height: 12),

            // Combined Steps & Streak Card
            StepsStreakCard(
              steps: statsState.steps,
              stepGoal: ref.read(profileProvider).stepGoal,
            ),
            const SizedBox(height: 12),

            // Last Activity Card
            if (lastActivityState != null &&
                lastActivityState.activityPreview != null)
              _buildLastActivityCard(context, lastActivityState),

            const SizedBox(height: 24),

            // Weekly Section
            _buildSectionHeader(context, "Weekly Stats", theme),
            const SizedBox(height: 12),

            // Weekly Steps Chart with Sleep
            WeeklyStepsChart(
              stepsData: statsState.weeklySteps,
              sleepData: statsState.weeklySleep,
              stepGoal: ref.read(profileProvider).stepGoal,
            ),
            const SizedBox(height: 16),

            // Exercise Minutes Card
            ExerciseMinutesCard(
              minutesToday: statsState.exerciseMinutesToday,
              minutesWeek: statsState.exerciseMinutesWeek,
            ),
            const SizedBox(height: 24),

            // Achievements Section
            _buildSectionHeader(
                context, l10n.challenges_achievements_title, theme),
            const SizedBox(height: 12),

            // Badge Preview using new component
            AchievementPreviewCard(onTapViewAll: navigateToBadges),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    if (trackingState != null && trackingState.isRecording)
      _buildCurrentTracking(
          context, ref, trackingState, stopTracking, pauseTracking),
  ]);
}

Widget _buildSectionHeader(
    BuildContext context, String title, ThemeData theme) {
  return Row(
    children: [
      Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    ],
  );
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
  Future<void> Function() pauseTracking,
) {
  return ActiveTracking(
    activity: state.activity,
    durationMillis: state.durationMillis,
    paused: state.isPaused,
    onCardClick: () => _onCardClick(context),
    onPause: pauseTracking,
    onStop: stopTracking,
  );
}

Widget _buildLastActivityCard(
    BuildContext context, LastActivityState lastActivityState) {
  return LastActivityCard(
    lastActivity: lastActivityState.activityPreview,
  );
}
