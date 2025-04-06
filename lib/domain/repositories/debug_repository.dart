abstract class DebugRepository {
  Future<bool> isDebugBuild();

  Future<void> simulateStreakForPastDays(int days);

  Future<void> resetStreakData();

  Future<void> simulateStreakForSpecificDate(DateTime date);

  Future<void> resetBadgeData();

  Future<void> validateAllBadges();

  Future<void> toggleBadgeStatus(int badgeId, bool achieved);
}
