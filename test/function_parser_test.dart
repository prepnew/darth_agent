import 'package:darth_agent/input/function_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Checks basic function call', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('get_weather_data(coordinates=(59.741, 10.411))');
    expect(result[0]['function'], 'get_weather_data');
    expect(result[0]['arguments'], [
      {
        'coordinates': [59.741, 10.411]
      }
    ]);
  });

  test('Handle functions without argument', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('get_weather_data()');
    expect(result[0]['function'], 'get_weather_data');
    expect(result[0]['arguments'], []);
  });

  test('Check for multiline function call', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('''
get_weather_data(coordinates=(59.741, 10.411))
get_city_coordinates(city_name='Oslo')
get_review_score(product='Ollama')
''');
    expect(result[0]['function'], 'get_weather_data');
    expect(result[1]['function'], 'get_city_coordinates');
    expect(result[2]['function'], 'get_review_score');
    expect(result[0]['arguments'], [
      {
        'coordinates': [59.741, 10.411]
      }
    ]);
    expect(result[1]['arguments'], [
      {'city_name': 'Oslo'}
    ]);
    expect(result[2]['arguments'], [
      {'product': 'Ollama'}
    ]);
  });

  test('Check for function call with multiple arguments', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('''get_weather_data(coordinates=(59.741, 10.411),city_name='Oslo',altitude=100)''');

    expect(result[0]['function'], 'get_weather_data');
    expect(result[0]['arguments'], [
      {
        'coordinates': [59.741, 10.411],
        'city_name': 'Oslo',
        'altitude': 100,
      }
    ]);
  });

  test('Check for simple nested function call', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('''get_weather_data(coordinates=get_city_coordinates(city_name='Oslo'))''');
    expect(result[0]['function'], 'get_weather_data');
    expect(result[0]['arguments'], [
      {
        'coordinates': {
          'function': 'get_city_coordinates',
          'arguments': [
            {'city_name': 'Oslo'}
          ],
        }
      }
    ]);
  });

  test('Ensure that nested function calls with multiple argument works properly', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('''get_weather_data(coordinates=get_city_coordinates(city_name='Oslo'),altitude=100)''');
    expect(result[0]['function'], 'get_weather_data');
    expect(result[0]['arguments'], [
      {
        'coordinates': {
          'function': 'get_city_coordinates',
          'arguments': [
            {'city_name': 'Oslo'}
          ],
        },
        'altitude': 100,
      },
    ]);
  });

  test('Multi layered function calling', () {
    final parser = FunctionParser();
    final result = parser.parseFunctionCalls('''
get_weather_data(coordinates=get_city_coordinates(city_name='Stockholm'),altitude=get_altitude())
get_awesome_llm(coordinates=(17.12, 18.12))''');
    expect(result[0]['function'], 'get_weather_data');
    expect(
      result[0]['arguments'],
      [
        {
          'coordinates': {
            'function': 'get_city_coordinates',
            'arguments': [
              {'city_name': 'Stockholm'}
            ],
          },
          'altitude': {
            'function': 'get_altitude',
            'arguments': [],
          }
        }
      ],
    );
    expect(result[1]['function'], 'get_awesome_llm');
    expect(
      result[1]['arguments'],
      [
        {
          'coordinates': [17.12, 18.12]
        }
      ],
    );
  });
}
