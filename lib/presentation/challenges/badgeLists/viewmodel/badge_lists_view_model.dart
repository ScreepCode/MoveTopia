import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/service/badge_service.dart';

class BadgeListViewModel
    extends StateNotifier<AsyncValue<List<AchievementBadge>>> {
  final BadgeService _badgeService;
  final log = Logger('BadgeListViewModel');

  BadgeListViewModel({required BadgeService badgeService})
      : _badgeService = badgeService,
        super(const AsyncValue.loading()) {
    refreshBadges();
  }

  Future<void> refreshBadges() async {
    log.info('Refreshing badge list');
    state = const AsyncValue.loading();

    try {
      // Check and update badges
      await _badgeService.checkAndUpdateBadges();

      // Reload badges after update
      final updatedBadges = await _badgeService.getAllBadges();

      if (updatedBadges.isEmpty) {
        log.warning('No badges were loaded from repository');

        // Versuch, die Badge-Validation zu triggern
        try {
          log.info('Attempting to validate badges by checking again');
          await _badgeService.checkAndUpdateBadges();

          // Versuche erneut, die Badges zu laden
          final retryBadges = await _badgeService.getAllBadges();
          log.info(
              'After validation attempt, loaded ${retryBadges.length} badges');

          if (retryBadges.isEmpty) {
            log.severe(
                'Still no badges after validation, possible asset loading issue');
            state = AsyncValue.error(
                'Keine Badges gefunden. Möglicherweise ein Problem mit der Anwendung.',
                StackTrace.current);
            return;
          } else {
            log.info(
                'Successfully loaded ${retryBadges.length} badges after retry');
            state = AsyncValue.data(retryBadges);
          }
        } catch (validationError, validationStackTrace) {
          log.severe('Error during badge validation', validationError,
              validationStackTrace);
          state = AsyncValue.error(validationError, validationStackTrace);
        }
      } else {
        // Log Kategorie-Statistiken
        _logBadgeCategories(updatedBadges);

        // Normaler Fall: Badges wurden geladen
        log.info('Successfully loaded ${updatedBadges.length} badges');
        state = AsyncValue.data(updatedBadges);
      }
    } catch (e, stackTrace) {
      log.severe('Error refreshing badges', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void _logBadgeCategories(List<AchievementBadge> badges) {
    try {
      // Gruppiere nach Kategorien
      log.info('Processing ${badges.length} badges by category');

      final totalSteps = badges
          .where(
              (badge) => badge.category == AchievementBadgeCategory.totalSteps)
          .toList();
      log.info('Found ${totalSteps.length} total step badges');

      final totalCyclingDistance = badges
          .where((badge) =>
              badge.category == AchievementBadgeCategory.totalCyclingDistance)
          .toList();
      log.info(
          'Found ${totalCyclingDistance.length} total cycling distance badges');

      final dailySteps = badges
          .where(
              (badge) => badge.category == AchievementBadgeCategory.dailySteps)
          .toList();
      log.info('Found ${dailySteps.length} daily step badges');

      // Gesamtzahl der erreichten Badges
      final achievedBadges = badges.where((badge) => badge.isAchieved).toList();
      log.info('Found ${achievedBadges.length} achieved badges');
    } catch (e, stackTrace) {
      log.severe('Error analyzing badge categories', e, stackTrace);
    }
  }

  List<AchievementBadge> getBadgesByCategory(
      AchievementBadgeCategory category) {
    return state.valueOrNull
            ?.where((badge) => badge.category == category)
            .toList() ??
        [];
  }

  List<AchievementBadge> getAchievedBadges() {
    return state.valueOrNull?.where((badge) => badge.isAchieved).toList() ?? [];
  }
}

final badgeListsViewModelProvider = StateNotifierProvider<BadgeListViewModel,
    AsyncValue<List<AchievementBadge>>>((ref) {
  final badgeService = ref.watch(badgeServiceProvider);
  return BadgeListViewModel(badgeService: badgeService);
});
