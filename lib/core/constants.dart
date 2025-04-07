/// Zentrale Konstanten für die App
class AppConstants {
  /// GitHub Repository URL
  static const String githubRepoUrl = 'https://movetopia.de/github';

  /// GitHub Issues URL
  static const String githubIssuesUrl = 'https://movetopia.de/known-issues';

  /// GitHub Discussions URL
  static const String githubDiscussionsUrl = 'https://movetopia.de/discussions';

  /// GitHub Profile URL
  static const String githubProfileUrl = 'https://movetopia.de/profile';

  /// Main website URL
  static const String mainWebsiteUrl = 'https://movetopia.de';

  /// Developer website URLs
  static const String niklasWebsiteUrl = 'https://niklas-buse.de';

  static const String joshuaWebsiteUrl = 'https://joshua.slaar.de';
}

/// Extension for URL-Formatierung
extension URLFormatting on String {
  /// Remove prefix 'https://' from url
  String removeURLPrefix() {
    return replaceAll('https://', '');
  }
}
