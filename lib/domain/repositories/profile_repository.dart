const stepGoalKey = 'stepGoal';
const isDarkModeKey = 'isDarkMode';
const userEPKey = 'userEP';
const userLevelKey = 'userLevel';

abstract class ProfileRepository {
  Future<void> saveSetting(String key, dynamic value);

  Future<dynamic> loadSetting(String key);

  // More specific methods
  Future<int> getStepGoal();

  Future<void> saveStepGoal(int stepGoal);

  Future<bool> getIsDarkMode();

  Future<void> saveIsDarkMode(bool isDarkMode);

  Future<int> getUserEP();

  Future<void> saveUserEP(int ep);

  Future<int> getUserLevel();

  Future<void> saveUserLevel(int level);
}
