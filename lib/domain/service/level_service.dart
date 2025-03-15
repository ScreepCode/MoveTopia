import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/repositories/profile_repository.dart';

import '../../presentation/profile/view_model/profile_view_model.dart';

const userEpKey = 'userEP';
const userLevelKey = 'userLevel';

class LevelService {
  final ProfileRepository profileRepository;

  LevelService(this.profileRepository);

  // Formula: X = (L-1)*150 + ((L-1)^2*50) as specified in research document
  int calculateRequiredEpForLevel(int level) {
    return (level - 1) * 150 + ((level - 1) * (level - 1) * 50);
  }

  // Calculate level based on EP
  int calculateLevelFromEp(int ep, int level) {
    while (calculateRequiredEpForLevel(level + 1) <= ep) {
      level++;
    }
    return level;
  }

  // Get current EP
  Future<int> getCurrentEp() async {
    return await profileRepository.getUserEP();
  }

  // Get current level
  Future<int> getCurrentLevel() async {
    return await profileRepository.getUserLevel();
  }

  // Add EP and update level if needed
  Future<bool> addEp(int amount) async {
    int currentEp = await getCurrentEp();
    int newEp = currentEp + amount;

    int currentLevel = await getCurrentLevel();
    int newLevel = calculateLevelFromEp(newEp, currentLevel);

    // Save the new EP
    await profileRepository.saveUserEP(newEp);

    // Update level if necessary and return if level up occurred
    if (newLevel > currentLevel) {
      await profileRepository.saveUserLevel(newLevel);
      return true; // Level up occurred
    }

    return false; // No level up
  }

  // Get EP required for next level
  Future<int> getEpForNextLevel() async {
    int currentLevel = await getCurrentLevel();
    return calculateRequiredEpForLevel(currentLevel + 1);
  }

  // Calculate progress to next level (0.0 to 1.0)
  Future<double> getProgressToNextLevel() async {
    int currentEp = await getCurrentEp();
    int currentLevel = await getCurrentLevel();

    int currentLevelEp = calculateRequiredEpForLevel(currentLevel);
    int nextLevelEp = calculateRequiredEpForLevel(currentLevel + 1);

    // Handle division by zero
    if (nextLevelEp - currentLevelEp == 0) return 1.0;

    return (currentEp - currentLevelEp) / (nextLevelEp - currentLevelEp);
  }

  // EP remaining to next level
  Future<int> getEpRemainingForNextLevel() async {
    int currentEp = await getCurrentEp();
    int currentLevel = await getCurrentLevel();
    return calculateRequiredEpForLevel(currentLevel + 1) - currentEp;
  }

  // Reset level and EP (for testing)
  Future<void> resetLevelAndEp() async {
    await profileRepository.saveUserEP(0);
    await profileRepository.saveUserLevel(1);
  }

  Future<bool> addEpForBadge(AchievementBadge badge, bool isRepeat) async {
    int xpAmount = getEpForBadge(badge);
    return await addEp(xpAmount);
  }

  // Get EP for a badge - moved from BadgeService
  int getEpForBadge(AchievementBadge badge) {
    // Check if badge has XP value in its JSON
    if (badge.epValue != null) {
      return badge.epValue!;
    }

    // Fallback calculation if XP isn't specified in JSON
    int baseXp = 50;

    // Modifier based on tier
    int tierMultiplier = badge.tier;

    return baseXp * tierMultiplier;
  }
}

final levelServiceProvider = Provider<LevelService>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return LevelService(profileRepository);
});
