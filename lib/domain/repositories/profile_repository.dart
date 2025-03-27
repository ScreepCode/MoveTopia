const stepGoalKey = 'stepGoal';
const isDarkModeKey = 'isDarkMode';
const userEPKey = 'userEP';
const userLevelKey = 'userLevel';
const installationDateKey = 'installationDate';
const lastUpdatedKey = 'lastUpdated';

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

  Future<DateTime> getInstallationDate();

  Future<void> saveInstallationDate(DateTime date);

  Future<DateTime> getLastUpdated();

  Future<void> saveLastUpdated(DateTime date);
}
