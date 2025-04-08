import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/common/widgets/permission_card.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';
import 'package:movetopia/presentation/tracking/widgets/current_activity.dart';
import 'package:movetopia/presentation/tracking/widgets/start_activity.dart';
import 'package:movetopia/utils/health_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackingScreen extends HookConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingViewModelProvider);
    final permissionsState = ref.watch(permissionsProvider);

    useEffect(() {
      if (trackingState?.isRecording == true) {
        ref.read(trackingViewModelProvider.notifier).startTimer();
      }
      return null;
    }, [trackingState?.isRecording]);

    useEffect(() {
      Future.microtask(() {
        ref.read(trackingViewModelProvider.notifier).checkTrackingPermission();
      });
      return null;
    }, [
      permissionsState.healthWritePermissionStatus,
      permissionsState.activityPermissionStatus,
      permissionsState.locationPermissionStatus,
      permissionsState.notificationPermissionStatus
    ]);

    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            if (trackingState.isRecording == false) {
              ref.read(trackingViewModelProvider.notifier).clearState();
            }
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: trackingState!.isRecording
                  ? Text(getTranslatedActivityType(
                      context,
                      HealthWorkoutActivityType.values.firstWhere((t) =>
                          t.name == trackingState.activity.activityType?.name)))
                  : Text(AppLocalizations.of(context)!.tracking_title),
            ),
            body: trackingState.permissionsGranted
                ? _buildTracking(
                    context,
                    trackingState,
                    ref.read(trackingViewModelProvider.notifier).startTracking,
                    ref.read(trackingViewModelProvider.notifier).stopTracking,
                    ref
                        .read(trackingViewModelProvider.notifier)
                        .togglePauseTracking,
                    ref.read(trackingViewModelProvider.notifier).startTimer)
                : _buildPermissions(context, ref, trackingState)));
  }

  Widget _buildTracking(
      BuildContext ref,
      TrackingState trackingState,
      Function startTracking,
      Function stopTracking,
      Function togglePauseTracking,
      Function startTimer) {
    return trackingState.activity.activityType == ActivityType.unknown
        ? StartActivity(
            onStart: (activityType) {
              startTracking(activityType);
            },
          )
        : CurrentActivity(
            activity: trackingState.activity,
            onStop: () {
              stopTracking();
            },
            onPause: () {
              togglePauseTracking();
            },
            startTimer: startTimer,
            durationMillis: trackingState.durationMillis,
            isRecording: trackingState.isRecording,
            isPaused: trackingState.isPaused,
          );
  }

  Widget _buildPermissions(
      BuildContext context, WidgetRef ref, TrackingState trackingState) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final permissionsState = ref.watch(permissionsProvider);

    return Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),

            Container(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Text(
                    "Tracking Permissions",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tracking_permissions_description,
                    textAlign: TextAlign.center,
                  )
                ])),

            const SizedBox(height: 32),

            PermissionCard(
              icon: Icons.drive_file_rename_outline,
              title: l10n.permission_health_write_title,
              description: l10n.permission_health_write_description,
              status: permissionsState.healthWritePermissionStatus
                  ? PermissionStatus.granted
                  : PermissionStatus.denied,
              onRequestPermission: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(l10n.requesting_health_write_permissions),
                      ],
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );

                // Request optional WRITE-Permissions
                ref
                    .read(permissionsProvider.notifier)
                    .requestHealthWritePermission()
                    .then((_) {
                  // Nach dem Anfordern den Status prüfen
                  final writeGranted =
                      ref.read(permissionsProvider).healthWritePermissionStatus;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(writeGranted
                          ? l10n.health_write_granted
                          : l10n.health_write_denied),
                      backgroundColor: writeGranted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                });
              },
              onOpenSettings: () => openAppSettings(),
              isRequired: true,
            ),
            const SizedBox(height: 16),
            PermissionCard(
              icon: Icons.location_on,
              title: l10n.permission_location_title,
              description: l10n.permission_location_description,
              status: permissionsState.locationPermissionStatus,
              onRequestPermission: () => ref
                  .read(permissionsProvider.notifier)
                  .requestLocationPermission(),
              onOpenSettings: () => openAppSettings(),
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Activity recognition permission
            PermissionCard(
              icon: Icons.directions_walk,
              title: l10n.permission_activity_title,
              description: l10n.permission_activity_description,
              status: permissionsState.activityPermissionStatus,
              onRequestPermission: () => ref
                  .read(permissionsProvider.notifier)
                  .requestActivityPermission(),
              onOpenSettings: () => openAppSettings(),
              isRequired: true,
            ),

            const SizedBox(height: 16),

            // Notification permission
            PermissionCard(
              icon: Icons.notifications,
              title: l10n.permission_notification_title,
              description: l10n.permission_notification_description,
              status: permissionsState.notificationPermissionStatus,
              onRequestPermission: () => ref
                  .read(permissionsProvider.notifier)
                  .requestNotificationPermission(),
              onOpenSettings: () => openAppSettings(),
              isRequired: true,
            ),
          ],
        )));
  }
}
