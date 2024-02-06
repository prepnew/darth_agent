import 'package:darth_agent/skills/skill.dart';
import 'package:darth_agent/input/skill_parser.dart';
import 'package:darth_agent/input/python_skill_parser.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:flutter_test/flutter_test.dart';

final _skills = [
  _FakeWeatherAbility(),
  _FakeGetCity(),
  _FakeReview(),
  _FakeAwesome(),
  _FakeAltitude(),
];

void main() {
  test('Checks basic function call', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('get_weather_data(coordinates=(59.741, 10.411))', _skills);
    expect(result[0].skill.name, 'get_weather_data');
    expect(result[0].arguments, {
      'coordinates': [59.741, 10.411]
    });
  });

  test('Handle functions without argument', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('get_weather_data()', _skills);
    expect(result[0].skill.name, 'get_weather_data');
    expect(result[0].arguments, {});
  });

  test('Check for multiline function call', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('''
get_weather_data(coordinates=(59.741, 10.411))
get_city_coordinates(city_name='Oslo')
get_review_score(product='Ollama')
''', _skills);
    expect(result[0].skill.name, 'get_weather_data');
    expect(result[1].skill.name, 'get_city_coordinates');
    expect(result[2].skill.name, 'get_review_score');
    expect(result[0].arguments, {
      'coordinates': [59.741, 10.411]
    });
    expect(result[1].arguments, {'city_name': 'Oslo'});
    expect(result[2].arguments, {'product': 'Ollama'});
  });

  test('Check for function call with multiple arguments', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('''get_weather_data(coordinates=(59.741, 10.411),city_name='Oslo',altitude=100)''', _skills);

    expect(result[0].skill.name, 'get_weather_data');
    expect(result[0].arguments, {
      'coordinates': [59.741, 10.411],
      'city_name': 'Oslo',
      'altitude': 100,
    });
  });

  test('Check for simple nested function call', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('''get_weather_data(coordinates=get_city_coordinates(city_name='Oslo'))''', _skills);
    expect(result[0].skill.name, 'get_weather_data');
    final coordinateArgument = result[0].arguments['coordinates'];
    assert(coordinateArgument is SkillUse);
    assert(coordinateArgument.ability.functionName == 'get_city_coordinates');
    assert(coordinateArgument.arguments['city_name'] == 'Oslo');
  });

  test('Ensure that nested function calls with multiple argument works properly', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('''get_weather_data(coordinates=get_city_coordinates(city_name='Oslo'),altitude=100)''', _skills);
    expect(result[0].skill.name, 'get_weather_data');
    final coordinateArgument = result[0].arguments['coordinates'];
    assert(coordinateArgument is SkillUse);
    assert(coordinateArgument.ability.functionName == 'get_city_coordinates');
    assert(coordinateArgument.arguments['city_name'] == 'Oslo');
    assert(result[0].arguments['altitude'] == 100);
  });

  test('Multi layered function calling', () {
    final parser = PythonSkillParser();
    final result = parser.parseSkills('''
get_weather_data(coordinates=get_city_coordinates(city_name='Stockholm'),altitude=get_altitude())
get_awesome_llm(coordinates=(17.12, 18.12))''', _skills);
    expect(result[0].skill.name, 'get_weather_data');
    final firstCoordinateArgument = result[0].arguments['coordinates'];
    assert(firstCoordinateArgument is SkillUse);
    assert(firstCoordinateArgument.ability.functionName == 'get_city_coordinates');
    assert(firstCoordinateArgument.arguments['city_name'] == 'Stockholm');
    final altitudeArgument = result[0].arguments['altitude'];
    assert(altitudeArgument is SkillUse);
    assert(altitudeArgument.ability.functionName == 'get_altitude');
    assert(altitudeArgument.arguments.isEmpty);
    expect(result[1].skill.name, 'get_awesome_llm');
    expect(result[1].arguments, {
      'coordinates': [17.12, 18.12]
    });
  });
}

class _FakeWeatherAbility extends Skill {
  @override
  Future<String> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) =>
      Future.value('');
  @override
  String get name => 'get_weather_data';
  @override
  String get description => '';
}

class _FakeGetCity extends Skill {
  @override
  Future<String> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) =>
      Future.value('');
  @override
  String get name => 'get_city_coordinates';
  @override
  String get description => '';
}

class _FakeReview extends Skill {
  @override
  Future<String> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) =>
      Future.value('');
  @override
  String get name => 'get_review_score';
  @override
  String get description => '';
}

class _FakeAwesome extends Skill {
  @override
  Future<String> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) =>
      Future.value('');
  @override
  String get name => 'get_awesome_llm';
  @override
  String get description => '';
}

class _FakeAltitude extends Skill {
  @override
  Future<String> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) =>
      Future.value('');
  @override
  String get name => 'get_altitude';
  @override
  String get description => '';
}
