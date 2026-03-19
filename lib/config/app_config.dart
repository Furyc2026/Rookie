class AppConfig {
  static const String appName = 'Energy Sales Rookie';

  static String get baseUrl {
    const isWeb = bool.fromEnvironment('dart.library.js_util');

    if (isWeb) {
      return '';
    }

    return 'http://localhost:8080';
  }
}