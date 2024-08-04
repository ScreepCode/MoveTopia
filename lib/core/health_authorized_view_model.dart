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
    _health.configure(useHealthConnectIfAvailable: true);
    _init();
  }

  Future<void> _init() async {
    await _authorize();
  }

  Future<void> _authorize() async {
    // await Permission.activityRecognition.request();
    // await Permission.location.request();

    bool? hasPermissions = await _health.hasPermissions(neededPermissions);
    if (!hasPermissions!) {
      try {
        bool authorized = await _health.requestAuthorization(neededPermissions);
        if (authorized) {
          state = HealthAuthViewModelState.authorized;
        } else {
          state = HealthAuthViewModelState.authorizationNotGranted;
        }
      } catch (error) {
        debugPrint("Exception in authorize: $error");
        state = HealthAuthViewModelState.error;
      }
    }
  }
}

enum HealthAuthViewModelState {
  notAuthorized, // App started
  authorized,
  authorizationNotGranted,
  error,
}
