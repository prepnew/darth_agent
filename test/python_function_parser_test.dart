import 'package:darth_agent/ability/ability.dart';
import 'package:darth_agent/input/ability_parser.dart';
import 'package:darth_agent/input/python_ability_parser.dart';
import 'package:flutter_test/flutter_test.dart';

final _abilities = [
  _FakeWeatherAbility(),
  _FakeGetCity(),
  _FakeReview(),
  _FakeAwesome(),
  _FakeAltitude(),
];

void main() {
  test('Checks basic function call', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('get_weather_data(coordinates=(59.741, 10.411))', _abilities);
    expect(result[0].ability.functionName, 'get_weather_data');
    expect(result[0].arguments, {
      'coordinates': [59.741, 10.411]
    });
  });

  test('Handle functions without argument', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('get_weather_data()', _abilities);
    expect(result[0].ability.functionName, 'get_weather_data');
    expect(result[0].arguments, {});
  });

  test('Check for multiline function call', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('''
get_weather_data(coordinates=(59.741, 10.411))
get_city_coordinates(city_name='Oslo')
get_review_score(product='Ollama')
''', _abilities);
    expect(result[0].ability.functionName, 'get_weather_data');
    expect(result[1].ability.functionName, 'get_city_coordinates');
    expect(result[2].ability.functionName, 'get_review_score');
    expect(result[0].arguments, {
      'coordinates': [59.741, 10.411]
    });
    expect(result[1].arguments, {'city_name': 'Oslo'});
    expect(result[2].arguments, {'product': 'Ollama'});
  });

  test('Check for function call with multiple arguments', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('''get_weather_data(coordinates=(59.741, 10.411),city_name='Oslo',altitude=100)''', _abilities);

    expect(result[0].ability.functionName, 'get_weather_data');
    expect(result[0].arguments, {
      'coordinates': [59.741, 10.411],
      'city_name': 'Oslo',
      'altitude': 100,
    });
  });

  test('Check for simple nested function call', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('''get_weather_data(coordinates=get_city_coordinates(city_name='Oslo'))''', _abilities);
    expect(result[0].ability.functionName, 'get_weather_data');
    final coordinateArgument = result[0].arguments['coordinates'];
    assert(coordinateArgument is AbilityCall);
    assert(coordinateArgument.ability.functionName == 'get_city_coordinates');
    assert(coordinateArgument.arguments['city_name'] == 'Oslo');
  });

  test('Ensure that nested function calls with multiple argument works properly', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('''get_weather_data(coordinates=get_city_coordinates(city_name='Oslo'),altitude=100)''', _abilities);
    expect(result[0].ability.functionName, 'get_weather_data');
    final coordinateArgument = result[0].arguments['coordinates'];
    assert(coordinateArgument is AbilityCall);
    assert(coordinateArgument.ability.functionName == 'get_city_coordinates');
    assert(coordinateArgument.arguments['city_name'] == 'Oslo');
    assert(result[0].arguments['altitude'] == 100);
  });

  test('Multi layered function calling', () {
    final parser = PythonAbilityParser();
    final result = parser.parseFunctionCalls('''
get_weather_data(coordinates=get_city_coordinates(city_name='Stockholm'),altitude=get_altitude())
get_awesome_llm(coordinates=(17.12, 18.12))''', _abilities);
    expect(result[0].ability.functionName, 'get_weather_data');
    final firstCoordinateArgument = result[0].arguments['coordinates'];
    assert(firstCoordinateArgument is AbilityCall);
    assert(firstCoordinateArgument.ability.functionName == 'get_city_coordinates');
    assert(firstCoordinateArgument.arguments['city_name'] == 'Stockholm');
    final altitudeArgument = result[0].arguments['altitude'];
    assert(altitudeArgument is AbilityCall);
    assert(altitudeArgument.ability.functionName == 'get_altitude');
    assert(altitudeArgument.arguments.isEmpty);
    expect(result[1].ability.functionName, 'get_awesome_llm');
    expect(result[1].arguments, {
      'coordinates': [17.12, 18.12]
    });
  });
}

class _FakeWeatherAbility extends Ability {
  @override
  Future<String> call(Map<String, dynamic> args, {bool llmOutput = true}) => Future.value('');
  @override
  String get functionName => 'get_weather_data';
  @override
  String get functionsDescription => '';
}

class _FakeGetCity extends Ability {
  @override
  Future<String> call(Map<String, dynamic> args, {bool llmOutput = true}) => Future.value('');
  @override
  String get functionName => 'get_city_coordinates';
  @override
  String get functionsDescription => '';
}

class _FakeReview extends Ability {
  @override
  Future<String> call(Map<String, dynamic> args, {bool llmOutput = true}) => Future.value('');
  @override
  String get functionName => 'get_review_score';
  @override
  String get functionsDescription => '';
}

class _FakeAwesome extends Ability {
  @override
  Future<String> call(Map<String, dynamic> args, {bool llmOutput = true}) => Future.value('');
  @override
  String get functionName => 'get_awesome_llm';
  @override
  String get functionsDescription => '';
}

class _FakeAltitude extends Ability {
  @override
  Future<String> call(Map<String, dynamic> args, {bool llmOutput = true}) => Future.value('');
  @override
  String get functionName => 'get_altitude';
  @override
  String get functionsDescription => '';
}
