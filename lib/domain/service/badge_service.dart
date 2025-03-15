import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/data/repositories/badge_repository_impl.dart';
import 'package:movetopia/data/repositories/device_info_repository_impl.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:movetopia/domain/repositories/local_health.dart';

import '../../data/repositories/local_health_impl.dart';
import '../../presentation/profile/view_model/profile_view_model.dart';
import '../repositories/profile_repository.dart';

class BadgeService {
  final BadgeRepository badgeRepository;
  final LocalHealthRepository localHealthRepository;
  final DeviceInfoRepository deviceInfoRepository;
  final ProfileRepository profileRepository;

  BadgeService({
    required this.badgeRepository,
    required this.localHealthRepository,
    required this.deviceInfoRepository,
    required this.profileRepository,
  });

  Future<void> checkAndUpdateBadges() async {
    final installationDate = await deviceInfoRepository.getInstallationDate();
    final lastCheckDate = await deviceInfoRepository.getLastOpenedDate();
    final now = DateTime.now();

    await _checkTotalStepsBadges(installationDate, now);
    await _checkTotalCyclingBadges(installationDate, now);
    await _checkDailyStepsBadges(lastCheckDate, now);

    await deviceInfoRepository
        .updateLastOpenedDate(now.subtract(Duration(days: 30)));
  }

  Future<void> _checkTotalStepsBadges(
      DateTime installationDate, DateTime end) async {
    final totalSteps =
        await localHealthRepository.getStepsInInterval(installationDate, end);
    print(totalSteps);
    final badges = await badgeRepository
        .getBadgesByCategory(AchivementBadgeCategory.totalSteps);

    for (var badge in badges) {
      if (totalSteps >= badge.threshold && !badge.isAchieved) {
        await badgeRepository.saveBadge(badge.copyWith(
          isAchieved: true,
          achievedCount: 1,
          lastAchievedDate: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _checkTotalCyclingBadges(
      DateTime installationDate, DateTime end) async {
    final totalCyclingKm = await localHealthRepository
            .getDistanceOfWorkoutsInInterval(
                installationDate, end, [HealthWorkoutActivityType.BIKING]) /
        1000; // Convert to km
    final badges = await badgeRepository
        .getBadgesByCategory(AchivementBadgeCategory.totalCyclingDistance);

    for (var badge in badges) {
      if (totalCyclingKm >= badge.threshold && !badge.isAchieved) {
        await badgeRepository.saveBadge(badge.copyWith(
          isAchieved: true,
          achievedCount: 1,
          lastAchievedDate: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _checkDailyStepsBadges(
      DateTime lastCheckDate, DateTime now) async {
    final badges = await badgeRepository
        .getBadgesByCategory(AchivementBadgeCategory.dailySteps);

    // Only check completed days (yesterday and earlier)
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    // Check each day between last check and yesterday
    for (var day = lastCheckDate;
        day.isBefore(yesterday) || day.isAtSameMomentAs(yesterday);
        day = day.add(const Duration(days: 1))) {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay =
          startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      final steps =
          await localHealthRepository.getStepsInInterval(startOfDay, endOfDay);

      for (var badge in badges) {
        if (steps >= badge.threshold) {
          final currentBadge = await badgeRepository.getBadgeById(badge.id);
          await badgeRepository.saveBadge(currentBadge.copyWith(
            isAchieved: true,
            achievedCount: currentBadge.achievedCount + 1,
            lastAchievedDate: DateTime.now(),
          ));
        }
      }
    }
  }

  Future<List<AchivementBadge>> getBadgesByCategory(
      AchivementBadgeCategory category) async {
    return await badgeRepository.getBadgesByCategory(category);
  }

  Future<List<AchivementBadge>> getAllBadges() async {
    return await badgeRepository.getAllBadges();
  }
}

final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService(
    badgeRepository: ref.watch(badgeRepositoryProvider),
    localHealthRepository: ref.watch(localHealthRepositoryProvider),
    deviceInfoRepository: ref.watch(deviceInfoRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});
