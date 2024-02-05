import 'dart:io';

class Env {
  /// Google Maps API key
  static String get locationApiKey => Platform.environment['LOCATION_API_KEY'] ?? '';

  /// Weather Meteo user agent identifier
  static String get weatherUserAgent => Platform.environment['WEATHER_USER_AGENT'] ?? '';
}
