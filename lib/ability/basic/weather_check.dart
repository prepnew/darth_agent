import 'dart:convert';
import 'dart:io';

import 'package:darth_agent/ability/ability.dart';
import 'package:darth_agent/input/ability_parser.dart';
import 'package:http/http.dart' as http;

/// Accesses the weather API to check the weather at a given location
/// Use https://api.met.no/doc/ForecastJSON to add more to the resulting data
class WeatherCheck extends Ability {
  WeatherCheck({required this.userAgent});

  final String userAgent;
  @override
  String get functionsDescription => '''
Function:
def $functionName(coordinates: tuple):
"""
Fetches weather data from the Open-Meteo API for the given latitude and longitude.
If missing coordinates then this method is invalid or must be found with another method.

- coordinates (tuple): The latitude and longitude of the location to fetch weather for. Does not support array of coordinates.

Returns: float: The current temperature in the coordinates you've asked for
"""
''';

  @override
  String get functionName => 'get_weather_data';

  @override
  Future call(Map<String, dynamic> args, {bool llmOutput = true}) async {
    final coordinates = args['coordinates'];
    if (coordinates is AbilityCall) {
      final location = coordinates.arguments['location'];
      //stdout.writeln('Weather calling function: ${coordinates.ability.functionName} for coordinates with location: $location');
      final ability = coordinates.ability;
      final coordResult = await ability.call(coordinates.arguments, llmOutput: false) as List<double>?;
      if (coordResult != null) {
        final lat = coordResult[1];
        final lng = coordResult[0];
        stdout.writeln('Finding weather for $location at $lat, $lng');
        final weatherResponse = await http.get(
          Uri.parse('https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=$lat&lon=$lng'),
          headers: {'Accept': 'application/json', 'User-Agent': userAgent},
        );
        final json = jsonDecode(weatherResponse.body);
        if (weatherResponse.statusCode != 200) {
          if (llmOutput) {
            return 'Failed to fetch weather data for $coordinates with status code: ${weatherResponse.statusCode}';
          } else {
            return null;
          }
        } else {
          final output = WeatherResponse.fromJson(json);
          if (llmOutput) {
            return 'The temperature at $location is ${output.properties.timeSeries[0].data.instant.details.airTemperature} degrees ${output.properties.meta.units.airTemperature}';
          } else {
            return output.properties.timeSeries[0].data.instant.details.airTemperature;
          }
        }
      } else {
        if (llmOutput) {
          return 'Unable to fetch coordinates for location: ${coordinates.arguments}';
        } else {
          return null;
        }
      }
    } else {
      return 'Weather is terrible at: $coordinates';
    }
  }
}

class WeatherResponse {
  WeatherResponse({required this.properties});
  final Properties properties;

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      properties: Properties.fromJson(json['properties']),
    );
  }
}

class Properties {
  Properties({required this.meta, required this.timeSeries});
  final Meta meta;
  final List<TimeSeries> timeSeries;

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      meta: Meta.fromJson(json['meta']),
      timeSeries: (json['timeseries'] as List<dynamic>).map((e) => TimeSeries.fromJson(e)).toList(growable: false),
    );
  }
}

class Meta {
  Meta({required this.units});
  final Units units;
  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(units: Units.fromJson(json['units']));
  }
}

class Units {
  Units({required this.airTemperature});
  final String airTemperature;
  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(airTemperature: json['air_temperature']);
  }
}

class TimeSeries {
  TimeSeries({required this.data});
  final Data data;
  factory TimeSeries.fromJson(Map<String, dynamic> json) {
    return TimeSeries(data: Data.fromJson(json['data']));
  }
}

class Data {
  Data({required this.instant});
  final Instant instant;
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(instant: Instant.fromJson(json['instant']));
  }
}

class Instant {
  Instant({required this.details});
  final Details details;

  factory Instant.fromJson(Map<String, dynamic> json) {
    return Instant(details: Details.fromJson(json['details']));
  }
}

class Details {
  Details({required this.airTemperature});
  final double airTemperature;

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(airTemperature: json['air_temperature']);
  }
}

