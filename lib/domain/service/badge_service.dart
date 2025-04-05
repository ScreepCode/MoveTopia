import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/data/repositories/badge_repository_impl.dart';
import 'package:movetopia/data/repositories/device_info_repository_impl.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:movetopia/domain/repositories/local_health.dart';

import '../../data/repositories/local_health_impl.dart';
import 'level_service.dart';

class BadgeService {
  final BadgeRepository badgeRepository;
  final LocalHealthRepository localHealthRepository;
  final DeviceInfoRepository deviceInfoRepository;
  final LevelService levelService;

  BadgeService({
    required this.badgeRepository,
    required this.localHealthRepository,
    required this.deviceInfoRepository,
    required this.levelService,
  });

  Future<void> checkAndUpdateBadges() async {
    final installationDate = await deviceInfoRepository.getInstallationDate();
    final lastCheckDate = await deviceInfoRepository.getLastOpenedDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _checkTotalStepsBadges(installationDate, now);
    await _checkTotalCyclingBadges(installationDate, now);
    await _checkDailyStepsBadges(lastCheckDate, now);

    // Update the last check date to today
    await deviceInfoRepository.updateLastOpenedDate(today);
  }

  // Check and update badge status, return whether a level up occurred
  Future<bool> checkAndUpdateBadgeStatus(
      AchievementBadge badge, int currentValue) async {
    bool leveledUp = false;
    bool wasAchieved = badge.isAchieved;

    if (currentValue >= badge.threshold) {
      if (!badge.isAchieved) {
        // First achievement of this badge
        final updatedBadge = badge.copyWith(
          isAchieved: true,
          achievedCount: 1,
          lastAchievedDate: DateTime.now(),
        );

        await badgeRepository.saveBadge(updatedBadge);

        // Award EP for new badge achievement
        leveledUp = await levelService.addEp(badge.epValue);
      } else if (badge.isRepeatable &&
          badge.lastAchievedDate?.day != DateTime.now().day) {
        // Repeated achievement of repeatable badge (only once per day)
        final updatedBadge = badge.copyWith(
          achievedCount: badge.achievedCount + 1,
          lastAchievedDate: DateTime.now(),
        );

        await badgeRepository.saveBadge(updatedBadge);

        // Award partial EP for repeat achievements
        int ep = (badge.epValue * 0.3).floor(); // 30% of original EP
        leveledUp = await levelService.addEp(ep);
      }
    }

    return leveledUp;
  }

  Future<void> _checkTotalStepsBadges(
      DateTime installationDate, DateTime end) async {
    final totalSteps =
        await localHealthRepository.getStepsInInterval(installationDate, end);
    final badges = await badgeRepository
        .getBadgesByCategory(AchievementBadgeCategory.totalSteps);

    for (var badge in badges) {
      await checkAndUpdateBadgeStatus(badge, totalSteps);
    }
  }

  Future<void> _checkTotalCyclingBadges(
      DateTime installationDate, DateTime end) async {
    final totalCyclingKm = await localHealthRepository
            .getDistanceOfWorkoutsInInterval(
                installationDate, end, [HealthWorkoutActivityType.BIKING]) /
        1000; // Convert to km
    final badges = await badgeRepository
        .getBadgesByCategory(AchievementBadgeCategory.totalCyclingDistance);

    for (var badge in badges) {
      await checkAndUpdateBadgeStatus(badge, totalCyclingKm.floor());
    }
  }

  Future<void> _checkDailyStepsBadges(
      DateTime lastCheckDate, DateTime now) async {
    final badges = await badgeRepository
        .getBadgesByCategory(AchievementBadgeCategory.dailySteps);

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
        final currentBadge = await badgeRepository.getBadgeById(badge.id);
        await checkAndUpdateBadgeStatus(currentBadge, steps);
      }
    }
  }

  Future<List<AchievementBadge>> getBadgesByCategory(
      AchievementBadgeCategory category) async {
    return await badgeRepository.getBadgesByCategory(category);
  }

  Future<List<AchievementBadge>> getAllBadges() async {
    return await badgeRepository.getAllBadges();
  }

  Future<void> validateAllBadges() async {
    await badgeRepository.validateAllBadges();
  }
}

final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService(
    badgeRepository: ref.watch(badgeRepositoryProvider),
    localHealthRepository: ref.watch(localHealthRepositoryProvider),
    deviceInfoRepository: ref.watch(deviceInfoRepositoryProvider),
    levelService: ref.watch(levelServiceProvider),
  );
});
