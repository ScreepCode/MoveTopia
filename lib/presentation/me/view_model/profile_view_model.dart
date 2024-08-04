import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final logger =
    Logger('ProfileViewModel'); // Erstelle einen Logger für diese Klasse

final profileProvider =
    StateNotifierProvider<ProfileViewModel, Map<String, dynamic>>((ref) {
  return ProfileViewModel();
});

class ProfileViewModel extends StateNotifier<Map<String, dynamic>> {
  ProfileViewModel()
      : super({
          'stepGoal': 0, // Default step goal
          'count': 0, // Default counter value
          'isDarkMode': false, // Default to light mode
        }) {
    loadSettings();
  }

  final _prefs = SharedPreferences.getInstance();

  Future<void> loadSettings() async {
    try {
      final prefs = await _prefs;
      state = prefs.getString('Profile')?.isNotEmpty == true
          ? Map<String, dynamic>.from(jsonDecode(prefs.getString('Profile')!))
          : {};
      logger.info('Profile settings loaded');
    } catch (e, s) {
      logger.severe('Error loading profile settings', e, s);
    }
  }

  Future<void> saveSettings(Map<String, dynamic> newSettings) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(newSettings);
    await prefs.setString('Profile', jsonString);
    state = newSettings;
    await loadSettings();
  }

  int get stepGoal => state['stepGoal'];
  int get count => state['count'];
  bool get isDarkMode => state['isDarkMode'];

  void setStepGoal(int stepGoal) {
    state['stepGoal'] = stepGoal;
    saveSettings(state);
  }

  void incrementCount() {
    logger.info('count: ${state['count']}');
    state['count'] = (state['count'] ?? 0) + 1;
    logger.info('Incremented count: ${state['count']}');
    saveSettings(state);
    logger.info('Get count: ${count}');
  }

  void setIsDarkMode(bool isDarkMode) {
    state['isDarkMode'] = isDarkMode;
    saveSettings(state);
  }
}
