import 'dart:async';

import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, PermissionsState>(
  (ref) => PermissionsNotifier(ref),
);

class PermissionsState {
  final PermissionStatus locationPermissionStatus;
  final PermissionStatus activityPermissionStatus;
  final PermissionStatus notificationPermissionStatus;
  final bool healthPermissionStatus;
  final bool healthWritePermissionStatus;
  final bool healthHistoricalPermissionStatus;

  /*
  * Determine if historical health functionality is available
  * Only relevant for Android, on iOS this is always false
  * */
  final bool isHealthHistoricalAvailable;

  bool get hasRequiredPermissions => healthPermissionStatus;

  PermissionsState({
    this.locationPermissionStatus = PermissionStatus.denied,
    this.activityPermissionStatus = PermissionStatus.denied,
    this.notificationPermissionStatus = PermissionStatus.denied,
    this.healthPermissionStatus = false,
    this.healthWritePermissionStatus = false,
    this.healthHistoricalPermissionStatus = false,
    this.isHealthHistoricalAvailable = false,
  });

  PermissionsState copyWith({
    PermissionStatus? locationPermissionStatus,
    PermissionStatus? activityPermissionStatus,
    PermissionStatus? notificationPermissionStatus,
    bool? healthPermissionStatus,
    bool? healthWritePermissionStatus,
    bool? healthHistoricalPermissionStatus,
    bool? isHealthHistoricalAvailable,
  }) {
    return PermissionsState(
      locationPermissionStatus:
          locationPermissionStatus ?? this.locationPermissionStatus,
      activityPermissionStatus:
          activityPermissionStatus ?? this.activityPermissionStatus,
      notificationPermissionStatus:
          notificationPermissionStatus ?? this.notificationPermissionStatus,
      healthPermissionStatus:
          healthPermissionStatus ?? this.healthPermissionStatus,
      healthWritePermissionStatus:
          healthWritePermissionStatus ?? this.healthWritePermissionStatus,
      healthHistoricalPermissionStatus: healthHistoricalPermissionStatus ??
          this.healthHistoricalPermissionStatus,
      isHealthHistoricalAvailable:
          isHealthHistoricalAvailable ?? this.isHealthHistoricalAvailable,
    );
  }

  @override
  String toString() {
    return 'PermissionsState(location: $locationPermissionStatus, activity: $activityPermissionStatus, notification: $notificationPermissionStatus, health: $healthPermissionStatus, healthWrite: $healthWritePermissionStatus, healthHistorical: $healthHistoricalPermissionStatus)';
  }
}

