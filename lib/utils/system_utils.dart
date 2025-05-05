import 'dart:typed_data';

Future<Uint8List?> getInstalledAppIcon(String sourceId) async {
  if (sourceId.isNotEmpty) {
    // Sadly due to the QUERY_ALL_PACKAGES permission not being allowed for release in the Play Store in this use case, this
    // method is not usable in production. Therefore we have to disable it for now.
    // TODO: Find a way to get the app icon without using QUERY_ALL_PACKAGES
    // var appIcon =
    //     (await InstalledApps.getAppInfo(sourceId.toString(), null))?.icon;
    // if (appIcon != null && appIcon.isNotEmpty) {
    //   return appIcon;
    // }
  }
  return null;
}

DateTime toUtc(DateTime date) {
  return date.toUtc();
}

DateTime toLocal(DateTime date) {
  // Convert UTC to local time
  return date.toLocal();
}
