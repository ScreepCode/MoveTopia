import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/repositories/badge_repository.dart';
import '../../domain/repositories/debug_repository.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../domain/service/badge_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DebugRepositoryImpl implements DebugRepository {
  final logger = Logger('DebugRepositoryImpl');
  final StreakRepository _streakRepository;
  final BadgeRepository _badgeRepository;
  final BadgeService? _badgeService;

  DebugRepositoryImpl(this._streakRepository, this._badgeRepository,
      [this._badgeService]);

  @override
  Future<bool> isDebugBuild() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String packageName = packageInfo.packageName;

      // Check if the package name contains '.debug' or ends with '.debug'
      // You might need to adjust this condition based on your actual naming convention
      return packageName.contains('.debug') || packageName.endsWith('.debug');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> resetStreakData() async {
    try {
      await _streakRepository.saveStreakCount(0);
      await _streakRepository.saveLastCompletedDate(DateTime(2000, 1, 1));
      await _streakRepository.saveCompletedDaysList([]);
      logger.info('All streak data has been reset');
    } catch (e) {
      logger.severe('Error resetting streak data: $e');
      rethrow;
    }
  }

  @override
  Future<void> simulateStreakForPastDays(int days) async {
    if (days <= 0) return;

    try {
      final now = DateTime.now();
      final completedDays = <DateTime>[];

      for (int i = 0; i < days; i++) {
        final date = DateTime(now.year, now.month, now.day - i);
        completedDays.add(date);
      }
      await _streakRepository.saveCompletedDaysList(completedDays);
      await _streakRepository.saveStreakCount(days);
      await _streakRepository.saveLastCompletedDate(now);

      logger.info('Simulated streak for $days past days');
    } catch (e) {
      logger.severe('Error simulating streak for past days: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetBadgeData() async {
    try {
      final allBadges = await _badgeRepository.getAllBadges();

      for (final badge in allBadges) {
        await _badgeRepository.saveBadge(badge.copyWith(
          isAchieved: false,
          achievedCount: 0,
          lastAchievedDate: null,
        ));
      }
      logger.info('All badge data has been reset');
    } catch (e) {
      logger.severe('Error resetting badge data: $e');
      rethrow;
    }
  }

  @override
  Future<void> simulateStreakForSpecificDate(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final days = await _streakRepository.getCompletedDays();
      if (!days.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day)) {
        days.add(normalizedDate);
      }
      await _streakRepository.saveCompletedDaysList(days);
      final lastDate = await _streakRepository.getLastCompletedDate();
      if (lastDate == null || normalizedDate.isAfter(lastDate)) {
        await _streakRepository.saveLastCompletedDate(normalizedDate);
      }
      await _updateStreakCount();

      logger.info('Simulated streak for specific date: $normalizedDate');
    } catch (e) {
      logger.severe('Error simulating streak for specific date: $e');
      rethrow;
    }
  }

  Future<void> _updateStreakCount() async {
    final days = await _streakRepository.getCompletedDays();
    if (days.isEmpty) {
      await _streakRepository.saveStreakCount(0);
      return;
    }

    days.sort((a, b) => b.compareTo(a));
    int streak = 1;
    DateTime lastDate = days[0];

    for (int i = 1; i < days.length; i++) {
      final diff = lastDate.difference(days[i]).inDays;
      if (diff == 1) {
        streak++;
        lastDate = days[i];
      } else {
        break;
      }
    }

    await _streakRepository.saveStreakCount(streak);
  }

  @override
  Future<void> validateAllBadges() async {
    try {
      if (_badgeService == null) {
        throw Exception('BadgeService is not available for validation');
      }

      await _badgeService!.checkAndUpdateBadges();
      logger.info('All badges have been revalidated');
    } catch (e) {
      logger.severe('Error validating badges: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleBadgeStatus(int badgeId, bool achieved) async {
    try {
      final badge = await _badgeRepository.getBadgeById(badgeId);

      await _badgeRepository.saveBadge(badge.copyWith(
        isAchieved: achieved,
        achievedCount:
            achieved ? (badge.achievedCount > 0 ? badge.achievedCount : 1) : 0,
        lastAchievedDate: achieved ? DateTime.now() : null,
      ));

      logger.info('Badge $badgeId status toggled to: $achieved');
    } catch (e) {
      logger.severe('Error toggling badge $badgeId status: $e');
      rethrow;
    }
  }
}
