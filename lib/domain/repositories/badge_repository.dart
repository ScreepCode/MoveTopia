import 'package:movetopia/data/model/badge.dart';

abstract class BadgeRepository {
  Future<void> saveBadge(AchievementBadge badge);

  Future<List<AchievementBadge>> getBadgesByCategory(
      AchievementBadgeCategory category);

  Future<List<AchievementBadge>> getAllBadges();

  Future<AchievementBadge> getBadgeById(int id);

  Future<void> initializeAppDates();

  Future<DateTime> getFirstOpenDate();

  Future<DateTime> getLastCheckDate();

  Future<void> updateLastCheckDate(DateTime date);
}
