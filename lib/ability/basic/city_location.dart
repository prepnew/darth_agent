import 'package:darth_agent/ability/ability.dart';

/// Finds a city's coordinates using the Maps.co Geocoding API using its name
class CityLocation extends Ability {
  @override
  Future<String> functionCall(List<Map<String, dynamic>> args) async {
    return 'City: $args';
  }

  @override
  String get functionName => 'get_coordinates_for_city';

  @override
  String get functionsDescription => '''
Function:
def $functionName(city_name: str):
"""
Fetches the coordinates (latitude and longitude) of a given city name using the Maps.co Geocoding API.

- city_name (str): The name of the city.

Returns: tuple: The latitude and longitude of the city.
"""
''';
}
