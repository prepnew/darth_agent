import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:darth_agent/ability/ability.dart';

/// Finds a city's coordinates using the MapBox Geocoding API using its name
/// When returning the result, it will either return a readable string for llm
/// or a List of lat/long for the agent to use
/// Note that coordinates are returned as [longitude, latitude]
class LocationCheck extends Ability {
  LocationCheck({required this.locationApiKey});
  final String locationApiKey;
  @override
  Future<dynamic> call(Map<String, dynamic> args, {bool llmOutput = true}) async {
    //return [59.9133301, 10.7389701];
    final location = args['location'];
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
      final error = ErrorResponse.fromJson(json);
      final badResponse = 'Failed to fetch location data for $location with message: ${error.message}.';
      stdout.writeln(badResponse);
      if (llmOutput) {
        return badResponse;
      } else {
        return null;
      }
    } else {
      final output = GeoCodingResponse.fromJson(json);
      if (llmOutput) {
        return 'The location of $location is at ${output.location[0]}, ${output.location[1]}';
      } else {
        return output.location;
      }
    }
  }

  @override
  String get functionName => 'get_coordinates_for_city';

  @override
  String get functionsDescription => '''
Function:
def $functionName(location: str):
"""
Fetches the coordinates (latitude and longitude) of a given address or city name using the MapBox Geocoding API.

- location (str): The name of the location.

Returns: tuple: The latitude and longitude of the location.
"""
''';
}

class GeoCodingResponse {
  GeoCodingResponse({required this.features});
  final List<Feature> features;

  List<double> get location => features.first.geometry.coordinates;

  factory GeoCodingResponse.fromJson(Map<String, dynamic> json) => GeoCodingResponse(
        features: (json['features'] as List).map((e) => Feature.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

class Feature {
  Feature({required this.geometry});
  final Geometry geometry;

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        geometry: Geometry.fromJson(json['geometry']),
      );
}

class Geometry {
  Geometry({required this.coordinates});
  final List<double> coordinates;
  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        coordinates: (json['coordinates'] as List).map((e) => e as double).toList(),
      );
}

class ErrorResponse {
  ErrorResponse({required this.message});
  final String message;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        message: json['message'] as String,
      );
}
