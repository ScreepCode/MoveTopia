import 'package:movetopia/data/model/badge.dart';

abstract class BadgeRepository {
  Future<void> saveBadge(AchivementBadge badge);

  Future<List<AchivementBadge>> getBadgesByCategory(
      AchivementBadgeCategory category);

  Future<List<AchivementBadge>> getAllBadges();

  Future<AchivementBadge> getBadgeById(int id);

  Future<void> initializeAppDates();

  Future<DateTime> getFirstOpenDate();

  Future<DateTime> getLastCheckDate();

  Future<void> updateLastCheckDate(DateTime date);
}
