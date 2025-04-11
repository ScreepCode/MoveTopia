// Provider for today's steps
import 'package:collection/collection.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/domain/service/badge_service.dart';

final todayStepsProvider = FutureProvider<double>((ref) async {
  final service = ref.read(badgeServiceProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay =
      startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));
  final todaySteps = (await service.healthService.getStepsInInterval(
    startOfDay,
    endOfDay,
  ))
      .sum;
  return todaySteps.toDouble();
});

// Provider for total steps
final totalStepsProvider = FutureProvider<double>((ref) async {
  final service = ref.read(badgeServiceProvider);
  final installationDate =
      await service.deviceInfoRepository.getInstallationDate();
  final now = DateTime.now();
  final endOfToday = DateTime(
    now.year,
    now.month,
    now.day,
    23,
    59,
    59,
  );
  final totalSteps = (await service.healthService.getStepsInInterval(
    installationDate,
    endOfToday,
  ))
      .sum;

  return totalSteps.toDouble();
});

// Provider for total cycling distance
final totalCyclingProvider = FutureProvider<double>((ref) async {
  final service = ref.read(badgeServiceProvider);
  final installationDate =
      await service.deviceInfoRepository.getInstallationDate();
  final totalCyclingKilometer =
      await service.healthService.getDistanceOfWorkoutsInInterval(
    installationDate,
    DateTime.now(),
    [HealthWorkoutActivityType.BIKING],
  );
  return totalCyclingKilometer / 1000;
});
