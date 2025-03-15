const stepGoalKey = 'stepGoal';
const countKey = 'count';
const isDarkModeKey = 'isDarkMode';

abstract class ProfileRepository {
  Future<void> saveSetting(String key, dynamic value);

  Future<dynamic> loadSetting(String key);

  // More specific methods
  Future<int> getStepGoal();

  Future<void> saveStepGoal(int stepGoal);

  Future<int> getCount();

  Future<void> saveCount(int count);

  Future<bool> getIsDarkMode();

  Future<void> saveIsDarkMode(bool isDarkMode);
}
