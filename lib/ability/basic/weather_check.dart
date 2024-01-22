import 'package:darth_agent/ability/ability.dart';

/// Accesses the weather API to check the weather at a given location
class WeatherCheck extends Ability {
  WeatherCheck();

  @override
  Future<String> functionCall(List<Map<String, dynamic>> args) async {
    return 'Weather is terrible: $args';
  }

  @override
  String get functionsDescription => '''
Function:
def $functionName(coordinates: tuple):
"""
Fetches weather data from the Open-Meteo API for the given latitude and longitude.
If coordinates are not available method is invalid. Do not assume coordinates.

- coordinates (tuple): The latitude and longitude of the location to fetch weather for. Does not support array of coordinates.

Returns: float: The current temperature in the coordinates you've asked for
"""
''';

  @override
  String get functionName => 'get_weather_data';
}
