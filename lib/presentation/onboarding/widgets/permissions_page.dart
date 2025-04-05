import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/common/widgets/permission_card.dart';
import 'package:movetopia/presentation/common/widgets/section_header.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends ConsumerWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissionsState = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    final requiredPermissionsGranted = permissionsState.hasRequiredPermissions;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Icon
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

            const SizedBox(height: 32),

            Text(
              l10n.onboarding_permissions_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              l10n.onboarding_permissions_description,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Required permissions
            SectionHeader(title: l10n.required_permissions),

            const SizedBox(height: 16),

            // Health data READ permission (required)
            PermissionCard(
              icon: Icons.favorite,
              title: l10n.permission_health_read_title,
              description: l10n.permission_health_read_description,
              status: permissionsState.healthPermissionStatus
                  ? PermissionStatus.granted
                  : PermissionStatus.denied,
              onRequestPermission: () {
                if (permissionsState.healthPermissionStatus) return;

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
                        Text(l10n.requesting_health_permissions),
                      ],
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );

                ref
                    .read(permissionsProvider.notifier)
                    .requestHealthPermission()
                    .then((_) {})
                    .catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(l10n.health_permission_error(error.toString())),
                      backgroundColor: theme.colorScheme.error,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: l10n.retry,
                        textColor: Colors.white,
                        onPressed: () {
                          ref
                              .read(permissionsProvider.notifier)
                              .requestHealthPermission();
                        },
                      ),
                    ),
                  );
                });
              },
              onOpenSettings: () => openAppSettings(),
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // Optional Permissions
            SectionHeader(title: l10n.optional_permissions),

            const SizedBox(height: 16),

            PermissionCard(
              icon: Icons.drive_file_rename_outline,
              title: l10n.permission_health_write_title,
              description: l10n.permission_health_write_description,
              status: permissionsState.healthWritePermissionStatus
                  ? PermissionStatus.granted
                  : PermissionStatus.denied,
              onRequestPermission: () {
                // Überprüfe zuerst, ob Read-Berechtigung vorhanden ist
                if (!permissionsState.healthPermissionStatus) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Bitte erteile zuerst die Leseberechtigung für Gesundheitsdaten'),
                      backgroundColor: theme.colorScheme.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }

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
              isRequired: false,
            ),

            const SizedBox(height: 16),

            PermissionCard(
              icon: Icons.directions_walk,
              title: l10n.permission_activity_title,
              description: l10n.permission_activity_description,
              status: permissionsState.activityPermissionStatus,
              onRequestPermission: () {
                if (permissionsState.activityPermissionStatus.isGranted) return;
                ref
                    .read(permissionsProvider.notifier)
                    .requestActivityPermission();
              },
              onOpenSettings: () => openAppSettings(),
              isRequired: false,
            ),

            const SizedBox(height: 16),

            // Location permission
            PermissionCard(
              icon: Icons.location_on,
              title: l10n.permission_location_title,
              description: l10n.permission_location_description,
              status: permissionsState.locationPermissionStatus,
              onRequestPermission: () {
                if (permissionsState
                    .locationPermissionStatus.isPermanentlyDenied) {
                  openAppSettings();
                  return;
                }
                ref
                    .read(permissionsProvider.notifier)
                    .requestLocationPermission();
              },
              onOpenSettings: () => openAppSettings(),
              isRequired: false,
            ),

            const SizedBox(height: 16),

            // Notification permission
            PermissionCard(
              icon: Icons.notifications,
              title: l10n.permission_notification_title,
              description: l10n.permission_notification_description,
              status: permissionsState.notificationPermissionStatus,
              onRequestPermission: () {
                if (permissionsState
                    .notificationPermissionStatus.isPermanentlyDenied) {
                  openAppSettings();
                  return;
                }
                ref
                    .read(permissionsProvider.notifier)
                    .requestNotificationPermission();
              },
              onOpenSettings: () => openAppSettings(),
              isRequired: false,
            ),

            if (!requiredPermissionsGranted) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.grant_required_permissions,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.permissions_required_for_app_functionality,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!permissionsState.healthPermissionStatus)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.health_data_access_missing,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
