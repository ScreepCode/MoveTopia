// Provider for today's steps
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/domain/service/badge_service.dart';

final todayStepsProvider = FutureProvider<double>((ref) async {
  final service = ref.read(badgeServiceProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay =
      startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));
  final todaySteps = await service.localHealthRepository.getStepsInInterval(
    startOfDay,
    endOfDay,
  );
  return todaySteps.toDouble();
});

// Provider for total steps
final totalStepsProvider = FutureProvider<double>((ref) async {
  final service = ref.read(badgeServiceProvider);
  final installationDate =
      await service.deviceInfoRepository.getInstallationDate();
  final totalSteps = await service.localHealthRepository.getStepsInInterval(
    installationDate,
    DateTime.now(),
  );
  return totalSteps.toDouble();
});

// Provider for total cycling distance
final totalCyclingProvider = FutureProvider<double>((ref) async {
  final service = ref.read(badgeServiceProvider);
  final installationDate =
      await service.deviceInfoRepository.getInstallationDate();
  final totalCyclingKilometer =
      await service.localHealthRepository.getDistanceOfWorkoutsInInterval(
    installationDate,
    DateTime.now(),
    [HealthWorkoutActivityType.BIKING],
  );
  return totalCyclingKilometer / 1000;
});