class PermissionsNotifier extends StateNotifier<PermissionsState> {
  final Ref ref;
  final _health = Health();
  final neededPermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED
  ];

  final writePermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.WORKOUT
  ];

  final log = Logger('PermissionsNotifier');

  PermissionsNotifier(this.ref) : super(PermissionsState()) {
    try {
      _health.configure();
    } catch (e) {
      log.severe(
          'Failed to configure health package in PermissionsNotifier: $e');
    }
    checkAllPermissions();
  }

  // Check all permissions
  Future<void> checkAllPermissions() async {
    try {
      await checkLocationPermission();
      await checkActivityPermission();
      await checkNotificationPermission();
      await checkHealthPermission();
      await checkHealthWritePermission();
      await checkHealthHistoricalPermission();
    } catch (e) {
      log.severe('Error checking all permissions: $e');
    }
  }

  // Check location permission
  Future<void> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      state = state.copyWith(locationPermissionStatus: status);
    } catch (e) {
      log.severe('Error checking location permission: $e');
    }
  }

  // Request location permission
  Future<void> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      state = state.copyWith(locationPermissionStatus: status);
    } catch (e) {
      log.severe('Error requesting location permission: $e');
    }
  }

  // Check activity recognition permission
  Future<void> checkActivityPermission() async {
    try {
      final status = await Permission.activityRecognition.status;
      state = state.copyWith(activityPermissionStatus: status);
    } catch (e) {
      log.severe('Error checking activity recognition permission: $e');
    }
  }

  // Request activity recognition permission
  Future<void> requestActivityPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      state = state.copyWith(activityPermissionStatus: status);
    } catch (e) {
      log.severe('Error requesting activity recognition permission: $e');
    }
  }

  // Check notification permission
  Future<void> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      state = state.copyWith(notificationPermissionStatus: status);
    } catch (e) {
      log.severe('Error checking notification permission: $e');
    }
  }

  // Request notification permission
  Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      state = state.copyWith(notificationPermissionStatus: status);
    } catch (e) {
      log.severe('Error requesting notification permission: $e');
    }
  }

  Future<void> checkHealthPermission() async {
    try {
      bool? hasPermissions = await _health.hasPermissions(neededPermissions);

      state = state.copyWith(healthPermissionStatus: hasPermissions ?? false);

      final healthViewModel = ref.read(healthViewModelProvider);

      // Aktualisiere den Status basierend auf dem HealthAuthViewModel-Zustand
      if ((healthViewModel == HealthAuthViewModelState.authorized ||
              healthViewModel ==
                  HealthAuthViewModelState.authorizedWithHistoricalAccess) &&
          !state.healthPermissionStatus) {
        state = state.copyWith(healthPermissionStatus: true);
      }

      // Prüfe historische Berechtigungen wenn Read-Berechtigungen vorhanden sind
      if (state.healthPermissionStatus) {
        await checkHealthHistoricalPermission();
      }
    } catch (e) {
      log.severe("Error checking health permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
      state = state.copyWith(healthPermissionStatus: false);
    }
  }

  // Check health write permissions
  Future<void> checkHealthWritePermission() async {
    try {
      if (!state.healthPermissionStatus) {
        // If read permissions aren't granted, write permissions can't be granted
        state = state.copyWith(healthWritePermissionStatus: false);
        return;
      }

      // Check for WRITE permissions on the optional write permissions
      bool? hasWritePermissions = await _health.hasPermissions(
        writePermissions,
        permissions:
            List.filled(writePermissions.length, HealthDataAccess.WRITE),
      );

      state = state.copyWith(
          healthWritePermissionStatus: hasWritePermissions ?? false);
    } catch (e) {
      log.severe("Error checking health write permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
      state = state.copyWith(healthWritePermissionStatus: false);
    }
  }

  // Request health permission
  Future<void> requestHealthPermission() async {
    try {
      // Rufe die authorize-Methode von HealthAuthViewModel auf
      final healthViewModel = ref.read(healthViewModelProvider.notifier);
      await healthViewModel.authorize();

      final result = ref.read(healthViewModelProvider);
      final authorized = result == HealthAuthViewModelState.authorized ||
          result == HealthAuthViewModelState.authorizedWithHistoricalAccess;

      // Aktualisiere den Status basierend auf dem Ergebnis der Autorisierung
      if (state.healthPermissionStatus != authorized) {
        state = state.copyWith(healthPermissionStatus: authorized);
      }

      // Nach dem Aktualisieren der Leseberechtigungen auch die Schreibberechtigungen prüfen
      if (authorized) {
        // Diese Aufrufe können fehlschlagen, aber die App sollte trotzdem funktionieren
        try {
          await checkHealthWritePermission();
        } catch (e) {
          log.warning("Error checking write permissions: $e");
        }

        try {
          await checkHealthHistoricalPermission();
        } catch (e) {
          log.warning("Error checking historical permissions: $e");
        }
      }
    } catch (e) {
      log.severe("Error requesting health permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
    }
  }

  // Request health write permissions
  Future<void> requestHealthWritePermission() async {
    try {
      if (!state.healthPermissionStatus) {
        // Can't request write permissions if read permissions aren't granted
        return;
      }

      // Request write permissions
      final healthViewModel = ref.read(healthViewModelProvider.notifier);
      bool success = await healthViewModel.authorizeWriteAccess();

      // Update state
      state = state.copyWith(healthWritePermissionStatus: success);
    } catch (e) {
      log.severe("Error requesting health write permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
    }
  }

  // Check health historical permission
  Future<void> checkHealthHistoricalPermission() async {
    try {
      if (!state.healthPermissionStatus) {
        // If read permissions aren't granted, historical permissions can't be granted
        state = state.copyWith(healthHistoricalPermissionStatus: false);
        return;
      }

      try {
        // Überprüfe die Verfügbarkeit historischer Berechtigungen
        // Dies ist nur für Android relevant, auf iOS ist dies nicht verfügbar

        bool isHistoricalAvailable =
            await _health.isHealthDataHistoryAvailable();
        state =
            state.copyWith(isHealthHistoricalAvailable: isHistoricalAvailable);
        if (!isHistoricalAvailable) {
          log.warning("Historical Health feature is not available");
          return;
        }

        // Verwende die direkte API-Methode, um zu prüfen, ob historische Berechtigungen gewährt wurde

        bool hasHistoricalPermissions =
            await _health.isHealthDataHistoryAuthorized();

        // Wenn die API-Methode true zurückgibt, aktualisiere auch das ViewModel
        if (hasHistoricalPermissions) {
          // Stelle sicher, dass das ViewModel konsistent ist
          final healthViewModel = ref.read(healthViewModelProvider);
          if (healthViewModel !=
              HealthAuthViewModelState.authorizedWithHistoricalAccess) {
            ref.read(healthViewModelProvider.notifier).state =
                HealthAuthViewModelState.authorizedWithHistoricalAccess;
          }
        }

        // Setze den Status
        state = state.copyWith(
            healthHistoricalPermissionStatus: hasHistoricalPermissions);

        // Debug-Info
        log.info('Historical permissions check: $hasHistoricalPermissions');
      } catch (e) {
        // Fallback: Wenn die API-Methode fehlschlägt, verwenden wir den Status aus dem ViewModel
        log.warning(
            "Error during direct historical permission check, using ViewModel state: $e");

        final healthViewModel = ref.read(healthViewModelProvider);
        final hasHistorical = healthViewModel ==
            HealthAuthViewModelState.authorizedWithHistoricalAccess;

        state = state.copyWith(healthHistoricalPermissionStatus: hasHistorical);
        log.info(
            'Historical permissions fallback check from ViewModel: $hasHistorical');
      }
    } catch (e) {
      log.severe("Error checking health historical permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
      state = state.copyWith(healthHistoricalPermissionStatus: false);
    }
  }

  // Request health historical permission
  Future<void> requestHealthHistoricalPermission() async {
    try {
      if (!state.healthPermissionStatus) {
        // Can't request historical permissions if read permissions aren't granted
        log.warning(
            "Can't request historical permissions without read permissions");
        return;
      }

      log.info("Requesting historical health permissions using health API");

      // Direkt die API-Methode für historische Berechtigungen verwenden
      bool success = await _health.requestHealthDataHistoryAuthorization();

      // Nach der Anfrage den aktuellen Zustand prüfen (nicht auf ein anderes Objekt verlassen)
      bool hasHistorical = await _health.isHealthDataHistoryAuthorized();

      // Debug-Info
      log.info(
          "Historical permission result: success=$success, hasHistorical=$hasHistorical");

      // Stelle sicher, dass das ViewModel konsistent ist
      if (hasHistorical) {
        ref.read(healthViewModelProvider.notifier).state =
            HealthAuthViewModelState.authorizedWithHistoricalAccess;
      }

      // Update state
      state = state.copyWith(healthHistoricalPermissionStatus: hasHistorical);
    } catch (e) {
      log.severe("Error requesting health historical permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
    }
  }
}
