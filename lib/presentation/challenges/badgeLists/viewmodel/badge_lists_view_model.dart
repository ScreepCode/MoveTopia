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
    loadBadges();
  }

  Future<void> loadBadges() async {
    try {
      state = const AsyncValue.loading();
      // Load all badges
      final badges = await _badgeService.getAllBadges();

      // Check and update badges, then reload
      await _badgeService.checkAndUpdateBadges();
      final updatedBadges = await _badgeService.getAllBadges();

      state = AsyncValue.data(updatedBadges.cast<AchievementBadge>());
      log.info('Loaded ${updatedBadges.length} badges');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      log.severe('Failed to load badges', error, stackTrace);
    }
  }

  Future<void> refreshBadges() async {
    await loadBadges();
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
