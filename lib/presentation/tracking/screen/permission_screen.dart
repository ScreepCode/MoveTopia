import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/common/widgets/permission_card.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends HookConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            // Activity recognition permission - only for Android
            if (Theme.of(context).platform == TargetPlatform.android)
              Column(
                children: [
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
                ],
              ),

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
