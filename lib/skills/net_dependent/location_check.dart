import 'dart:convert';
import 'dart:io';
import 'package:darth_agent/memory/util/datastore.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:http/http.dart' as http;
import 'package:darth_agent/skills/skill.dart';

/// Finds a city's coordinates using the MapBox Geocoding API using its name
/// When returning the result, it will either return a readable string for llm
/// or a List of lat/long for the agent to use
/// Note that coordinates are returned as [longitude, latitude]
class LocationCheck extends Skill {
  LocationCheck({required this.locationApiKey, this.dataStore});

  @override
  String get name => 'get_coordinates_for_city';

  @override
  String get description => '''
Function:
def $name(location: str):
"""
Fetches the coordinates (latitude and longitude) of a given address or city name using the MapBox Geocoding API.

- location (str): The name of the location.

Returns: tuple: The latitude and longitude of the location.
"""
''';

  final String locationApiKey;
  final DataStore? dataStore;
  @override
  Future<dynamic> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async {
    //return [59.9133301, 10.7389701];
    final location = args['location'];
    final cachedResult = await dataStore?.read(location);
    if (cachedResult != null) {
      final output = _GeoCodingResponse.fromJson(cachedResult);
      if (llmOutput) {
        return 'The location of $location is at ${output.location[0]}, ${output.location[1]}';
      } else {
        return output.location;
      }
    }
    final String url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$location.json?access_token=$locationApiKey';
    final result = await http.get(Uri.parse(url));
    final json = jsonDecode(result.body);
    if (result.statusCode != 200) {
      if (llmOutput) {
        return 'Failed to fetch location data for $location with status code: ${result.statusCode}';
      } else {
        return null;
      }
    }
    if (json['error_message'] != null) {
      final error = _ErrorResponse.fromJson(json);
      final badResponse = 'Failed to fetch location data for $location with message: ${error.message}.';
      stdout.writeln(badResponse);
      if (llmOutput) {
        return badResponse;
      } else {
        return null;
      }
    } else {
      final output = _GeoCodingResponse.fromJson(json);
      dataStore?.insert(location, output);
      if (llmOutput) {
        return 'The location of $location is at ${output.location[0]}, ${output.location[1]}';
      } else {
        return output.location;
      }
    }
  }
}

class _GeoCodingResponse {
  _GeoCodingResponse({required this.features});
  final List<_Feature> features;

  List<double> get location => features.first.geometry.coordinates;

  factory _GeoCodingResponse.fromJson(Map<String, dynamic> json) => _GeoCodingResponse(
        features: (json['features'] as List).map((e) => _Feature.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'features': features.map((e) => e.toJson()).toList(),
      };
}

class _Feature {
  _Feature({required this.geometry});
  final _Geometry geometry;

  factory _Feature.fromJson(Map<String, dynamic> json) => _Feature(
        geometry: _Geometry.fromJson(json['geometry']),
      );

  Map<String, dynamic> toJson() => {
        'geometry': geometry.toJson(),
      };
}

class _Geometry {
  _Geometry({required this.coordinates});
  final List<double> coordinates;
  factory _Geometry.fromJson(Map<String, dynamic> json) => _Geometry(
        coordinates: (json['coordinates'] as List).map((e) => e as double).toList(),
      );

  Map<String, dynamic> toJson() => {
        'coordinates': coordinates,
      };
}

class _ErrorResponse {
  _ErrorResponse({required this.message});
  final String message;

  factory _ErrorResponse.fromJson(Map<String, dynamic> json) => _ErrorResponse(
        message: json['message'] as String,
      );
}
