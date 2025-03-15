abstract class DeviceInfoRepository {
  Future<void> initializeAppDates();

  Future<DateTime> getInstallationDate();

  Future<DateTime> getLastOpenedDate();

  Future<void> updateLastOpenedDate(DateTime date);
}
