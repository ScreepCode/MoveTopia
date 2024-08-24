abstract class ProfileRepository {
  Future<void> saveSetting(String key, dynamic value);
  Future<dynamic> loadSetting(String key);
}