/* Example weather response
{
    "type": "Feature",
    "geometry": {
        "type": "Point",
        "coordinates": [
            59.9133,
            10.739,
            0
        ]
    },
    "properties": {
        "meta": {
            "updated_at": "2024-02-05T17:28:24Z",
            "units": {
                "air_pressure_at_sea_level": "hPa",
                "air_temperature": "celsius",
                "cloud_area_fraction": "%",
                "precipitation_amount": "mm",
                "relative_humidity": "%",
                "wind_from_direction": "degrees",
                "wind_speed": "m/s"
            }
        },
        "timeseries": [
            {
                "time": "2024-02-05T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.6,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 6.2,
                            "relative_humidity": 75.7,
                            "wind_from_direction": 51.3,
                            "wind_speed": 7.1
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-05T19:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.4,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 34.4,
                            "relative_humidity": 75.9,
                            "wind_from_direction": 52.1,
                            "wind_speed": 6.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-05T20:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.1,
                            "air_temperature": 26.8,
                            "cloud_area_fraction": 34.4,
                            "relative_humidity": 76.3,
                            "wind_from_direction": 52.8,
                            "wind_speed": 6.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-05T21:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.5,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 22.7,
                            "relative_humidity": 76.2,
                            "wind_from_direction": 56.2,
                            "wind_speed": 6.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-05T22:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.8,
                            "air_temperature": 26.6,
                            "cloud_area_fraction": 94.5,
                            "relative_humidity": 75.7,
                            "wind_from_direction": 56.3,
                            "wind_speed": 6.1
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-05T23:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.5,
                            "air_temperature": 26.6,
                            "cloud_area_fraction": 60.9,
                            "relative_humidity": 75.7,
                            "wind_from_direction": 56.5,
                            "wind_speed": 6.1
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.5,
                            "air_temperature": 26.5,
                            "cloud_area_fraction": 74.2,
                            "relative_humidity": 75.3,
                            "wind_from_direction": 58.5,
                            "wind_speed": 6.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T01:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.9,
                            "air_temperature": 26.5,
                            "cloud_area_fraction": 39.8,
                            "relative_humidity": 74.5,
                            "wind_from_direction": 59.7,
                            "wind_speed": 5.7
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T02:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.5,
                            "air_temperature": 26.5,
                            "cloud_area_fraction": 81.2,
                            "relative_humidity": 74.3,
                            "wind_from_direction": 60.5,
                            "wind_speed": 5.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T03:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.2,
                            "air_temperature": 26.6,
                            "cloud_area_fraction": 12.5,
                            "relative_humidity": 74.1,
                            "wind_from_direction": 63.2,
                            "wind_speed": 5.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T04:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.9,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 19.5,
                            "relative_humidity": 73.3,
                            "wind_from_direction": 66.1,
                            "wind_speed": 5.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T05:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.3,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 18.7,
                            "relative_humidity": 71.5,
                            "wind_from_direction": 66.8,
                            "wind_speed": 6.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.4,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 5.5,
                            "relative_humidity": 71.3,
                            "wind_from_direction": 63.3,
                            "wind_speed": 6.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T07:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.9,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 3.1,
                            "relative_humidity": 71.5,
                            "wind_from_direction": 60.7,
                            "wind_speed": 6.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T08:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.0,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 10.9,
                            "relative_humidity": 71.5,
                            "wind_from_direction": 57.3,
                            "wind_speed": 5.9
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T09:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.0,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 11.7,
                            "relative_humidity": 70.9,
                            "wind_from_direction": 56.7,
                            "wind_speed": 5.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T10:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.1,
                            "air_temperature": 27.1,
                            "cloud_area_fraction": 8.6,
                            "relative_humidity": 70.3,
                            "wind_from_direction": 57.1,
                            "wind_speed": 5.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T11:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.6,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 8.6,
                            "relative_humidity": 69.7,
                            "wind_from_direction": 57.4,
                            "wind_speed": 5.1
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.7,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 78.1,
                            "relative_humidity": 69.3,
                            "wind_from_direction": 57.7,
                            "wind_speed": 5.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T13:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.1,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 72.7,
                            "relative_humidity": 67.7,
                            "wind_from_direction": 59.4,
                            "wind_speed": 5.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T14:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.5,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 85.2,
                            "relative_humidity": 68.3,
                            "wind_from_direction": 62.2,
                            "wind_speed": 5.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T15:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.2,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 11.7,
                            "relative_humidity": 69.3,
                            "wind_from_direction": 61.9,
                            "wind_speed": 5.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T16:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.1,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 8.6,
                            "relative_humidity": 69.9,
                            "wind_from_direction": 58.9,
                            "wind_speed": 5.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T17:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.9,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 7.8,
                            "relative_humidity": 69.2,
                            "wind_from_direction": 57.5,
                            "wind_speed": 5.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.0,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 6.2,
                            "relative_humidity": 68.8,
                            "wind_from_direction": 59.0,
                            "wind_speed": 5.7
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T19:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.9,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 5.5,
                            "relative_humidity": 68.8,
                            "wind_from_direction": 59.5,
                            "wind_speed": 6.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T20:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.8,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 9.4,
                            "relative_humidity": 68.4,
                            "wind_from_direction": 60.7,
                            "wind_speed": 6.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T21:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.2,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 14.1,
                            "relative_humidity": 68.1,
                            "wind_from_direction": 59.7,
                            "wind_speed": 6.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T22:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.8,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 28.1,
                            "relative_humidity": 66.8,
                            "wind_from_direction": 53.2,
                            "wind_speed": 7.1
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.3
                        }
                    }
                }
            },
            {
                "time": "2024-02-06T23:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.6,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 29.7,
                            "relative_humidity": 67.4,
                            "wind_from_direction": 48.8,
                            "wind_speed": 7.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.4
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.8,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 37.5,
                            "relative_humidity": 68.3,
                            "wind_from_direction": 47.1,
                            "wind_speed": 7.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.4
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T01:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.2,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 20.3,
                            "relative_humidity": 66.6,
                            "wind_from_direction": 45.6,
                            "wind_speed": 7.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.4
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T02:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.8,
                            "air_temperature": 26.6,
                            "cloud_area_fraction": 61.7,
                            "relative_humidity": 76.6,
                            "wind_from_direction": 44.3,
                            "wind_speed": 8.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "lightrainshowers_day"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.4
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T03:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.5,
                            "air_temperature": 25.8,
                            "cloud_area_fraction": 26.6,
                            "relative_humidity": 84.8,
                            "wind_from_direction": 52.6,
                            "wind_speed": 8.5
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "lightrainshowers_day"
                        },
                        "details": {
                            "precipitation_amount": 0.1
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T04:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.1,
                            "air_temperature": 26.4,
                            "cloud_area_fraction": 28.1,
                            "relative_humidity": 80.6,
                            "wind_from_direction": 53.6,
                            "wind_speed": 8.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "lightrainshowers_day"
                        },
                        "details": {
                            "precipitation_amount": 0.1
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T05:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.5,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 22.7,
                            "relative_humidity": 78.5,
                            "wind_from_direction": 50.5,
                            "wind_speed": 8.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.6,
                            "air_temperature": 26.8,
                            "cloud_area_fraction": 11.7,
                            "relative_humidity": 77.0,
                            "wind_from_direction": 50.9,
                            "wind_speed": 8.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T07:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.9,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 28.9,
                            "relative_humidity": 76.2,
                            "wind_from_direction": 55.5,
                            "wind_speed": 7.9
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T08:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.7,
                            "air_temperature": 26.8,
                            "cloud_area_fraction": 50.0,
                            "relative_humidity": 77.2,
                            "wind_from_direction": 56.1,
                            "wind_speed": 7.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T09:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.3,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 27.3,
                            "relative_humidity": 76.5,
                            "wind_from_direction": 57.4,
                            "wind_speed": 7.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T10:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.4,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 32.0,
                            "relative_humidity": 75.9,
                            "wind_from_direction": 58.6,
                            "wind_speed": 7.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T11:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.9,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 38.3,
                            "relative_humidity": 75.8,
                            "wind_from_direction": 57.8,
                            "wind_speed": 7.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.1,
                            "air_temperature": 27.1,
                            "cloud_area_fraction": 60.2,
                            "relative_humidity": 75.7,
                            "wind_from_direction": 59.1,
                            "wind_speed": 7.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T13:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.7,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 60.9,
                            "relative_humidity": 74.7,
                            "wind_from_direction": 57.7,
                            "wind_speed": 7.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T14:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.1,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 40.6,
                            "relative_humidity": 74.6,
                            "wind_from_direction": 54.7,
                            "wind_speed": 8.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T15:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.9,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 7.8,
                            "relative_humidity": 73.9,
                            "wind_from_direction": 54.7,
                            "wind_speed": 8.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T16:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.7,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 29.7,
                            "relative_humidity": 75.0,
                            "wind_from_direction": 55.1,
                            "wind_speed": 8.9
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T17:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.2,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 36.7,
                            "relative_humidity": 75.2,
                            "wind_from_direction": 56.0,
                            "wind_speed": 8.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.2,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 55.5,
                            "relative_humidity": 75.7,
                            "wind_from_direction": 54.4,
                            "wind_speed": 8.9
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T19:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.0,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 82.8,
                            "relative_humidity": 77.9,
                            "wind_from_direction": 54.5,
                            "wind_speed": 8.7
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "lightrainshowers_night"
                        },
                        "details": {
                            "precipitation_amount": 0.1
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.1
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T20:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.7,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 91.4,
                            "relative_humidity": 77.3,
                            "wind_from_direction": 56.2,
                            "wind_speed": 8.6
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T21:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.0,
                            "air_temperature": 26.8,
                            "cloud_area_fraction": 90.6,
                            "relative_humidity": 76.6,
                            "wind_from_direction": 56.4,
                            "wind_speed": 8.7
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.1
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T22:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.3,
                            "air_temperature": 26.8,
                            "cloud_area_fraction": 82.8,
                            "relative_humidity": 76.9,
                            "wind_from_direction": 54.2,
                            "wind_speed": 8.5
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-07T23:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.9,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 87.5,
                            "relative_humidity": 76.6,
                            "wind_from_direction": 53.5,
                            "wind_speed": 8.3
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.8,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 15.6,
                            "relative_humidity": 76.8,
                            "wind_from_direction": 49.1,
                            "wind_speed": 8.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.2
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T01:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.4,
                            "air_temperature": 26.5,
                            "cloud_area_fraction": 36.7,
                            "relative_humidity": 78.0,
                            "wind_from_direction": 46.8,
                            "wind_speed": 8.6
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "lightrainshowers_night"
                        },
                        "details": {
                            "precipitation_amount": 0.1
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T02:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.3,
                            "air_temperature": 26.5,
                            "cloud_area_fraction": 29.7,
                            "relative_humidity": 78.7,
                            "wind_from_direction": 45.8,
                            "wind_speed": 8.4
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T03:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.3,
                            "air_temperature": 26.6,
                            "cloud_area_fraction": 93.7,
                            "relative_humidity": 76.9,
                            "wind_from_direction": 45.4,
                            "wind_speed": 8.6
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T04:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.0,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 89.1,
                            "relative_humidity": 76.8,
                            "wind_from_direction": 45.7,
                            "wind_speed": 8.6
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T05:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.6,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 75.8,
                            "relative_humidity": 76.3,
                            "wind_from_direction": 46.3,
                            "wind_speed": 8.3
                        }
                    },
                    "next_1_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.5,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 88.3,
                            "relative_humidity": 76.2,
                            "wind_from_direction": 45.0,
                            "wind_speed": 8.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.0,
                            "air_temperature": 26.6,
                            "cloud_area_fraction": 21.9,
                            "relative_humidity": 76.9,
                            "wind_from_direction": 40.7,
                            "wind_speed": 8.7
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-08T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.6,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 62.5,
                            "relative_humidity": 71.2,
                            "wind_from_direction": 46.9,
                            "wind_speed": 9.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-09T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.7,
                            "air_temperature": 26.3,
                            "cloud_area_fraction": 40.6,
                            "relative_humidity": 73.0,
                            "wind_from_direction": 48.8,
                            "wind_speed": 9.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-09T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.3,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 53.1,
                            "relative_humidity": 68.4,
                            "wind_from_direction": 53.0,
                            "wind_speed": 8.3
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-09T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.2,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 91.4,
                            "relative_humidity": 68.9,
                            "wind_from_direction": 41.1,
                            "wind_speed": 8.5
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-09T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.2,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 36.7,
                            "relative_humidity": 73.3,
                            "wind_from_direction": 39.4,
                            "wind_speed": 9.5
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-10T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.9,
                            "air_temperature": 26.3,
                            "cloud_area_fraction": 57.0,
                            "relative_humidity": 74.6,
                            "wind_from_direction": 53.4,
                            "wind_speed": 8.5
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-10T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.6,
                            "air_temperature": 26.7,
                            "cloud_area_fraction": 92.2,
                            "relative_humidity": 70.4,
                            "wind_from_direction": 55.1,
                            "wind_speed": 8.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-10T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.8,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 12.5,
                            "relative_humidity": 69.7,
                            "wind_from_direction": 45.1,
                            "wind_speed": 8.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-10T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.0,
                            "air_temperature": 27.1,
                            "cloud_area_fraction": 64.8,
                            "relative_humidity": 67.8,
                            "wind_from_direction": 56.1,
                            "wind_speed": 8.9
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-11T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.2,
                            "air_temperature": 26.8,
                            "cloud_area_fraction": 22.7,
                            "relative_humidity": 68.5,
                            "wind_from_direction": 72.0,
                            "wind_speed": 8.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-11T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.2,
                            "air_temperature": 27.3,
                            "cloud_area_fraction": 65.6,
                            "relative_humidity": 67.5,
                            "wind_from_direction": 68.3,
                            "wind_speed": 6.9
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-11T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.2,
                            "air_temperature": 27.7,
                            "cloud_area_fraction": 17.2,
                            "relative_humidity": 66.2,
                            "wind_from_direction": 61.2,
                            "wind_speed": 7.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-11T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.4,
                            "air_temperature": 27.6,
                            "cloud_area_fraction": 82.8,
                            "relative_humidity": 66.6,
                            "wind_from_direction": 66.0,
                            "wind_speed": 7.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-12T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.0,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 44.5,
                            "relative_humidity": 67.2,
                            "wind_from_direction": 63.7,
                            "wind_speed": 7.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-12T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1018.1,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 13.3,
                            "relative_humidity": 68.1,
                            "wind_from_direction": 57.0,
                            "wind_speed": 7.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-12T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.8,
                            "air_temperature": 27.7,
                            "cloud_area_fraction": 44.5,
                            "relative_humidity": 65.2,
                            "wind_from_direction": 52.5,
                            "wind_speed": 7.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-12T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.8,
                            "air_temperature": 27.0,
                            "cloud_area_fraction": 90.6,
                            "relative_humidity": 70.3,
                            "wind_from_direction": 58.7,
                            "wind_speed": 7.4
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "cloudy"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-13T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.5,
                            "air_temperature": 26.2,
                            "cloud_area_fraction": 35.9,
                            "relative_humidity": 75.2,
                            "wind_from_direction": 51.9,
                            "wind_speed": 7.0
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-13T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1017.3,
                            "air_temperature": 26.4,
                            "cloud_area_fraction": 56.2,
                            "relative_humidity": 74.1,
                            "wind_from_direction": 54.6,
                            "wind_speed": 7.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-13T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1012.4,
                            "air_temperature": 26.3,
                            "cloud_area_fraction": 5.5,
                            "relative_humidity": 76.7,
                            "wind_from_direction": 42.4,
                            "wind_speed": 7.1
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "clearsky_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-13T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1015.5,
                            "air_temperature": 26.4,
                            "cloud_area_fraction": 14.1,
                            "relative_humidity": 77.4,
                            "wind_from_direction": 60.3,
                            "wind_speed": 8.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-14T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.7,
                            "air_temperature": 26.5,
                            "cloud_area_fraction": 49.2,
                            "relative_humidity": 74.2,
                            "wind_from_direction": 61.5,
                            "wind_speed": 7.2
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "partlycloudy_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-14T06:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1016.4,
                            "air_temperature": 26.9,
                            "cloud_area_fraction": 14.8,
                            "relative_humidity": 71.2,
                            "wind_from_direction": 69.6,
                            "wind_speed": 7.6
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_day"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-14T12:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1011.9,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 13.3,
                            "relative_humidity": 68.6,
                            "wind_from_direction": 59.7,
                            "wind_speed": 7.8
                        }
                    },
                    "next_12_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {}
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-14T18:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1014.8,
                            "air_temperature": 27.4,
                            "cloud_area_fraction": 18.7,
                            "relative_humidity": 68.2,
                            "wind_from_direction": 64.4,
                            "wind_speed": 8.6
                        }
                    },
                    "next_6_hours": {
                        "summary": {
                            "symbol_code": "fair_night"
                        },
                        "details": {
                            "precipitation_amount": 0.0
                        }
                    }
                }
            },
            {
                "time": "2024-02-15T00:00:00Z",
                "data": {
                    "instant": {
                        "details": {
                            "air_pressure_at_sea_level": 1013.0,
                            "air_temperature": 27.2,
                            "cloud_area_fraction": 18.0,
                            "relative_humidity": 69.6,
                            "wind_from_direction": 63.0,
                            "wind_speed": 8.5
                        }
                    }
                }
            }
        ]
    }
}
*/