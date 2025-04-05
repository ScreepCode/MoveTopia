import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:movetopia/presentation/common/widgets/permission_card.dart';
import 'package:movetopia/presentation/common/widgets/section_header.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsSettingsScreen extends ConsumerWidget {
  const PermissionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissionsState = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    // Überprüfe die Berechtigungen beim Aufbau des Bildschirms
    Future.microtask(() {
      ref.read(permissionsProvider.notifier).checkAllPermissions();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permission_settings_title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.permission_settings_subtitle,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Required permissions section
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
                  // Zeige Ladeindikator
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

                  // Request health data permission
                  ref.read(healthViewModelProvider.notifier).authorize();
                  ref
                      .read(permissionsProvider.notifier)
                      .requestHealthPermission();
                },
                onOpenSettings: () => openAppSettings(),
                isRequired: true,
              ),

              const SizedBox(height: 24),

              // Optional permissions section
              SectionHeader(title: l10n.optional_permissions),
              const SizedBox(height: 16),

              // Health data WRITE permission (optional)
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
                    final writeGranted = ref
                        .read(permissionsProvider)
                        .healthWritePermissionStatus;
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

              // Location permission
              PermissionCard(
                icon: Icons.location_on,
                title: l10n.permission_location_title,
                description: l10n.permission_location_description,
                status: permissionsState.locationPermissionStatus,
                onRequestPermission: () => ref
                    .read(permissionsProvider.notifier)
                    .requestLocationPermission(),
                onOpenSettings: () => openAppSettings(),
                isRequired: false,
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
                isRequired: false,
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
                isRequired: false,
              ),

              const SizedBox(height: 24),

              // Hinweistext
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hinweis: Einige Berechtigungen können nur in den Systemeinstellungen deines Geräts geändert werden.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
