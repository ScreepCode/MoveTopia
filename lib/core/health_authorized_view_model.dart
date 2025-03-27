import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:riverpod/riverpod.dart';

final healthViewModelProvider =
    StateNotifierProvider<HealthAuthViewModel, HealthAuthViewModelState>(
  (ref) => HealthAuthViewModel(ref),
);

class HealthAuthViewModel extends StateNotifier<HealthAuthViewModelState> {
  final Ref ref;
  final _health = Health();
  final neededPermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE
  ];

  HealthAuthViewModel(this.ref)
      : super(HealthAuthViewModelState.notAuthorized) {
    _health.configure();
  }

  Future<void> authorize() async {
    bool? hasPermissions = await _health.hasPermissions(neededPermissions);
    if (hasPermissions == null || !hasPermissions) {
      try {
        bool authorized = await _health.requestAuthorization(neededPermissions,
            permissions: [HealthDataAccess.READ_WRITE]);
        if (authorized) {
          state = HealthAuthViewModelState.authorized;
        } else {
          state = HealthAuthViewModelState.authorizationNotGranted;
        }
      } catch (error) {
        debugPrint("Exception in authorize: $error");
        state = HealthAuthViewModelState.error;
      }
    } else {
      state = HealthAuthViewModelState.authorized;
    }
  }
}

enum HealthAuthViewModelState {
  notAuthorized, // App started
  authorized,
  authorizationNotGranted,
  error,
}
