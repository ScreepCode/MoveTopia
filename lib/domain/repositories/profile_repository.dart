const stepGoalKey = 'stepGoal';
const themeModeKey = 'themeMode';
const userEPKey = 'userEP';
const userLevelKey = 'userLevel';
const installationDateKey = 'installationDate';
const lastUpdatedKey = 'lastUpdated';

enum AppThemeMode {
  system,
  light,
  dark,
}

abstract class ProfileRepository {
  Future<void> saveSetting(String key, dynamic value);

  Future<dynamic> loadSetting(String key);

  // More specific methods
  Future<int> getStepGoal();

  Future<void> saveStepGoal(int stepGoal);

  Future<AppThemeMode> getThemeMode();

  Future<void> saveThemeMode(AppThemeMode themeMode);

  Future<int> getUserEP();

  Future<void> saveUserEP(int ep);

  Future<int> getUserLevel();

  Future<void> saveUserLevel(int level);

  Future<DateTime> getInstallationDate();

  Future<void> saveInstallationDate(DateTime date);

  Future<DateTime> getLastUpdated();

  Future<void> saveLastUpdated(DateTime date);
}
